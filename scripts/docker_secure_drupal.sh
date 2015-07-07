#!/bin/bash
# * * *
# This file follows Drupal best-practices and secures the Drupal installation
# It assigns the file owner to root, but you can alter the owner here if you desire.
# Remember that the user context here is meant to be inside a container, so you may
# have to be sure the user exists in the container. 
#
#
DPATH=$1 

if [ -d "${DPATH}" ] ; then 
     echo "Setting permissions on $DPATH ...";
     chown -R root:www-data "$DPATH"
     find "$DPATH" -type d -exec chmod u=rwx,g=rx,o= '{}' \;
     find "$DPATH" -type f -exec chmod u=rw,g=r,o= '{}' \;

     echo "Allowing www-data user permissions to files directory.";
     for d in "$DPATH/sites/*/files"
	do
         find $d -type d -exec chmod ug=rwx,o= '{}' \;
         find $d -type f -exec chmod ug=rw,o= '{}' \;
     done     
     exit 0     
else 
  echo "The argument [ ${DPATH} ] is not a valid directory. Usage: ";
  echo " $0 <directory to be secured> ";
  exit 1
fi
