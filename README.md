# openvpn-watchdog-script
A simple bash script to detect connection hangs and keep OpenVPN running.

I used to have problems to keep OpenVPN running as a service for a long period.
For different reasons the connection would hang while OpenVPN process would still be up running but wouldn't recover the connection.
For that reason, I wrote this watchdog script to keep the VPN up. It will determine the Internet connection status by pinging some preconfigured hosts.
If none of the hosts replies, we assume the connection has dropped and restart OpenVPN.
