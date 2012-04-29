#!/usr/bin/perl --

# July 26, 2011

#copied from 123webmaster.com/perlcookies2.shtml
#
# This routine takes (name,value,minutes_to_live,path,domain) as arguments
# to set a cookie.
#
# 0 minutes means a current browser session cookie life
#
sub set_cookie() {

  my ($name,$value,$expires,$path,$domain) = @_;

  $name=&cookie_scrub($name);
  $value=&cookie_scrub($value);

  $expires=$expires * 60;

  my $expire_at=&cookie_date($expires);
  my $namevalue="$name=$value";

  my $COOKIE="";

print "cookie name $name value $value ..expire_at $expire_at
  if ($expires != 0) {
     $COOKIE= "Set-Cookie: $namevalue; expires=$expire_at; " or die;
  }
   else {
     $COOKIE= "Set-Cookie: $namevalue; ";   #current session cookie if 0
   }
  if ($path ne ""){
     $COOKIE .= "path=$path; ";
  }
  if ($domain ne ""){
     $COOKIE .= "domain=$domain; ";
  }

  return $COOKIE;
}

#
# This routine removes cookie of (name) by setting the expiration
# to a date/time GMT of (now - 24hours)
#
sub remove_cookie() {

  my ($name,$path,$domain) = @_;

  $name=&cookie_scrub($name);
  my $value="";
  my $expire_at=&cookie_date(-86400);
  my $namevalue="$name=$value";

  my $COOKIE= "Set-Cookie: $namevalue; expires=$expire_at; ";
  if ($path ne ""){
     $COOKIE .= "path=$path; ";
  }
  if ($domain ne ""){
     $COOKIE .= "domain=$domain; ";
  }

  return $COOKIE;
}


#
# given a cookie name, this routine returns the value component
# of the name=value pair
#
sub get_cookie() {

  my ($name) = @_;

  $name=&cookie_scrub($name);
  my $temp=$ENV{'HTTP_COOKIE'};
  @pairs=split(/\; /,$temp);
  foreach my $sets (@pairs) {
    my ($key,$value)=split(/=/,$sets);
    $clist{$key} = $value;
  }
  my $retval=$clist{$name};

  return $retval;
}

#
# this routine accepts the number of seconds to add to the server
# time to calculate the expiration string for the cookie. Cookie
# time is ALWAYS GMT!
#
sub cookie_date() {

  my ($seconds) = @_;

  my %mn = ('Jan','01', 'Feb','02', 'Mar','03', 'Apr','04',
            'May','05', 'Jun','06', 'Jul','07', 'Aug','08',
            'Sep','09', 'Oct','10', 'Nov','11', 'Dec','12' );
  my $sydate=gmtime(time+$seconds);
  my ($day, $month, $num, $time, $year) = split(/\s+/,$sydate);
  my    $zl=length($num);
  if ($zl == 1) { 
    $num = "0$num";
  }

  my $retdate="$day $num-$month-$year $time GMT";

  return $retdate;
}


#
# don't allow = or ; as valid elements of name or data
#
sub cookie_scrub() {

  my($retval) = @_;

  $retval=~s/\;//;
  $retval=~s/\=//;

  return $retval;
}


# usual kluge so require does not fail....

     my $XyZ=1;
1;