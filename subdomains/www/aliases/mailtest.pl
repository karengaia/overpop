#!/usr/bin/perl

# Script to just test functionality from sendmail.
open(MAIL, "|/usr/sbin/sendmail -t");
print(MAIL"To: darkmoon\@lunamorena.net\n");
print(MAIL"From: darkmoon\@gaia-s.net\n");
print(MAIL"Subject: Test Successful\n\n");
print(MAIL"Mail was sent to mailtest\@gaia-s.net.\n");
close(MAIL);
