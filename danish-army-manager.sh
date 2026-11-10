#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#          DANISH ARMY TMP MANAGER
# ==========================================

GREEN='\033[1;32m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
RESET='\033[0m'

TMP_DIR="/data/local/tmp"
DEST="/data/local/tmp/danish.sh"
TEMP="$HOME/danish-download.tmp"

URL="https://raw.githubusercontent.com/Amir03218321/DANISH-ARMY-PANEL/e1685e0fb1befb6923a3125ca196c7a66c309dec/danish.sh"
CHANNEL="https://whatsapp.com/channel/0029Vb9KKE9EQIas4fPYVG1c"

TERMUX_BASH="/data/data/com.termux/files/usr/bin/bash"
TERMUX_PATH="/data/data/com.termux/files/usr/bin:/system/bin:/system/xbin"

FILES=()
SELECTED=""

banner() {
    clear
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════╗"
    echo "║                                    ║"
    echo "║       DANISH ARMY MANAGER          ║"
    echo "║          TMP CONTROL PANEL         ║"
    echo "║                                    ║"
    echo "╚════════════════════════════════════╝"
    echo -e "${RESET}"
}

pause() {
    echo
    read -r -p "Press ENTER to continue..."
}

quote_path() {
    local s="${1//\'/\'\\\'\'}"
    printf "'%s'" "$s"
}

open_channel() {
    if command -v termux-open-url >/dev/null 2>&1; then
        termux-open-url "$CHANNEL"
    else
        am start -a android.intent.action.VIEW -d "$CHANNEL"
    fi
}

# ==========================================
#             CHANNEL GATE
# ==========================================

channel_gate() {
    banner
    echo -e "${CYAN}OPENING WHATSAPP CHANNEL...${RESET}"
    open_channel

    echo
    echo -e "${YELLOW}HAVE YOU JOINED OUR CHANNEL?${RESET}"
    echo
    echo -e "${GREEN}1. YES${RESET}"
    echo -e "${RED}2. NO${RESET}"
    echo

    read -r -p "SELECT: " answer
    answer="$(printf '%s' "$answer" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')"

    case "$answer" in
        1|YES)
            echo -e "${GREEN}WELCOME TO DANISH ARMY!${RESET}"
            sleep 1
            ;;
        2|NO)
            echo -e "${RED}BRO, FIRST JOIN OUR CHANNEL!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}INVALID SELECTION!${RESET}"
            exit 0
            ;;
    esac
}

# ==========================================
#                ROOT CHECK
# ==========================================

root_check() {
    if ! su -c "test -d '$TMP_DIR'"; then
        echo -e "${RED}ROOT ACCESS REQUIRED!${RESET}"
        exit 1
    fi
}

# ==========================================
#               FILE DATABASE
# ==========================================

refresh_files() {
    mapfile -d '' -t FILES < <(
        su -c "find '$TMP_DIR' -maxdepth 1 -type f -print0"
    )
}

show_files() {
    refresh_files

    echo
    echo -e "${CYAN}══════════ TMP FILE DATABASE ══════════${RESET}"

    if [ "${#FILES[@]}" -eq 0 ]; then
        echo -e "${YELLOW}NO FILES FOUND!${RESET}"
        return
    fi

    for i in "${!FILES[@]}"; do
        echo
        echo -e "${GREEN}[$((i+1))]${RESET} ${WHITE}${FILES[$i]##*/}${RESET}"
    done

    echo
    echo -e "${CYAN}TOTAL FILES: ${#FILES[@]}${RESET}"
}

# ==========================================
#               SELECT FILE
# ==========================================

select_file() {
    show_files

    if [ "${#FILES[@]}" -eq 0 ]; then
        return 1
    fi

    echo
    read -r -p "ENTER FILE NUMBER: " number

    if ! [[ "$number" =~ ^[0-9]+$ ]] ||
       [ "$number" -lt 1 ] ||
       [ "$number" -gt "${#FILES[@]}" ]; then
        echo -e "${RED}INVALID FILE SELECTION!${RESET}"
        return 1
    fi

    SELECTED="${FILES[$((number-1))]}"

    if ! su -c "test -f $(quote_path "$SELECTED")"; then
        echo -e "${RED}FILE NO LONGER EXISTS!${RESET}"
        return 1
    fi

    return 0
}

# ==========================================
#                VIEW FILE
# ==========================================

view_file() {
    echo
    echo -e "${CYAN}FILE PREVIEW${RESET}"
    echo -e "${WHITE}FILE: ${SELECTED##*/}${RESET}"
    echo

    su -c "sed -n '1,60p' $(quote_path "$SELECTED")"

    echo
    echo -e "${YELLOW}FIRST 60 LINES SHOWN${RESET}"
}

# ==========================================
#              EXECUTE FILE
# ==========================================

execute_file() {
    if [[ "$SELECTED" != *.sh ]]; then
        echo -e "${RED}ONLY .SH FILES ARE SUPPORTED!${RESET}"
        return
    fi

    if ! su -c "test -r $(quote_path "$SELECTED")"; then
        echo -e "${RED}FILE CANNOT BE READ!${RESET}"
        return
    fi

    echo
    echo -e "${CYAN}EXECUTION PREVIEW${RESET}"
    view_file

    echo
    echo -e "${RED}WARNING: THIS FILE WILL RUN WITH ROOT PRIVILEGES!${RESET}"
    echo -e "${YELLOW}ONLY EXECUTE FILES YOU TRUST.${RESET}"
    echo

    read -r -p "TYPE YES TO CONFIRM: " confirm
    confirm="$(printf '%s' "$confirm" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')"

    if [ "$confirm" = "YES" ]; then
        echo
        echo -e "${GREEN}STARTING EXECUTION...${RESET}"
        echo

        local dir="${SELECTED%/*}"

        su -c "cd $(quote_path "$dir") &&
            export PATH=$(quote_path "$TERMUX_PATH") &&
            exec $(quote_path "$TERMUX_BASH") $(quote_path "$SELECTED")"

        local result=$?

        echo
        if [ "$result" -eq 0 ]; then
            echo -e "${GREEN}EXECUTION COMPLETED SUCCESSFULLY!${RESET}"
        else
            echo -e "${RED}EXECUTION FAILED! EXIT CODE: $result${RESET}"
        fi
    else
        echo -e "${YELLOW}EXECUTION CANCELLED!${RESET}"
    fi
}

# ==========================================
#            PERMISSION CONTROL
# ==========================================

permission_menu() {
    echo
    echo -e "${CYAN}════════ PERMISSION CONTROL ════════${RESET}"
    echo
    echo -e "${GREEN}1. 700 - OWNER ONLY${RESET}"
    echo -e "${GREEN}2. 755 - OWNER WRITE, ALL EXECUTE${RESET}"
    echo -e "${YELLOW}3. 777 - FULL ACCESS FOR EVERYONE${RESET}"
    echo -e "${WHITE}4. BACK${RESET}"
    echo

    read -r -p "SELECT PERMISSION: " perm

    case "$perm" in
        1) mode="700" ;;
        2) mode="755" ;;
        3) mode="777" ;;
        4) return ;;
        *)
            echo -e "${RED}INVALID PERMISSION!${RESET}"
            return
            ;;
    esac

    if [ "$mode" = "777" ]; then
        echo
        echo -e "${RED}WARNING: 777 ALLOWS EVERYONE TO MODIFY THE FILE!${RESET}"
        read -r -p "TYPE YES TO CONFIRM: " confirm
        confirm="$(printf '%s' "$confirm" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')"

        if [ "$confirm" != "YES" ]; then
            echo -e "${YELLOW}PERMISSION CHANGE CANCELLED!${RESET}"
            return
        fi
    fi

    if su -c "chmod $mode $(quote_path "$SELECTED")"; then
        echo
        echo -e "${GREEN}PERMISSION CHANGED SUCCESSFULLY!${RESET}"
        echo -e "${WHITE}NEW PERMISSION: $mode${RESET}"
    else
        echo -e "${RED}PERMISSION CHANGE FAILED!${RESET}"
    fi
}

# ==========================================
#                DELETE FILE
# ==========================================

delete_file() {
    echo
    echo -e "${RED}SELECTED FILE: ${SELECTED##*/}${RESET}"
    read -r -p "TYPE DELETE TO CONFIRM: " confirm

    if [ "$confirm" = "DELETE" ]; then
        if su -c "rm -f $(quote_path "$SELECTED")"; then
            echo -e "${GREEN}FILE DELETED SUCCESSFULLY!${RESET}"
            SELECTED=""
        else
            echo -e "${RED}DELETE FAILED!${RESET}"
        fi
    else
        echo -e "${YELLOW}DELETE CANCELLED!${RESET}"
    fi
}

# ==========================================
#             DELETE ALL TMP FILES
# ==========================================

delete_all_tmp_files() {
    echo
    echo -e "${RED}WARNING: ALL TMP FILES WILL BE DELETED!${RESET}"
    echo -e "${YELLOW}LOCATION: $TMP_DIR${RESET}"
    echo

    refresh_files

    local total="${#FILES[@]}"

    if [ "$total" -eq 0 ]; then
        echo -e "${YELLOW}NO FILES FOUND!${RESET}"
        return
    fi

    echo -e "${CYAN}TOTAL FILES FOUND: $total${RESET}"
    echo
    read -r -p "TYPE DELETE ALL TO CONFIRM: " confirm

    if [ "$confirm" != "DELETE ALL" ]; then
        echo -e "${YELLOW}DELETE CANCELLED!${RESET}"
        return
    fi

    if su -c "find '$TMP_DIR' -maxdepth 1 -type f -delete"; then
        SELECTED=""
        refresh_files
        echo
        echo -e "${GREEN}ALL TMP FILES DELETED SUCCESSFULLY!${RESET}"
    else
        echo -e "${RED}DELETE FAILED!${RESET}"
    fi
}

# ==========================================
#             FILE CONTROL PANEL
# ==========================================

file_control() {
    while [ -n "$SELECTED" ]; do

        if ! su -c "test -f $(quote_path "$SELECTED")"; then
            echo -e "${RED}FILE NOT FOUND!${RESET}"
            SELECTED=""
            break
        fi

        echo
        echo -e "${PURPLE}════════ FILE CONTROL PANEL ════════${RESET}"
        echo
        echo -e "${WHITE}SELECTED: ${GREEN}${SELECTED##*/}${RESET}"
        echo
        echo -e "${GREEN}1. EXECUTE FILE ▶${RESET}"
        echo -e "${CYAN}2. CHANGE PERMISSION${RESET}"
        echo -e "${WHITE}3. VIEW FILE${RESET}"
        echo -e "${RED}4. DELETE FILE${RESET}"
        echo -e "${YELLOW}5. BACK TO FILE LIST${RESET}"
        echo

        read -r -p "SELECT ACTION: " action

        case "$action" in
            1) execute_file ;;
            2) permission_menu ;;
            3) view_file ;;
            4) delete_file ;;
            5) SELECTED="" ;;
            *) echo -e "${RED}INVALID OPTION!${RESET}" ;;
        esac
    done
}

# ==========================================
#               PANEL DOWNLOAD
# ==========================================

panel_download() {
    banner

    # Already downloaded check
    if su -c "test -s $(quote_path "$DEST")"; then
        echo
        echo -e "${YELLOW}╔══════════════════════════════════════╗${RESET}"
        echo -e "${YELLOW}║                                      ║${RESET}"
        echo -e "${GREEN}║   YOUR PANEL IS ALREADY DOWNLOADED!  ║${RESET}"
        echo -e "${YELLOW}║                                      ║${RESET}"
        echo -e "${YELLOW}╚══════════════════════════════════════╝${RESET}"
        echo
        echo -e "${WHITE}PANEL: danish.sh${RESET}"
        echo -e "${CYAN}LOCATION: $DEST${RESET}"
        echo
        sleep 2
        return
    fi

    echo -e "${CYAN}══════════ PANEL DOWNLOAD ══════════${RESET}"
    echo
    echo -e "${WHITE}FILE: danish.sh${RESET}"
    echo -e "${WHITE}DESTINATION: $DEST${RESET}"
    echo

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}CURL NOT FOUND! INSTALL: pkg install curl${RESET}"
        pause
        return
    fi

    local uid gid
    uid="$(id -u)"
    gid="$(id -g)"

    echo -e "${CYAN}DOWNLOADING DANISH.SH...${RESET}"

    rm -f "$TEMP"

    if ! curl -fL --retry 2 "$URL" -o "$TEMP"; then
        echo -e "${RED}DOWNLOAD FAILED!${RESET}"
        rm -f "$TEMP"
        pause
        return
    fi

    if [ ! -s "$TEMP" ]; then
        echo -e "${RED}DOWNLOADED FILE IS EMPTY!${RESET}"
        rm -f "$TEMP"
        pause
        return
    fi

    if su -c "mkdir -p '$TMP_DIR' &&
        cp $(quote_path "$TEMP") $(quote_path "$DEST") &&
        chown '$uid:$gid' $(quote_path "$DEST") &&
        chmod 700 $(quote_path "$DEST")"; then

        rm -f "$TEMP"

        echo
        echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
        echo -e "${GREEN}║                                    ║${RESET}"
        echo -e "${GREEN}║   DOWNLOAD 100% SUCCESSFUL! ✓      ║${RESET}"
        echo -e "${GREEN}║                                    ║${RESET}"
        echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
        echo
        echo -e "${WHITE}FILE: danish.sh${RESET}"
        echo -e "${WHITE}LOCATION: $DEST${RESET}"
        echo -e "${YELLOW}PERMISSION: 700${RESET}"
        echo
        echo -e "${CYAN}OPENING WHATSAPP CHANNEL...${RESET}"

        open_channel
        sleep 2
        return

    else
        echo
        echo -e "${RED}DOWNLOAD FAILED: COULD NOT COPY FILE TO TMP!${RESET}"
        rm -f "$TEMP"
        pause
        return
    fi
}

# ==========================================
#                  MAIN MENU
# ==========================================

main_menu() {
    while true; do
        banner

        echo -e "${GREEN}1. SHOW ALL TMP FILES${RESET}"
        echo -e "${CYAN}2. SELECT FILE${RESET}"
        echo -e "${WHITE}3. REFRESH FILE LIST${RESET}"
        echo -e "${YELLOW}4. JOIN WHATSAPP CHANNEL${RESET}"
        echo -e "${PURPLE}5. PANEL DOWNLOAD ⬇${RESET}"
        echo -e "${RED}6. EXIT${RESET}"

        echo
        read -r -p "SELECT OPTION: " option

        case "$option" in
            1)
                banner
                show_files
                pause
                ;;
            2)
                if select_file; then
                    file_control
                fi
                pause
                ;;
            3)
                refresh_files
                echo -e "${GREEN}FILE LIST REFRESHED!${RESET}"
                pause
                ;;
            4)
                open_channel
                pause
                ;;
            5)
                panel_download
                ;;
            6)
                echo -e "${YELLOW}DANISH ARMY MANAGER CLOSED!${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}INVALID OPTION!${RESET}"
                pause
                ;;
        esac
    done
}

# ==========================================
#                  START
# ==========================================

channel_gate
root_check
main_menu
