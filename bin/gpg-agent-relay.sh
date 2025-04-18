#!/bin/bash
# Launches socat+npiperelay to relay the gpg-agent socket file for use in WSL
# See https://justyn.io/blog/using-a-yubikey-for-gpg-in-windows-10-wsl-windows-subsystem-for-linux/ for details

GPGDIR="${HOME}/.gnupg"
WIN_GPGDIR="C:/Users/Ben/AppData/Local/gnupg"
NPIPERELAY="/mnt/c/Users/Ben/go/bin/npiperelay.exe"
PIDFILE="${GPGDIR}/.gpg-agent-relay.pid"
OLDPID=$(cat "${PIDFILE}")

# Launch socat+npiperelay for the regular gpg-agent
if [ ! -z "${OLDPID}" ]; then
    ps -p "${OLDPID}" >/dev/null && \
    echo "gpg-agent-relay.sh already running with process id $(cat ${PIDFILE})" && \
    exit 0
fi


rm -f "${GPGDIR}/S.gpg-agent*"

echo $$ > ${PIDFILE}


# Relay the regular gpg-agent socket for gpg operations
socat UNIX-LISTEN:"${GPGDIR}/S.gpg-agent,fork" EXEC:"${NPIPERELAY} -ep -ei -s -a '${WIN_GPGDIR}/S.gpg-agent'",nofork &
AGENTPID=$!

# Relay the gpg ssh-agent
socat UNIX-LISTEN:"${GPGDIR}/S.gpg-agent.ssh,fork" EXEC:"${NPIPERELAY} -ep -ei -s -a '${WIN_GPGDIR}/S.gpg-agent.ssh'",nofork &
SSHPID=$!

wait ${AGENTPID}
wait ${SSHPID}
