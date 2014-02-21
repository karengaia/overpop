#!/usr/bin/perl --

# January 23, 2012    # replaced by sectsubs.pl

#        sections.pl

## Processes  interactions between docitems.pl, sectsubs.pl and indexes.pl;
## store docloc & seq on sectsub index
## docloc (docsection) - M=middle, 1,2,3,4,5,6=top, U,V,W,X,Y,Z=bottom

## sections directory: sectid-subid.idx has list of docid's
##                     sectid-subid.html has generated html to piece together


## Called by article.pl or docitem.pl

## 2012 Feb   - pulled out sectsubs.pl and indexes.pl
## 2010 Nov11 - substitued $cMobidesk for $CRtCol
## 2010 Sep11  - changed get_addl_sections to look at cCategory (from sections.html) instead of various sectsubids;
##               also picked up any missing sectsubs from the three dropdowwns;
##               Also added stratus and image to News Processing sections
## 2010 Aug 28 - added Headlines_sustainability to default newsprocsectsub on newArticle form
## 2010 Aug 25 - fixed multiple problems with news sections - was deleting and adding sectsubs it shouldn't.
## 2010 Aug 4 - fixed scriptpath for paging - 3 places.
## 2010 Apr 12 - moved to radio buttons on selection section for: News, Headlines,
##               Suggested (emailed, summarized, suggested); removed some HTML and text from script
##               Added new sectsubs called newsprocsectsub and sub get_news_only_sections
##               In do
## 2006 Mar 18 - write better delete; reorganized code in sections.pl
## 2006 Jan 25 - sort order for priority set stratus to A for 2006
## 2006 Jan07  - write item count to a .cnt file for page indexing
## 2005 Dec 4 - added item counts for paging



## 100 INITIALIZING SECTIONS CONTROL INFORMATION


1;