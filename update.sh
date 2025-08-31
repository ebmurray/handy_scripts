#!/bin/bash
# Update script for apt update and clean, then checks for flatpak and snap (ebmurray)

# CHANGELOG:
# Added checks for pacman, yum, dpkg, rpm, pip.

# Set default vars
cver="1.04"
reldate="01 Sept 2025"
tmpfile="/tmp/upd_sh-$(date +%Y%m%d%H).txt"
script_url="https://raw.githubusercontent.com/ebmurray/handy_scripts/main/update.sh"

# Root check
function rootcheck () {
    if [ "$(id -u)" != "0" ]; then
        echo "Error: Please re-run this script as root."
        exit
    fi
}

# Echo current version
function echo_cver () {
    echo "Version $cver ($reldate)" ;
}

# Check for new version
function check_cver () {
    wget -q -t 1 -T 5 --no-check-certificate -O $tmpfile $script_url
    chmod +x $tmpfile
    ver_info="$($tmpfile -v)"
    CURR_FILE="$(readlink -f "$0")"
    latest_ver="$(echo $ver_info | awk {'print $3'})"
    latest_rd="$(date -d "$(echo $ver_info | awk -F"(" {'print $2'} | awk -F")" {'print $1'})" +%Y%m%d)"
    if [ "$latest_ver" != "" -a "$latest_rd" != "" ] ; then
        if [ $latest_rd -gt $(date -d "$release_date" +%Y%m%d) ] ; then
            [ $SKIP_UPGRADE ] && echo "Upgrade v${latest_ver} available" && return
            [ $AUTOUPDATE -eq 0 ] && echo -n "Your version: $current_version Latest version: ${latest_ver} Upgrade? [Y|n] " && read YORN || echo "Auto-updating"
            if [[ $YORN != N* ]] && [[ $YORN != n* ]] ; then
                echo "Updating $current_version to $latest_ver"
                mv $CURR_FILE ${CURR_FILE}${current_version}.$(date -d "$release_date" +%Y%m%d)
                mv $tmpfile $CURR_FILE
                echo ; echo "Re-running with new version"
                echo "" ; $CURR_FILE
                exit 0
            else
                echo "Not updating."
                rm -f $tmpfile
            fi
        else
            echo "Using latest revision."
            rm -f $tmpfile
        fi
    else
        echo "Unable to determine latest revision. Continuing..."
        rm -f $tmpfile
    fi
}

# Package manager checks if found
function appcheck () {
    if [ "$(which apt|awk -F/ '{print $NF}')" == "apt" ] ; then
        aptinst=1 ; aptproc=" apt" ;
	else
		aptinst=0 ; aptproc="" ;
    fi

    if [ "$(which pacman|awk -F/ '{print $NF}')" == "pacman" ] ; then
        pacinst=1 ; pacproc=" pacman" ;
    else
        pacinst=0 ; pacproc="" ;
    fi

    if [ "$(which dpkg|awk -F/ '{print $NF}')" == "dpkg" ] ; then
        dpkginst=1 ; dpkgproc=" dpkg" ;
    else
        dpkginst=0 ; dpkgproc="" ;
    fi

    if [ "$(which yum|awk -F/ '{print $NF}')" == "yum" ] ; then
        yuminst=1 ; yumproc=" yum" ;
    else
        yuminst=0 ; yumgproc="" ;
    fi

    if [ "$(which rpm|awk -F/ '{print $NF}')" == "rpm" ] ; then
        rpminst=1 ; rpmproc=" rpm" ;
    else
        rpminst=0 ; rpmgproc="" ;
    fi

    if [ "$(which pip|awk -F/ '{print $NF}')" == "pip" ] ; then
        pipinst=1 ; pipproc=" pip" ;
    else
        pipinst=0 ; pipproc="" ;
    fi

    if [ "$(which flatpak|awk -F/ '{print $NF}')" == "flatpak" ] ; then
        flatpakinst=1 ; flatpakproc=" flatpak" ;
	else
		flatpakinst=0 ; flatpakproc="" ;
    fi

    if [ "$(which snap|awk -F/ '{print $NF}')" == "snap" ] ; then
        snapinst=1 ; snapproc=" snap" ;
	else
		snapinst=0 ; snapproc="" ;
    fi
}

# Update proclamation
function updateproc () {
    echo "Detected & updating:$aptproc$pacproc$dpkgproc$yumproc$prmproc$pipproc$flatpakproc$snapproc" ;
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