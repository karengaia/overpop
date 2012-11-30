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
 my $msg = $_[0];
 print "<p>$msg</p>\n";
}

sub printUserMsg
{
 my $errormsg = $_[0];
 $errmsg = $errormsg if($errormsg);
 print "<div class=\"error\">*** $errmsg</div>\n";
 &errLogit;
}

sub printUserMsgExit
{
 my $errormsg = $_[0];
 $errmsg = $errormsg if($errormsg);
 print "<div class=\"error\">*** $errmsg</div>\n";
 &errLogit;
 exit;
}

sub printInvalidExit
{
 my $errormsg = $_[0];
 print "<div class=\"error\">***WOA SYSTEM ERROR: PROCESS STOPPED: $errormsg</\div>\n" if($errormsg);
 &errLogit;
 exit;
}

sub msgDie
{
 my $errormsg = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">***WOA SYSTEM ERROR: PROCESS STOPPED: $errmsg</\div>\n";
 &errLogit;
 exit;
}

sub printCompleteExit
{
 my $errormsg = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">WOA SYSTEM ERROR: $errmsg</div>\n";
 exit;
}

sub printBadContinue
{
 my $errormsg = $_[0];
 $errmsg = $errormsg if($errormsg =~ /[A-Za-z0-9]/);
 print "<div class=\"error\">***WOA SYSTEM ERROR: USAGE ERROR: $errmsg</div>\n";
 &errLogit;
 $errmsg = "";	
}

sub printDataErr_Continue
{
 my $errormsg = $_[0];
 print "<div class=\"error\">***WOA SYSTEM ERROR: data condition unexpected: $errormsg</div>\n";
 &errLogit;	
 $errmsg = "";
}

sub printSysErrExit
{
 my $errormsg = $_[0];
 print "<div class=\"error\">***WOA SYSTEM ERROR: - PROCESS STOPPED - $errormsg</div>\n" if($errormsg);
 &errLogit;
 exit;
}

#       Log errors
sub errLogit
{
# my ($msg,$cmd,$action,$docid,$docaction,$operator_access,$userid,$sectsubname) = @_;
 my $logline = "$todaydate $msg ..cmd $cmd ..action $action ..docid-$docid ..action=$docaction ..user-$operator_access $userid ..SS-$sectsubname ::: @_\n";

 unlink "$errlog_old" if(-f "$errlogold");
 system "cp $errlogpath $errlog_old" if(-f "$errlogold");
 open(ERRLOG, ">>$errlogpath");
 print ERRLOG "$logline<br>\n";
 close(ERRLOG);
 return;
}


1;