#!/bin/sh -e

while getopts g: flag
do

    case "${flag}" in

        g) smnet_dflt_gw=${OPTARG};;

        ?) echo "script usage: [-g] the default gateway value";exit 1;;
    esac
done

echo "default gateway value is : $smnet_dflt_gw"

$PATH = /sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/home/zsroot/bin:/sc/update
sleep 10
echo $PATH

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
# Get private ip and subnet mask for Service Interface
SMNET_IP=$(curl -H Metadata:true --silent "http://169.254.169.254/metadata/instance/network/interface/1/ipv4/ipAddress/0/privateIpAddress?api-version=2021-12-13&format=text")
SMNET_MASK=$(curl -H Metadata:true --silent "http://169.254.169.254/metadata/instance/network/interface/1/ipv4/subnet/0/prefix?api-version=2021-12-13&format=text")

# NSS Service Interface and Default Gateway IP Configuration
echo "Set IP Service Interface IP Address and Default Gateway"
smnet_dflt_gw=$smnet_dflt_gw
sudo nss configure --cliinput ${SMNET_IP}"/"${SMNET_MASK},${smnet_dflt_gw}


# Updading FreeBSD.conf Packages
echo "Updading FreeBSD.conf Packages"
mkdir -p /usr/local/etc/pkg/repos
echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
echo "FreeBSD: { url: "http://13.66.198.11/FreeBSD:11:amd64/latest/", enabled: yes}" > /usr/local/etc/pkg/repos/FreeBSD.conf
pkg update && pkg check -d -y
mkdir /sc/build/24pkg-update

# Download NSS Binaries
sudo nss update-now
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
sudo mkdir nss_dump_config
sudo netstat -r > nss_dump_config/nss_netstat.log
sudo nss dump-config > nss_dump_config/nss_dump_config.log
sudo nss checkversion > nss_dump_config/nss_checkversion.log
sudo nss troubleshoot netstat|grep tcp > nss_dump_config/nss_netstat_grep_tcp.log
sudo nss test-firewall > nss_dump_config/nss_test_firewall.log
sudo nss troubleshoot netstat > nss_dump_config/nss_troubleshoot_netstat.log
sudo /sc/bin/smmgr -ys smnet=ifconfig > nss_dump_config/nss_smnet_ifconfig.log
cat /sc/conf/sc.conf | egrep "smnet_dev|smnet_dflt_gw" > nss_dump_config/nss_dump_config.log

exit 0
