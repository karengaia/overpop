-- phpMyAdmin SQL Dump
  `acronym` varchar(50) NOT NULL,
  `title` varchar(200) DEFAULT NULL,
  UNIQUE KEY `acronym` (`acronym`(10))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
  `codetype` varchar(6) NOT NULL,
  `code` varchar(6) DEFAULT NULL,
  `description` varchar(100) DEFAULT '',
  `codename` varchar(12) DEFAULT '',
  KEY `codetype` (`codetype`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
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
) ENGINE=InnoDB AUTO_INCREMENT=207 DEFAULT CHARSET=latin1 AUTO_INCREMENT=207 ;
  `hits` int(20) NOT NULL,
  `doccount` int(10) NOT NULL,
  `maiduhits` int(20) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
  `sectsubid` smallint(5) unsigned NOT NULL,
  `docid` varchar(40) NOT NULL DEFAULT '',
  `stratus` char(1) NOT NULL DEFAULT 'M',
  `lifonum` int(10) unsigned NOT NULL DEFAULT '0',
  `pubdate` char(8) DEFAULT NULL,
  `sortchar` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`sectsubid`,`docid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;