-- phpMyAdmin SQL Dump-- version 2.6.0-pl2-- http://www.phpmyadmin.net-- -- Host: db.telavant.com-- Generation Time: Aug 09, 2012 at 03:30 PM-- Server version: 5.1.47-- PHP Version: 5.3.3-- -- Database: `overpop`-- -- ---------------------------------------------------------- -- Table structure for table `acronyms`-- CREATE TABLE `acronyms` (
  `acronym` varchar(50) NOT NULL,
  `title` varchar(200) DEFAULT NULL,
  UNIQUE KEY `acronym` (`acronym`(10))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;-- ---------------------------------------------------------- -- Table structure for table `codes`-- CREATE TABLE `codes` (
  `codetype` varchar(6) NOT NULL,
  `code` varchar(6) DEFAULT NULL,
  `description` varchar(100) DEFAULT '',
  `codename` varchar(12) DEFAULT '',
  KEY `codetype` (`codetype`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;-- ---------------------------------------------------------- -- Table structure for table `contributors`-- CREATE TABLE `contributors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uaccess` varchar(1) NOT NULL DEFAULT 'P',
  `uuserid` varchar(15) DEFAULT '',
  `upin` varchar(15) NOT NULL DEFAULT '0000',
  `ulastdate` varchar(15) DEFAULT '',
  `ulastname` varchar(30) DEFAULT '',
  `ufirstname` varchar(30) DEFAULT '',
  `umiddle` varchar(2) DEFAULT '',
  `uaddr` varchar(32) DEFAULT '',
  `ucity` varchar(32) DEFAULT '',
  `ustate` varchar(2) DEFAULT '',
  `uzip` varchar(10) DEFAULT '',
  `uphone` varchar(35) DEFAULT '',
  `uemail` varchar(100) DEFAULT '',
  `upayrole` varchar(3) DEFAULT '',
  `uhandle` varchar(6) DEFAULT '',
  `upermissions` varchar(60) DEFAULT '',
  `ucomment` tinytext,
  `uBlanks` varchar(1) DEFAULT '',
  `uSeparator` varchar(20) DEFAULT '',
  `uLocSep` varchar(40) DEFAULT '',
  `uSkipon` varchar(50) DEFAULT '',
  `uSkipoff` varchar(50) DEFAULT '',
  `uSkip` varchar(50) DEFAULT '',
  `uEmpty` varchar(15) DEFAULT '',
  `uDateloc` varchar(40) DEFAULT '',
  `uDateFormat` varchar(40) DEFAULT '',
  `uHeadlineloc` varchar(40) DEFAULT '',
  `uSourceloc` varchar(40) DEFAULT '',
  `uSingleLineFeeds` varchar(1) DEFAULT '',
  `uEnd` varchar(40) DEFAULT '',
  `created_on` datetime DEFAULT NULL,
  `updated_on` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=207 DEFAULT CHARSET=latin1 AUTO_INCREMENT=207 ;-- ---------------------------------------------------------- -- Table structure for table `counters`-- CREATE TABLE `counters` (
  `hits` int(20) NOT NULL,
  `doccount` int(10) NOT NULL,
  `maiduhits` int(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;-- ---------------------------------------------------------- -- Table structure for table `indexes`-- CREATE TABLE `indexes` (
  `sectsubid` smallint(5) unsigned NOT NULL,
  `docid` varchar(40) NOT NULL DEFAULT '',
  `stratus` char(1) NOT NULL DEFAULT 'M',
  `lifonum` int(10) unsigned NOT NULL DEFAULT '0',
  `pubdate` char(8) DEFAULT NULL,
  `sortchar` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`sectsubid`,`docid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;-- ---------------------------------------------------------- -- Table structure for table `ml_lists`-- CREATE TABLE `ml_lists` (
  `ml_id` int(11) NOT NULL AUTO_INCREMENT,
  `listname` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`ml_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;-- ---------------------------------------------------------- -- Table structure for table `ml_subscriptions`-- CREATE TABLE `ml_subscriptions` (
  `ml_id` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) NOT NULL DEFAULT '0',
  `pending` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ml_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;-- ---------------------------------------------------------- -- Table structure for table `ml_users`-- CREATE TABLE `ml_users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(255) DEFAULT '',
  `lastname` varchar(255) DEFAULT '',
  `e_mail` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=329 DEFAULT CHARSET=latin1 AUTO_INCREMENT=329 ;-- ---------------------------------------------------------- -- Table structure for table `owners`-- CREATE TABLE `owners` (
  `owner` varchar(8) NOT NULL,
  `ownerlongname` varchar(70) DEFAULT '',
  `owebsitepath` varchar(100) DEFAULT '',
  `oSScategory` varchar(5) DEFAULT '',
  `odefaultSS` varchar(50) DEFAULT '',
  `ocsspath` varchar(100) DEFAULT '',
  `ocssformpath` varchar(75) DEFAULT NULL,
  `otoptemplate` varchar(15) DEFAULT '',
  `ologintemplate` varchar(15) DEFAULT '',
  `oupdatetemplate` varchar(15) DEFAULT '',
  `oreviewtemplate` varchar(15) DEFAULT '',
  `ologopath` varchar(15) DEFAULT '',
  `oftpinfo` varchar(15) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;-- ---------------------------------------------------------- -- Table structure for table `regions`-- CREATE TABLE `regions` (
  `regionid` smallint(6) NOT NULL AUTO_INCREMENT,
  `seq` smallint(5) unsigned NOT NULL,
  `r_type` char(1) DEFAULT 'c',
  `regionname` varchar(75) NOT NULL,
  `rstarts_with_the` char(1) DEFAULT 'F',
  `regionmatch` varchar(200) DEFAULT '',
  `rnotmatch` varchar(100) DEFAULT '',
  `members_ids` varchar(200) DEFAULT NULL,
  `continent_grp` char(2) DEFAULT '',
  `location` varchar(75) DEFAULT '',
  `extended_name` varchar(100) DEFAULT '',
  `f1st2nd3rd_world` smallint(5) unsigned DEFAULT NULL,
  `fertility_rate` decimal(2,2) unsigned DEFAULT NULL,
  `population` int(10) unsigned DEFAULT NULL,
  `pop_growth_rate` decimal(2,2) DEFAULT NULL,
  `sustainability_index` decimal(2,2) unsigned DEFAULT NULL,
  `humanity_index` decimal(2,2) unsigned DEFAULT NULL,
  PRIMARY KEY (`regionid`)
) ENGINE=MyISAM AUTO_INCREMENT=344 DEFAULT CHARSET=latin1 AUTO_INCREMENT=344 ;-- ---------------------------------------------------------- -- Table structure for table `schema_info`-- CREATE TABLE `schema_info` (
  `version` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;-- ---------------------------------------------------------- -- Table structure for table `sectsubs`-- CREATE TABLE `sectsubs` (
  `sectsubid` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `seq` smallint(6) NOT NULL,
  `sectsub` varchar(100) NOT NULL,
  `fromsectsubid` smallint(6) DEFAULT '0',
  `fromsectsub` varchar(100) DEFAULT NULL,
  `subdir` varchar(100) DEFAULT NULL,
  `page` varchar(50) DEFAULT NULL,
  `category` char(2) DEFAULT 'N',
  `visable` char(2) DEFAULT 'V',
  `preview` char(1) DEFAULT 'D',
  `order1` char(1) DEFAULT 'P',
  `pg2order` char(1) DEFAULT 'P',
  `template` varchar(50) DEFAULT NULL,
  `titletemplate` varchar(50) DEFAULT NULL,
  `title` varchar(100) DEFAULT NULL,
  `allor1` varchar(10) DEFAULT 'all',
  `mobidesk` varchar(10) DEFAULT 'desk',
  `doclink` varchar(10) DEFAULT 'doclink',
  `header` varchar(50) DEFAULT NULL,
  `footer` varchar(50) DEFAULT NULL,
  `ftpinfo` varchar(50) DEFAULT NULL,
  `pg1items` tinyint(3) unsigned DEFAULT '7',
  `pg2items` tinyint(3) unsigned DEFAULT '70',
  `pg2header` varchar(100) DEFAULT NULL,
  `more` tinyint(3) unsigned DEFAULT NULL,
  `subtitle` varchar(100) DEFAULT NULL,
  `subtitletemplate` varchar(50) DEFAULT NULL,
  `menutitle` varchar(60) DEFAULT NULL,
  `keywordsmatch` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`sectsubid`),
  UNIQUE KEY `sectsub` (`sectsub`),
  KEY `sectsub_2` (`sectsub`),
  KEY `seq` (`seq`)
) ENGINE=MyISAM AUTO_INCREMENT=434 DEFAULT CHARSET=latin1 AUTO_INCREMENT=434 ;-- ---------------------------------------------------------- -- Table structure for table `sources`-- CREATE TABLE `sources` (
  `sourceid` smallint(6) NOT NULL AUTO_INCREMENT,
  `sourcename` varchar(75) NOT NULL,
  `sstarts_with_the` char(1) DEFAULT '',
  `shortname` varchar(75) DEFAULT NULL,
  `shortname_use` char(1) DEFAULT '',
  `sourcematch` varchar(200) DEFAULT NULL,
  `linkmatch` varchar(100) DEFAULT NULL,
  `snotmatch` varchar(100) DEFAULT NULL,
  `sregionname` varchar(75) DEFAULT NULL,
  `sregionid` smallint(6) DEFAULT NULL,
  `region_use` char(1) DEFAULT '',
  `subregion` varchar(75) DEFAULT NULL,
  `subregionid` smallint(6) DEFAULT NULL,
  `subregion_use` char(1) DEFAULT '',
  `locale` varchar(75) DEFAULT NULL,
  `locale_use` char(1) DEFAULT '',
  `headline_regex` varchar(75) DEFAULT NULL,
  `linkdate_regex` varchar(75) DEFAULT NULL,
  `date_format` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`sourceid`)
) ENGINE=MyISAM AUTO_INCREMENT=641 DEFAULT CHARSET=latin1 AUTO_INCREMENT=641 ;-- ---------------------------------------------------------- -- Table structure for table `switches_counts`-- CREATE TABLE `switches_counts` (
  `name` varchar(20) DEFAULT NULL,
  `switch_count` int(10) unsigned DEFAULT '0',
  `description` varchar(70) DEFAULT NULL,
  KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;