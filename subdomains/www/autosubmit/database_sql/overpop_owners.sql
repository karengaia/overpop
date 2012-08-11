CREATE TABLE `owners` (
  `owner` varchar(8) NOT NULL,
  `ownerlongname` varchar(70) DEFAULT '',
  `owebsitepath` varchar(100) DEFAULT '',
  `oSScategory` varchar(5) DEFAULT '',
  `odefaultSS` varchar(50) DEFAULT '',
  `ocsspath` varchar(100) DEFAULT '',
  `otoptemplate` varchar(15) DEFAULT '',
  `ologintemplate` varchar(15) DEFAULT '',
  `oupdatetemplate` varchar(15) DEFAULT '',
  `oreviewtemplate` varchar(15) DEFAULT '',
  `ologopath` varchar(15) DEFAULT '',
  `oftpinfo` varchar(15) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `owners` WRITE;
/*!40000 ALTER TABLE `owners` DISABLE KEYS */;

INSERT INTO `owners` (`owner`, `ownerlongname`, `owebsitepath`, `oSScategory`, `odefaultSS`, `ocsspath`, `otoptemplate`, `ologintemplate`, `oupdatetemplate`, `oreviewtemplate`, `ologopath`, `oftpinfo`)
VALUES
	('CSWP','Committee for a Sustainable World Population','motherlode.sierraclub.org/population/','c','CSWP_Calendar','/css/ownercss','cswp_top','ownerlogin','ownerUpdate','ownerReview','',''),
	('default','','','','','/css/ownercss','','ownerlogin','ownerUpdate','ownerReview','',''),
	('MAIDU','Maidu Group','motherlode.sierraclub.org/maidu/','m','','/css/maidu_css','','','','','','');

/*!40000 ALTER TABLE `owners` ENABLE KEYS */;
UNLOCK TABLES;


