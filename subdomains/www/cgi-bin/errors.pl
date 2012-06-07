#!/usr/bin/perl --

# January 23, 2012

#      errors.pl  - Does both error messages and plain messages

# 2012 Jan 23


sub printShadowMsg
{
 local($msg) = $_[0];
 print "<div class=\"shadow\">$msg</div>\n";
}

sub msgHdr
{
 my($msg,$hx) = @_;
 print "<$hx>*** $msg</$hx>\n";
}

sub itemMsg
{
 local($msg) = $_[0];
 print "<p>$msg</p>\n";
}

sub printUserMsg
{
 local($errormsg) = $_[0];
 $errmsg = $errormsg if($errormsg);
 print "<div class=\"error\">*** $errmsg</div>\n";
 &errLogit;
}

sub printUserMsgExit
{
 local($errormsg) = $_[0];
 $errmsg = $errormsg if($errormsg);
 print "<div class=\"error\">*** $errmsg</div>\n";
 &errLogit;
 exit;
}

sub printInvalidExit
{
 my $errormsg = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">***WOA SYSTEM ERROR: PROCESS STOPPED: $errmsg</\div>\n";
 &errLogit;
 exit;
}

sub msgDie
{
 local($errormsg) = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">***WOA SYSTEM ERROR: PROCESS STOPPED: $errmsg</\div>\n";
 &errLogit;
 exit;
}

sub printCompleteExit
{
 local($errormsg) = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">WOA SYSTEM ERROR: $errmsg</div>\n";
 exit;
}

sub printBadContinue
{
 local($errormsg) = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">***WOA SYSTEM ERROR: USAGE ERROR: $errmsg</div>\n";
 &errLogit;
 $errmsg = "";	
}

sub printDataErr_Continue
{
 local($errormsg) = $_[0];
 print "<div class=\"error\">***WOA SYSTEM ERROR: data condition unexpected: $errormsg</div>\n";
 &errLogit;	
 $errmsg = "";
}

sub printSysErrExit
{
 local($errormsg) = $_[0];
 print "<div class=\"error\">***WOA SYSTEM ERROR: - PROCESS STOPPED - $errormsg</div>\n";
 &errLogit;
 exit;
}

1;