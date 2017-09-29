#!/bin/bash

# Check if root
#if [ "$EUID" -ne 0 ]
#  then echo "Please run as root or use sudo..."
#  exit 1
#fi

# see if pi-hole dir exists
if ! [ -e /opt/pihole/ ]
then
  echo "Directory '/opt/pihole/' does not exist. Please install the latest version of pi-hole first."
  exit 1
fi

# get and save the scripts
wget -O /opt/pihole/whiptail.sh url_here # TODO
wget -O /opt/pihole/pihole-helper.sh url_here # TODO

# Make 'em executable
chmod +X /opt/pihole/whiptail.sh
chmod +X /opt/pihole/pihole-helper.sh

# register command
echo "# Register pihole-helper to easily add a custom DNS entry" >> ~/.bashrc
echo "alias pihole-helper='/opt/pihole/pihole-helper.sh'"

# reload bashrc
source ~/.bashrc

# Inform the user
echo ""
echo "You can now use the 'pihole-helper' command to add custom DNS entries."
echo "Use 'pihole-helper -h' to view your options."
echo ""

exit 0
