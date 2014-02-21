#!/usr/bin/perl --

# owner.pl (page owner) 2012 June 29
## called by article.pl

# Also look at A. userid wrong thing passed in query string; 
# /www/cswp/cswp_admin.php  # CSWP admin page accessible by group password.
#   ... various lists available for changing - access update by tiny grey button, taking you to ...
# /www/prepage/viewOwnerUpdate.php


sub init_owner
{
 $OWNER = ();
 $OWNER_DEFAULT = ();
 my $sth_odefault = $DBH->prepare("SELECT otoptemplate,ologintemplate,oupdatetemplate,oreviewtemplate
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
 my $sth_owner = $DBH->prepare('SELECT ownerlongname, owebsitepath, oSScategory,odefaultSS,ocsspath,ocssformpath,otoptemplate,ologintemplate,oupdatetemplate,oreviewtemplate,ologopath,oftpinfo
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
 $OWNER{'ologintemplate'}  = $OWNER_DEFAULT{'ologintemplate'}  unless($ologintemplate);
 $OWNER{'oupdatetemplate'} = $OWNER_DEFAULT{'oupdatetemplate'} unless($oupdatetemplate);
 $OWNER{'oreviewtemplate'} = $OWNER_DEFAULT{'oreviewtemplate'} unless($oreviewtemplate);
}

sub owner_set_sectsubs
{
 my($ownersSections,$ownerSubs) = @_;
 $OWNER{'ownersections'} = $ownerSections;
 $OWNER{'ownersubs'}     = $ownerSubs;
}


sub owner_set_update_return    # called from article.pl
{
  my($docid,$thisSectsub,$userid,$owner) = @_; 
	my  $l_docid = $docid;
    $l_docid = "" unless($docid =~ /[0-9]{6}/);
    $oupdatetemplate = $OWNER{'oupdatetemplate'};
    my  $ownerSubs              = $OWNER{'ownersubs'};
    my  $viewOwnerUpdt          = "http://$publicUrl/prepage/viewOwnerUpdate.php?$l_docid%$oupdatetemplate%$thisSectsub%$owner%$userid%$ownerSubs";
    my  $metaViewOwnerUpdt      = "<meta http-equiv=\"refresh\" content=\"0;url=" . $viewOwnerUpdt . "\">\n";
    $OWNER{'viewOwnerUpdt'}     = $viewOwnerUpdt;
    $OWNER{'metaViewOwnerUpdt'} = $metaViewOwnerUpdt;
#    $x = $OWNER{'metaViewOwnerUpdt'};
#    print "ow84 meta <!-- $x --><br>\n";
}

sub create_owners
{   ## Easier to do this on Telavant interface
	$DBH = &db_connect();
	
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

$sth2 = $DBH->do($sql);
}



1;

