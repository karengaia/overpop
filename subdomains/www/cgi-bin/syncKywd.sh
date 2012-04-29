#!/bin/bash

#perlscript to choose which directories and get a password and then system "rsync set of commands"
# call by ... system "rsyncSVR_SpPlex.sh"; <<put the entire set of commands within this!
# type 'crontab -e' at the command line

##export RSYNC_PASSWORD=password

# Configuration
SOURCE=/home/httpd/vhosts/overpopulation.org
DESTHOME=/home/popaware

#refers to the PBP server
SSH=/usr/bin/ssh
PARAMS="--rsh=$SSH -upgtvI --delete"
DESTSERV=popaware@66.92.222.41
DEST=$DESTSERV:$DESTHOME

# keywords
sync $PARAMS \
$SOURCE/httpdocs/autosubmit/keywords * \
$DEST/public_html/autosubmit/keywords