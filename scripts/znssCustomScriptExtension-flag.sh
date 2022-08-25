#!/bin/sh -e

while getopts g: flag
do

    case "${flag}" in

        g) smnet_dflt_gw=${OPTARG};;

        ?) echo "script usage: [-g] the default gateway value";exit 1;;
    esac
done

echo "default gateway value is : $smnet_dflt_gw"

sleep 10

echo "Initiating ZSOS configuration"
echo "Create dependency file"
sudo touch /sc/conf/sc.conf
#checking
if [ $? -eq 0 ]; then
   echo dependency file created.
else
   echo FAIL
   exit 1
fi

# Install NSS Certificate
if ! [ -f "NssCertificate.zip" ]; then
    echo "The file NssCertificate.zip was not found."
    echo "Put this script in the same path where NssCertificate.zip is."
    echo "And run it again."
    exit 1
fi

echo "Installing Certificate"
sudo /sc/update/nss install-cert NssCertificate.zip
#checking
if [ $? -eq 0 ]; then
   echo certificate installed.
else
   echo FAIL installing certificates 
   exit 1
fi
# Get private ip and subnet mask for Service Interface
SMNET_IP=$(curl -H Metadata:true --silent "http://169.254.169.254/metadata/instance/network/interface/1/ipv4/ipAddress/0/privateIpAddress?api-version=2021-12-13&format=text")
SMNET_MASK=$(curl -H Metadata:true --silent "http://169.254.169.254/metadata/instance/network/interface/1/ipv4/subnet/0/prefix?api-version=2021-12-13&format=text")

# NSS Service Interface and Default Gateway IP Configuration
echo "Set IP Service Interface IP Address and Default Gateway"
smnet_dflt_gw=$smnet_dflt_gw
sudo /sc/update/nss configure --cliinput ${SMNET_IP}"/"${SMNET_MASK},${smnet_dflt_gw}
#checking
if [ $? -eq 0 ]; then
   echo Set IP Service Done.
else
   echo FAIL setting ip services
   exit 1
fi

# Updading FreeBSD.conf Packages
echo "Updading FreeBSD.conf Packages"
mkdir -p /usr/local/etc/pkg/repos
#checking
if [ $? -eq 0 ]; then
   echo  /usr/local/etc/pkg/repos Created.
else
   echo FAILED creating /usr/local/etc/pkg/repos
   exit 1
fi
echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
#checking
if [ $? -eq 0 ]; then
   echo  FreeBSD enabled: no Done.
else
   echo FAILED Disabling freeBSD
   exit 1
fi
echo "FreeBSD: { url: "http://13.66.198.11/FreeBSD:11:amd64/latest/", enabled: yes}" > /usr/local/etc/pkg/repos/FreeBSD.conf
#checking
if [ $? -eq 0 ]; then
   echo  Done setting FreeBSD URL .
else
   echo FAILED setting FreeBSD URL
   exit 1
fi
pkg update && pkg check -d -y
#checking
if [ $? -eq 0 ]; then
   echo  Update Done.
else
   echo FAILED Updating packages
   exit 1
fi
mkdir /sc/build/24pkg-update
#checking
if [ $? -eq 0 ]; then
   echo  mkdir /sc/build/24pkg-update Done.
else
   echo FAILED on mkdir /sc/build/24pkg-update
   exit 1
fi

# Download NSS Binaries
sudo /sc/update/nss update-now
#checking
if [ $? -eq 0 ]; then
    echo "Connecting to server..."
    echo "Downloading latest version" # Wait until system echo back the next message
    echo "Installing build /sc/smcdsc/nss_upgrade.sh" # Wait until system echo back the next message
    echo "Finished installation!"
else
   echo FAILED Updating NSS
   exit 1
fi


 #Check NSS Version
sudo /sc/update/nss checkversion
if [ $? -eq 0 ]; then
   echo  version Chcked.
else
   echo FAILED checking version
   exit 1
fi
# Start NSS Service
sudo /sc/update/nss start
#checking
if [ $? -eq 0 ]; then
   echo  NSS service running.
else
   echo FAILED Starting NSS Services
   exit 1
fi


# Enable the NSS to start automatically
sudo /sc/update/nss enable-autostart
#checking
if [ $? -eq 0 ]; then
   echo "Auto-start of NSS enabled "
else
   echo FAILED Auto Starting NSS
   exit 1
fi
# Dump all Important Configuration
sudo mkdir nss_dump_config
sudo netstat -r > nss_dump_config/nss_netstat.log
sudo /sc/update/nss dump-config > nss_dump_config/nss_dump_config.log
sudo /sc/update/nss checkversion > nss_dump_config/nss_checkversion.log
sudo /sc/update/nss troubleshoot netstat|grep tcp > nss_dump_config/nss_netstat_grep_tcp.log
sudo /sc/update/nss test-firewall > nss_dump_config/nss_test_firewall.log
sudo /sc/update/nss troubleshoot netstat > nss_dump_config/nss_troubleshoot_netstat.log
sudo /sc/bin/smmgr -ys smnet=ifconfig > nss_dump_config/nss_smnet_ifconfig.log
cat /sc/conf/sc.conf | egrep "smnet_dev|smnet_dflt_gw" > nss_dump_config/nss_dump_config.log

exit 0
