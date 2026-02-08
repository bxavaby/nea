#!/bin/bash

set -e

# > Cleanup
cleanup() {
  [[ -n "$temp_file" ]] && rm -f "$temp_file"
}

trap cleanup EXIT INT TERM

# > Palette: Alien Microbes
c_base="#8cff96"
c_text="#8f7fb0"
c_highlight="#745380"
c_error="#ff7eb6"
c_white="#fff3f2"
c_surface="#3b3366"

# > Voguish gum theming
export GUM_INPUT_PROMPT_FOREGROUND="$c_base"
export GUM_INPUT_CURSOR_FOREGROUND="$c_base"
export GUM_INPUT_PLACEHOLDER_FOREGROUND="$c_text"

export GUM_CONFIRM_PROMPT_FOREGROUND="$c_text"
export GUM_CONFIRM_SELECTED_BACKGROUND="$c_highlight"
export GUM_CONFIRM_SELECTED_FOREGROUND="$c_white"
export GUM_CONFIRM_UNSELECTED_FOREGROUND="$c_text"

export GUM_SPIN_SPINNER="globe"
export GUM_SPIN_SPINNER_FOREGROUND="$c_base"
export GUM_SPIN_TITLE_FOREGROUND="$c_text"

title() { gum style --foreground="$c_base" --bold --padding "1 0" "$1"; }
error() { gum style --foreground="$c_error" "✗ $1"; }
info() { gum style --foreground="$c_text" "$1"; }

# > Pre-flight check
# :: Dependency needs
clear
for cmd in gum curl jq; do
  if ! command -v $cmd &> /dev/null; then
    error "Command not found: $cmd. Please install it."
    exit 1
  fi
done

title "OBSERA << ٩(̾●̮̮̃̾•̃̾)۶ >> real sightly"

# > Is IP private/local
is_private() {
  local ip="$1"
  case "$ip" in
    10.*|172.1[6-9].*|172.2[0-9].*|172.3[0-1].*|192.168.*|127.*|169.254.*|::1|fc00:*|fd00:*|fe80:*)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

# > Validate IP format
validate() {
  local ip="$1"
  if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    IFS='.' read -ra ADDR <<< "$ip"
    for i in "${ADDR[@]}"; do
      if [[ $i -gt 255 ]]; then
        return 1
      fi
    done
    return 0
  fi
  return 1
}

# > Public IP
get_public() {
  local ip
  for service in "https://api.ipify.org" "https://ipinfo.io/ip" "https://icanhazip.com"; do
    ip=$(curl -s --max-time 5 "$service" 2>/dev/null | tr -d '\n\r' || echo "")
    if validate "$ip"; then
      echo "$ip"
      return 0
    fi
  done
  return 1
}

# :: IP/domain input
target=$(gum input --placeholder "Enter IP, domain, or 'public' for your IP..." --prompt " Target: ") \
  || { clear; exit 0; }

[[ -z "$target" ]] && { error "No target provided"; sleep 2; clear; exit 0; }

# :: Handle public ones
if [[ "$target" == "public" ]]; then
  info "Fetching your public IP..."
  if ! target=$(get_public); then
    error "Failed to fetch public IP"
    sleep 2; clear; exit 0
  fi
  info "Found public IP: $target"
fi

# :: Resolve domain2IP
if ! validate "$target"; then
  info "Resolving domain: $target"
  resolved_ip=$(dig +short "$target" A 2>/dev/null | head -n1 | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || echo "")

  if [[ -z "$resolved_ip" ]]; then
    resolved_ip=$(nslookup "$target" 2>/dev/null | awk '/^Address: / { print $2 }' | head -n1 || echo "")
  fi

  if [[ -z "$resolved_ip" ]] || ! validate "$resolved_ip"; then
    error "Failed to resolve domain: $target"
    sleep 2; clear; exit 0
  fi

  original_target="$target"
  target="$resolved_ip"
  info "Resolved to: $target"
fi

# :: Private IPs
if is_private "$target"; then
  info "  Private IP detected: $target"
  echo
  if gum confirm "Check your public IP instead?"; then
    info "Fetching your public IP..."
    if ! target=$(get_public); then
      error "Failed to fetch public IP"
      sleep 2; clear; exit 0
    fi
    info "Using public IP: $target"
  else
    error "Cannot geolocate private IP addresses"
    sleep 2; clear; exit 0
  fi
fi

# :: Fetch loc data
temp_file=$(mktemp)
if ! gum spin --title "Observing target: $target..." -- \
  curl -s --max-time 10 "http://ip-api.com/json/$target?fields=status,message,country,countryCode,region,city,lat,lon,timezone,isp,org,as,query" \
  -o "$temp_file"; then
  error "Network request failed"
  exit 1
fi

# :: Parse response
if ! jq -e . "$temp_file" &>/dev/null; then
  error "Invalid response from API"
  exit 1
fi

status=$(jq -r '.status' "$temp_file")
if [[ "$status" != "success" ]]; then
  message=$(jq -r '.message // "Unknown error"' "$temp_file")
  error "API error: $message"
  exit 1
fi

# > Extract data
country=$(jq -r '.country // "Unknown"' "$temp_file")
country_code=$(jq -r '.countryCode // "XX"' "$temp_file")
region=$(jq -r '.region // "Unknown"' "$temp_file")
city=$(jq -r '.city // "Unknown"' "$temp_file")
lat=$(jq -r '.lat // "0"' "$temp_file")
lon=$(jq -r '.lon // "0"' "$temp_file")
timezone=$(jq -r '.timezone // "Unknown"' "$temp_file")
isp=$(jq -r '.isp // "Unknown"' "$temp_file")
org=$(jq -r '.org // "Unknown"' "$temp_file")
asn=$(jq -r '.as // "Unknown"' "$temp_file")
ip=$(jq -r '.query // "Unknown"' "$temp_file")

# :: Code2flag
ctf() {
  case "$1" in
    AD) echo "🇦🇩" ;; AE) echo "🇦🇪" ;; AF) echo "🇦🇫" ;; AG) echo "🇦🇬" ;; AI) echo "🇦🇮" ;;
    AL) echo "🇦🇱" ;; AM) echo "🇦🇲" ;; AO) echo "🇦🇴" ;; AQ) echo "🇦🇶" ;; AR) echo "🇦🇷" ;;
    AS) echo "🇦🇸" ;; AT) echo "🇦🇹" ;; AU) echo "🇦🇺" ;; AW) echo "🇦🇼" ;; AX) echo "🇦🇽" ;;
    AZ) echo "🇦🇿" ;; BA) echo "🇧🇦" ;; BB) echo "🇧🇧" ;; BD) echo "🇧🇩" ;; BE) echo "🇧🇪" ;;
    BF) echo "🇧🇫" ;; BG) echo "🇧🇬" ;; BH) echo "🇧🇭" ;; BI) echo "🇧🇮" ;; BJ) echo "🇧🇯" ;;
    BL) echo "🇧🇱" ;; BM) echo "🇧🇲" ;; BN) echo "🇧🇳" ;; BO) echo "🇧🇴" ;; BQ) echo "🇧🇶" ;;
    BR) echo "🇧🇷" ;; BS) echo "🇧🇸" ;; BT) echo "🇧🇹" ;; BV) echo "🇧🇻" ;; BW) echo "🇧🇼" ;;
    BY) echo "🇧🇾" ;; BZ) echo "🇧🇿" ;; CA) echo "🇨🇦" ;; CC) echo "🇨🇨" ;; CD) echo "🇨🇩" ;;
    CF) echo "🇨🇫" ;; CG) echo "🇨🇬" ;; CH) echo "🇨🇭" ;; CI) echo "🇨🇮" ;; CK) echo "🇨🇰" ;;
    CL) echo "🇨🇱" ;; CM) echo "🇨🇲" ;; CN) echo "🇨🇳" ;; CO) echo "🇨🇴" ;; CR) echo "🇨🇷" ;;
    CU) echo "🇨🇺" ;; CV) echo "🇨🇻" ;; CW) echo "🇨🇼" ;; CX) echo "🇨🇽" ;; CY) echo "🇨🇾" ;;
    CZ) echo "🇨🇿" ;; DE) echo "🇩🇪" ;; DJ) echo "🇩🇯" ;; DK) echo "🇩🇰" ;; DM) echo "🇩🇲" ;;
    DO) echo "🇩🇴" ;; DZ) echo "🇩🇿" ;; EC) echo "🇪🇨" ;; EE) echo "🇪🇪" ;; EG) echo "🇪🇬" ;;
    EH) echo "🇪🇭" ;; ER) echo "🇪🇷" ;; ES) echo "🇪🇸" ;; ET) echo "🇪🇹" ;; FI) echo "🇫🇮" ;;
    FJ) echo "🇫🇯" ;; FK) echo "🇫🇰" ;; FM) echo "🇫🇲" ;; FO) echo "🇫🇴" ;; FR) echo "🇫🇷" ;;
    GA) echo "🇬🇦" ;; GB) echo "🇬🇧" ;; GD) echo "🇬🇩" ;; GE) echo "🇬🇪" ;; GF) echo "🇬🇫" ;;
    GG) echo "🇬🇬" ;; GH) echo "🇬🇭" ;; GI) echo "🇬🇮" ;; GL) echo "🇬🇱" ;; GM) echo "🇬🇲" ;;
    GN) echo "🇬🇳" ;; GP) echo "🇬🇵" ;; GQ) echo "🇬🇶" ;; GR) echo "🇬🇷" ;; GS) echo "🇬🇸" ;;
    GT) echo "🇬🇹" ;; GU) echo "🇬🇺" ;; GW) echo "🇬🇼" ;; GY) echo "🇬🇾" ;; HK) echo "🇭🇰" ;;
    HM) echo "🇭🇲" ;; HN) echo "🇭🇳" ;; HR) echo "🇭🇷" ;; HT) echo "🇭🇹" ;; HU) echo "🇭🇺" ;;
    ID) echo "🇮🇩" ;; IE) echo "🇮🇪" ;; IL) echo "🇮🇱" ;; IM) echo "🇮🇲" ;; IN) echo "🇮🇳" ;;
    IO) echo "🇮🇴" ;; IQ) echo "🇮🇶" ;; IR) echo "🇮🇷" ;; IS) echo "🇮🇸" ;; IT) echo "🇮🇹" ;;
    JE) echo "🇯🇪" ;; JM) echo "🇯🇲" ;; JO) echo "🇯🇴" ;; JP) echo "🇯🇵" ;; KE) echo "🇰🇪" ;;
    KG) echo "🇰🇬" ;; KH) echo "🇰🇭" ;; KI) echo "🇰🇮" ;; KM) echo "🇰🇲" ;; KN) echo "🇰🇳" ;;
    KP) echo "🇰🇵" ;; KR) echo "🇰🇷" ;; KW) echo "🇰🇼" ;; KY) echo "🇰🇾" ;; KZ) echo "🇰🇿" ;;
    LA) echo "🇱🇦" ;; LB) echo "🇱🇧" ;; LC) echo "🇱🇨" ;; LI) echo "🇱🇮" ;; LK) echo "🇱🇰" ;;
    LR) echo "🇱🇷" ;; LS) echo "🇱🇸" ;; LT) echo "🇱🇹" ;; LU) echo "🇱🇺" ;; LV) echo "🇱🇻" ;;
    LY) echo "🇱🇾" ;; MA) echo "🇲🇦" ;; MC) echo "🇲🇨" ;; MD) echo "🇲🇩" ;; ME) echo "🇲🇪" ;;
    MF) echo "🇲🇫" ;; MG) echo "🇲🇬" ;; MH) echo "🇲🇭" ;; MK) echo "🇲🇰" ;; ML) echo "🇲🇱" ;;
    MM) echo "🇲🇲" ;; MN) echo "🇲🇳" ;; MO) echo "🇲🇴" ;; MP) echo "🇲🇵" ;; MQ) echo "🇲🇶" ;;
    MR) echo "🇲🇷" ;; MS) echo "🇲🇸" ;; MT) echo "🇲🇹" ;; MU) echo "🇲🇺" ;; MV) echo "🇲🇻" ;;
    MW) echo "🇲🇼" ;; MX) echo "🇲🇽" ;; MY) echo "🇲🇾" ;; MZ) echo "🇲🇿" ;; NA) echo "🇳🇦" ;;
    NC) echo "🇳🇨" ;; NE) echo "🇳🇪" ;; NF) echo "🇳🇫" ;; NG) echo "🇳🇬" ;; NI) echo "🇳🇮" ;;
    NL) echo "🇳🇱" ;; NO) echo "🇳🇴" ;; NP) echo "🇳🇵" ;; NR) echo "🇳🇷" ;; NU) echo "🇳🇺" ;;
    NZ) echo "🇳🇿" ;; OM) echo "🇴🇲" ;; PA) echo "🇵🇦" ;; PE) echo "🇵🇪" ;; PF) echo "🇵🇫" ;;
    PG) echo "🇵🇬" ;; PH) echo "🇵🇭" ;; PK) echo "🇵🇰" ;; PL) echo "🇵🇱" ;; PM) echo "🇵🇲" ;;
    PN) echo "🇵🇳" ;; PR) echo "🇵🇷" ;; PS) echo "🇵🇸" ;; PT) echo "🇵🇹" ;; PW) echo "🇵🇼" ;;
    PY) echo "🇵🇾" ;; QA) echo "🇶🇦" ;; RE) echo "🇷🇪" ;; RO) echo "🇷🇴" ;; RS) echo "🇷🇸" ;;
    RU) echo "🇷🇺" ;; RW) echo "🇷🇼" ;; SA) echo "🇸🇦" ;; SB) echo "🇸🇧" ;; SC) echo "🇸🇨" ;;
    SD) echo "🇸🇩" ;; SE) echo "🇸🇪" ;; SG) echo "🇸🇬" ;; SH) echo "🇸🇭" ;; SI) echo "🇸🇮" ;;
    SJ) echo "🇸🇯" ;; SK) echo "🇸🇰" ;; SL) echo "🇸🇱" ;; SM) echo "🇸🇲" ;; SN) echo "🇸🇳" ;;
    SO) echo "🇸🇴" ;; SR) echo "🇸🇷" ;; SS) echo "🇸🇸" ;; ST) echo "🇸🇹" ;; SV) echo "🇸🇻" ;;
    SX) echo "🇸🇽" ;; SY) echo "🇸🇾" ;; SZ) echo "🇸🇿" ;; TC) echo "🇹🇨" ;; TD) echo "🇹🇩" ;;
    TF) echo "🇹🇫" ;; TG) echo "🇹🇬" ;; TH) echo "🇹🇭" ;; TJ) echo "🇹🇯" ;; TK) echo "🇹🇰" ;;
    TL) echo "🇹🇱" ;; TM) echo "🇹🇲" ;; TN) echo "🇹🇳" ;; TO) echo "🇹🇴" ;; TR) echo "🇹🇷" ;;
    TT) echo "🇹🇹" ;; TV) echo "🇹🇻" ;; TW) echo "🇹🇼" ;; TZ) echo "🇹🇿" ;; UA) echo "🇺🇦" ;;
    UG) echo "🇺🇬" ;; UM) echo "🇺🇲" ;; US) echo "🇺🇸" ;; UY) echo "🇺🇾" ;; UZ) echo "🇺🇿" ;;
    VA) echo "🇻🇦" ;; VC) echo "🇻🇨" ;; VE) echo "🇻🇪" ;; VG) echo "🇻🇬" ;; VI) echo "🇻🇮" ;;
    VN) echo "🇻🇳" ;; VU) echo "🇻🇺" ;; WF) echo "🇼🇫" ;; WS) echo "🇼🇸" ;; YE) echo "🇾🇪" ;;
    YT) echo "🇾🇹" ;; ZA) echo "🇿🇦" ;; ZM) echo "🇿🇲" ;; ZW) echo "🇿🇼" ;;
    *) echo "🌍" ;;
  esac
}

flag=$(ctf "$country_code")

# :: Loc string
location="$city"
[[ "$city" != "Unknown" && "$region" != "Unknown" && "$city" != "$region" ]] && location="$city, $region"
[[ "$city" == "Unknown" && "$region" != "Unknown" ]] && location="$region"
[[ "$location" == "Unknown" && "$country" != "Unknown" ]] && location="$country"

# > Results
clear
title "٩(̾●̮̮̃̾•̃̾)۶ OBSERVATION COMPLETE"

# :: Build-O
output="Location: $location, $country $flag
ISP: $isp
Organization: $org
IP: $ip
Timezone: $timezone
ASN: $asn
Coordinates: $lat, $lon"

# :: OG domain
[[ -n "$original_target" ]] && output="Domain: $original_target\n$output"

gum style \
  --border double \
  --border-foreground="$c_highlight" \
  --padding "1 2" \
  --margin "1 0" \
  --foreground="$c_white" \
  "$output"

# :: Copy IP
clipboard_success=false

if command -v wl-copy &>/dev/null; then
  echo "$ip" | wl-copy 2>/dev/null && clipboard_success=true
elif command -v xclip &>/dev/null; then
  echo "$ip" | xclip -selection clipboard 2>/dev/null && clipboard_success=true
elif command -v pbcopy &>/dev/null; then
  echo "$ip" | pbcopy 2>/dev/null && clipboard_success=true
elif command -v xsel &>/dev/null; then
  echo "$ip" | xsel --clipboard --input 2>/dev/null && clipboard_success=true
fi

if $clipboard_success; then
  info "IP copied to clipboard: $ip"
else
  info "Clipboard not available - IP is: $ip"
fi

echo
