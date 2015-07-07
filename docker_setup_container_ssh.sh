#!/bin/bash
echo "This script will fetch YOUR ssh public key and set it up so you can log in as ROOT in the container."
echo "it simply copies your public key into the authorized_keys file in this project, which is then copied "
echo "into the docker container. You can add more than one authorized key manually, if you want. If you lack "
echo "an ssh key, one will be generated for you with ssh-keygen and then copied into the authorized_keys file"
echo "e.g. logged in as user you can issue a command such as ssh root@172.xxx.yyy.zzz and attach to the container"
echo "as root. Note that SSH is not recommended for production containers but can be handy for development containers"
echo ""
echo ""
echo ""
echo ""
sleep 5 


get_ssh_pub_key() {
  local ${ssh_key_locations}
  ssh_key_locations=(
    ~/.ssh/id_ed25519.pub
    ~/.ssh/id_ecdsa.pub
    ~/.ssh/id_rsa.pub
    ~/.ssh/id_dsa.pub
    ~core/.ssh/authorized_keys
  )

  local $keyfile
  for keyfile in "${ssh_key_locations[@]}"; do
    if [[ -e ${keyfile} ]] ; then
      ssh_pub_key="$(cat ${keyfile})"
      if [[ -e authorized_keys ]] ; then 
        echo "Warning -- this script sets up authorized_keys for the container, and authorized_keys already exists; one usually only needs to run this command once."
	echo "Ctrl-C to abort and examine the authorized_keys file to be sure you aren't adding unneeded duplicate keys" 
        sleep 5 
      fi
      echo $ssh_pub_key >> authorized_keys
      return 0
    fi
  done

  if tty -s ; then
    echo "This user has no SSH key, but a SSH key is required to access the Discourse Docker container."
    read -p "Generate a SSH key? (Y/n) " -n 1 -r
    if [[ $REPLY =~ ^[Nn]$ ]] ; then
      echo
      echo WARNING: You may not be able to log in to your container.
      echo
    else
      echo
      echo Generating SSH key
      mkdir -p ~/.ssh && ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
      echo
      ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)"
      echo $ssh_pub_key >> authorized_keys
      return 0
    fi
  fi

  return 1
}
if [[ -e ${keyfile} ]] ; then 
      echo "Warning -- authorized_keys already exists; you usually only need to run this command once."
      sleep 5 
fi
get_ssh_pub_key
