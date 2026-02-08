#!/bin/bash

set -e

# > Config
w_dir="$HOME/Pictures/wallpapers"
mon="eDP-1"

# > Palette: Alien Microbes
c_base="#1a181a"
c_surface="#3b3366"
c_highlight="#745380"
c_text="#8f7fb0"

# > Voguish gum theming
export GUM_CHOOSE_HEADER_FOREGROUND="$c_highlight"
export GUM_CHOOSE_CURSOR_FOREGROUND="$c_highlight"
export GUM_CHOOSE_ITEM_FOREGROUND="$c_text"
export GUM_CHOOSE_SELECTED_FOREGROUND="$c_highlight"

export GUM_CONFIRM_PROMPT_FOREGROUND="$c_text"
export GUM_CONFIRM_SELECTED_BACKGROUND="$c_highlight"
export GUM_CONFIRM_SELECTED_FOREGROUND="$c_base"
export GUM_CONFIRM_UNSELECTED_FOREGROUND="$c_text"

export GUM_SPIN_SPINNER="moon"
export GUM_SPIN_TITLE_FOREGROUND="$c_text"
export GUM_SPIN_SPINNER_FOREGROUND="$c_highlight"

# > Main loop
while true; do
  clear

  # :: List of wallpapers w/ gum menu
  sel=$(find "$w_dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -printf "%P\n" | sort | gum choose --height=15 --header "Wallopt << ٩(̾●̮̮̃̾•̃̾)۶ >> Wallpaper Selector")

  if [ -z "$sel" ]; then
    clear
    exit 0
  fi

  # > Confirm dialog
  # :: W/ live img preview
  clear

  # :: Header w/ selected wallpaper's name
  header=$(gum style --padding "1 3" --border double --border-foreground "$c_highlight" "$sel")
  echo -e "$header\n"

  # :: If possible, show the img preview
  if [[ "$TERM" == "xterm-kitty" ]]; then
    kitty +icat --align center "$w_dir/$sel"
  elif [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
    wezterm imgcat "$w_dir/$sel"
  elif [[ -n "$ITERM_SESSION_ID" ]]; then
    imgcat "$w_dir/$sel"
  else
    gum style --foreground="$c_text" --italic " (Image preview not available for your terminal)"
  fi

  echo # New line 4 spacing

  # :: Confirmation
  if gum confirm "$(gum style --foreground="$c_text" "Set this as wallpaper?")"; then
    # > Set wallpaper
    # :: Apply wallpaper using hyprctl
    gum spin --title "Setting wallpaper..." -- \
      sh -c "hyprctl hyprpaper preload \"$w_dir/$sel\" && hyprctl hyprpaper wallpaper \"$mon,$w_dir/$sel\""

    # :: Success notification (optional)
    # notify-send -u low -i "image-photo" "Wallpaper Updated" "Set to <b>${sel}</b>"
    
    break
  fi
  # :: Allow 4 re-selection
done

clear
exit 0
