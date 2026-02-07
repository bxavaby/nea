#!/bin/bash
# grasp.sh - a lashware util (voguish command mem)

set -Eeuo pipefail
IFS=$'\n\t'

# > Config
config_dir="$HOME/.config/grasp"
command_file="$config_dir/commands.json"

# > Palette: Alien Microbes
c_base="#8cff96"
c_sec="#1a181a"
c_text="#8f7fb0"
c_highlight="#745380"
c_error="#ff7eb6"
c_white="#fff3f2"
c_surface="#3b3366"

# > Voguish gum theming
export GUM_INPUT_PROMPT="٩(̾●̮̮̃̾•̃̾)۶ >> "
export GUM_INPUT_PLACEHOLDER_FOREGROUND="$c_text"
export GUM_INPUT_CURSOR_FOREGROUND="$c_base"
export GUM_INPUT_PROMPT_FOREGROUND="$c_base"

export GUM_CHOOSE_HEADER_FOREGROUND="$c_highlight"
export GUM_CHOOSE_CURSOR_FOREGROUND="$c_highlight"
export GUM_CHOOSE_ITEM_FOREGROUND="$c_text"
export GUM_CHOOSE_SELECTED_FOREGROUND="$c_highlight"

export GUM_CONFIRM_PROMPT_FOREGROUND="$c_text"
export GUM_CONFIRM_SELECTED_BACKGROUND="$c_highlight"
export GUM_CONFIRM_SELECTED_FOREGROUND="$c_sec"
export GUM_CONFIRM_UNSELECTED_FOREGROUND="$c_text"

export GUM_SPIN_SPINNER="moon"
export GUM_SPIN_SPINNER_FOREGROUND="$c_base"
export GUM_SPIN_TITLE_FOREGROUND="$c_text"

export GUM_TABLE_HEADER_FOREGROUND="$c_base"

# > Style helpers
title() { gum style --foreground="$c_base" --bold --padding "1 0" "$1"; }
error() { gum style --foreground="$c_error" "✗ $1"; }
success() { gum style --foreground="$c_base" "✓ $1"; }

# > Copy helper
copy_clip() {
  if command -v wl-copy >/dev/null 2>&1; then
    cat | wl-copy
    echo "(clipboard: wl-copy)"
  elif command -v xclip >/dev/null 2>&1; then
    cat | xclip -selection clipboard
    echo "(clipboard: xclip)"
  elif command -v pbcopy >/dev/null 2>&1; then
    cat | pbcopy
    echo "(clipboard: pbcopy)"
  elif command -v clip.exe >/dev/null 2>&1; then
    cat | clip.exe
    echo "(clipboard: clip.exe)"
  else
    return 1
  fi
}

# > Pre-flight check
# :: Dependency needs
clear
for cmd in gum jq fzf; do
  if ! command -v $cmd &> /dev/null; then
    gum style --foreground="$c_highlight" "Error: Command not found: $cmd. Please install it."; exit 1; fi
done
mkdir -p "$config_dir"
[ -s "$command_file" ] || echo "{}" > "$command_file"

# :: Grasp
run_nc() {
  clear
  local header cmd desc tags_raw tags new_entry tmp_file
  header=$(gum style --padding "0 1" --border double --border-foreground="$c_highlight" "Grasp")
  echo -e "$header\n"
  
  cmd=$(gum input --placeholder='git commit -m "feat: ..."' ) || return
  if [[ -z "$cmd" ]]; then error "Command cannot be blank."; sleep 1.2; return; fi
  
  desc=$(gum input --placeholder="Commit changes with a feature message") || return
  
  tags_raw=$(gum input --placeholder="git, commit, feature (up to 4)") || return
  tags=$(echo "$tags_raw" | tr ',' ' ' | awk '{print $1, $2, $3, $4}')
  
  # :: Create JSON obj
  new_entry=$(jq -n --arg cmd "$cmd" --arg desc "$desc" --arg tags "$tags" \
    '{($cmd): {command: $cmd, desc: $desc, tags: $tags}}')
    
  # :: Merge w/ existing file
  tmp_file=$(mktemp)
  jq -s '.[0] * .[1]' "$command_file" <(echo "$new_entry") > "$tmp_file" && mv "$tmp_file" "$command_file"
  
  success "Command grasped!"
  sleep 0.8
}

# :: Browser
run_saved() {
  local count
  count=$(jq '. | length' "$command_file")
  if [[ "$count" -eq 0 ]]; then error "No commands grasped yet."; sleep 0.8; return; fi

  # :: Quick keys
  # :: Enter  <-> Actions menu
  # :: Ctrl-Y <-> Copy to clipboard
  # :: F1     <-> Show more
  mapfile -t fzf_out < <(
    jq -r 'keys[]' "$command_file" | fzf \
      --header=$'[Enter] Actions  │  [Ctrl-Y] Copy  │  [F1] More' \
      --expect=ctrl-y,f1 \
      --no-multi
  )

  [[ ${#fzf_out[@]} -eq 0 ]] && return

  local keypress selected_key
  keypress="${fzf_out[0]}"
  selected_key="${fzf_out[-1]}"

  # :: Info card
  show_more() {
    local d t
    d=$(jq -r --arg k "$selected_key" '.[$k].desc // ""' "$command_file")
    t=$(jq -r --arg k "$selected_key" '.[$k].tags // ""' "$command_file")
    {
      printf "COMMAND:\n%s\n\n" "$selected_key"
      printf "DESCRIPTION:\n%s\n\n" "${d:-<none>}"
      printf "TAGS:\n%s\n" "${t:-<none>}"
    } | gum style --padding "1 2" --border double --border-foreground "$c_highlight"
    read -n 1 -s -r -p "Press any key to go back..."
  }

  # :: Quick actions
  case "$keypress" in
    "ctrl-y")
      # :: Copy stored .command
      local cmd_to_copy
      cmd_to_copy=$(jq -r --arg k "$selected_key" '.[$k].command' "$command_file")
      if echo -n "$cmd_to_copy" | copy_clip; then
        success "Command copied."
      else
        success "No clipboard backend; command printed above."
      fi
      sleep 0.6
      return
      ;;
    "f1")
      show_more
      return
      ;;
  esac

  # :: Enter menu
  local action
  action=$(gum choose "Copy" "Edit" "Delete" "More" "Back" --header "What do you want to do?") || return

  case "$action" in
    "Copy")
      local cmd_to_copy
      cmd_to_copy=$(jq -r --arg k "$selected_key" '.[$k].command' "$command_file")
      if echo -n "$cmd_to_copy" | copy_clip; then
        success "Command copied."
      else
        success "No clipboard backend; command printed above."
      fi
      sleep 0.6
      ;;
    "Edit")
      local new_cmd tmp_file
      new_cmd=$(gum input --value="$selected_key" --placeholder="Edit the command") || return
      if [[ -n "$new_cmd" && "$new_cmd" != "$selected_key" ]]; then
        tmp_file=$(mktemp)
        jq --arg key "$selected_key" --arg newkey "$new_cmd" '
          (.[$key] | .command = $newkey) as $obj
          | . + {($newkey): $obj}
          | del(.[$key])
        ' "$command_file" > "$tmp_file" && mv "$tmp_file" "$command_file"
        success "Command updated."
        sleep 0.6
      fi
      ;;
    "Delete")
      if gum confirm "Delete this command?"; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg key "$selected_key" 'del(.[$key])' "$command_file" > "$tmp_file" && mv "$tmp_file" "$command_file"
        success "Command deleted."
        sleep 0.6
      fi
      ;;
    "More")
      show_more
      ;;
    "Back") : ;;
  esac
}

# > Main loop
while true; do
  clear
  command_count=$(jq '. | length' "$command_file")
  title "GRASP << ٩(̾●̮̮̃̾•̃̾)۶ >> memdev ($command_count commands)"
  
  options=("Grasp")
  (( command_count > 0 )) && options+=("Recall")
  options+=("Quit")

  choice=$(printf "%s\n" "${options[@]}" | gum choose) \
    || { clear; exit 0; }
  
  case "$choice" in
    "Grasp")
      run_nc ;;
    "Recall")
      run_saved ;;
    "Quit")
      clear; exit 0 ;;
  esac
done
