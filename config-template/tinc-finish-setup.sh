#!/bin/sh
set -e

NET="%NET%"
ADDRESS_PREFIX="%ADDRESS_PREFIX%"
OCTET="%OCTET%"
SN_USER="%SN_USER%"
SN_UID="%SN_USER%"

# check if script was installed properly
[ x"$NET" = x'%''NET''%' ] && exit 1

choice () {
    local tmp

    while true; do
        if ! read -p "$1 ($2): " tmp
        then
            echo "$0: read failed" >&2
            exit 1
        fi

        if echo "$tmp" | grep -Eiq '^'"$2"'$'
        then
            eval "${3}=\"$(echo "$tmp" | tr '[:upper:]' '[:lower:]')\""
            return 0
        else
            printf "\nInvalid format, must match regex: \`%s'\n" "$2" >&2
        fi
    done

}

cd $(dirname "$0")

if [ ! -e hosts/$SN_USER ]; then
    tincd -K 4096 -n $NET </dev/null
    chmod 644 hosts/$SN_USER
    ( echo "Subnet = ${ADDRESS_PREFIX}.${OCTET}.0/24";
      cat hosts/$SN_USER
    ) > hosts/${SN_USER}_
    mv hosts/${SN_USER}_ hosts/$SN_USER
fi


#
# These bits need root
#

if ! read -p "User name of tinc dameon system user to create [tinc]: " TINC_USER
then
    echo "$0: read failed" >&2
    exit 1
fi

if [ -z "$TINC_USER" ]; then
    TINC_USER=tinc
fi

if ! id $TINC_USER >/dev/null 2>&1; then
    echo "Creating tinc daemon user...">&2
    adduser --no-create-home --system --home /etc/tinc tinc
fi

echo "Setting user via /etc/default/tinc">&2
if [ -e /etc/default/tinc ]; then
    echo "EXTRA=\"-U $TINC_USER\"" > /etc/default/tinc
fi

choice "What distro are you using?" "debian|ubuntu|arch|other" DISTRO

case "$DISTRO" in
    debian|ubunut)
        echo "on debian -> adding \`$NET' to /etc/tinc/nets.boot"
        echo "$NET" >> /etc/tinc/nets.boot
        cat /etc/tinc/nets.boot | sort | uniq > /etc/tinc/nets.boot_
        mv /etc/tinc/nets.boot_  /etc/tinc/nets.boot

        ;;

    arch)
        echo "on arch -> systemctl enable tincd@$NET"
        systemctl enable tincd@"$NET"
        ;;
    *)

        printf "\
WARNING: Unknown distribution, cannot ensure tincd will run on startup and\n\
handle the $NET net. Please do this manually."
esac
