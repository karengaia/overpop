#!/usr/bin/perl --

##     OBSOLETE - NOT USED

# misc_dbtables.pl    - renamed from dbtables.pl  - then moved to dbtables.ctrl
# Contains code to parse the miscellaneous tables: acronyms, switches_codes, counters, codes, projects

## called by article.pl and parsedata.pl and docitem.pl??

## 2011 Jan - Separated out Sources.pl and Regions.pl
## 2010 Jul    - Merged in changes neglected from May 7th change
## 2010 May 7 -- Check for Mac server (testing) and chmod to 777

# Hit counter all in SQL  an example:
#create table ipstat(ip int unsigned not null primary key,
#                          hits int unsigned not null,
#                          last_hit timestamp);

#insert into ipstat values(inet_aton('192.168.0.1'),1,now())
#                       on duplicate key update hits=hits+1;




1;

