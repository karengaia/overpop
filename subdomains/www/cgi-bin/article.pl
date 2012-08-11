#!/usr/bin/perl --

# March 2012
#        article.pl  : controller for autosubmit; entry point for almost all perl programs
#                      exceptions: move.pl getmail.pl

##  Must be escaped in regex:    \ . ^ $ * + ? { } [ ] ( ) |

## Polish notation: (try to do more of this)
## g =global, l=local, f=form, q=query d=document (Use Camel notation i.e. gTidytops)

## CHANGE LOG (for all perl scripts)#######################

## 2012 Mar - enhanced smartdata.pl to better parse popnews in; added headlines_priority;
##             eliminated sections.pl (goes to sectsubs.pl and indexes.pl); also db_controlfiles.pl and 
##               controlfiles.pl; Added smartdata.pl and date.pl
## 2011 Nov    - pulled out template_ctrl.pl and display.pl; now article.pl is just a controller.


$args = $_[0];   # In case we do it from the command line
if($args) {
  my @args = split(/,/,$args);
  my $cmd  = $args[0];
}

print "Content-type: text/html\n\n";
require './bootstrap.pl';
require 'common.pl';        # sets up environment and paths; also has some common routines
require 'errors.pl';         # error display and termination or return
require 'display.pl';        # takes sectsub info for a particular section or subsection and uses it to create a page with html
require 'template_ctrl.pl';  # merges data with template; processes template commands for what to do with data.
require 'database.pl';       # basic database functions
require 'dbtables_ctrl.pl';  # maintains and retrieves miscellaneous tables: acronyms, switches_codes, list_imports_export links
## require 'db_controlfiles.pl'; # not used - rolled into controlfiles.pl
require 'date.pl';         # parses and processes date data in docitems
# require 'sections.pl';      # replaced by sectsubs.pl or indexes.pl
require 'sectsubs.pl';      # maintains and retrieves sections (sectsubs) control data.
require 'indexes.pl';       # maintains and retrieves indexes control data. Indexes are lists of docitem ids; each list represents a subsection
require 'sources.pl';       # maintains and retrieves publisher sources
require 'regions.pl';       # maintains and retrieves region and country data
##require 'controlfiles.pl';  # maintains and retrieves miscellaneous tables: acronyms, switches_codes, list_imports_export links
require 'contributor.pl';   # maintains, verifies and retrieves contributor (volunteer or user) data
require 'email2docitem.pl';   ## require 'sepmail.pl'; processes and separates email articles
require 'docitem.pl';       # maintains and retrieves docitem (article) data; assigns to appropriate subsections
require 'smartdata.pl';  # extension of docitem.pl used to parse data from an email or single textbox form
require 'send_email.pl';   # sends an email
require 'selecteditems_crud.pl'; # processes items selected from a list.

&get_site_info;        ## in common.pl	
&set_date_variables;   ## in date.pl
&DB_get_switches_counts;  #in dbtables_ctrl.pl - Sets switches for using database - Yes or No?	
&init_display_variables; # in display.pl

&clear_sectsubs_variables;
&init_contributors;
&init_paging_variables; # in indexes.pl
&init_email;  #in send_email.pl
&init_docitem_variables;

$userCount    = "";
$hitCount     = "";
$docCount     = "";
&read_docCount;     # In dbtables_ctrl.pl
&read_hitCount;
&read_userCount;

if(-f "debugit.yes") {
  $email_filename = "201102180702-2011-02-18-.email";
  print "art00 filename $email_filename<br>\n";
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

if($ENV{QUERY_STRING} or -f 'debugit.yes') {
   $queryString = 'Y';
   $cmd         = $info[0];

   $aTemplate   = $info[1];
   $qTemplate   = $aTemplate;
   $docid       = $info[2];
   $fly         = $docid if($docid =~ /[a-zA-Z]/);
   $action      = $docid if($docid =~ /[a-zA-Z]/);
   $qFrom       = $docid;
   $thisSectsub = $info[3];
   $qSectsub    = $thisSectsub;
   $qTo         = $thisSectsub;
   $doclist     = $info[4];
   $qPage       = $info[4]; 
   $acctnum     = $info[5];
   $userid      = $info[5];  ## overlap between userid, acctnum, and start_count
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
   if($info[7] =~ /prtmove/) {
	 $qPrtmove = 'Y';
   }
   else {
      $qHeader     = $info[7];	
   }
   $qFooter     = $info[8];
   $qOrder      = $info[9];
   $qMobidesk   = $info[10];
   $qOwner      = $info[11];
   $owner = $qOwner;
   $listnum = $info[12];
# http://overpop/cgi-bin/article.pl?display%ownerlogin%026391%cswp_events%%%%%%%%CSWP
# overpop/cgi-bin/article.pl?display%ownerlogin%026391%cswp_events%%%%%%%%cswp
}

else {
   &parse_form;  #in common.pl
   $cmd       = $FORM{cmd};

   $aTemplate = $FORM{template};
   if($aTemplate =~ /;/) {
     ($qHeader,$aTemplate,$qFooter) = split(/;/,$aTemplate);
   }
   $action      = $FORM{action};
   $docid       = $FORM{docid};
   $userid      = $FORM{userid} if $FORM{userid};
   $pin         = $FORM{pin};
   $password    = $FORM{password};
   $ipform      = $FORM{ipform};
   $thisSectsub = $FORM{thisSectsub};
   $owner       = $FORM{owner};
}
($userid,$rest) = split(/;/,$userid,2) if($userid =~ /;/);

$op_userid = $userid;
if($owner) {
  require 'owner.pl'; 
  &get_owner($owner);
  my  $o_updt_template   = $OWNER{'oupdatetemplate'};
  my  $o_review_template = $OWNER{'oreviewtemplate'};
  $ownerSections = "";
  $ownerSubs = "";
}

if($aTemplate ne 'login') {
   &read_sectCtrl_to_array($qOrder);  # in sectsubs.pl
   &read_sources_to_array;
   &read_regions_to_array;
}

if($owner) {  # 2nd owner must be done after &read_sectCtrl_to_array which gets ownersections and ownersubs
   &owner_set_update_return($docid,$thisSectsub,$userid,$owner);
   $ownerSections     = $OWNER{'ownersections'};
   $ownerSubs         = $OWNER{'ownersubs'};
   $viewOwnerUpdt     = $OWNER{'viewOwnerUpdt'};
   $metaViewOwnerUpdt = $OWNER{'metaViewOwnerUpdt'};
}		
#        ##### PROCESS THE VARIOUS COMMANDS

if($cmd eq "list_sepmail") {
	opendir(POPMAILDIR, "$sepmailpath");  # overpopulation.org/popnews_mail 
	local(@popnewsfiles) = grep /^.+\.email$/, readdir(POPMAILDIR);
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

elsif($cmd eq "display") {  # used to display login, form, template, or docitem 		
# my $otemplate = 'ownerUpdate';

  if($aTemplate =~ /docUpdate/ or ($owner and $aTemplate =~ /$OWNER{'oupdatetemplate'}/) ) {   #$o_updt_template
	  $firstname     = "";
	  $lastname      = "";
	  $action = "new" unless($action or $docid);
	  $operator_access = 'A' if($userid =~ /A/);
  }
  else {
	   if($aTemplate eq 'select_login') {
	   	$access = 'A';
	   }
	   &get_doc_form_values if($queryString ne 'Y'); #in docitem.pl
   }
  &display_one($aTemplate,'Y','N','N'); # in docitem.pl
}

elsif($cmd eq "processlogin") {
  $firstname     = "";
   $lastname      = "";
   $pin = $password if($password and !$pin);
  ($userdata, $access,$permissions) = &check_user($userid,$pin);  ## in common.pl
   $operator_access  = $access;
   $op_permissions   = $permissions;

   if($owner) { 
       $$o_updt_template = $OWNER{'oupdatetemplate'};       
# print "http://$publicUrl/prepage/viewOwnerUpdate.php?$docid%$aTemplate%$thisSectsub%$owner\"<br>\n";
exit;
       print "$metaViewOwnerUpdt"; 
	   exit(0); 
   }
   elsif($action eq "emailit") {
       $email_it = 'Y';
       &email_full_article;
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
       else {
           $aTemplate = "summarize"   if($action eq "update");
           $aTemplate = "suggest"     if($action eq "new");
           $aTemplate = "fullArticle" if($action eq "view");
        }
       &display_one($aTemplate,'Y','N','N');
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
	   ($userdata,$access) = &read_contributors(N,N,_,_,$userid,98989) if($userid ne "");  ## args=print?, html file?, handle, email, acct#
	   if(($userdata =~ /BAD/ or $access !~ /[ABCD]/)
	        and $cmd =~ /print_select|process_select_login/) {
	          &printInvalidExit("You are not authorized to use admin functions");
       }
    }
    $operator_access  = $access;
    $addsectsubs = $FORM{addsectsubs};

    if($cmd =~ /process_select_login/) {
         $cmd = "print_select"    if($action =~ /print_select/);
         if($action =~ /fix_sectsub/) {
               $cmd = "display_subsection";
               $fix_sectsub = 'Y';
         }
         elsif($action =~ /display_subsection/) {
               $cmd = "display_subsection";
               my $selectsectsub = $FORM{'selectsectsub'};
               my ($x,$y,$sectsub,$rest) = split(/\^/,$selectsectsub,4);
               $thisSectsub = $sectsub;
               $addsectsubs = $thisSectsub;
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

     $select_kgp  = $FORM{select_kgp};
     $chk_pubdate = $FORM{chk_pubdate};
     $startDocid  = $FORM{start_docid};
     $sortorder   = $FORM{sortorder};
     $start_found = 'N';

     &printInvalidExit("Nothing was selected - hit your Back button and correct") 
       if($addsectsubs !~ /[A-Za-z0-9]/ and $ipform =~ /select_prelim|select_login/);
     
     if($ipform =~ /select_prelim|select_login/) {
         ($thisSectsub,$rest) = split(/;/,$addsectsubs,2);  # <--- maybe need to find sectsub, not sectsubid
     }

     $rSectsub    = $thisSectsub;
     ($rSectsubid,$rSectid,$rSubid,$stratus,$lifonum) = &split_sectsub($rSectsub);

     if($rSectsubid =~/$emailedSS/ and $operator_access =~ /[ABC]/) {
        &separate_email_files;    # in email2docitem.pl -- Takes intake emails from popnews_bkup and processes 
                                  # to popnews_mail which are docitem.item format; create_html (below) reads them 
                                  # from popnews_mail and prints a selection list; no index needed
#     	&separate_out_email;        ##OLD  sepmail.pl; Will be mixed: email, apps, and convert
#     	&index_suggested_email;     ## in sections.pl -- will read from popnews_mail directory instead
        undef $emailpath;
        $cmd="print_select";     # to read in emails docitems from popnews_mail to a selection list
        $supress_nonsectsubs = 'Y';
##        $stop_count = '0060';
     }
    $print_it = 'Y';

    &create_html($rSectsubid,$aTemplate,$pg_num);  #in display.pl
}

elsif($cmd eq "storeform") {
  $newsprocsectsub = $FORM{"newsprocsectsub"};
  $owner = $FORM{"owner"};
  $ipform = $FORM{"ipform"};
   if($newsprocsectsub =~ /$emailedSS/) {
	   $emessage = $fullbody;
	   $filepath = "$inboxpath/$sysdatetm.email";
	   open(EMAIL, ">$filepath") or die;
	   print EMAIL "$emessage";
	   close(EMAIL);
	   exit;
   }

   if($ipform eq 'newArticle' or $ipform eq 'docUpdate' or $ipform eq 'volunteerDocForm') {
      ($userdata, $access, $permissions) = &check_user($userid,$pin);  ## in contributor.pl
       if($newsprocsectsub =~ /Headlines_priority/) {
          $newsprocsectsub = $headlinesSS;
          $priority = "6";
          $docloc_news = "A";    # priority 6 is the same as docloc (stratus) = "A"
       # headlines will sort by sysdate; headlines Priority will sort by stratus/sysdate
       }
       elsif($newsprocsectsub =~ /Headlines_sustainability/) {
          $priority = "5";
          $docloc_news = "M";    # priority 6 is the same as docloc (stratus) = "A"
       # headlines will sort by sysdate; headlines Priority will sort by stratus/sysdate
       }
       elsif($permissions) {
		  $sectsubs = $FORM{"sectsubs"};
	      @sectsubs = split(/;/,$sectsubs);
	      foreach $sectsub (@sectsubs) {
		     if($sectsub !~ /$permissions/) {
			   print "<br><br><b>Very sorry. You do not have permission to create/update/delete this article, which is in a restricted section ($sectsubs).<br>\n";
			   print "Please notify Karen Gaia 916-599-4329 if you think this is an error.<br></b>\n";
               exit;
		     }
		  }
      }
      $FORM{"suggestAcctnum"}= $userid;
      
   }
   elsif($owner) {
	    ($userdata, $access, $permissions) = &check_user($userid,$pin);  ## in contributor.pl
	
	    $ownersectsub = $FORM{"ownersectsub"};
  }
  &storeform;    ## this is in docitem.pl

  exit;
#   print "$metaViewOwnerUpdt" if($owner);  # NOT NEEDED FOR STOREFORM

}

elsif($cmd eq 'storesectsubs') {  # from article_control form
    &add_updt_sectsub_values;  #in sectsubs.pl
    &print_article_control;
    exit;
}

elsif($cmd eq "list_sepmail") {
	opendir(POPMAILDIR, "$sepmailpath");  # overpopulation.org/popnews_mail 
	local(@popnewsfiles) = grep /^.+\.email$/, readdir(POPMAILDIR);
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
     ($userdata, $access) = &check_user($userid,98989);
  if ($access =~ /[ABCD]/) {
#     $aTemplate = "select_prelim";
#     $print_it = 'Y';
     &display_one("select_prelim",'Y','N','N');
  }
  else {
     &printInvalidExit("Sorry, you cannot access this function without authorization.");
  }
}


elsif($cmd =~ /parseNewItem/) {
	  $docid    = "";
	  $fullbody = $FORM{fullbody};
	  $handle   = $FORM{handle};
	  $sectsubs = $FORM{sectsubs};
	  $pdfline  = $FORM{pdfline};
	  $ipform   = $FORM{ipform};	

      &separate_email('P',$handle,$pdfline,$sectsubs,$fullbody);  #in email2docitem.pl

  $sectsubs = $save_sectsubs;	
	
#      if($sectsubs =~ /Headlines_priority/) {
#	     $sectsubs = $headlinesSS;
#	     $priority = "6";
#	     $docloc_news = "A";    # priority 6 is the same as docloc (stratus) = "A"
#	         # headlines will sort by sysdate; headlines Priority will sort by stratus/sysdate
#	  }
#	  elsif($sectsubs =~ /Headlines_sustainability/) {
#         $priority = "5";
#         $docloc_news = "M";    # priority 6 is the same as docloc (stratus) = "A"
#      }
	  if($sectsubs =~ /Suggested_suggestedItem/) {
#         $priority = "5";
#         $docloc_news = "M";
#         &storeform;    #in docitem.pl
#	     $DOCARRAY{'docitem'} = "";
#	     $DOCARRAY{'fullbody'} = "";
#	     $DOCARRAY{'sectsubs'} = "";
#	     $FORM{'sectsubs'} = "";
#	     $operator_access = 'A';
		 $aTemplate = 'newItemParse';
         &process_template($aTemplate,'Y', 'N','N');    # ($print_it, template) in template_ctrl.pl
	     exit;       
      }

	  $action = "update";
	  $dSectsubs = $sectsubs;
	  $operator_access = 'A';
	  $aTemplate = 'docUpdate';
	  &process_template($aTemplate,'Y', 'N','N');    # ($print_it, template) in template_ctrl.pl
	  exit;
}

##       Comes here after items have been selected from a list

elsif($cmd =~ /selectItems/) {
	#     &check_user($userid,98989);
##     ($userdata, $access) = &check_user($userid,$pin);
#     $thisSectsub = $FORM{thisSectsub};
#     $owner       = $FORM{owner};
    if($thisSectsub =~ /$emailedSS/) {
     	 &select_email;
     }
     elsif(($thisSectsub =~ /Suggested_suggestedItem/) or
            $thisSectsub =~ /$volunteerSS/) {
         &updt_select_list_items($thisSectsub,$ipform);   # in selecteditems_crud.pl
     }
     else {
         &do_selected_items;  #in selecteditems_crud.pl
	    
#	     &delete_from_index_by_list($thisSectsub,$DELETELIST) if($delflag eq 'Y'); #in indexes.pl

   	    if($owner) {   
 			print "<br><a href=\"$viewOwnerUpdt\">Click here to go to next page</a><br>\n";
        }
	    else { 
	        print "<br><a href=\"http://$scriptpath/article.pl?display_section%%%$thisSectsub%%$userid%10\">Back to $thisSectsub List</a><br>\n";	    
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
    &display_one($aTemplate,'Y','N','N');  # maybe it's ("") ??   in docitem.pl
 }
 else {
    print "$docid not found<br>\n";
 }
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

   $docid = $docCount;
   $filepath = "$itempath/$docid.itm";

   if(-f $filepath) {
      &display_one($aTemplate,'Y','N','N');  #in docitem.pl
   }
   else {
      print "$docid not found<br>\n";
   }
   $num = $num +1;
 }
}

elsif($cmd eq "getownerinfo") {
	 print "$OWNER{'owebsitepath'},$OWNER{'ocsspath'},$OWNER{'ocssformpath'}"; #for viewOwnerUpdate.php
}

elsif($cmd eq "import_docitems") {
  &clear_doc_data;     # bring $DATA and variables into global scope
  &clear_doc_variables;
  &import_docitems;    # in docitems.pl  
}

elsif($cmd eq "updateCvrtItems") {
     ($userdata, $access) = &check_user($userid,98989);
     if ($access =~ /[ABCD]/) {
     	$thisSectsub = $convertSS;
     	&updt_select_list_items;
     }
}

elsif($cmd eq "start_acctapp") {
   &verify_new_acct;          # in contributor.pl
}

elsif($cmd eq "write_acctapp") { 
  &write_acctapp;             # in contributor.pl
}

elsif($cmd eq "contactWOA") {
   $sectsub    = $FORM{sectsub};
   $recipient  = $FORM{email};
   $username   = $FORM{username};
   $comment    = $FORM{usercomment};

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
     &do_email;

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
    &clean_index($thisSectsub);  ## in sections.pl
}

elsif($cmd eq "init_section") {
     $rSectsubid = $thisSectsub;
     $doclistname = "$sectionpath/$thisSectsub.idx";
     $dFilename = "$thisSectsub";
     &process_doclist($thisSectsub);   # in display.pl
}

elsif($cmd eq 'print_users') {
   $print_contributors = 'Y';
## $acctnum = "ZZZZ";
   $ckuserid  = "ZZZZ";
##     found in contributors.pl
   ($userdata,$access) = &read_contributors(Y,N,H,E,$ckuserid,98989);
## $userdata = &read_contributors(Y,N,H,E,$acctnum);
}

elsif($cmd eq "DBctrl") {
	&DB_controller($info[1],$info[2]);
}

elsif($cmd eq "convert_old_subsection") {
   $woapage = $doclist;
   $rSectsubid = $thisSectsub;
   require 'convert.pl';
   &convert_old_subsection;  #in convert.pl
}

elsif($cmd eq "popnewsWeekly") {
   &ck_popnews_weekly;
}

elsif($cmd eq "email2list") {
    ($userdata, $access) = &check_user($userid,$pin);
    $emaillist= $FORM{emaillist};
    $esubject  = $FORM{subject};
    $emailmsg = $FORM{emailmsg};
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

else {
  &printUserMsgExit("Command $cmd not found. Terminating. (location:art741)");
}


exit;


sub print_article_control
{
 $print_it = 'Y';
 &process_template('article_control','Y','N','N');  #in template_ctrl.pl
 $aTemplate = $qTemplate;
 $print_it = 'N';
}


###  00890 EMAIL #########

##                   called from docitem.pl
sub ck_popnews_weekly
{
 if($delsectsubs =~ /$newsdigestSectid/) {
    &subtractFromCount('popnews'); ## in dbtables_ctrl.pl;
    return;
 }

 my $popnews_cnt = &getAddtoCount('popnews'); # in dbtables_ctrl.pl
 $cSectsubid = $rSectsubid = $newsWeeklySS;
 &split_section_ctrlB($rSectsubid);    #get count from sections

 my $max    = &padCount6($cMaxItems);
 my $popcnt = &padCount6($popnews_cnt);

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
   &do_email;
   $email_msg = "";
   &clearPopCount;
   &do_popnews_wkly_email;
 }
}


## 00900

sub email_review_not_used
{
 $userid = $suggestAcctnum if($ipform eq 'suggest');
 $userid = $sumAcctnum     if($ipform eq 'summarize');
 ($userdata,$access) = &read_contributors(N,N,_,_,$userid,98989); ## args=print?, html file?, handle, email, acct#
#$userdata = &read_contributors(N,N,,,$acctnum);    ## args=print?, html file?, handle, email, acct#

 if($ipform eq 'docUpdate' and $access =~ /[AB]/) {
    $sender    = $adminEmail;
    $bcc       = $adminEmail;
    $recipient = $useremail;
 }
 else {
     $sender    = $userEmail;
     $recipient = $adminEmail;
 }

 if($sender ne $recipient and $userdata eq "GOOD" and $recipient !~ /^@/ and $sender !~ /^@/) {
## if($recipient !~ /^@/ and $sender !~ /^@/) {
    $subject  = "WOA Article $handle $docid $headline";
    $email_msg = "Your submittal has been processed at WOA!!\n and sto
 in $sectsubs sections\n\n$note\n\n";
    $email_msg = "$email_msg $docid $headline \n\n $body \n\n$fullbody\n\n$email_std_end";

###    &do_email;
 }
}