#!/bin/sh

checkInstall()
{
    BINNAME=$1
    type $BINNAME > /dev/null 2>&1

    if [ "$?" = 0 ]; then
        V_CHECKINSTALL=0
        echo "'$BINNAME' installed!"
    else
        echo "$BINNAME is not Installed."
        if [ "$2" = 1 ]; then
            echo "Exit Script ..."
            exit 1
        fi
    fi
}

installPackage()
{
    whoSysAmi
    if [ "$V_WHOSYSAMI" = "rhel fedora" ]; then
        yum install $1 -y
        killOnFailure
    fi

    if [ "$V_WHOSYSAMI" = "debian" ]; then
        apt-get install $1 -y
        killOnFailure
    fi

}


whoSysAmi()
{

    V_WHOSYSAMI=$(grep -oP '(?<=^ID_LIKE=).+' /etc/os-release | tr -d '"')
}

checkContainerized()
{
    cat /proc/self/cgroup | grep docker >/dev/null >2&1
    if [ ! "$?" = 0 ]; then
        V_CHECKCONTAINERIZED=1
        echo "This script runs inside a containerized environment." >&2
    fi
}

prettyDateTime()
{
    V_PRETTYDATETIME=$(date +'%d%m%Y%M')
}

checkRoot()
{
    MUID=$(id -u)
    echo "DEBUG: checkroot"
    echo "DEBUG: EUID = $MUID"
    if [ "$MUID" = 0 ]; then
        echo "DEBUG: ROOT CHECK PASSED"
        echo "This script runs privileged"
    else
        if [ "$1" = 1 ]; then
            echo "DEBUG: ROOT CHECK NOT PASSED"
            echo "This script runs unprivileged"
            echo "Aborting Script..."
            echo $2
            exit 1
        fi
        echo "DEBUG: ROOT CHECK NOT PASSED"
        $?=1
    fi
}
checkNoRoot()
{
    MUID=$(id -u)
    echo "DEBUG: checkNoRoot"
    echo "DEBUG: EUID = $MUID"
    if [ ! "$MUID" = 0 ]; then
        echo "DEBUG: Check Passed"
        echo "This script runs unprivileged"
    else
        if [ "$1" = 1 ]; then
            echo "DEBUG: NON-ROOT CHECK NOT PASSED"
            echo "This script runs privileged"
            echo "Aborting Script..."
            echo $2
            exit 1
        fi
        echo "DEBUG: NON-ROOT CHECK NOT PASSED"
        $?=1
    fi
}

checkUser()
{
    if [ ! "$EUID" = "$1" ]; then
        V_CHECKUSER=1
    else
        echo "UserID not corresponding"
    fi
}

scriptLocation()
{
    V_SCRIPTLOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}

killOnFailure()
{
    if [ ! "$?" = 0 ]; then
        if [ -z "$1" ]; then
            echo $1
        else
            echo "Error during previous operation."
        fi

        echo "Aborting Script.."
        exit
    fi
}