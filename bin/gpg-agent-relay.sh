#!/bin/bash

GPGDIR="${HOME}/.gnupg"
WIN_GPGDIR="C:/Users/Ben/AppData/Local/gnupg"
NPIPERELAY="/mnt/c/Users/Ben/go/bin/npiperelay.exe"
PIDFILE="${GPGDIR}/.gpg-agent-relay.pid"
OLDPID=$(cat "${PIDFILE}")


ALREADY_RUNNING=$(ps -auxww | grep -q "[n]piperelay.exe -ep -ei -s -a 'C:/Users/Ben/AppData/Local/gnupg/S.gpg-agent.ssh'"; echo $?)

if [ $ALREADY_RUNNING != "0" ] ; then
    if [ -S $GPGDIR/S.gpg-agent ]; then
        # not expecting the socket to exist as the forwarding command isn't running (http://www.tldp.org/LDP/abs/html/fto.html)
        echo "removing previous socket..."
        rm $GPGDIR/S.gpg-agent
        rm $GPGDIR/S.gpg-agent.ssh
    fi


        echo "Starting gpg agent relay"
        (setsid socat UNIX-LISTEN:"${GPGDIR}/S.gpg-agent,fork" EXEC:"${NPIPERELAY} -ep -ei -s -a '${WIN_GPGDIR}/S.gpg-agent'",nofork &) >/dev/null 2>&1
        (setsid socat UNIX-LISTEN:"${GPGDIR}/S.gpg-agent.ssh,fork" EXEC:"${NPIPERELAY} -ep -ei -s -a '${WIN_GPGDIR}/S.gpg-agent.ssh'",nofork &) >/dev/null 2>&1

else 
    echo "Already running"
fi
