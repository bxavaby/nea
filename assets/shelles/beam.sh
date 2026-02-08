#!/bin/bash

# set -e not needed

# > Palette: Alien Microbes
c_base="#8cff96"
c_text="#8f7fb0"
c_highlight="#745380"
c_error="#ff7eb6"
c_white="#fff3f2"
c_surface="#3b3366"

# > Voguish gum theming
export GUM_SPIN_SPINNER="moon"
export GUM_SPIN_SPINNER_FOREGROUND="$c_base"
export GUM_SPIN_TITLE_FOREGROUND="$c_text"

# > Helpers
title() { gum style --foreground="$c_base" --bold --padding "1 0" "$1"; }
error() { gum style --foreground="$c_error" "✗ $1"; }

# > Pre-flight check
# :: Dependency needs
clear
for cmd in fzf jq ss curl gum qrencode python3 ngrok; do
  command -v "$cmd" &> /dev/null || { error "$cmd not found. Please install it."; exit 1; }
done
# :: Authtoken check
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
env_file="$script_dir/.env"
if [ -f "$env_file" ]; then source "$env_file"; else
  error ".env file not found."; exit 1; fi
if [ -z "$NGROK_AUTHTOKEN" ]; then
  error "'NGROK_AUTHTOKEN' not set in .env file."; exit 1; fi

title "BEAM << ٩(̾●̮̮̃̾•̃̾)۶ >> voguish & ephemeral file transfer"

# :: Search 4 files
search_fl=$(find ~ -type f 2>/dev/null | fzf \
  --height=40% --layout=reverse --border=double --multi \
  --border-label=' SELECT FILES [TAB, ENTER] ' \
  --prompt='›› ' --pointer='->' \
  --color="bg+:$c_surface,header:$c_base,fg:$c_text,fg+:$c_white,hl:$c_highlight,hl+:$c_base,border:$c_highlight") \
  || { clear; exit 0; }

[[ -z "$search_fl" ]] && { clear; exit 0; }

# :: Ephemeral stage
stage_dir=$(mktemp -d)
PIPE=$(mktemp -u); mkfifo "$PIPE"
cleanup() {
  clear
  
  trap - INT TERM EXIT

  gum spin --title "Cleaning..." -- bash -c '
    # :: TERM 1st
    for pid in "$@"; do [ -n "$pid" ] && kill -TERM "$pid" 2>/dev/null; done

    # :: Hold on a sec
    for pid in "$@"; do
      [ -n "$pid" ] || continue
      for _ in 1 2 3 4; do kill -0 "$pid" 2>/dev/null || break; sleep 2; done
      kill -KILL "$pid" 2>/dev/null || true
    done
  ' _ "${server_pid:-}" "${ngrok_pid:-}"

  rm -rf -- "$stage_dir" "$PIPE"
  clear
}

on_int() {
  cleanup
  exit 0
}

trap on_int INT TERM
trap cleanup EXIT

# :: Create symlinks & uniquify basenames inside the stage
while IFS= read -r file; do
  base=$(basename -- "$file")
  i=0; dest="$stage_dir/$base"
  while [ -e "$dest" ]; do i=$((i+1)); dest="$stage_dir/${base%.*}-$i.${base##*.}"; done
  ln -s -- "$file" "$dest"
done <<< "$search_fl"

# > Broadcast
clear
port=$(shuf -i 10000-65535 -n 1)

# :: Start local server
(
  cd "$stage_dir" || exit 1
  exec python3 -m http.server -b 0.0.0.0 "$port" &> /dev/null
) & server_pid=$!

# :: Probe it
gum spin --title "Serving..." -- \
  sh -c 'for i in {1..50}; do ss -H -ltn "sport = :$1" | grep -q . && exit 0; sleep 0.1; done; exit 1' _ "$port"

# :: Start ngrok tunnel
( exec ngrok http "$port" --log=stdout > /dev/null ) & ngrok_pid=$!

gum spin --title "Tunnelling..." -- sleep 2
ngrok_url=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')

if [[ -z "$ngrok_url" || "$ngrok_url" == "null" ]]; then
  error "Failed to create ngrok tunnel. Check your authtoken."
  exit 1
fi

# > Lean TUI
fl_display=$(echo "$search_fl" | sed "s|^$HOME|~|" | head -n 5 | awk '{print "› " $0}')
if [ "$(echo "$search_fl" | wc -l)" -gt 5 ]; then
  fl_display+=$'\n  ...'
fi

gum spin --title "Encoding..." -- sleep 1
qr_code=$(qrencode -t UTF8 "$ngrok_url")

o_block=$(
  gum style --bold --foreground="$c_base" "SHARING ON:"
  gum style --foreground="$c_text" "$ngrok_url"
  echo
  echo
  gum style --bold --foreground="$c_base" "FILES:"
  gum style --foreground="$c_text" "$fl_display"
  echo
  echo
  gum style --bold --foreground="$c_base" "SCAN DEVICE:"
  echo "$qr_code"
)
echo "$o_block" | gum style --padding "1 2" --border double --border-foreground="$c_highlight"

gum style --padding "1 0" --foreground="$c_text" --italic "[Ctrl+C] will stop the server & self-destruct."

# :: Keep alive until server is stopped
read <"$PIPE"
