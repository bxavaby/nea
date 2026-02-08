#!/bin/bash

set -e

# > Palette: Alien Microbes
c_base="#8cff96"
c_text="#8f7fb0"
c_highlight="#745380"
c_error="#ff7eb6"
c_white="#fff3f2"
c_surface="#3b3366"

# > Voguish gum theming
export GUM_CHOOSE_HEADER="Select PNGs to optimize"
export GUM_CHOOSE_CURSOR=">> "
export GUM_CHOOSE_CURSOR_FOREGROUND="$c_base"
export GUM_CHOOSE_HEADER_FOREGROUND="$c_base"
export GUM_CHOOSE_ITEM_FOREGROUND="$c_text"
export GUM_CHOOSE_SELECTED_FOREGROUND="$c_surface"
export GUM_CHOOSE_SELECTED_PREFIX="󰎤 "
export GUM_CHOOSE_UNSELECTED_PREFIX="󰎡 "

export GUM_SPIN_SPINNER="moon"
export GUM_SPIN_SPINNER_FOREGROUND="$c_base"
export GUM_SPIN_TITLE_FOREGROUND="$c_text"

title() { gum style --foreground="$c_base" --bold --padding "1 0" "$1"; }
error() { gum style --foreground="$c_error" "✗ $1"; }

# > Pre-flight check
# :: Dependency needs
clear
for cmd in fzf gum oxipng; do
  if ! command -v $cmd &> /dev/null; then
    gum style --foreground="$c_highlight" "Error: Command not found: $cmd. Please install it."
    exit 1
  fi
done

title "GOXI << ٩(̾●̮̮̃̾•̃̾)۶ >> glamorous oxipng wrapper"

# :: Select the dir
search_dir=$(find ~ -type d 2>/dev/null | fzf \
  --height=40% --layout=reverse --border=double \
  --border-label=' SELECT DIRECTORY ' \
  --prompt='›› ' --pointer='->' \
  --color="bg+:$c_surface,header:$c_base,fg:$c_text,fg+:$c_white,hl:$c_highlight,hl+:$c_base,border:$c_highlight") \
  || { clear; exit 0; }

# :: Find PNGs in the provided dir
file_list=$(find "$search_dir" -maxdepth 1 -type f -name "*.png" 2>/dev/null || true)

# :: File check
if [[ -z "$file_list" ]]; then
  error "No PNGs found in '$search_dir'."
  sleep 2; clear; exit 0
fi

# :: Multi-selector 4 existing PNGs
selected_files=$(echo "$file_list" | gum choose --no-limit --height=20) \
  || { clear; exit 0; }

[[ -z "$selected_files" ]] && { clear; exit 0; }

# :: Process them
clear
report_file=$(mktemp)
file_count=$(echo "$selected_files" | wc -l)

gum spin --title "Optimizing $file_count file(s)..." -- \
  sh -c "echo \"$selected_files\" | while IFS= read -r file; do
           output=\$(oxipng -o 4 --strip safe \"\$file\" 2>&1)
           echo \"\$output\" | gum style --border double --border-foreground=\"$c_highlight\" --padding \"0 1\" --margin \"1 0\" >> \"$report_file\"
         done"

gum spin --title "Finalizing report..." -- sleep 2

# :: Collated report
clear
title "٩(̾●̮̮̃̾•̃̾)۶ >> Optimizations"
cat "$report_file"
rm "$report_file"

# :: Final message & graceful exit
echo
gum style --foreground="$c_text" "All tasks complete:)"
# sleep 2
