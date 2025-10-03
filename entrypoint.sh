#!/usr/bin/env bash
set -e

# 1️⃣ Start systemd in the background
/usr/lib/systemd/systemd &
SYS_PID=$!

# 2️⃣ Give X a little time to start
sleep 5

# 3️⃣ Start XFCE desktop environment
export DISPLAY=:1
Xvfb $DISPLAY -screen 0 1024x768x16 &
XVFB_PID=$!

# 4️⃣ Launch the XFCE session
startxfce4 &
XFCE_PID=$!

# 5️⃣ Start the VNC server (tightvncserver is already in the base image)
#    – creates a virtual desktop on :1 (port 5901)
vncserver $DISPLAY -geometry 1024x768 -depth 16 -SecurityTypes None

# 6️⃣ Bridge VNC to the browser with noVNC / websockify
#    – serves on port 6080 (exposed above)
websockify --web=/usr/share/novnc/ 6080 localhost:5901 &
NOVNC_PID=$!

# 7️⃣ Wait for the systemd process so the container stays alive
wait $SYS_PID
