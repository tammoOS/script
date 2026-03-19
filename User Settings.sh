#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Error: Please run the script with: sudo $0"
   exit 1
fi

TEMPLATE_USER="tammo"

copy_template_settings() {
    local DEST_USER=$1
    
    if [ -d "/home/$TEMPLATE_USER" ]; then
     
 
        for folder in .config .local .themes .icons; do
            if [ -d "/home/$TEMPLATE_USER/$folder" ]; then
               
                rm -rf "/home/$DEST_USER/$folder"
                cp -rp "/home/$TEMPLATE_USER/$folder" "/home/$DEST_USER/"
            fi
        done
        
   
        chown -R "$DEST_USER:$DEST_USER" "/home/$DEST_USER"
     
    else
        echo "cannot find /home/$TEMPLATE_USER."
    fi
}

while true; do
    clear
    echo "=========================================="
    echo "           tammoOS USER SETTINGS          "
    echo "=========================================="
    echo " Accounts: $(ls /home | xargs)"
    echo "------------------------------------------"
    echo "1) add a new User"
    echo "2) rename User"
    echo "3) change password"
    echo "4) change profile-picture"
    echo "5) change hostname"
    echo "6) delete a User"
    echo "7) exit"
    echo "------------------------------------------"
    read -p " [1-7] " OPT

    case $OPT in
        1)
            read -p "New Username: " NEW_USER_NAME
            if [ -n "$NEW_USER_NAME" ]; then
               
                useradd -m -s /bin/bash "$NEW_USER_NAME"
                
                
               
                passwd "$NEW_USER_NAME"
                
            
                copy_template_settings "$NEW_USER_NAME"
                
        
                read -p "Admin rights? (y/n): " IS_ADMIN
                [[ $IS_ADMIN == "y" ]] && usermod -aG sudo "$NEW_USER_NAME"
                echo "ATTENTION: The password of the main user may be required for the first login."
                echo "--- Sucess! ---"
            fi
            read -p "Press Enter..." ;;
            
        2)
            read -p "Username: " OLD_L
            read -p "New username: " NEW_L
            if usermod -l "$NEW_L" -d "/home/$NEW_L" -m "$OLD_L" 2>/dev/null; then
                groupmod -n "$NEW_L" "$OLD_L" 2>/dev/null
                
            else
             
                chfn -f "$NEW_L" "$OLD_L"
            fi
            read -p "Done :) Press Enter..." ;;

        3) 
            read -p "User: " U
            if id "$U" &>/dev/null; then passwd "$U"; else echo "doesn´t exist"; fi
            read -p "Enter..." ;;

        4) 
            read -p "User: " U
            read -p "Please enter the path to the picture: " P
            if [ -f "$P" ]; then
                ICON_DEST="/var/lib/AccountsService/icons/$U"
                cp "$P" "$ICON_DEST" && chmod 644 "$ICON_DEST"
                dbus-send --system --dest=org.freedesktop.Accounts --type=method_call "/org/freedesktop/Accounts/User$(id -u $U)" org.freedesktop.Accounts.User.SetIconFile string:"$ICON_DEST"
                echo "Done."
            fi
            read -p "Enter..." ;;

        5) read -p "Hostname: " NH; hostnamectl set-hostname "$NH"; read -p "Enter..." ;;

        6) 
            read -p "Username: " DU
            read -p "Do you want to continue? (y/n): " DF
            [[ $DF == "y" ]] && userdel -r "$DU" || userdel "$DU"
            read -p "Enter..." ;;

        7) exit ;;
        
        *)  sleep 1 ;;
    esac
done