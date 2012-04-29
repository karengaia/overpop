#!/bin/sh

##export RSYNC_PASSWORD=password
## options, another choice: -upgtvI or -lptgoD (-rlptgoD same as -a) -d --exclude='*/'

ARG1=$1
ARG2=$2

RSH=--rsh=/usr/bin/ssh
options_r="$RSH -rlptgoD --delete-after --progress"
options="$RSH -lptgoD --progress"
## skip subdirectories and their contents
options_d="$RSH -dlptgoD --exclude='*/' --progress"
options_dd="$RSH -dlptgoD --exclude='*/' --delete-after --progress"
## try -a to preserve permissions


if [ $ARG1 == tel2mac ]; then

SRCHOME=/home/overpop/www/overpopulation.org
SRCSRVR=overpop@shell.telavant.com
SRC=$SRCSRVR:$SRCHOME
DEST=/Users/karenpitts/Sites/web/www/overpopulation.org


elif [  $ARG1 == mac2tel ]; then

SRC=/Users/karenpitts/Sites/web/www/overpopulation.org
DESTSRVR=overpop@shell.telavant.com
DESTHOME=/home/overpop/www/overpopulation.org
DEST=$DESTSRVR:$DESTHOME

else
   echo "Error: Arg1 is neither 'tel2mac' nor 'mac2tel : $Arg1'; quitting"
fi

echo "options $options options_d $options_dd"
echo "src $SRC"
echo "dest $DEST"

if [ $ARG2 == data ]; then

# ovrpop.org --- test www
#echo "syncing 'ovrpop.org'"
#echo "  testrsync"
#rsync $options_dd $SRC/testrsync/ $DEST/testrsync/

# popnewsmail www
echo "syncing 'root'---"
echo "  popnews_mail"
rsync $options_dd $SRC/popnews_mail/ $DEST/popnews_mail/

echo "syncing www (public)"
rsync $options_d $SRC/subdomains/www/ $DEST/subdomains/www/ 

# www subdirs
echo "syncing 'www' subdirs---"
echo "  popnews_sepmail/"
rsync $options_dd $SRC/subdomains/www/popnews_sepmail/ $DEST/subdomains/www/popnews_sepmail/ 
echo "  popnews_nodupmail/"
rsync $options_dd $SRC/subdomains/www/popnews_nodupmail/ $DEST/subdomains/www/popnews_nodupmail/ 
echo "  counter/"
##      exclude program files, include only count files
rsync $options_d $SRC/subdomains/www/counter/*.txt $DEST/subdomains/www/counter/ 
echo "  counter/mailto.php/"
rsync $options_d $SRC/subdomains/www/counter/mailto.php $DEST/subdomains/www/counter/

# autosubmit subdirs
echo "syncing 'autosubmit' subdirs---"
for sub in deleted sections items itemsSave popnews prepage
do
  echo "  $sub/"
  rsync $options_dd $SRC/subdomains/www/autosubmit/$sub/ $DEST/subdomains/www/autosubmit/$sub/ 
done

echo "   control/"
rsync $options_dd $SRC/subdomains/www/autosubmit/control/ $DEST/subdomains/www/autosubmit/control/

else
   echo "Error: Arg2 is not 'data' : $ARG2 : quitting"
fi
