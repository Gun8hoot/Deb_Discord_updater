#!/bin/bash
API_URL='https://discord.com/api/download?platform=linux&format=deb'
UPDATE_NAME="discord-update.deb"
LOG_FILENAME="update_logs:$(date +"%m-%d-%Y_%H:%M:%S")"
CURRENT_TIME=$(date +"%H:%M:%S")
DISCORD_VERSION=$(apt list 2>/dev/null |grep discord/now | awk '{print $2}')
NEW_DISCORD_VERSION=$(apt list 2>/dev/null |grep discord/now | awk '{print $2}')
LOG_PATH="/tmp/discord.update/logs/$LOG_FILENAME"

DL_EXEC () {
    echo -e "$DISCORD_VERSION" > /tmp/discord.update/version && DISCORD_VERSION=$(cat /tmp/discord.update/version)
    curl -s --output /tmp/discord.update/discord-update.deb -L $API_URL && if [ -f "$UPDATE_NAME" ];then echo -e "[+] The update file has been downloaded" && echo "[+] Update file $UPDATE_NAME has been downloaded : $CURRENT_TIME" >> $LOG_PATH ;fi
    if [ -f "/tmp/discord.update/$UPDATE_NAME" ]; then
        apt -qq install /tmp/discord.update/discord-update.deb 
        if [ NEW_DISCORD_VERSION != DISCORD_VERSION ]; then
            echo -e "\x1b[38;5;40m[+] Succesfully updated ! \x1b[0m" && echo "[+] Update installed : $CURRENT_TIME" >> $LOG_PATH

        elif [ NEW_DISCORD_VERSION -eq DISCORD_VERSION ]; then
            echo -e "\x1b[38;5;40m[-] Discord is already update \x1b[0m" && echo "[-] Discord is already update : $CURRENT_TIME" >> $LOG_PATH
            
        fi
    elif [ ! -f "/tmp/discord.update/$UPDATE_NAME" ]; then
        echo "[!] An error have ocured during the update. Check the last logs file in /tmp/discord.update/logs"
    fi 
}

CHECK_ROOT () {
    if [ $EUID -eq 0 ];then 
        :
    else
        echo -e "\x1b[38;5;9m[!] It seems that you don't have sudoers privileges. Try : sudo ./discord_auto-update.sh\n\x1b[0mPRESS A KEYS TO CONTINUE :" 
        read
        echo -e "\x1b[A                             \x1b[A"
    fi
}

main () {
    CHECK_ROOT
    if [ -d "/tmp/discord.update" ]; then
        echo "[+] The project temporary folder already exist : $CURRENT_TIME" >> $LOG_PATH
        DL_EXEC
    elif [ ! -d "/tmp/discord.update" ]; then
        mkdir /tmp/discord.update && mkdir /tmp/discord.update/logs & echo "https://github.com/Gun8hoot/Deb_Discord_updater.git" >> /tmp/discord.update/whatisthisfolder.txt
        echo "[+] The project temporary folder have been create : $CURRENT_TIME" >> $LOG_PATH
        DL_EXEC
    else
        echo "ERROR"
    fi
}

main