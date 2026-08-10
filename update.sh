#!/bin/bash

# -------------------------------------------------------------------------------------------------------------
# CHANGELOG:
# Update script for apt update and clean, then checks for flatpak and snap
# Added checks for pacman, yum, dpkg, rpm, pip.
# Added which errors redirected to /dev/null
# Fixed $reldate. Should be release_date throughout the document.
# Added yay
# Updated yay to run as sudo-invoking user, not as root
# Fixed auto-update & update to respect sudo-ing user
# Overhaul of typos, syntax bad habits fixed
# Updated post-update ownership behaviour to be less buggy and behave better
# Slight fix to the yay command to reduce verbosity
# -------------------------------------------------------------------------------------------------------------

# Set default vars
cver="1.11"
release_date="10 Aug 2026"
tmpfile="/tmp/upd_sh-$(date +%Y%m%d%H).txt"
script_url="https://raw.githubusercontent.com/ebmurray/handy_scripts/main/update.sh"
SUDO_USER="${SUDO_USER:-$(id -un)}"
SUDO_GROUP="${SUDO_GROUP:-$(id -gn "$SUDO_USER")}"

# Root check
function rootcheck () {
    if [ "$(id -u)" != "0" ]; then
        echo "Error: Please re-run this script as root."
        exit
    fi
}

# Echo current version
function echo_cver () {
    echo "Version "$cver" ($release_date)" ;
}

# Check for new version
function check_cver () {
    wget -q -t 1 -T 10 --no-check-certificate -O "$tmpfile" "$script_url"
    chown "$SUDO_USER":"$SUDO_GROUP" "$tmpfile"
    chmod 0744 "$tmpfile"
    ver_info="$("$tmpfile" -v)"
    curr_file="$(readlink -f "$0")"
    fbase="${curr_file%.*}"
    fext="${curr_file##*.}"
    latest_ver="$(echo $ver_info | awk {'print $2'})"
    latest_rd="$(date -d "$(echo $ver_info | awk -F"(" {'print $2'} | awk -F")" {'print $1'})" +%Y%m%d)"
    if [ "$latest_ver" != "" -a "$latest_rd" != "" ] ; then
        if [ $latest_rd -gt $(date -d "$release_date" +%Y%m%d) ] ; then
            echo "Upgrade v${latest_ver} available"
            echo
            echo "If you DO NOT want to update file owner:group to sudoer, use N/n below, then use "su -" or "sudo -i" and re-run the script."
            echo
            echo -n "Your version: $cver - Latest version: ${latest_ver} - Upgrade? [Y|n] " && read YORN
            if [[ $YORN != N* ]] && [[ $YORN != n* ]] ; then
                echo "Updating "$cver" to "$latest_ver""
                mv "$curr_file" "${fbase}_v${cver}.${fext}"
                mv "$tmpfile" "$curr_file"
                echo ; echo "Re-running with new version"
                echo "" ; "$curr_file"
                exit 0
            else
                echo "Not updating."
                rm -f "$tmpfile"
            fi
        else
            echo "Using latest revision."
            rm -f "$tmpfile"
        fi
    else
        echo "Unable to determine latest revision. Continuing..."
        rm -f "$tmpfile"
    fi
}

# Package manager checks if found
function appcheck () {
    if [ "$(which apt 2>/dev/null|awk -F/ '{print $NF}')" == "apt" 2> /dev/null] ; then
        aptinst=1 ; aptproc=" apt" ;
    else
        aptinst=0 ; aptproc="" ;
    fi

    if [ "$(which pacman 2>/dev/null|awk -F/ '{print $NF}')" == "pacman" ] ; then
        pacinst=1 ; pacproc=" pacman" ;
    else
        pacinst=0 ; pacproc="" ;
    fi

    if [ "$(which yay 2>/dev/null|awk -F/ '{print $NF}')" == "yay" ] ; then
        yayinst=1 ; yayproc=" yay" ;
    else
        yayinst=0 ; yayproc="" ;
    fi

    if [ "$(which dpkg 2>/dev/null|awk -F/ '{print $NF}')" == "dpkg" ] ; then
        dpkginst=1 ; dpkgproc=" dpkg" ;
    else
        dpkginst=0 ; dpkgproc="" ;
    fi

    if [ "$(which yum 2>/dev/null|awk -F/ '{print $NF}')" == "yum" ] ; then
        yuminst=1 ; yumproc=" yum" ;
    else
        yuminst=0 ; yumproc="" ;
    fi

    if [ "$(which rpm 2>/dev/null|awk -F/ '{print $NF}')" == "rpm" ] ; then
        rpminst=1 ; rpmproc=" rpm" ;
    else
        rpminst=0 ; rpmproc="" ;
    fi

    if [ "$(which pip 2>/dev/null|awk -F/ '{print $NF}')" == "pip" ] ; then
        pipinst=1 ; pipproc=" pip" ;
    else
        pipinst=0 ; pipproc="" ;
    fi

    if [ "$(which flatpak 2>/dev/null|awk -F/ '{print $NF}')" == "flatpak" ] ; then
        flatpakinst=1 ; flatpakproc=" flatpak" ;
    else
        flatpakinst=0 ; flatpakproc="" ;
    fi

    if [ "$(which snap 2>/dev/null|awk -F/ '{print $NF}')" == "snap" ] ; then
        snapinst=1 ; snapproc=" snap" ;
    else
        snapinst=0 ; snapproc="" ;
    fi
}

# Update proclamation
function updateproc () {
    echo "Detected & updating:$aptproc$pacproc$yayproc$dpkgproc$yumproc$rpmproc$pipproc$flatpakproc$snapproc" ;
}

# Update apt
function upd_if_found () {
    if [ "$aptinst" == "1" ] ; then
        echo ; echo "apt update -y" ; apt update -y &&
        echo ; echo "apt upgrade -y" ; apt upgrade -y &&
        echo ; echo "apt dist-upgrade -Vy" ; apt dist-upgrade -Vy &&
        echo ; echo "apt autoremove -y" ; apt autoremove -y &&
        echo ; echo "apt autoclean" ; apt autoclean &&
        echo ; echo "apt clean" ; apt clean &&
        echo ; echo "apt purge" ; apt purge -y $(dpkg -l | awk '/^rc/ { print $2 }')
        echo ; echo "Done." ;
    fi

    if [ "$pacinst" == "1" ] ; then
        echo ; echo "pacman -Syu" ; pacman -Syu
    fi

    if [ "$yayinst" == "1" ] && [ -n "$SUDO_USER" ] ; then
        echo ; echo "yay -Sua (as "$SUDO_USER")" ; sudo -u "$SUDO_USER" -- yay -Sua
    fi

    if [ "$pipinst" == "1" ] ; then
        echo ; echo "pip list -o" ; pip list -o ;
    fi

    if [ "$flatpakinst" == "1" ] ; then
        echo ; echo "flatpak update -y" ; flatpak update -y ;
    fi

    if [ "$snapinst" == "1" ] ; then
        echo ; echo "snap refresh" ; snap refresh ;
    fi
}

invoke () {
    [[ "$invoke_args" ]] && invoke_args="$invoke_args -$1" || invoke_args="-$1"
}

while getopts "v" opt ; do
    case $opt in
        v) invoke "v" ; echo_cver ; exit 0 ;;
    esac
done

# Run functions
rootcheck
echo_cver
check_cver
appcheck
updateproc
upd_if_found
echo '';
exit
