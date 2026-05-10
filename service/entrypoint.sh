#!/bin/bash
set -e

trap ctrl_c INT
function ctrl_c() {
    echo "Stopping container..."
    exit 0
}

rm -f /tmp/.X*-lock /tmp/.X11-unix/X* || true

echo -e "$TIGER_VNC_PASSWORD\n$TIGER_VNC_PASSWORD" | tigervncserver :1 \
    -rfbport $VNC_PORT \
    -xstartup /src/startdoom.sh \
    -geometry 1024x768 \
    -depth 24 \
    -localhost no

sleep 2

/opt/noVNC/utils/launch.sh --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT &

echo "Doom is ready on port $NO_VNC_PORT"
wait