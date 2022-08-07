#!/bin/sh -e

sleep 10

echo "Initiating ZSOS configuration"
echo "Create dependency file"
sudo touch /sc/conf/sc.conf

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
# Parameters passed by user input via ARM Template
echo "Set IP Service Interface IP Address and Default Gateway"
smnet_dev=${SMNET_IPMASK}
smnet_dflt_gw=${SMNET_GW}
sudo nss configure --cliinput ${SMNET_IPMASK},${SMNET_GW}
echo "Successfully Applied Changes"

# Updading FreeBSD.conf Packages
echo "Updading FreeBSD.conf Packages"
sudo mkdir -p /usr/local/etc/pkg/repos
echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
echo "FreeBSD: { url: "http://13.66.198.11/FreeBSD:11:amd64/latest/", enabled: yes}" > /usr/local/etc/pkg/repos/FreeBSD.conf
sudo pkg update && pkg check -d -y
sudo mkdir /sc/build/24pkg-update

# Download NSS Binaries
sudo nss force-update-now
echo "Connecting to server..."
echo "Downloading latest version" # Wait until system echo back the next message
echo "Installing build /sc/smcdsc/nss_upgrade.sh" # Wait until system echo back the next message
echo "Finished installation!"

 #Check NSS Version
sudo nss checkversion

# Start NSS Service
sudo nss start
echo "NSS service running."

# Enable the NSS to start automatically
sudo nss enable-autostart
echo "Auto-start of NSS enabled "

# Dump all Important Configuration
mkdir nss_dump_config
sudo netstat -r > nss_dump_config/nss_netstat.log
sudo nss dump-config > nss_dump_config/nss_dump_config.log
sudo nss checkversion > nss_dump_config/nss_checkversion.log
sudo nss troubleshoot netstat|grep tcp > nss_dump_config/nss_netstat_grep_tcp.log
sudo nss test-firewall > nss_dump_config/nss_test_firewall.log
sudo nss troubleshoot netstat > nss_dump_config/nss_troubleshoot_netstat.log
/sc/bin/smmgr -ys smnet=ifconfig > nss_dump_config/nss_smnet_ifconfig.log
cat /sc/conf/sc.conf | egrep "smnet_dev|smnet_dflt_gw" > nss_dump_config/nss_dump_config.log

# Upload NSS Dump Config to S3 Bucket
aws s3 nss_dump_config s3://example-38818791f97e2ed9/content/ --recursive
echo "Upload Successfully Complete"

exit 0
