#!/bin/bash

ssh zsroot@20.63.40.175

# Install NSS Certificate
sudo nss install-cert NssCertificate.zip

# Check the default Gateway
netstat -rn

# Configure NSS Settings
sudo nss configure

# Need to configure Name Servers
# Need to Output the IP Address and Mask of the Service Interface [Zscaler-NSS-SRVC-NIC]
nameserver:168.63.129.16 (Options <c:change, d:delete, n:no change>) [n]n
Do you wish to add a new nameserver? <n:no y:yes> [n]: n

# Provide Service interface IP address with netmask
smnet_dev (Service interface IP address with netmask) []: 192.168.100.4/24

# Provide Service interface default gateway IP address
smnet_dflt_gw (Service interface default gateway IP address) []: 192.168.100.1

echo "Successfully Applied Changes"

# Download NSS Binaries
sudo nss update-now
 echo "Connecting to server..."
 echo "Downloading latest version" # Wait until system echo back the next message
 echo "Installing build /sc/smcdsc/nss_upgrade.sh" # Wait until system echo back the next message
 echo "Finished installation!"

 # Check NSS Version
sudo nss checkversion

# Enable the NSS to start automatically
sudo nss enable-autostart
echo "Auto-start of NSS enabled "

# Start NSS Service
sudo nss start
echo "NSS service running with pid 1700"

$url = "https://raw.githubusercontent.com/willguibr/nss-azure-deploy/main/azuredeploy.json"
[uri]::EscapeDataString($url)