#!/usr/bin/perl --

# owner.pl (page owner) 2012 June 29
## called by article.pl

# Also look at A. userid wrong thing passed in query string; 
# /www/cswp/cswp_admin.php  # CSWP admin page accessible by group password.
#   ... various lists available for changing - access update by tiny grey button, taking you to ...
# /www/prepage/viewOwnerUpdate.php


sub init_owner
{
 $OWNER = "";
 $OWNER_DEFAULT = "";

 my $sth_odefault = $dbh->prepare("SELECT otoptemplate,ologintemplate,oupdatetemplate,oreviewtemplate
 FROM owners WHERE owner = 'default';");

 $sth_odefault->execute();
 ($otoptemplate,$ologintemplate,$oupdatetemplate,$oreviewtemplate) = $sth_odefault->fetchrow_array();

 $sth_odefault->finish();
 $OWNER_DEFAULT{'otoptemplate'}    = $otoptemplate;
 $OWNER_DEFAULT{'ologintemplate'}  = $ologintemplate;
 $OWNER_DEFAULT{'oupdatetemplate'} = $oupdatetemplate;
 $OWNER_DEFAULT{'oreviewtemplate'} = $oreviewtemplate;
 return();   # OWNER_ARRAY and OWNER_DEFAULT are already  globals
}

sub get_owner
{
 my $l_owner = $_[0];
 &init_owner;
 my $sth_owner = $dbh->prepare('SELECT ownerlongname, owebsitepath, oSScategory,odefaultSS,ocsspath,ocssformpath,otoptemplate,ologintemplate,oupdatetemplate,oreviewtemplate,ologopath,oftpinfo
 FROM owners WHERE owner = ?;');

 $sth_owner->execute($owner);
 my ($ownerlongname,$owebsitepath,$oSScategory,$odefaultSS,$ocsspath,$ocssformpath,$otoptemplate,$ologintemplate,$oupdatetemplate,$oreviewtemplate,$ologopath,$oftpinfo) = $sth_owner->fetchrow_array();
 $sth_owner->finish();

 $OWNER{'owner'}           = $owner;
 $OWNER{'ownerlongname'}   = $ownerlongname;
 $OWNER{'owebsitepath'}    = $owebsitepath;
 $OWNER{'oSScategory'}     = $oSScategory;
 $OWNER{'oSScategory'}     = trim($oSScategory);
 $OWNER{'odefaultSS'}      = $odefaultSS;
 $OWNER{'ocsspath'}        = $ocsspath;
 $OWNER{'ocssformpath'}    = $ocssformpath;
 $OWNER{'otoptemplate'}    = $otoptemplate if($otoptemplate);
 $OWNER{'ologintemplate'}  = $ologintemplate if($ologintemplate);
 $OWNER{'oupdatetemplate'} = $oupdatetemplate if($oupdatetemplate);
 $OWNER{'oreviewtemplate'} = $oreviewtemplate if($oreviewtemplate);
 $OWNER{'ologopath'}       = $ologopath if($ologopath);
 $OWNER{'oftpinfo'}        = $oftpinfo;

 $OWNER{'otoptemplate'}    = $OWNER_DEFAULT{'otoptemplate'}    unless($otoptemplate);
 $OWNER{'ologintemplate'}  = $OWNER_DEFAULT{'ologintemplate'}  unless(ologintemplate);
 $OWNER{'oupdatetemplate'} = $OWNER_DEFAULT{'oupdatetemplate'} unless(oupdatetemplate);
 $OWNER{'oreviewtemplate'} = $OWNER_DEFAULT{'oreviewtemplate'} unless(oreviewtemplate);
}

sub owner_set_sectsubs
{
 my($ownersSections,$ownerSubs) = @_;
 $OWNER{'ownersections'} = $ownerSections;
 $OWNER{'ownersubs'}     = $ownerSubs;
}


sub owner_set_update_return
{
  my($docid,$thisSectsub,$userid,$owner) = @_; 
	my  $l_docid = $docid;
    $l_docid = "" unless($docid =~ /[0-9]{6}/);
    $oupdatetemplate = $OWNER{'oupdatetemplate'};
    my  $ownerSubs         = $OWNER{'ownersubs'};
    my  $viewOwnerUpdt = "http://$publicUrl/prepage/viewOwnerUpdate.php?$l_docid%$oupdatetemplate%$thisSectsub%$owner%$userid%$ownerSubs";
    my  $metaViewOwnerUpdt = "<meta http-equiv=\"refresh\" content=\"0;url=$viewOwner\">\n";
    $OWNER{'viewOwnerUpdt'} = $viewOwnerUpdt;
    $OWNER{'metaViewOwnerUpdt'} = $metaViewOwnerUpdt;
}

sub create_owners
{   ## Easier to do this on Telavant interface
	$dbh = &db_connect();
	
	dbh->do("DROP TABLE IF EXISTS owners");

$sql = <<OWNERS;
CREATE TABLE owners (owner varchar(8) not null,
  ownerlongname varchar(70) default "",  
  owebsitepath varchar(100) default "", 
  oSScategory varchar(5) default "",
  odefaultSS  varchar(50) default "",
  ocsspath varchar(100) default "",
  otoptemplate varchar(15) default "",
  ologintemplate varchar(15) default "",
  oupdatetemplate varchar(15) default "",
  oreviewtemplate varchar(15) default "",
  ologopath varchar(15) default "",
  oftpinfo varchar(15) default "");
OWNERS

$sth2 = $dbh->do($sql);
}

# article.pl :   
# ---------------- require owner.pl
#... 157
#	$qOrder      = $info[9];
#	$qMobidesk   = $info[10];
#	$qOwner      = $info[11];
#	$owner = $qOwner;
#... 178
#	$thisSectsub = $FORM{thisSectsub};
#	$owner     = $FORM{owner};
# ---- 180 --------- if($owner) {require owner.pl; &get_owner($owner);$o_updt_template = $OWNER{oupdatetemplate};$o_review_template = $OWNER{oreviewtemplate}}
#...205
#	  elsif($cmd eq "display") {  # used to display login, form, template, or docitem 
#	     my $otemplate = 'ownerUpdate';  -------------------  DELETE
#	     if($aTemplate =~ /docUpdate/ or ($owner and $aTemplate =~ /$otemplate/) ) {  ------------ =~ /$o_updt_template/
#...225
#		elsif($cmd eq "processlogin") {
#
#		   if($owner) { 
#		       $aTemplate = "ownerUpdate";  ----------------  $aTemplate = $OWNER{oupdatetemplate};
#		       print "<meta http-equiv=\"refresh\" content=\"0;url=http://$publicUrl/prepage/viewOwnerUpdate.php?$docid%$aTemplate%$thisSectsub%$owner%$userid\"<br>\n";
#			   exit(0); 
#		   }
#... 264
#   elsif($cmd eq "display_section"
#        if($owner) {   # http://overpop/cgi-bin/article.pl?display_section%%%CSWP_Calendar%%%%%%%%CSWP
# ... 336
#   elsif($cmd eq "storeform") {
#   	elsif($owner) {
#	      ($userdata, $access, $permissions) = &check_user($userid,$pin);  ## in contributor.pl
#	      $ownersectsub = $FORM{"ownersectsub"};
# ... 383
#		&storeform;
#		print "<meta http-equiv=\"refresh\" content=\"0;url=http://$publicUrl/prepage/viewSimpleUpate.php?$docid%cswpReview;cswpUpdate%$sectsubs\"<br>\n"
#	--------------print "<meta http-equiv=\"refresh\" content=\"0;url=http://$publicUrl/prepage/viewSimpleUpate.php?$docid%$o_review_template;$o_update_template%$sectsubs\"<br>\n"
#		   if($ipform eq 'cswpUpdate'); --------------  if($owner);
#		 print "<a href=\"http://$publicUrl/prepage/viewOwnerUpdate.php?$docid%cswpUpdate%$sectsubs%$owner\"><br><br></a><br>\n" --- DELETE
#		   if($owner);   -------------------- DELETE
# ... 502     ---------- ADD owner to query string -----------------
#		elsif($cmd eq "display" and ($aTemplate =~ /docUpdate/ or $aTemplate =~ /Update/) {  -----------CHANGE THIS
#		  $owner = $1; ------------- DELETE
#		  $firstname     = "";
#		  $lastname      = "";
#		  $action = "new" unless($action or $docid);
#		  $operator_access = 'A' if($userid =~ /A/);
#		  &display_one('Y',$aTemplate);   #found in docitem.pl  (print_it,template)
# ... 521
#		elsif($cmd eq "display_section"   ------------------ PUT owner in the query string again
#		   if($doclist =~ /(CSWP)/ or $doclist =~ /(MAIDU)/) { -----------  CHANGE TO ------if($owner) {
#			 $owner = lc($1);  ---------------- DELETE
# ...597
#		elsif($cmd =~ /selectItems/) {
#		     $thisSectsub = $FORM{thisSectsub};
#		     $owner       = $FORM{owner}; --------------- DELETE? REDUNDANT? ------------
#...
#		   	    if($owner) {                     -------- CHANGE TO $o_updt_template below
#		 			print "<br><a href=\"http://overpop/prepage/viewOwnerUpdate.php?$docid%ownerUpdate%$thisSectsub%$owner%$userid\">Click here to go to next page</a><br>\n";       }
#			    else {

# selecteditems_crud.pl
#... 147
#	sub prelim_select_items
#...207
#		print "<html xmlns=\"http://www.w3.org/1999/xhtml\" ><head><title>$owner action on selected items $thisSectsub<\/title>\n";
#		 print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" />\n";
#         ------------------ $aTemplate = $OWNER{oupdatetemplate}; $ownerformcss = $OWNER{ocsspath};
#		 my $lc_owner = lc($owner);
#		 $aTemplate = $lc_owner . "Update";
#            ------------------- CHANGE BELOW TO print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/css/$ownerformcss\" media=\"Screen\" />\n" 
#		print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/css/ownerform.css\" media=\"Screen\" />\n" 
#		  if($owner);

# docitem.pl
#.. 138
#  sub storeform
#.. 165
#	if($owner) {
#	  &print_review('ownerReview');   -------------- $o_review = $OWNER{oreviewtemplate};&print_review($o_review);
#..
#  sub get_doc_form_values
#.. 736
#      $owner          = $FORM{"owner$pgitemcnt"}; ---------- ADD &get_owner($owner);
#..757 $ownersectsub     = $FORM{"ownersectsub$pgitemcnt"};
#  $sectsubs = 'CSWP_Calendar' if($sectsubs =~ /CSWP_event/ or $ownersectsub =~ /CSWP_event/); #fix a problem
#.. 1061
#  sub put_data_to_array
#      $DOCARRAY{owner}          = $owner;
#.. 1204
#  sub write_doc_data_out
#      &titlize_headline if( ($docaction =~ /N/ and !$owner)  or $titlize =~ /Y/);

# sectsubs.pl
#..199
#sub saveNewsSections
#..    --------------------------------- my $oSScategory = $OWNER{oSScategory}; $oSScategory = trim($oSScategory);
#         ------------------------------- $cCategory = trim($cCategory);
#------------ ADD THE FOLLOWING to common.pl :
#sub trim
#{
#	my $string = shift;
#	$string =~ s/^\s+//;
#	$string =~ s/\s+$//;
#	return $string;
#}  ---------------------- 
#  elsif($cCategory eq 'c') {   ---------------- elsif($cCategory eq $oSScategory) {
	
#---------	or ($cCategory eq $oSScategory and $ownerchg eq 'Y' and $ownerprocsectsub !~ /$sectsubname/) ## NO $ownerchg or $ownerprocsectsub FOUND
    
# --- 210
#	if($cswpSections) {         ---------------- if($ownerSections) {
#	   $cswpSections .= '|'.$cSectsubid; -------    $cswpSections .= '|'.$cSectsubid;
#   }
#    else {
#	   $cswpSections .= $cSectsubid;   ---------   $ownerSections .= $cSectsubid;
#   }
#  } --------------- DELETE THE FOLLOWING ----------
#  elsif($cCategory eq 'm') {
#	if($maiduSections) {
#	   $maiduSections .= '|'.$cSectsubid;
#    }
#    else {
#	   $maiduSections .= $cSectsubid;
#    }
#..
#.. 229 
# sub do_sectsubs
#..			
#	 if($docaction ne 'N' and $sectsubs !~ /$thisSectsub/ and !$newsprocsectsub and !$pointssectsub and !$ownersectsub) {
#	      $sectsubs = "$sectsubs;$thisSectsub`M";
#..534
#	sub delete_sectsubs
#	{
#	##          current sectsubs
#	 my @sectsubs = split(/;/,$sectsubs);
#	 foreach $xsectsub (@sectsubs) {
#	   my $sectsub = $xsectsub;
#	   last if(!$sectsub);
#
#	   my($sectsubname,$subinfo) = split(/`/, $sectsub);
#	   &split_section_ctrlB($sectsubname);    # get $cCategory
#	   if(($cmd eq "storeform" and $updsectsubs !~ /$sectsubname/ 
#	           and $newsSections !~ /$sectsubname/ and $cswpSections !~ /$sectsubname/ and $maiduSections !~ /$sectsubname/)
#	 ----- CHANGE THE ABOVE TO ---  and $newsSections !~ /$sectsubname/ and $ownerSections !~ /$sectsubname/)
#.. 960
# sub get_owner_sections
#		{
#		  my $ownerSections = $_[0];
#		  my $expSections = "$ownerSections|$deleteSS";
#		  my (@xsects) = split(/\|/,$expSections); 
#		  my $currentSS = "";
#		  my $docloc = "";
#---------------  my $ownerDefaultSS = $OWNER{odefaultSS};
#		  $ownerDefaultSS = "CWSP_Calendar";  -------------- DELETE
#		  $dSectsubs = $ownerDefaultSS unless($dSectsubs);
#		  foreach $xsect (@xsects) {
#		    $xsect =~ s/`+$//;  #get rid of trailing tic marks
#		    if($dSectsubs =~ /$xsect/ or $xsect =~ /$dSectsubs/ or $dSectsubs eq $xsect) {	
#			   $selected = "selected";
#			   $currentSS = $xsect;
#			} # end if
#			my $option = $xsect;
#			$option = 'Deleted' if($xsect =~ /delete/);
#			print MIDTEMPL "<option value=\"$xsect\" $selected >$option</option>\n";
#			$selected = "";
#
#		  } # end outer foreach
#
#		  if($currentSS and $action ne 'new' and $lifonum and $lifonum > 0) {
#			  $SSid = &get_SSid($currentSS);
#			  my($docloc,$lifonum) = &DB_get_lifo_stratus($SSid,$docid); #For now we won't use stratus; later move this up to do docloc
#		      print MIDTEMPL "<cite class=\"verdana\">Change <b>LIFOnum</b>&nbsp; <\/cite><input type=\"text\" name=\"lifonum_$currentSS\" value=\"$lifonum\" size=\"6\" maxlength=\"10\"><br>\n";
#		      print MIDTEMPL "<cite>Cannot change Lifonum if changing CSWP Section above</cite><br>\n";
#		  }
#		}


# template_ctrl.pl .. sub do_redarrow
#     $link = "<a class=\"tinyimg\" href=\"http://$scriptpath/article.pl?display%ownerlogin%$docid%$sectsubs%%$userid%%%%%%$owner\">";
#... 656
#	elsif($linecmd =~ /\[CSWPDOCLINK\]/) {   # can get rid of this one
#		  print MIDTEMPL "<a href=\"http://$scriptpath/article.pl?display%cswplogin%$docid%$sectsubs\">$docid</a>";
#	}
#	elsif($linecmd =~ /\[OWNERDOCLINK\]/) {
#		  my $lc_owner = lc($owner);  ------------------
#		  print MIDTEMPL "<a href=\"http://$scriptpath/article.pl?display%$lc_owner" . "login%$docid%$qSectsub\">$docid</a>";
#	}
#	elsif($linecmd =~ /\[OWNERCHANGEADD\]/) {
#		  if(!$docid) {
#			print MIDTEMPL "Add new item";
#			print MIDTEMPL "<input name=\"action\" type=\"hidden\" value=\"new\" > Change item below or ";
#		  }
#...
#	elsif($linecmd =~ /\[OWNER_CSS\]/) {
#		  my $owner_css = "";  -----------------
#		  $owner_css = "http://motherlode.sierraclub.org/population/css/cswp.css" if($owner = "CSWP");
#		  print MIDTEMPL "$owner_css";
#...
#	elsif($linecmd =~ /\[OWNER_SECTIONS\]/) {  # CSWP and Maidu
#	      &get_owner_sections($cswpSections)  if($owner =~ /CSWP/);   # in sectsubs.pl ---------
#	      &get_owner_sections($maiduSections) if($owner =~ /Maidu/);  # in sectsubs.pl


1;

