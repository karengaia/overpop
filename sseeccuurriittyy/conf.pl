#!/usr/bin/perl --

# This script is disguised by its name and put in an inaccessible folder
# The DB password has been stored in the server variable QUACK
# It is encrypted using the Salt 'Say the Secret Word'
# And then stored in the ENV variable DB_PASS, which will revert to its 
#   former value after this session
# Then we connect to the database using this encrypted password.
# A dummy password is passed but we will not use it.
# First we must determine the encrypted password and change the DB password

# In overpopulation.org/security folder

sub config {
local @DB = @_;
$DB{'pswd'} = crypt('fr00tfl1','Say the Secret Word');
return(@DB);
}  

1;