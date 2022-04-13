#!/bin/bash

SERVICE="spigot.jar"
LOGS=/opt/minecraft/server/logs/latest.log
NO_PLAYERS="There are 0 of a max of 20 players online"
VERBOSE_MODE=0
DISABLED=0
DELAY=5m


if [[ "$DISABLED" -eq 1 ]]
then
    exit 0
fi

while getopts v flag
do
    case "${flag}" in
        v) VERBOSE_MODE=1;;
    esac
done

function get_players() {
    sudo -H -u minecraft bash -c 'tmux send-keys -t "minecraft" "list" Enter'
    sleep 5s
    PLAYERS=$(tail -n 1 $LOGS | cut -d ":" -f 4 | xargs)
}

function shutdown() {
    sudo shutdown -h now
}

function log() {
    if [[ "$VERBOSE_MODE" = 1 ]]
    then
        echo "$1"
    fi
}

if ps aux | grep $SERVICE | grep -v grep > /dev/null
then
    log "$SERVICE is running"
else
    log "$SERVICE is stopped"
    shutdown
fi

get_players
log $PLAYERS
if [[ "$PLAYERS" == "$NO_PLAYERS" ]]
then
    log "EMPTY"
    sleep $DELAY
    get_players
    if [[ "$PLAYERS" == "$NO_PLAYERS" ]]
    then
        log "STILL EMPTY - SHUTDOWN"
        shutdown
    fi
else
    log "NOT EMPTY"
fi
