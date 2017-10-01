#!/bin/bash

source /opt/pihole/whiptail.sh
ADD_ENTRY=true
CUSTOM_LIST="/etc/pihole/custom-LAN.list"
title_of_installer="Pi-Hole DNS extender"


# ------------------------------------------------------------------------------

function display_help() {
  echo -e "\nThis script will add or remove a custom DNS entry for local devices.\n"
  echo "The following arguments are allowed:"
  echo -e "\t-a | --add-dns-entry\t\tAdd a custom DNS entry (default argument)."
  echo -e "\t-r | --remove-dns-entry\t\tRemove a custom DNS entry."
  echo -e "\t-l | --list\t\tList your current custom entries."

}

# Test an IP address for validity:
# Usage:
#      if valid_ip IP_ADDRESS; then echo good; else echo bad; fi
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function ask_ip() {
  ip_address=$(w_get_string "${title_of_installer}" "\n\nWhat's the IPv4 address of the device that you want to add?\n" "192.168.1.50")

  if ! valid_ip ${ip_address}
  then
    echo "${ip_address} is not a valid IPv4 address... Exiting now."
    exit 1
  fi
}

function ask_fqdn() {
  fqdn=$(w_get_string "${title_of_installer}" "\n\nWhat's the URL that you want to assign to the local device?\nSpaces will be truncated automatically.\n\n" "movie.server")
  fqdn=$(echo ${fqdn} | tr -d ' ')  # Remove spaces
}

function add_dns_entry() {
  # TODO check for existing url

  # show welcome message
  if ! ( w_ask_yesno "${title_of_installer}" "\n\nThis will add a custom DNS entry to your pi-hole so that you can reach local devices using a readable url (e.g. movie.server).\n\n\nDo you want to continue?" )
  then
    exit 1
  fi

  # get IP address of device
  ask_ip

  # get desired address
  ask_fqdn

  # add entry
  echo "${ip_address} ${fqdn}" >> ${CUSTOM_LIST}

  # reload dnsmasq service
  service dnsmasq restart &

  # Wait for the changes to take effect
  {
    echo 0
    for i in {0..100..5}
    do
      if [ ${i} -eq 95 ]
      then
        echo "Fatal error, you're on your own now!"
        sleep 1
        exit 1
      fi
      if nslookup "${fqdn}" | grep -q ${ip_address}
      then
       echo 100
       sleep 1
       break
      fi
      echo ${i}
    done
  } | w_show_gauge "${title_of_installer}" "\n\nWaiting for the changes to come active..."

  w_show_message "${title_of_installer}" "\n\nYou can now reach your device on http://${fqdn}\nHave fun!"
}

function remove_dns_entry() {
  # show welcome message
  if ! ( w_ask_yesno "${title_of_installer}" "\n\nThis will remove a custom DNS entry from your pi-hole so that you can't reach a certain local devices anymore using a readable url.\n\n\nDo you want to continue?" )
  then
    exit 1
  fi

  # TODO SHOW SCROLLBARS WHEN MANY ENTRIES

  # Get the urls that the user wants to delete
  # This is not in whiptail.sh because it was easier to program it here
  url_array=($(cat ${CUSTOM_LIST} | awk '{print $2;}'))
  number_of_options=$(wc -l < ${CUSTOM_LIST})
  parameters=( --title "${title_of_installer}" --checklist "Select the ones that you want to remove:" ${r_whiptail} ${c_whiptail} ${number_of_options} )
  i=0
  while [[ $i -lt ${#url_array[@]} ]]
  do
    parameters+=( "${url_array[$i]}" "" off )
    i=$[$i+1]
  done
  choices=$(whiptail "${parameters[@]}" 3>&2 2>&1 1>&3)
  # if cancelled, exit
  if [ $? -ne 0 ]; then exit 0; fi

  # check if the custom conf file exists
  if [ -e ${CUSTOM_LIST} ]
  then
    # remove selected entry
    for choice in ${choices}
    do
      choice=$(echo "$choice" | tr -d '"') # removes quotes
      sudo sed -i "/${choice}/d" ${CUSTOM_LIST}
    done
  fi

  # reload dnsmasq service
  service dnsmasq restart &

  w_show_message "${title_of_installer}" "\n\nThe DNS entries have been removed.\nHave fun!"
}






# ------------------------------------------------------------------------------

while [[ $# -ge 1 ]]
do
  key="$1"

  case $key in
      -h|--help)
      display_help true
      exit 0
      ;;
      -a|--add-dns-entry)
      ADD_ENTRY=true
      shift
      ;;
      -r|--remove-dns-entry)
      ADD_ENTRY=false
      shift
      ;;
      -l|--list)
      cat ${CUSTOM_LIST}
      exit 0
      ;;
      --change-host-name)
      change_host_name
      exit O
      ;;
      *)
      echo -e "\nUnknown argument...\n"
      display_help false
      exit 1
      ;;
  esac
done

# Check if root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or use sudo..."
  exit 1
fi

if [ ${ADD_ENTRY} = true ]
then
  add_dns_entry
else
  remove_dns_entry
fi

exit 0
