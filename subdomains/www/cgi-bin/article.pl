#!/usr/bin/perl --

# February 2014
#        article.pl  : controller for autosubmit; entry point for almost all perl programs
#                      exceptions: move.pl getmail.pl

##  Must be escaped in regex:    \ . ^ $ * + ? { } [ ] ( ) | and ; (?) see http://perldoc.perl.org/perlrequick.html for more

## Polish notation: (try to do more of this)
## g =global, l=local, f=form, q=query d=document (Use Camel notation i.e. gTidytops)

## CHANGE LOG (for all perl scripts)#######################

## 2012 Mar - enhanced smartdata.pl to better parse popnews in; added headlines_priority;
##             eliminated sections.pl (goes to sectsubs.pl and indexes.pl); also db_controlfiles.pl and
##               controlfiles.pl; Added smartdata.pl and date.pl
## 2011 Nov    - pulled out template_ctrl.pl and display.pl; now article.pl is just a controller.

# push @INC, "/www/overpopulation.org/subdomains/www/cgi-bin";  ## telana
# push @INC, "/Users/karenpitts/Sites/web/www/overpopulation.org/subdomains/www/cgi-bin";  #Karens Mac Air

print "Content-type: text/html\n\n";

$args = $_[0];   # In case we do it from the command line
if($args) {
  my @args = split(/,/,$args);
  my $cmd  = $args[0];
}

require './bootstrap.pl';
$DBH = $dbh;
require 'common.pl';        # sets up environment and paths; also has some common routines
require 'database.pl';      # basic database functions
require 'date.pl';          # parses and processes date data in docitems
require 'errors.pl';        # error display and termination or return
require 'counters-switches.pl';
require 'dbtables_ctrl.pl'; # maintains and retrieves miscellaneous tables: acronyms, switches_codes, list_imports_export links
require 'intake.pl';        # separates articles in email and removes email headers.
require 'display_list.pl';  # takes sectsub info for a particular section or subsection and uses it to create a page with html
require 'template_ctrl.pl'; # merges data with template; processes template commands for what to do with data.
require 'sectsubs.pl';      # maintains and retrieves sections (sectsubs) control data.
require 'indexes.pl';       # maintains and retrieves indexes control data. Indexes are lists of docitem ids; each list represents a subsection
require 'sources.pl';       # maintains and retrieves publisher sources
require 'regions.pl';       # maintains and retrieves region and country data
require 'user.pl';          # maintains, verifies and retrieves user data - base of editor and contributor data
require 'editor.pl';        # maintains, verifies and retrieves editor data
require 'contributor.pl';   # maintains, verifies and retrieves contributor data
require 'docitem.pl';       # maintains and retrieves docitem (article) data; assigns to appropriate subsections
require 'smartdata.pl';     # extension of docitem.pl used to parse data from an email or single textbox form
require 'send_email.pl';   # sends an email
require 'selecteditems_crud.pl'; # processes items selected from a list.

&get_site_info;        ## in common.pl
&set_date_variables;   ## in date.pl
&DB_get_switches_counts;   # in dbtables_ctrl.pl - Sets switches for using database - Yes or No?
&messages_initialize;      # in errors.pl
&clear_sectsubs_variables; # in sectsubs.pl
&init_display_variables;   # in display.pl
&init_paging_variables;    # in display.pl
&init_users;
&init_editors;
&init_contributors;
&init_email;    # in send_email.pl
&init_docitem;  # in docitem.pl

if(-f "debugit.yes") {
  $email_filename = "201102180702-2011-02-18-.email";
  &read_emailItem(2);       ## in docitem.pl
  &parse_popnews_email(2);  ## in docitem.pl
      print "  FROM:: $fromEmail ehandle $ehandle eaccess $eaccess userid $euserid\n";
      print "  SENTDATE:: $sentdate\n";
      print "  SUBJECT:: $subject\n";
      print "  LINK:: $link\n";
      print "  HEADLINE:: $headline\n";
      print "  SOURCE:: $source\n";
      print "  FULLBODY:: $fullbody\n";
      print "  REGIONS:: $region\n";
  exit;
}

elsif($ENV{QUERY_STRING} and $ENV{QUERY_STRING} =~ /%/) {
  @info  = split(/%/,$ENV{QUERY_STRING});
}

elsif($ENV{QUERY_STRING} and $ENV{QUERY_STRING} =~ /&/) {
  @info  = split(/&/,$ENV{QUERY_STRING});
}
else {
	$info[0] = $ENV{QUERY_STRING};
}

if($ENV{QUERY_STRING} or -f 'debugit.yes') {
	##article.pl?0-cmd%1-atemplate%2-docid%3-listSectsub%4-doclist/sectsubid%5-userid/pgnum%6-pgcnt%7-header%8-footer%9-order%10-mobidesk

   $queryString = 'Y';
   $cmd         = $info[0];
   $A{cmd}      = $info[0];
   $aTemplate   = $info[1];
   $qTemplate   = $aTemplate;
   $A{template} = $aTemplate;
   $docid       = $info[2];
   $A{qdocid}   = $docid;
   $fly         = $docid if($docid =~ /[a-zA-Z]/);
   $action      = $docid if($docid =~ /[a-zA-Z]/);
   $A{action}   = $action;
   $qFrom       = $docid;
   $thisSectsub = $info[3];
   $listSectsub = $thisSectsub;
   $info_3      = $info[3];
   $qSectsub    = $thisSectsub;
   $qTo         = $thisSectsub;
   $doclist     = $info[4];
   $L{listname} = $info[4];
   $qPage       = $info[4];
   $acctnum     = $info[5];
   $userid      = $info[5];  ## overlap between userid, acctnum, and start_count
   $A{userid}   = $userid;
   if($info[5] =~ /[0-9]/ and $info[5] !~ /[a-zA-Z]/) {
      $pg_num = $info[5];
   }
   else {
      $pg_num = 1;
   }

   if($info[6] =~ /[0-9]/) {
      $count    = $info[6];
      if($count =~ /:/) {
      	 ($qItemMax,$qPg1max) = split(/:/,$count,2);
      }
      else {
      	 $qItemMax = $count;
      	 $qPg1max = $qItemMax;
      }
   }
   $L{page1max} = $qPg1max;
   $L{page2max} = $qItemMax;
   if($info[7] =~ /prtmove/) {
	 $qPrtmove = 'Y';
   }
   else {
      $qHeader     = $info[7];
   }
   $qFooter       = $info[8];
   $qOrder        = $info[9];
   $L{qlistorder} = $info[9];
   $qMobidesk     = $info[10];
   $qOwner        = $info[11];
   $owner = $qOwner;
   $listnum = $info[12];

# http://overpop/cgi-bin/article.pl?display%ownerlogin%026391%cswp_events%%%%%%%%CSWP
# overpop/cgi-bin/article.pl?display%ownerlogin%026391%cswp_events%%%%%%%%cswp
}

else {
   &parse_form;  #in common.pl

   $cmd       = $FORM{'cmd'};

   $aTemplate = $FORM{'template'};
   if($aTemplate =~ /;/) {
     ($qHeader,$aTemplate,$qFooter) = split(/;/,$aTemplate);
   }
   $action      = $FORM{'action'};
   $A{action}   = $action;
   $docid       = $FORM{'docid'};
   $A{qdocid}   = $docid;
   $userid      = $FORM{'userid'} if $FORM{'userid'};
   $upin        = $FORM{'pin'};
   $ipform      = $FORM{'ipform'};
   $A{ipform}   = $ipform;
   $thisSectsub = $FORM{'thisSectsub'};
   $listSectsub = $thisSectsub;
   $L{listname} = $FORM{'thisSectsub'};
   $owner       = $FORM{'owner'};
}

($userid,$rest) = split(/;/,$userid,2) if($userid =~ /;/);
$A{userid}    = $userid;
$op_userid    = $userid;
$A{op_userid} = $op_userid;
$A{owner}     = $owner;

if($owner) {
  require 'owner.pl';
  &init_owner;
  &get_owner($owner);
  $lc_owner = lc($owner);
  my  $o_updt_template   = $OWNER{'oupdatetemplate'};
  my  $o_review_template = $OWNER{'oreviewtemplate'};
  $ownerSections = "";
  $ownerSubs = "";
}

if($aTemplate ne 'login') {
   &read_sectCtrl_to_array($qOrder);  # in sectsubs.pl
   &read_sources_to_array;
   &read_regions_to_array;
#   $summarizedCnt = &total_items($summarizedSS); #in indexes.pl  TODO - do these using the DB ----- LATER
#   $suggestedCnt  = &total_items($suggestedSS); #in indexes.pl
}

if($owner) {  # 2nd owner must be done after &read_sectCtrl_to_array which gets ownersections and ownersubs
   &owner_set_update_return($docid,$listSectsub,$userid,$owner); # in owner.pl
   $ownerSections     = $OWNER{'ownersections'};
   $ownerSubs         = $OWNER{'ownersubs'};
   $viewOwnerUpdt     = $OWNER{'viewOwnerUpdt'};
   $metaViewOwnerUpdt = $OWNER{'metaViewOwnerUpdt'};
}

        ##### PROCESS THE VARIOUS COMMANDS

if($cmd eq 'storeform'
   or $cmd eq 'parseNewItem'
   or $cmd eq 'selectItems'
   or $cmd eq 'import'
   or $cmd eq 'updateCvrtItems'
   or $cmd eq 'convert_old_subsection') {
   if($DB_docitems > 0 or $cmd eq 'import') {  # TODO move this to top of list handling
      $doc_insert_sth = $DB_prepare_doc_insert;  #in docitem.pl
      $doc_update_sth = $DB_prepare_doc_update;  #in docitem.pl
      $idx_insert_sth = &DB_prepare_idx_insert; #in indexes.pl
   }
}

if($cmd eq "login_volunteer") {
    $userid          = $FORM{'userid'};
    $upin            = $FORM{'upin'};
	$operator_userid = $FORM{'opax'};
	($userdata,$ulastname,$ufirstname,$umiddle,$uid) = &check_user($userid,$upin,'name');  ## in user.pl
	print"<meta http-equiv=\"refresh\" content=\"0;url=http://$scriptpath/article.pl?display%app%$uid%$operator_userid\">";
	exit;
}

elsif($cmd eq "display") {  # used to display login, form, template, or docitem
# my $otemplate = 'ownerUpdate';
  if($aTemplate =~ /docUpdate/ or ($owner and $aTemplate =~ /$OWNER{'oupdatetemplate'}/) ) {   #$o_updt_template
	   $firstname     = "";
	   $lastname      = "";
	   $action = "new" unless($action or $docid);
	   $operator_access = 'A' if($userid =~ /A/);
	   $source = " (select one)";
  }
  elsif($aTemplate eq 'article_control') {
	   &print_article_control;
	   exit;
  }
  elsif($aTemplate eq 'app') {
	   $operator_userid = $info[3];
	   $uid = 0;
	   $uid             = $info[2];
#NEW NEW NEW  	($userdata,$operator_access,$permissions,$user_visable) = &check_user($operator_userid,98989,'access');  ## in user.pl
       $operator_access = 'A' if($operator_userid eq 'A3491');  #temporary

	   &print_volunteer_app($operator_access,$uid,'editor');   # in user.pl   args = $opAccess, $uid, $form
	   exit;
  }
  else {
	   if($aTemplate eq 'select_login') {
	   	$access = 'A';
	   }
	   &get_doc_form_values("") if($queryString ne 'Y'); #in docitem.pl
   }
   &display_one($docid,$action,$aTemplate,'N','N','N'); # in docitem.pl - $docid and $action may be null
}

elsif($cmd eq "processlogin") {

  $firstname     = "";
   $lastname     = "";
   ($userdata,$access,$permissions,$user_visable) = &check_user($userid,$upin,'access');  ## in user.pl
   $operator_access  = $access;
   $op_permissions   = $permissions;

   if($action eq 'dev') {
        $A{development} = 'Y' if($operator_access eq 'A');
        $action = 'update';
   }

   if($owner) {
#       $o_updt_template = $OWNER{'oupdatetemplate'};
#       $metaViewOwnerUpdt = $OWNER{'metaViewOwnerUpdt'};
#       print "$metaViewOwnerUpdt";
#	   exit;
#   }
#   elsif($action eq "emailit") {
#       $email_it = 'Y';
#       &email_full_article;
   }
   else {
       if($operator_access =~ /[ABC]/)  {
          $aTemplate = "docUpdate";
       }
       elsif($operator_access =~ /D/)  {
	      if($permissions =~ /Dictionary/) {
               $aTemplate = "volunteerDictionaryCrud";
	      }
	      else {
               $aTemplate = "docUpdate_ssEditor";
          }
       }
       elsif($action =~ /update/ and $thisSectsub =~ /$newsdigestSS/) {
            &printUserMsgExit("Sorry. This article has already been summarized. Please <a href=\"http://overpopulation.org/prepage/viewsection.php?Headlines_sustainability\">click here</a><br> for an up-to-date list of articles needing summarization (most recent at the top)");
       }
       else {
           $aTemplate = "summarize"   if($action eq "update");
           $aTemplate = "suggest"     if($action eq "new");
           $aTemplate = "fullArticle" if($action eq "view");
       }

       &display_one($docid,$action,$aTemplate,'N','N','N');   #in docitem.pl
   }
	exit(0);
}


elsif($cmd eq "display_section"
   or $cmd eq "print_select"
   or $cmd eq "display_subsection"
   or $cmd eq "process_select_login") {

   $ss_ctr = 0;
   $savecmd = $cmd;   # we change it below
   $access = "";

   if($owner) {   # http://overpop/cgi-bin/article.pl?display_section%%%CSWP_Calendar%%%%%%%%CSWP
      $access = "A";
   }
   else {
       $operator_access = 'A';
   }

   $addsectsubs = $FORM{'addsectsubs'};   ## ?????

   if($cmd =~ /process_select_login/) {
	     if($FORM{'deletedocitems'}) {
		     my $deletelist = $FORM{'deletedocitems'};
		     my $selectsectsub    = $FORM{'selectsectsub'};
		     my ($rest1,$rest2,$sectsub,$rest3) = split(/\^/,$selectsectsub,4);
#			print "art351 cmd $cmd deletelist $deletelist sectsub $sectsub operator_access $operator_access<br>\n";

	       &delete_from_index_by_list($sectsub,$deletelist);  #in indexes.pl
	       &DB_delete_from_index_by_list($sectsub,$deletelist) unless($DB_indexes < 1);
		     exit;
	     }

       $cmd = "print_select"    if($action =~ /print_select/);
       if($action =~ /fix_sectsub/) {
               $cmd = "display_subsection";
               $fix_sectsub = 'Y';
       }
       elsif($action =~ /display_subsection/) {
               $cmd = "display_subsection";
               my $selectsectsub = $FORM{'selectsectsub'};
               my ($x,$y,$sectsub,$rest) = split(/\^/,$selectsectsub,4);
               $listSectsub = $sectsub;
               $addsectsubs = $listSectsub;
       }
   }
   elsif($action =~ /move_webpage/) {
           $chgsectsubs = $addsectsubs;
           &do_html_page($rSectsubid,$aTemplate,$pg_num);     # do this to get pagenames
print"<meta http-equiv=\"refresh\" content=\"0;url=http://$scriptpath/moveutil.pl?move%$pagenames\">";
           exit;
   }

   $supress_nonsectsubs = 'N';
   $supress_nonsectsubs = 'Y'
              if($cmd =~ /print_select|display_subsection/);

   $select_kgp  = $FORM{'select_kgp'};
   $chk_pubdate = $FORM{'chk_pubdate'};
   $startDocid  = $FORM{'start_docid'};
   $sortorder   = $FORM{'sortorder'};
   $start_found = 'N';
   &printInvalidExit("Nothing was selected - hit your Back button and correct")
        if($addsectsubs !~ /[A-Za-z0-9]/ and $ipform =~ /select_prelim|select_login/);

   if($ipform =~ /select_prelim|select_login/) {
         ($listSectsub,$rest) = split(/;/,$addsectsubs,2);  # <--- maybe need to find sectsub, not sectsubid
   }
   $rSectsubid = $listSectsub;

	 $print_it = 'Y';
   
   &create_html($rSectsubid,$aTemplate,$pg_num,$supress_nonsectsubs);  #in display.pl
}

elsif($cmd eq "maiduUpdtItem") {
   &storeMaiduform($docid);    ## this is in docitem.pl
}

elsif($cmd eq "storeform") {
   $newsprocsectsub = $FORM{"newsprocsectsub"};
   $owner    = $FORM{"owner"};
   $ipform   = $FORM{"ipform"};
   $priority = $FORM{"priority"};
   if($newsprocsectsub =~ /$emailedSS/) {
	    $emessage = $fullbody;
	    $filepath = "$inboxpath/$sysdatetm.email";
	    print "Writing email to inbox - art400<br>\n";
	    open(EMAIL, ">$filepath") or die;
	    print EMAIL "$emessage";
	    close(EMAIL);
	    exit;
   }

   if($ipform eq 'newArticle' or $ipform eq 'docUpdate' or $ipform eq 'volunteerDocForm') {
	      my($userdata,$access,$permissions,$user_visable) = &check_user($userid,$upin,'access');  ## in user.pl
	      if($newsprocsectsub =~ /Headlines_priority/) {
	          $newsprocsectsub = $headlinesSS;
	          $priority = "6" unless($priority =~ /[1-7]/);
	          $docloc_news = "A" if($priority =~ /7/);    # priority 7 is the same as docloc (stratus) = "A"
		      $docloc_news = "B" if($priority =~ /6/);
       # headlines will sort by sysdate; headlines Priority will sort by stratus/sysdate
          }
   }
   elsif($newsprocsectsub =~ /Headlines_sustainability/) {
        $priority = "5" unless($priority);
        $docloc_news = "M";    # priority 6 is the same as docloc (stratus) = "A"
     # headlines will sort by sysdate; headlines Priority will sort by stratus/sysdate
   }

   elsif($permissions) {
	    $sectsubs = $FORM{"sectsubs"};
	    @sectsubs = split(/;/,$sectsubs);
	    foreach $sectsub (@sectsubs) {
		    if($sectsub !~ /$permissions/) {
			   print "<br><br><b>Very sorry. You do not have permission to create/update/delete this article in $sectsubs.<br>\n";
			   print "Please notify Karen Gaia 916-599-4329 if you think this is an error.<br></b>\n";
		       exit;
		    }
	    }
	    $FORM{"suggestAcctnum"}= $userid;
   }
   elsif($owner) {
	    ($userdata,$access,$permissions,$user_visable) = &check_user($userid,$upin,'access');  ## in user.pl
	    $ownersectsub = $FORM{"ownersectsub"};
   }

   &storeform($docid);    ## this is in docitem.pl

   exit;
#   print "$metaViewOwnerUpdt" if($owner);  # NOT NEEDED FOR STOREFORM
}

elsif($cmd eq 'storesectsubs') {  # from article_control form
    &add_updt_sectsub_values;  #in sectsubs.pl
    &print_article_control;
    exit;
}

elsif($cmd eq "list_sepmail") {  ## THIS IS OLD - NOT USED
	opendir(POPMAILDIR, "$sepmailpath");  # overpopulation.org/popnews_mail
	my(@popnewsfiles) = grep /^.+\.email$/, readdir(POPMAILDIR);
	closedir(POPMAILDIR);

	foreach $filename (@popnewsfiles) {
	     if(-f "$sepmailpath/$filename" and $filename =~ /\.email/) {
		print ".. $sepmailpath/$filename<br>\n";
	#	    &do_email_file($filename);
	     }
	}
	print "DONE<br>\n";
	exit(0);
}

elsif($cmd eq "adminlogin") {
##    &check_user($userid,98989);
	($userdata,$access,$permissions,$user_visable) = &check_user($userid,98989,'access');  ## in user.pl
    if ($access =~ /[ABCD]/) {
#     $aTemplate = "select_prelim";
#     $print_it = 'Y';
        &display_one("","","select_prelim",'N','N','N');
    }
    else {
       &printInvalidExit("Sorry, you cannot access this function without authorization.");
    }
}

elsif($cmd =~ /parseNewItem/) {    ## <==== Entry for most new articles (May 2013)
	 $docid    = "";
	 $fullbody = $FORM{'fullbody'};
	 $handle   = $FORM{'handle'};
	 $sectsubs = $FORM{'sectsubs'};
	 $pdfline  = $FORM{'pdfline'};
	 $ipform   = $FORM{'ipform'};

     if($handle =~ /push/) {    ## separate into separate articles, parse, write to file
	     &do_one_email('P',$fullbody,$handle);   #in intake.pl
    	 print"<meta http-equiv=\"refresh\" content=\"10;url=http://$scriptpath/article.pl?display_subsection%%%Suggested_emailedItem%%A3491%skipinbox\">";
	 }
	 elsif($handle =~ /link/) {   #list of urls
		 $A{sectsubs} = $suggestedSS;
  	     &links_separate('P',$handle,$pdfline,$fullbody,"");  # in intake.pl
		 print"<meta http-equiv=\"refresh\" content=\"10;url=http://$scriptpath/article.pl?display_subsection%%%Suggested_suggestedItem%%%10\">";
	 }
	 else {
	#	 &separate_email('P',$handle,$pdfline,$sectsubs,$fullbody);  #in intake.pl
	     $savesectsubs = $sectsubs;
		 &pass2_separate_email('P',$handle,$pdfline,$sectsubs,$fullbody,"");  #in intake.pl
	   	 $sectsubs = $savesectsubs;
         if($sectsubs =~ /Suggested_suggestedItem/) {
			 $fullbody = "";
			 $DOCARRAY = "";   # get ready for the next one
			 $FORM = "";
			 $aTemplate = 'newItemParse';
	         &process_template($aTemplate,'Y', 'N','N');    # ($print_it, template) in template_ctrl.pl
	      }
          else {
			  $action = "update";
			  $dSectsubs = $sectsubs;
			  $operator_access = 'A';
			  $aTemplate = 'docUpdate';
			  &process_template($aTemplate,'Y', 'N','N');    # ($print_it, template) in template_ctrl.pl
	      }
		  exit;
	}
 }

##       Comes here after items have been selected from a list

 elsif($cmd =~ /selectItems/) {
##     ($userdata, $access) = &check_user($userid,$upin); #	($userdata,$access,$permissions,$user_visable) = &check_user($userid,98989,'access');  ## in user.pl
      $listSectsub = $FORM{'thisSectsub'};
#     $owner       = $FORM{owner};

    if($listSectsub =~ /$emailedSS/) {
     	 &select_email;    # in selecteditems_crud.pl
		 print"<br><br><a target=\"_blank\" href=\"http://$scriptpath/article.pl?display_subsection%%%Suggested_suggestedItem%%$userid%10\">Suggested List</a>\n";
		 print"<meta http-equiv=\"refresh\" content=\"0;url=http://$scriptpath/article.pl?display_subsection%%%Suggested_suggestedItem%%$userid%10\">";
         exit;
     }
     elsif($listSectsub =~ /($suggestedSS|$volunteerSS|$headlinesPriSS)/) {
         &updt_select_list_items($listSectsub,$ipform,$userid);   # in selecteditems_crud.pl
     }
     else {
         &do_selected_items;  #in selecteditems_crud.pl

#	     &delete_from_index_by_list($listSectsub,$DELETELIST) if($delflag eq 'Y'); #in indexes.pl

   	    if($owner) {
 			print "<br><a href=\"$viewOwnerUpdt\">Click here to go to next page</a><br>\n";
	        print "<br><br>Saving webpage: <iframe src=\"http://$publicUrl/php/savepage.php?$owner" . "_webpage/index.php%$owner" . "_webpage/index.html\" width=\"900\" height=\"1\"></iframe>";
            sleep 30;
	        print "<br><br>Saved webpage: (you may need to reload the frame to get the most recent version)<br><iframe src=\"http://$publicUrl/$owner" . "_webpage/index.html\" width=\"1000\" height=\"1000\"></iframe>";

        }
	    else {
	        print "<br><a href=\"http://$scriptpath/article.pl?display_subsection%%%$listSectsub%%$userid%10\">Back to $listSectsub List</a><br>\n";
	    }
	    print"</body></html>\n";
	}
}

elsif($cmd eq 'display_article') {   # not tested; use viewarticle.php in prepage to view
	if($docid !~ /[0-9]{6}/) {
	print "Invalid document id<br>\n";
 	exit;
 }
# $template = $qTemplate;
 $doclist = "";
 $filepath = "$itempath/$docid.itm";

 if(-f $filepath) {
    &display_one("","",$aTemplate,'Y','N','N');  # maybe it's ("") ??   in docitem.pl
 }
 else {
    print "$docid not found<br>\n";
 }
}

elsif($cmd eq 'displayVolunteerLogs') {  #numdays = how many days (up to now) to display
	$numdays = $info[1];
	&DB_print_users_doc_log($numdays);   #in user.pl
}

elsif($cmd eq 'displayRange') {
 print "<b>Display Items from $qFrom to $qTo .. template $aTemplate<br></b><font size=1 face=verdana>\n";
 if($qFrom !~ /[0-9]{6}/ or $qTo !~ /[0-9]{6}/) {
 	print "From or to invalid<br>\n";
 	exit;
 }
 $doclist = "";
 $num = $qFrom;
 $num = $num + 0;
 while($num <= $qTo) {
    $docCount = $num;
    if($docCount    < 10)     {$docCount = "00000$docCount";}
    elsif($docCount < 100)    {$docCount = "0000$docCount";}
    elsif($docCount < 1000)   {$docCount = "000$docCount";}
    elsif($docCount < 10000)  {$docCount = "00$docCount";}
    elsif($docCount < 100000) {$docCount = "0$docCount";}

   my $docid = $docCount;
   my $filepath = "$itempath/$docid.itm";

   if($DB_docitems > 0) {
	   &DB_get_docitem($sth_docrow,$docid);
   }
   elsif(-f $filepath) {
      &display_one("","",$aTemplate,'N','N','N');  #in docitem.pl
##     was &display_one($aTemplate,'Y','N','N');
   }
   else {
      print "$docid not found ... art589<br>\n";
   }
   $num = $num +1;
 }
}

elsif($cmd eq "getownerinfo") {
	 print "$OWNER{'owebsitepath'},$OWNER{'ocsspath'},$OWNER{'ocssformpath'}"; #for viewOwnerUpdate.php
}

elsif($cmd eq "do_line_cmd") {
	 my $line_cmd = $info[1];  #query_string
	 &do_imbedded_commands($line_cmd,"P");   #in template_ctrl
}

elsif($cmd eq "update_user-XXX") {
   &update_user;          # in editor.pl
}

elsif($cmd eq "write_acctapp") {    #Approve users - executed from article.pl?display%article_control
  &write_acctapp;             # in editor.pl
}

elsif($cmd eq "import" or $cmd eq "export") {
  my $table = $info[1];
  my $one = $info[2];
  my $two = $info[3];
  my $three = $info[4];
  &clear_doc_data;     # bring $DATA and variables into global scope ???
  &clear_doc_variables;
  &DB_controller($cmd,$table,$one,$two,$three);    # in dbtables_ctrl.pl
}

elsif($cmd eq 'do_editoracct') {
	&do_editoracct;        #in user.pl
	exit;
}

elsif($cmd eq "updateCvrtItems") {
	 ($userdata,$access,$permissions,$user_visable) = &check_user($userid,98989,'access');  ## in user.pl
     if ($access =~ /[ABCD]/) {
     	$listSectsub = $convertSS;
     	&updt_select_list_items;
     }
}

elsif($cmd eq "contactWOA") {
   $sectsub    = $FORM{'sectsub'};
   $recipient  = $FORM{'email'};
   $username   = $FORM{'username'};
   $comment    = $FORM{'usercomment'};

   if($recipient =~ /[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9]{1,3}/
       and $comment !~ /[advertising|SPAM]/
       and $comment =~ /[A-Za-z0-9]/
       and $comment !~ /prozac|just\-pills|viagra|metasart|prescription|casino|poker|alprazolam/) {
     $subject   = "WOA|$sectsub - Your message has been received.";
     $email_msg = "$email_msg * * DO NOT REPLY TO THIS EMAIL * *  \n\n";
     $email_msg = "$email_msg Thank you for contacting WOA!!. If your message requires a reply,";
     $email_msg = "$email_msg you will hear from me in a short time.\n\n";
     $email_msg = "$email_msg Karen G.\nWorld Population Awareness\n\n ---\n\n";
     $email_msg = "$email_msg $username $recipient said:\n";
     $email_msg = "$email_msg Message:\n$comment\n\n";
     &do_email($email_msg);    # in send_email.pl

     print "<p><br><br><font size=3 face=verdana><b>Thank you for contacting WOA!! Your message has been sent</b></font><p><br>\n";
   }
   else {
      print "<p><br><br><font size=3 face=verdana><b>Your message did not go through</b>";
   }

   print "Hit your back button to continue or go to <a target=\"_top\" href=\"http:\/\/$$publicURL\"> WOA!!s home page</a><p><p>\n";
   exit;
}

elsif($cmd eq "print_move_public") {
    print "<html><body>\n";
    print "<a href=\"http://$scriptpath/moveutil.pl?move%$qPage\"><b>Make $qPage public</b></a>\n";
    print "</body></html>\n";
}

elsif($cmd eq "clean_index") {
    &clean_index($listSectsub);  ## in sections.pl
}

elsif($cmd eq "init_section") {
     $rSectsubid = $listSectsub;
     $doclistname = "$sectionpath/$listSectsub.idx";
     $dFilename = "$listSectsub";
     &process_doclist($listSectsub);   # in display.pl
}

elsif($cmd eq 'print_users') {
   $print_contributors = 'Y';
   my($count) = &read_contributors('Y','N','','',''); # print,return-row,userid,handle,email
}

elsif($cmd eq "DBctrl") {
	&DB_controller($info[1],$info[2],$info[3],$info[4],$info[5]);  #in DBtables_ctrl
}

elsif($cmd eq "convert_old_subsection") {
   $woapage = $doclist;
   $rSectsubid = $listSectsub;
   require 'convert.pl';
   &convert_old_subsection;  #in convert.pl
}

elsif($cmd eq "popnewsWeekly") {
   &ck_popnews_weekly;
}

elsif($cmd eq "email2list") {
	($userdata,$access,$permissions,$user_visable) = &check_user($userid,$pin,'access');  ## in user.pl
    $emaillist = $FORM{'emaillist'};
    $esubject  = $FORM{'subject'};
    $emailmsg  = $FORM{'emailmsg'};
    &email2list($emailmsg,$esubject,$emaillist); ## found in common.pl
}

elsif($cmd eq "do_fullitem") {

     $printout = &get_doc_data($docid,Y);
     print $printout;
}

elsif($cmd eq "printtables") {
	$table = $info[1];
     &print_tables($table);  # in dbtables.pl
}

elsif($cmd eq "printsectsubs") {
	 &DB_print_sectsubs;  #in sectsubs.pl
}

else {
  &printUserMsgExit("No command found. Terminating. (location:art741)") unless($cmd);
  &printUserMsgExit("Command $cmd not found. Terminating. (location:art741)");
}

exit;


sub print_article_control
{
 $userCount    = "";
 $hitCount     = "";
 $docCount     = "";
 &get_docCount;     # In docitem.pl
 &read_hitCount;
 &read_userCount;
 $print_it = 'Y';
 &process_template('article_control','Y','N','N');  #in template_ctrl.pl
 $aTemplate = $qTemplate;
 $print_it = 'N';
}


##                   called from docitem.pl
sub ck_popnews_weekly
{
 if($delsectsubs =~ /$newsdigestSectid/) {
    &subtractFromCount('popnews'); ## in counters-switches.pl
    return;
 }

 my $popnews_cnt = &getAddtoCount('popnews'); # in counters-switches.pl
 $cSectsubid = $rSectsubid = $newsWeeklySS;
 &split_section_ctrlB($rSectsubid);    #get count from sections

 my $max    = &padCount4($cMaxItems);
 my $popcnt = &padCount4($popnews_cnt);
 print "<br><big>Population News Weekly count $popnews_cnt of $cMaxItems</big><br><br>\n";

 if($popcnt > $max) {
    &create_html($rSectsubid,$pg_num);  #in display.pl

print "&nbsp;&nbsp;Sending Population News Weekly ... don't forget to zero the counter<br>\n";
   $recipient = "$adminEmail";
   my $month = @months[$nowmm-1];
   my $news_date = "$month $nowdd, $nowyyyy";

   $email_msg =~ s/&nbsp;/ /g;
   $email_msg = "$news_date\n$email_msg";
   $subject  = "Population News $news_date";
   &do_email($email_msg);    # in send_email.pl
   $email_msg = "";
   &clearPopCount;         # in counters-switches.pl
#   &do_popnews_wkly_email($email_msg);  # in send_email.pl
 }
}
