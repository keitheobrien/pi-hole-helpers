#!/bin/bash

# Check if root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or use sudo..."
  exit 1
fi

# see if pi-hole dir exists
if ! [ -e /opt/pihole/ ]
then
  echo "Directory '/opt/pihole/' does not exist. Please install the latest version of pi-hole first."
  exit 1
fi

# get and save the scripts
wget -O /opt/pihole/whiptail.sh https://raw.githubusercontent.com/Kevin-De-Koninck/pi-hole-helpers/master/whiptail.sh
wget -O /opt/pihole/pihole-helper.sh https://raw.githubusercontent.com/Kevin-De-Koninck/pi-hole-helpers/master/pihole-helper.sh

# Make 'em executable
chmod +x /opt/pihole/whiptail.sh
chmod +x /opt/pihole/pihole-helper.sh

# register command
USER=$(who am i | awk '{print $1}')
echo "" >> /home/${USER}/.bashrc
echo "alias sudo='sudo '" >> /home/${USER}/.bashrc
echo "" >> /home/${USER}/.bashrc
echo "# Register pihole-helper to easily add a custom DNS entry" >> /home/${USER}/.bashrc
echo "alias pihole-helper='/opt/pihole/pihole-helper.sh'" >> /home/${USER}/.bashrc
echo "" >> /home/${USER}/.bashrc

# reload bashrc
source /home/${USER}/.bashrc

# Inform the user
echo "--------------------------------------------------------------------------"
echo ""
echo "PLEASE RUN 'source ~/.bashrc' IN YOUR TERMINAL TO SYNC EVERYTHING."
echo ""
echo "You can now use the 'pihole-helper' command to add custom DNS entries."
echo "Use 'pihole-helper -h' to view your options."
echo ""


exit 0
