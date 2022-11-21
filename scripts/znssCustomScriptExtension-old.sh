#!/bin/sh -e

sleep 10

# Install NSS Certificate
if ! [ -f "NssCertificate.zip" ]; then
    echo "The file NssCertificate.zip was not found."
    echo "Put this script in the same path where NssCertificate.zip is."
    echo "And run it again."
    exit 1
fi

echo "Installing Certificate"
sudo nss install-cert NssCertificate.zip

# NSS Service Interface and Default Gateway IP Configuration
# Parameters passed by the user input via ARM Template
echo "Set Service Interface and Default Gateway IP Address"
smnet_dev=${SMNET_IPMASK} # This value must be passed to the service interface IP question (Line 43)
smnet_dflt_gw=${SMNET_GW} # This value must be passed to the service interface IP question (Line 61)
sudo nss configure --cliinput ${SMNET_IPMASK},${SMNET_GW}
echo "Successfully Applied Changes"

# DNS Server IP Addresses
# Parameters are passed by the user input via ARM Template
dns_server1=${DNS_SERVER1}
dns_server2=${DNS_SERVER2}

# Configure NSS Settings
#Comment: Probably the most difficult part. The system will ask for name name server.
# If answer is no, then jump straight to line 47
# If answer is yes, user will provide the nameserver IP.
# system continues to ask for a nameserver until answer is no
# Ideally I want to only support a maximum of 2 name server IPs and then jump to line 47.
NEW_NAME_SERVER_IPS=()
NEW_NS="n"
echo "Do you wish to add a new nameserver? <n:no y:yes> , press enter for [n]"
read RESP
until [ -z "$RESP" ] || [ "$RESP"  != "y" ]; do
    echo "Enter the nameserver IP address:"
    read NEW_NAME_SERVER_IP
    until ! [ -z "$NEW_NAME_SERVER_IP" ] && [[ $NEW_NAME_SERVER_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; do
        echo "Please enter a valid nameserver IP address:"
        read NEW_NAME_SERVER_IP
    done
    NEW_NAME_SERVER_IPS+=("$NEW_NAME_SERVER_IP")
    echo "Do you wish to add a new nameserver? <n:no y:yes> , press enter for [n]"
    read RESP
done

# NSS Server Interface IP Configuration
# Comment: Service IP is being passed by the variable SMNET_IPMASK on line 19
# Need to press enter to proceed
echo "Enter service interface IP address with netmask. (ex. 192.168.100.130/25):" ${SMNET_IPMASK}
read SMNET_IPMASK

# NSS Default Gateway Configuration
# Comment: I don't think I need line 49 anymore,
# as I am passing the default gateway via variable SMNET_GW on line 20
DEFAULT_GW=$(netstat -r | grep default | awk '{print $2}')
echo "Enter service interface default gateway IP address, press enter for [${DEFAULT_GW}]:" ${SMNET_GW} # Need to press enter to proceed
read DEFAULT_GW_ENTERED
if ! [ -z "${DEFAULT_GW_ENTERED}" ]; then
    DEFAULT_GW=${DEFAULT_GW_ENTERED}
fi

SERVERS=$(sudo nss dump-config | grep "nameserver:"|  tr  "nameserver:" " " | tr [:space:] " ")
IFS=', ' read -r -a EXISTING_NAME_SERVERS <<< "$SERVERS"
# -----
SKIP_SERVERS=""
for server in "${EXISTING_NAME_SERVERS[@]}"
do
    SKIP_SERVERS+="\n"
done
NEW_SERVERS_COMMAND=""
for new_server in "${NEW_NAME_SERVER_IPS[@]}"
do
    NEW_SERVERS_COMMAND+="y\n${new_server}\n"
done
printf "${SKIP_SERVERS}${NEW_SERVERS_COMMAND}\n${SMNET_IPMASK}\n${SMNET_GW}\n\n" | sudo nss configure



# Download NSS Binaries
# Comment: No need to touch this section.
sudo nss update-now
echo "Connecting to server..."
echo "Downloading latest version" # Wait until system echo back the next message
echo "Installing build /sc/smcdsc/nss_upgrade.sh" # Wait until system echo back the next message
echo "Finished installation!"

 #Check NSS Version
sudo nss checkversion

# Enable the NSS to start automatically
sudo nss enable-autostart
echo "Auto-start of NSS enabled "

# Start NSS Service
sudo nss start
echo "NSS service running."

# Dump all Important Configuration
sudo netstat -r > nss_dump_config.log
sudo nss dump-config > nss_dump_config.log
sudo nss checkversion >> nss_dump_config.log
sudo nss troubleshoot netstat|grep tcp >> nss_dump_config.log
sudo nss test-firewall >> nss_dump_config.log
sudo nss troubleshoot netstat >> nss_dump_config.log
/sc/bin/smmgr -ys smnet=ifconfig >> nss_dump_config.log
cat /sc/conf/sc.conf | egrep "smnet_dev|smnet_dflt_gw" >> nss_dump_config.log

exit 0