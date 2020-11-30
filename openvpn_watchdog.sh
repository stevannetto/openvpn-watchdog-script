#!/bin/bash
#########################################################################################
# OpenVPN watchdog script
# Author: Stevan Netto
#########################################################################################

### Some required configurations
# Time to wait in seconds for OpenVPN to establish a connecion, before we check for it
OPENVPN_CONNECTION_TIMEOUT=60

# Interval between connection checks. Lower values means a shorter downtime, with a
# higher pings frequency.
PING_INTERVAL=120

# OpenVPN command
OPENVPN_CMD="/usr/sbin/openvpn --config /etc/openvpn/client.ovpn"

# List of hosts to ping
HOSTS_TO_PING=(google.com yahoo.com)

OPENVPN_PID=0
while true
do
    echo "Starting Openvpn..."
    echo $OPENVPN_CMD
    $OPENVPN_CMD &
    OPENVPN_PID=$(pidof openvpn)
    EXIT_ST=$?
    echo "EXIT ST: $EXIT_ST"
    if [ $EXIT_ST -ne 0 ]; then
        echo "OpenVPN process failed to start."
        echo "Terminating script."
        exit 1;
    else
        OPENVPN_PID=$(pidof openvpn)
        echo "OpenVPN started under PID $OPENVPN_PID"
    fi 
    sleep $OPENVPN_CONNECTION_TIMEOUT
    while true 
    do 
    # Watchdog loop.
    # Check if OpenVPN is still running
        kill -0 $OPENVPN_PID
        if [ $? -ne 0 ];
        then
            echo "OpenVPN isnt running"
        break;
        fi
        PING_REPLY=0
        for i in "${HOSTS_TO_PING[@]}"
        do
            ping -c1 $i && PING_REPLY=1 && break
        done
        if [ $PING_REPLY -ne 1 ]; then
            echo "None of the hosts have replied our pings. Killing OpenVPN process ($OPENVPN_PID)"
            kill $OPENVPN_PID
            # Give some time for OpenVPN to terminate
            sleep 10
            break; # Exit watchdog loop
        fi
        sleep $PING_INTERVAL
    done
done
