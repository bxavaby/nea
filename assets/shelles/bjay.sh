#!/bin/bash
# bjay.sh - a lashware util

set -e

# > Palette: Alien Microbes
c_base="#1a181a"
c_highlight="#745380"
c_text="#8f7fb0"

# > Voguish gum theming
export GUM_INPUT_PROMPT="٩(̾●̮̮̃̾•̃̾)۶ >> "
export GUM_INPUT_PLACEHOLDER_FOREGROUND="$c_text"
export GUM_INPUT_CURSOR_FOREGROUND="$c_highlight"
export GUM_INPUT_PROMPT_FOREGROUND="$c_highlight"
export GUM_CHOOSE_HEADER_FOREGROUND="$c_highlight"
export GUM_CHOOSE_CURSOR_FOREGROUND="$c_highlight"
export GUM_CHOOSE_ITEM_FOREGROUND="$c_text"
export GUM_CHOOSE_SELECTED_FOREGROUND="$c_highlight"
export GUM_CHOOSE_SELECTED_PREFIX="󰎤 "
export GUM_CHOOSE_UNSELECTED_PREFIX="󰎡 "

# > Pre-flight check
# :: Dependency needs
for cmd in gum wl-copy; do
  if ! command -v $cmd &> /dev/null; then
    echo "Error: Command not found: $cmd. Please install it."; exit 1; fi
done

# > Char set & length pwgen
generate_password() {
    local charset="$1"
    local length=$2
    password=$(head -c 256 /dev/urandom | tr -dc "$charset" | head -c "$length")
    echo "$password"
}

# > Header
display_header() {
    clear
    gum style --foreground="$c_highlight" --bold "bjay << ٩(̾●̮̮̃̾•̃̾)۶ >> pwd gen"
    gum style --foreground="$c_text" "✦ ¸ . ﹢°¸° ˖☆  .﹢ °¸﹢﹢"
    echo
}

display_header

# :: Mode selection
mode=$(gum choose "Password" "PIN") \
  || { clear; exit 0; }

# :: Vars
final_charset=""
length=0

case "$mode" in
    "Password")
        display_header
        charsets=$(gum choose --no-limit \
            "Lowercase (abc)" "Uppercase (ABC)" "Numbers (012)" "Symbols (!@#$)") \
            || { display_header; exit 0; }
        [[ -z "$charsets" ]] && { display_header; exit 0; }
        
        [[ "$charsets" == *"Lowercase"* ]] && final_charset+="a-z"
        [[ "$charsets" == *"Uppercase"* ]] && final_charset+="A-Z"
        [[ "$charsets" == *"Numbers"* ]] && final_charset+="0-9"
        [[ "$charsets" == *"Symbols"* ]] && final_charset+='!@#$%^&*()_+'
        
        display_header
        # :: Length
        length_profile=$(gum choose "Secure (24)" "Strong (16)" "Standard (12)" "Custom (n)") \
            || { display_header; exit 0; }

        case "$length_profile" in
            "Secure (24)") length=24 ;;
            "Strong (16)") length=16 ;;
            "Standard (12)") length=12 ;;
            "Custom (n)")
                length=$(gum input --placeholder="Enter length") || { display_header; exit 0; }
                if ! [[ "$length" =~ ^[0-9]+$ ]] || [ "$length" -lt 1 ]; then
                    gum style --foreground="$c_highlight" --italic "Invalid length. Aborting."; sleep 2; clear; exit 1
                fi ;;
        esac
        ;;

    "PIN")
        display_header
        final_charset="0-9"
        length_profile=$(gum choose "6-Digit" "4-Digit" "Custom (n)") \
            || { display_header; exit 0; }

        case "$length_profile" in
            "6-Digit") length=6 ;;
            "4-Digit") length=4 ;;
            "Custom (n)")
                length=$(gum input --placeholder="Enter length") || { display_header; exit 0; }
                if ! [[ "$length" =~ ^[0-9]+$ ]] || [ "$length" -lt 1 ]; then
                    gum style --foreground="$c_highlight" --italic "Invalid length. Aborting."; sleep 2; clear; exit 1
                fi ;;
        esac
        ;;
esac

password=$(generate_password "$final_charset" "$length")

clear
echo "$password" | wl-copy
copy_success=$(gum style --foreground="$c_highlight" "Password/PIN copied to clipboard!")
password_box=$(gum style --padding "1 3" --border double --border-foreground="$c_highlight" "$password")

echo "$copy_success"
echo "$password_box"
echo

for i in {5..1}; do
    echo -ne "\r$(gum style --foreground="$c_text" --italic "Clearing in $i seconds...")"
    sleep 1
done

clear
gum style --foreground="$c_highlight" "'Till a day, bluejay..."
gum style --foreground="$c_text" "°.˖ ･ ·̩ ｡ ☆ ¸* . ﹢ ˖¸.﹢"
sleep 1
clear
