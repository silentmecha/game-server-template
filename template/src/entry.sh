#!/bin/bash

trap "clean_up" SIGTERM
function clean_up() {
    kill -SIGINT $serverPID
}

cd ${STEAMAPPDIR}

if [ $AUTO_UPDATE]; then
    steamcmd \
	+force_install_dir "${STEAMAPPDIR}" \
	+login ${STEAM_LOGIN} \
	+app_update "${STEAMAPP_ID}" validate \
	+quit
fi

<<SERVER_START_COMMAND>> & serverPID=$!
wait $serverPID
exit 0
