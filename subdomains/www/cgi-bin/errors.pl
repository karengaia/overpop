#!/usr/bin/perl --

# January 23, 2012

#      errors.pl

# 2012 Jan 23


sub printShadowMsg
{
 local($msg) = $_[0];
 print "<div class=\"shadow\">$msg</div>\n";
}

sub printUserMsgExit
{
 local($errormsg) = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">*** $errmsg</div>\n";
 &errLogit;
 exit;
}

sub printInvalidExit
{
 local($errormsg) = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">***AUTOSUBMIT: PROCESS STOPPED: $errmsg</\div>\n";
 &errLogit;
 exit;
}

sub msgDie
{
 local($errormsg) = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">***AUTOSUBMIT: PROCESS STOPPED: $errmsg</\div>\n";
 &errLogit;
 exit;
}

sub printCompleteExit
{
 local($errormsg) = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">AUTOSUBMIT: $errmsg</div>\n";
 exit;
}

sub printBadContinue
{
 local($errormsg) = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">***AUTOSUBMIT: USAGE ERROR: $errmsg</div>\n";
 &errLogit;
 $errmsg = "";	
}

sub printDataErr_Continue
{
 local($errormsg) = $_[0];
 print "<div class=\"error\">***AUTOSUBMIT: data condition unexpected: $errormsg</div>\n";
 &errLogit;	
 $errmsg = "";
}

sub printSysErrExit
{
 local($errormsg) = $_[0];
 print "<div class=\"error\">***AUTOSUBMIT SYSTEM ERROR - PROCESS STOPPED - $errormsg</div>\n";
 &errLogit;
 exit;
}

1;