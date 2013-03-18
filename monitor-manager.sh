#!/bin/bash

#######################################
# WLNet Monitor Configuration Tool
# Last Updated: 2012-12-20
#######################################

CONNECTED_MONITORS=0
export DISPLAY=:0

declare -a UWMONITORS=("7R47741L05GQ" "7R47741L05H9")

containsElement () {
  echo $1
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

# First pass - how many monitors are connected?
for CONNECTION in $(find /sys/class/drm/ -name 'card*' -type d); do
  CONN_NAME=$(echo $CONNECTION | sed 's/\/sys\/class\/drm\/card1-//')
  echo "Checking display connection: $CONN_NAME"
  
  if [ `cat $CONNECTION/status` = 'connected' ]; then
    echo "$CONN_NAME is connected"
    let CONNECTED_MONITORS+=1
  fi
  
  # Add monitor/environment specific code here:
  
  
  # Finish monitor specific code here.
done

# Case when there is only one monitor available.
if [ $CONNECTED_MONITORS -eq 1 ]; then
  echo "Only laptop display available"

  xrandr --output DP3 --off --output DP2 --off --output DP1 --off \
    --output HDMI3 --off --output HDMI2 --off --output HDMI1 --off \
    --output LVDS1 --mode 1920x1080 --pos 0x0 --rotate normal --output VGA1 \
    --off
fi

UWMONITORCOUNT=0

for CONNECTION in $(find /sys/class/drm/ -name 'card1-*'); do
  CONN_NAME=$(echo $CONNECTION | sed 's/\/sys\/class\/drm\/card1-//')
  echo "Checking display connection: $CONN_NAME"
  
  if [ `cat $CONNECTION/status` = 'connected' ]; then
    echo "$CONN_NAME is connected"
    MYMONITOR=$(edid-decode $CONNECTION/edid | grep "Serial number" | awk '{print $3}')
    
    # Add monitor/environment specific code here:
    
    containsElement "$MYMONITOR" "${UWMONITORS[@]}"
    
    if [ $? -eq 0 ]; then
      let UWMONITORCOUNT+=1
    fi
    
    # Finish monitor specific code here.
  fi
  

done

echo "UW MONITORS: $UWMONITORCOUNT"

if [ $UWMONITORCOUNT -eq 2 ]; then
  xrandr --output DP3 --off --output DP2 --off --output DP1 --off --output HDMI3 \
    --mode 1280x1024 --pos 3200x0 --rotate normal --output HDMI2 --off --output HDMI1 \
    --mode 1280x1024 --pos 1920x0 --rotate normal --output LVDS1 --mode 1920x1080 --pos 0x0 \
    --rotate normal --output VGA1 --off

fi

echo "There are $CONNECTED_MONITORS connected monitor(s)"