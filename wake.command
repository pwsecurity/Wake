#!/bin/bash
# Double-clickable command file that toggles lid-close sleep with a simple UI.

SUDO=""
(( $EUID > 0 )) && SUDO="sudo -n" # prefix pmset with sudo when not root

RESET="\e[0m"
DIM="\e[2m"
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
YELLOW="\e[33m"
WHITE="\e[97m"
NEON="\e[92m"
GRAY_BG="\e[48;5;236m"
DARK_BG="\e[48;5;234m"
PANEL_BG="\e[48;5;233m"
PANEL_BORDER="\e[38;5;83m"

HIDDEN_CURSOR=0
if command -v tput >/dev/null 2>&1; then
    tput civis && HIDDEN_CURSOR=1
fi

if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    /usr/bin/osascript >/dev/null 2>&1 <<'EOF' &
delay 0.1
tell application "Terminal"
    if (count of windows) > 0 then set miniaturized of front window to true
end tell
EOF
fi

function draw_banner {
    clear
    printf "${DARK_BG}${NEON}${BOLD}   ╔══════════════════════════════════════════════════════════════════════╗   ${RESET}\n"
    printf "${DARK_BG}${NEON}${BOLD}   ║${RESET}${BOLD}${NEON}        Wake your Mac by Professor Rehan : SYSCORE        ${NEON}${BOLD}║   ${RESET}\n"
    printf "${DARK_BG}${NEON}${BOLD}   ╚══════════════════════════════════════════════════════════════════════╝   ${RESET}\n"
    printf "${DARK_BG}${DIM}   00110011 01010010 01000101 01001000 01000001 01001110 00110011 01000001   ${RESET}\n"
    printf "${DARK_BG}${DIM}   01010111 01000001 01001011 01000101 00101101 01011001 01001111 01010101   ${RESET}\n"
    printf "${DARK_BG}${DIM}   01010010 01001101 01000001 01000011 00101101 01000111 01010101 01000001   ${RESET}\n"
}

function draw_status {
    status_label=$1
    color=$2
    text=$3

    printf "${GRAY_BG}${BOLD}${color}   ● ${status_label}:${RESET} ${text}\n"
}

function draw_panels {
    printf "${PANEL_BG}${PANEL_BORDER}${BOLD}   ┏━━━━━━━━━━ Diagnostics ━━━━━━━━━━┓${RESET}\n"
    printf "${PANEL_BG}${WHITE}   ┃ Thermal load      : ${YELLOW}Nominal${RESET}\n"
    printf "${PANEL_BG}${WHITE}   ┃ Battery override  : ${GREEN}Engaged${RESET}\n"
    printf "${PANEL_BG}${WHITE}   ┃ Lid sensor link   : ${CYAN}Encrypted${RESET}\n"
    printf "${PANEL_BG}${WHITE}   ┃ Uptime checksum   : ${MAGENTA}0x5FA1AFE${RESET}\n"
    printf "${PANEL_BG}${PANEL_BORDER}${BOLD}   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"
    printf "${PANEL_BG}${PANEL_BORDER}${BOLD}   ┏━━━━━━━━━━ Command Feed ━━━━━━━━━┓${RESET}\n"
    printf "${PANEL_BG}${DIM}   ┃ > securing power matrix${RESET}\n"
    printf "${PANEL_BG}${DIM}   ┃ > aligning wake beacons${RESET}\n"
    printf "${PANEL_BG}${DIM}   ┃ > syncing neural reports${RESET}\n"
    printf "${PANEL_BG}${PANEL_BORDER}${BOLD}   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"
}

function animate_boot {
    local steps=("Injecting kernel hooks" "Stabilizing sleep bypass" "Hardening lid sensor" "Deploying wake daemon")
    local frames=("⣾" "⣷" "⣯" "⣟" "⡿" "⢿" "⣻" "⣽")
    for step in "${steps[@]}"; do
        for frame in "${frames[@]}"; do
            printf "\r${PANEL_BG}${CYAN}${BOLD}   ${frame} ${step}...${RESET}"
            sleep 0.08
        done
        printf "\r${PANEL_BG}${GREEN}${BOLD}   ✔ ${step}...done${RESET}\n"
    done
    printf "\n"
}

spinner_pid=""
function start_wait_spinner {
    local message=$1
    local frames=("▰▱▱▱" "▰▰▱▱" "▰▰▰▱" "▰▰▰▰")
    (
        i=0
        while true; do
            frame=${frames[$((i%4))]}
            printf "\r${DARK_BG}${CYAN}${BOLD}   ${frame} ${message}${RESET}"
            i=$((i+1))
            sleep 0.1
        done
    ) &
    spinner_pid=$!
}

function stop_wait_spinner {
    if [[ -n "$spinner_pid" ]]; then
        kill "$spinner_pid" 2>/dev/null
        wait "$spinner_pid" 2>/dev/null
        spinner_pid=""
        printf "\r${DARK_BG}                                                          ${RESET}\r"
    fi
}

function finish {
    ret=$?
    $SUDO pmset disablesleep 0 # re-enable normal sleep before exiting
    draw_banner
    draw_panels
    draw_status "Status" "${GREEN}" "Sleep enabled"
    printf "${DARK_BG}${CYAN}${BOLD}   READY // Press any key to close this window...${RESET}\n"
    read -rsn1
    if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
        /usr/bin/osascript >/dev/null 2>&1 <<'EOF' &
delay 0.25
tell application "Terminal"
    if (count of windows) > 0 then close front window
end tell
EOF
    fi
    if [[ $HIDDEN_CURSOR -eq 1 ]]; then
        tput cnorm
    fi
    exit $ret
}

$SUDO pmset disablesleep 1 || exit 1 # disable sleep; bail out if it fails

trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 131' QUIT
trap 'exit 143' TERM
trap finish EXIT

draw_banner
draw_panels
animate_boot
draw_status "Status" "${RED}" "Sleep disabled"
draw_status "Action" "${BLUE}" "Close the lid or press any key to re-enable"
start_wait_spinner "Awaiting secure keypress"
read -rsn1
stop_wait_spinner