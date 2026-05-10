#!/bin/bash
set -e
trap ctrl_c INT
function ctrl_c() {
  exit 0
}
rm /tmp/.X1-lock 2> /dev/null &
/opt/noVNC/utils/launch.sh --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT &
echo -e "$TIGER_VNC_PASSWORD\n$TIGER_VNC_PASSWORD" | tigervncserver -xstartup /src/startdoom.sh &
wait