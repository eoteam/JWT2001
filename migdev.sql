SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';
	
CREATE SCHEMA `migdev` DEFAULT CHARACTER SET latin1 ; 
USE `migdev`;

DROP TABLE IF EXISTS `colors`;
DROP TABLE IF EXISTS `comments`;
DROP TABLE IF EXISTS `content`;
DROP TABLE IF EXISTS `content_content`;
DROP TABLE IF EXISTS `content_customfields`;
DROP TABLE IF EXISTS `content_media`;
DROP TABLE IF EXISTS `content_terms`;
DROP TABLE IF EXISTS `content_users`;
DROP TABLE IF EXISTS `contenttabs`;
DROP TABLE IF EXISTS `customfieldgroups`;
DROP TABLE IF EXISTS `customfields`;
DROP TABLE IF EXISTS `managers`;
DROP TABLE IF EXISTS `media`;
DROP TABLE IF EXISTS `media_customfields`;
DROP TABLE IF EXISTS `media_terms`;
DROP TABLE IF EXISTS `permgroups`;
DROP TABLE IF EXISTS `perms`;
DROP TABLE IF EXISTS `settings`;
DROP TABLE IF EXISTS `statuses`;
DROP TABLE IF EXISTS `templates`;
DROP TABLE IF EXISTS `templates_contenttabs`;
DROP TABLE IF EXISTS `templates_contenttabs_parameters`;
DROP TABLE IF EXISTS `templates_customfields`;
DROP TABLE IF EXISTS `term_taxonomy`;
DROP TABLE IF EXISTS `terms`;
DROP TABLE IF EXISTS `termtaxonomy_customfields`;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS `user_customfields`;
DROP TABLE IF EXISTS `user_notes`;
DROP TABLE IF EXISTS `user_usercategories`;
DROP TABLE IF EXISTS `usercategories`;
DROP TABLE IF EXISTS `usergroup_perms`;


CREATE TABLE `colors` (
  `id` int(11) NOT NULL auto_increment,
  `value` varchar(7) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=261 DEFAULT CHARSET=utf8;


CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `contentid` int(11) NOT NULL,
  `authorname` varchar(100) NOT NULL,
  `authoremail` varchar(255) NOT NULL,
  `comment` mediumtext NOT NULL,
  `statusid` int(11) NOT NULL,
  `createdate` int(11) NOT NULL,
  `modifieddate` int(11) NOT NULL,
  `modifiedby` int(11) NOT NULL,
  `deleted` int(1) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `parentid` (`contentid`),
  KEY `comments_contentid_fk` (`contentid`),
  KEY `comments_statusid_fk` (`statusid`),
  CONSTRAINT `comments_contentid_fk` FOREIGN KEY (`contentid`) REFERENCES `content` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `comments_statusid_fk` FOREIGN KEY (`statusid`) REFERENCES `statuses` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `content` (
  `id` int(11) NOT NULL auto_increment,
  `parentid` int(11) NOT NULL,
  `revisionparentid` int(11) NOT NULL default '1',
  `is_revision` int(1) NOT NULL,
  `templateid` int(11) NOT NULL,
  `migtitle` varchar(255) NOT NULL,
  `statusid` int(11) NOT NULL,
  `containerpath` text NOT NULL,
  `deleted` int(1) NOT NULL,
  `is_fixed` int(1) NOT NULL,
  `createdby` int(11) NOT NULL,
  `createdate` int(11) NOT NULL,
  `modifieddate` int(11) NOT NULL,
  `modifiedby` int(11) NOT NULL,
  `search_exclude` int(1) NOT NULL,
  `displayorder` int(4) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` mediumtext NOT NULL,
  `short_description` mediumtext NOT NULL,
  `selections` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `parentid` (`parentid`),
  KEY `content_template_fk` (`templateid`),
  KEY `content_parent_content_fk` (`parentid`),
  KEY `content_status_fk` (`statusid`),
  KEY `content_createdby_fk` (`createdby`),
  KEY `content_modifiedby_fk` (`modifiedby`),
  KEY `content_revision_content_fk` (`revisionparentid`),
  CONSTRAINT `content_ibfk_1` FOREIGN KEY (`revisionparentid`) REFERENCES `content` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `content_createdby_fk` FOREIGN KEY (`createdby`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `content_modifiedby_fk` FOREIGN KEY (`modifiedby`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `content_parent_content_fk` FOREIGN KEY (`parentid`) REFERENCES `content` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `content_status_fk` FOREIGN KEY (`statusid`) REFERENCES `statuses` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `content_template_fk` FOREIGN KEY (`templateid`) REFERENCES `templates` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=205 DEFAULT CHARSET=latin1;


CREATE TABLE `content_content` (
  `id` int(11) NOT NULL auto_increment,
  `contentid` int(11) NOT NULL,
  `contentid2` int(11) NOT NULL,
  `desc` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `contentid` (`contentid`,`contentid2`),
  KEY `content_content_contentid_fk` (`contentid`),
  KEY `content_content_contentid2_fk` (`contentid2`),
  CONSTRAINT `content_content_contentid2_fk` FOREIGN KEY (`contentid2`) REFERENCES `content` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `content_content_contentid_fk` FOREIGN KEY (`contentid`) REFERENCES `content` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `content_customfields` (
  `id` int(11) NOT NULL auto_increment,
  `contentid` int(11) NOT NULL,
  `typeid` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `displayname` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `defaultvalue` mediumtext NOT NULL,
  `options` text NOT NULL,
  `displayorder` int(4) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `content_customfields_contentid_fk` (`contentid`),
  KEY `content_customfields_typeid_fk` (`typeid`),
  CONSTRAINT `content_customfields_contentid_fk` FOREIGN KEY (`contentid`) REFERENCES `content` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `content_customfields_typeid_fk` FOREIGN KEY (`typeid`) REFERENCES `c` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `content_media` (
  `id` int(11) NOT NULL auto_increment,
  `contentid` int(11) NOT NULL,
  `mediaid` int(11) NOT NULL,
  `statusid` int(11) NOT NULL,
  `usage_type` varchar(255) NOT NULL,
  `credits` mediumtext NOT NULL,
  `caption` varchar(255) NOT NULL,
  `displayorder` int(4) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `contentid` (`contentid`),
  KEY `mediaid` (`mediaid`),
  KEY `content_media_contentid_fk` (`contentid`),
  KEY `content_media_mediaid_fk` (`mediaid`),
  KEY `content_media_statusid_fk` (`statusid`),
  CONSTRAINT `content_media_contentid_fk` FOREIGN KEY (`contentid`) REFERENCES `content` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `content_media_mediaid_fk` FOREIGN KEY (`mediaid`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `content_media_statusid_fk` FOREIGN KEY (`statusid`) REFERENCES `statuses` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;


CREATE TABLE `content_terms` (
  `id` int(11) NOT NULL auto_increment,
  `contentid` int(11) NOT NULL,
  `termid` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `contentid` (`contentid`),
  KEY `tagid` (`termid`),
  KEY `content_terms_contentid_fk` (`contentid`),
  KEY `content_terms_termid_fk` (`termid`),
  CONSTRAINT `content_terms_contentid_fk` FOREIGN KEY (`contentid`) REFERENCES `content` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `content_terms_termid_fk` FOREIGN KEY (`termid`) REFERENCES `term_taxonomy` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `content_users` (
  `id` int(11) NOT NULL auto_increment,
  `contentid` int(11) NOT NULL,
  `userid` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `contentid` (`contentid`),
  KEY `userid` (`userid`),
  KEY `content_users_userid_fk` (`userid`),
  KEY `content_users_contentid_fk` (`contentid`),
  CONSTRAINT `content_users_contentid_fk` FOREIGN KEY (`contentid`) REFERENCES `content` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `contenttabs` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `contentview` varchar(255) default NULL,
  `itemview` varchar(255) default NULL,
  `editview` varchar(255) default NULL,
  `dto` varchar(255) default NULL,
  `tablename` varchar(255) default NULL,
  `labelfield` varchar(255) default NULL,
  `createContent` varchar(255) default NULL,
  `retrieveContent` varchar(255) default NULL,
  `updateContent` varchar(255) default NULL,
  `deleteContent` varchar(255) default NULL,
  `vars` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;


CREATE TABLE `customfieldgroups` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;


CREATE TABLE `customfields` (
  `id` int(4) NOT NULL auto_increment,
  `typeid` int(11) NOT NULL,
  `groupid` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `displayname` varchar(255) NOT NULL,
  `options` tinytext NOT NULL,
  `defaultvalue` tinytext NOT NULL,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `customfield_group_fk` (`groupid`),
  CONSTRAINT `customfield_group_fk` FOREIGN KEY (`groupid`) REFERENCES `customfieldgroups` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;


CREATE TABLE `managers` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `type` varchar(255) default NULL,
  `createContent` varchar(255) NOT NULL,
  `retrieveContent` varchar(255) default NULL,
  `updateContent` varchar(255) default NULL,
  `deleteContent` varchar(255) default NULL,
  `tablename` varchar(255) default NULL,
  `labelfield` varchar(255) default NULL,
  `customfields` varchar(255) NOT NULL default 'false',
  `cfTablename` varchar(255) default NULL,
  `cfCreateContent` varchar(255) default NULL,
  `cfRetrieveContent` varchar(255) default NULL,
  `cfUpdateContent` varchar(255) default NULL,
  `cfDeleteContent` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;


CREATE TABLE `media` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `mimetypeid` int(11) NOT NULL,
  `extension` varchar(255) NOT NULL,
  `size` int(11) NOT NULL,
  `color` varchar(7) NOT NULL,
  `width` int(11) NOT NULL,
  `height` int(11) NOT NULL,
  `playtime` float NOT NULL,
  `rating` int(11) NOT NULL,
  `path` varchar(255) NOT NULL,
  `thumb` varchar(255) NOT NULL,
  `video_proxy` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `createdby` int(11) NOT NULL,
  `createdate` bigint(20) NOT NULL,
  `modifiedby` int(11) NOT NULL,
  `modifieddate` bigint(20) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `media_createdby_fk` (`createdby`),
  KEY `media_modifiedby_fk` (`modifiedby`),
  CONSTRAINT `media_createdby_fk` FOREIGN KEY (`createdby`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `media_modifiedby_fk` FOREIGN KEY (`modifiedby`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=latin1;


CREATE TABLE `media_customfields` (
  `id` int(11) NOT NULL auto_increment,
  `customfieldid` int(11) NOT NULL,
  `fieldid` int(11) NOT NULL,
  `displayorder` int(4) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `media_customfields_customfieldid_fk` (`customfieldid`),
  CONSTRAINT `media_customfields_customfieldid_fk` FOREIGN KEY (`customfieldid`) REFERENCES `customfields` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `media_terms` (
  `id` int(11) NOT NULL auto_increment,
  `mediaid` int(11) NOT NULL,
  `termid` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `mediaid` (`mediaid`),
  KEY `termid` (`termid`),
  KEY `media_terms_mediaid_fk` (`mediaid`),
  KEY `media_terms_termid_fk` (`termid`),
  CONSTRAINT `media_terms_mediaid_fk` FOREIGN KEY (`mediaid`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `media_terms_termid_fk` FOREIGN KEY (`termid`) REFERENCES `term_taxonomy` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `permgroups` (
  `id` int(11) NOT NULL auto_increment,
  `permgroup` varchar(255) NOT NULL,
  `displayorder` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `perms` (
  `id` int(11) NOT NULL auto_increment,
  `permgroupid` int(11) NOT NULL,
  `perm` varchar(255) NOT NULL,
  `permtext` text NOT NULL,
  `displayorder` int(6) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `permgroupid` (`permgroupid`),
  KEY `perms_permgroupid_fk` (`permgroupid`),
  CONSTRAINT `perms_permgroupid_fk` FOREIGN KEY (`permgroupid`) REFERENCES `permgroups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `settings` (
  `id` int(11) NOT NULL auto_increment,
  `key` varchar(255) default NULL,
  `value` varchar(255) default NULL,
  `usage` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;


CREATE TABLE `statuses` (
  `id` int(11) NOT NULL auto_increment,
  `status` varchar(255) NOT NULL,
  `displayorder` int(4) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;


CREATE TABLE `templates` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `is_fixed` int(11) NOT NULL default '0',
  `can_have_children` int(1) NOT NULL,
  `nesting` int(11) NOT NULL default '0',
  `orderby` varchar(255) NOT NULL default 'id',
  `orderdirection` varchar(255) NOT NULL default 'ASC',
  `labelfield` varchar(255) NOT NULL default 'migtitle',
  `contentview` varchar(255) NOT NULL default 'org.mig.view.components.content.ContentView',
  `generalview` varchar(255) NOT NULL default 'org.mig.view.components.content.ContentGeneralEditor',
  `generallabel` varchar(255) NOT NULL default 'General',
  `createContent` varchar(255) NOT NULL default 'insertRecord',
  `retrieveContent` varchar(255) NOT NULL default 'getContent',
  `updateContent` varchar(255) NOT NULL default 'updateRecord',
  `deleteContent` varchar(255) NOT NULL default 'deleteContent',
  `verbosity` int(1) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;


CREATE TABLE `templates_contenttabs` (
  `id` int(11) NOT NULL auto_increment,
  `templateid` int(11) NOT NULL,
  `tabid` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `templateid` (`templateid`),
  KEY `tabid` (`tabid`),
  CONSTRAINT `template_contenttabs_tabid_fk` FOREIGN KEY (`tabid`) REFERENCES `contenttabs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `template_contenttabs_templateid_fk` FOREIGN KEY (`templateid`) REFERENCES `templates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;


CREATE TABLE `templates_contenttabs_parameters` (
  `id` int(11) NOT NULL auto_increment,
  `templateid` int(11) NOT NULL,
  `tabid` int(11) NOT NULL,
  `is_label` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `param1` varchar(255) NOT NULL,
  `param2` varchar(255) NOT NULL,
  `param3` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `templateid_fk` (`templateid`),
  KEY `tabid_fk` (`tabid`),
  CONSTRAINT `templates_contenttabs_parameters_ibfk_1` FOREIGN KEY (`templateid`) REFERENCES `templates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `templates_contenttabs_parameters_ibfk_2` FOREIGN KEY (`tabid`) REFERENCES `contenttabs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;


CREATE TABLE `templates_customfields` (
  `id` int(11) NOT NULL auto_increment,
  `templateid` int(11) NOT NULL,
  `customfieldid` int(11) NOT NULL,
  `displayorder` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `templateid` (`templateid`),
  KEY `customfieldid` (`customfieldid`),
  KEY `template_customfields_templateid_fk` (`templateid`),
  KEY `template_customfields_customfieldid_fk` (`customfieldid`),
  CONSTRAINT `template_customfields_customfieldid_fk` FOREIGN KEY (`customfieldid`) REFERENCES `customfields` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `template_customfields_templateid_fk` FOREIGN KEY (`templateid`) REFERENCES `templates` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8;


CREATE TABLE `term_taxonomy` (
  `id` int(11) NOT NULL auto_increment,
  `parentid` int(11) NOT NULL,
  `termid` int(11) NOT NULL,
  `taxonomy` varchar(32) NOT NULL default '',
  `description` longtext NOT NULL,
  `displayorder` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `termid` (`termid`),
  KEY `parentid` (`parentid`),
  KEY `term_taxonomy_termid_fk` (`termid`),
  KEY `term_taxonomy_parent_term_taxonomy_fk` (`parentid`),
  CONSTRAINT `term_taxonomy_parent_term_taxonomy_fk` FOREIGN KEY (`parentid`) REFERENCES `term_taxonomy` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `term_taxonomy_termid_fk` FOREIGN KEY (`termid`) REFERENCES `terms` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1;


CREATE TABLE `terms` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=latin1;


CREATE TABLE `termtaxonomy_customfields` (
  `id` int(11) NOT NULL auto_increment,
  `customfieldid` int(11) NOT NULL,
  `fieldid` int(11) NOT NULL,
  `displayorder` int(4) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `termtaxonomy_customfields_customfieldid_fk` (`customfieldid`),
  CONSTRAINT `termtaxonomy_customfields_customfieldid_fk` FOREIGN KEY (`customfieldid`) REFERENCES `customfields` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `user` (
  `id` int(11) NOT NULL auto_increment,
  `miggroup` int(1) NOT NULL,
  `privilegeid` int(11) NOT NULL,
  `firstname` varchar(255) character set latin1 NOT NULL,
  `lastname` varchar(255) character set latin1 NOT NULL,
  `username` varchar(255) character set latin1 NOT NULL,
  `email` varchar(255) character set latin1 NOT NULL,
  `password` varchar(255) character set latin1 NOT NULL,
  `lastlogin` int(11) NOT NULL,
  `active` int(2) NOT NULL,
  `createdby` int(11) NOT NULL,
  `createdate` int(11) NOT NULL,
  `modifiedby` int(11) NOT NULL,
  `modifieddate` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `user_createdby_fk` (`createdby`),
  KEY `user_modifiedby_fk` (`modifiedby`),
  CONSTRAINT `user_createdby_fk` FOREIGN KEY (`createdby`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `user_modifiedby_fk` FOREIGN KEY (`modifiedby`) REFERENCES `user` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;


CREATE TABLE `user_customfields` (
  `id` int(11) NOT NULL auto_increment,
  `customfieldid` int(11) NOT NULL,
  `fieldid` int(11) NOT NULL,
  `displayorder` int(4) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `user_customfields_customfieldid_fk` (`customfieldid`),
  CONSTRAINT `user_customfields_customfieldid_fk` FOREIGN KEY (`customfieldid`) REFERENCES `customfields` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `user_notes` (
  `id` int(11) NOT NULL auto_increment,
  `userid` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` mediumtext NOT NULL,
  KEY `id` (`id`),
  KEY `user_notes_userid_fk` (`userid`),
  CONSTRAINT `user_notes_userid_fk` FOREIGN KEY (`userid`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `user_usercategories` (
  `id` int(11) NOT NULL auto_increment,
  `userid` int(11) NOT NULL,
  `categoryid` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `userid` (`userid`),
  KEY `categoryid` (`categoryid`),
  KEY `user_usercategories_userid_fk` (`userid`),
  KEY `user_usercategories_categoryid_fk` (`categoryid`),
  CONSTRAINT `userusercategories_categoryid_fk` FOREIGN KEY (`categoryid`) REFERENCES `usercategories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `userusercategories_userid_fk` FOREIGN KEY (`userid`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `usercategories` (
  `id` int(11) NOT NULL auto_increment,
  `miggroup` int(1) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `usergroup_perms` (
  `id` int(11) NOT NULL auto_increment,
  `privilegeid` int(11) NOT NULL,
  `permid` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  KEY `permid` (`permid`),
  KEY `usergroup_perms_permid_fk` (`permid`),
  CONSTRAINT `usergroup_perms_permid_fk` FOREIGN KEY (`permid`) REFERENCES `perms` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;




SET FOREIGN_KEY_CHECKS = 0;


LOCK TABLES `colors` WRITE;
INSERT INTO `colors` (`id`, `value`) VALUES (1, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (2, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (3, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (4, '#3300');
INSERT INTO `colors` (`id`, `value`) VALUES (5, '#6600');
INSERT INTO `colors` (`id`, `value`) VALUES (6, '#9900');
INSERT INTO `colors` (`id`, `value`) VALUES (7, '#cc00');
INSERT INTO `colors` (`id`, `value`) VALUES (8, '#ff00');
INSERT INTO `colors` (`id`, `value`) VALUES (9, '#330000');
INSERT INTO `colors` (`id`, `value`) VALUES (10, '#333300');
INSERT INTO `colors` (`id`, `value`) VALUES (11, '#336600');
INSERT INTO `colors` (`id`, `value`) VALUES (12, '#339900');
INSERT INTO `colors` (`id`, `value`) VALUES (13, '#33cc00');
INSERT INTO `colors` (`id`, `value`) VALUES (14, '#33ff00');
INSERT INTO `colors` (`id`, `value`) VALUES (15, '#660000');
INSERT INTO `colors` (`id`, `value`) VALUES (16, '#663300');
INSERT INTO `colors` (`id`, `value`) VALUES (17, '#666600');
INSERT INTO `colors` (`id`, `value`) VALUES (18, '#669900');
INSERT INTO `colors` (`id`, `value`) VALUES (19, '#66cc00');
INSERT INTO `colors` (`id`, `value`) VALUES (20, '#66ff00');
INSERT INTO `colors` (`id`, `value`) VALUES (21, '#333333');
INSERT INTO `colors` (`id`, `value`) VALUES (22, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (23, '#33');
INSERT INTO `colors` (`id`, `value`) VALUES (24, '#3333');
INSERT INTO `colors` (`id`, `value`) VALUES (25, '#6633');
INSERT INTO `colors` (`id`, `value`) VALUES (26, '#9933');
INSERT INTO `colors` (`id`, `value`) VALUES (27, '#cc33');
INSERT INTO `colors` (`id`, `value`) VALUES (28, '#ff33');
INSERT INTO `colors` (`id`, `value`) VALUES (29, '#330033');
INSERT INTO `colors` (`id`, `value`) VALUES (30, '#333333');
INSERT INTO `colors` (`id`, `value`) VALUES (31, '#336633');
INSERT INTO `colors` (`id`, `value`) VALUES (32, '#339933');
INSERT INTO `colors` (`id`, `value`) VALUES (33, '#33cc33');
INSERT INTO `colors` (`id`, `value`) VALUES (34, '#33ff33');
INSERT INTO `colors` (`id`, `value`) VALUES (35, '#660033');
INSERT INTO `colors` (`id`, `value`) VALUES (36, '#663333');
INSERT INTO `colors` (`id`, `value`) VALUES (37, '#666633');
INSERT INTO `colors` (`id`, `value`) VALUES (38, '#669933');
INSERT INTO `colors` (`id`, `value`) VALUES (39, '#66cc33');
INSERT INTO `colors` (`id`, `value`) VALUES (40, '#66ff33');
INSERT INTO `colors` (`id`, `value`) VALUES (41, '#666666');
INSERT INTO `colors` (`id`, `value`) VALUES (42, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (43, '#66');
INSERT INTO `colors` (`id`, `value`) VALUES (44, '#3366');
INSERT INTO `colors` (`id`, `value`) VALUES (45, '#6666');
INSERT INTO `colors` (`id`, `value`) VALUES (46, '#9966');
INSERT INTO `colors` (`id`, `value`) VALUES (47, '#cc66');
INSERT INTO `colors` (`id`, `value`) VALUES (48, '#ff66');
INSERT INTO `colors` (`id`, `value`) VALUES (49, '#330066');
INSERT INTO `colors` (`id`, `value`) VALUES (50, '#333366');
INSERT INTO `colors` (`id`, `value`) VALUES (51, '#336666');
INSERT INTO `colors` (`id`, `value`) VALUES (52, '#339966');
INSERT INTO `colors` (`id`, `value`) VALUES (53, '#33cc66');
INSERT INTO `colors` (`id`, `value`) VALUES (54, '#33ff66');
INSERT INTO `colors` (`id`, `value`) VALUES (55, '#660066');
INSERT INTO `colors` (`id`, `value`) VALUES (56, '#663366');
INSERT INTO `colors` (`id`, `value`) VALUES (57, '#666666');
INSERT INTO `colors` (`id`, `value`) VALUES (58, '#669966');
INSERT INTO `colors` (`id`, `value`) VALUES (59, '#66cc66');
INSERT INTO `colors` (`id`, `value`) VALUES (60, '#66ff66');
INSERT INTO `colors` (`id`, `value`) VALUES (61, '#999999');
INSERT INTO `colors` (`id`, `value`) VALUES (62, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (63, '#99');
INSERT INTO `colors` (`id`, `value`) VALUES (64, '#3399');
INSERT INTO `colors` (`id`, `value`) VALUES (65, '#6699');
INSERT INTO `colors` (`id`, `value`) VALUES (66, '#9999');
INSERT INTO `colors` (`id`, `value`) VALUES (67, '#cc99');
INSERT INTO `colors` (`id`, `value`) VALUES (68, '#ff99');
INSERT INTO `colors` (`id`, `value`) VALUES (69, '#330099');
INSERT INTO `colors` (`id`, `value`) VALUES (70, '#333399');
INSERT INTO `colors` (`id`, `value`) VALUES (71, '#336699');
INSERT INTO `colors` (`id`, `value`) VALUES (72, '#339999');
INSERT INTO `colors` (`id`, `value`) VALUES (73, '#33cc99');
INSERT INTO `colors` (`id`, `value`) VALUES (74, '#33ff99');
INSERT INTO `colors` (`id`, `value`) VALUES (75, '#660099');
INSERT INTO `colors` (`id`, `value`) VALUES (76, '#663399');
INSERT INTO `colors` (`id`, `value`) VALUES (77, '#666699');
INSERT INTO `colors` (`id`, `value`) VALUES (78, '#669999');
INSERT INTO `colors` (`id`, `value`) VALUES (79, '#66cc99');
INSERT INTO `colors` (`id`, `value`) VALUES (80, '#66ff99');
INSERT INTO `colors` (`id`, `value`) VALUES (81, '#cccccc');
INSERT INTO `colors` (`id`, `value`) VALUES (82, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (83, '#cc');
INSERT INTO `colors` (`id`, `value`) VALUES (84, '#33cc');
INSERT INTO `colors` (`id`, `value`) VALUES (85, '#66cc');
INSERT INTO `colors` (`id`, `value`) VALUES (86, '#99cc');
INSERT INTO `colors` (`id`, `value`) VALUES (87, '#cccc');
INSERT INTO `colors` (`id`, `value`) VALUES (88, '#ffcc');
INSERT INTO `colors` (`id`, `value`) VALUES (89, '#3300cc');
INSERT INTO `colors` (`id`, `value`) VALUES (90, '#3333cc');
INSERT INTO `colors` (`id`, `value`) VALUES (91, '#3366cc');
INSERT INTO `colors` (`id`, `value`) VALUES (92, '#3399cc');
INSERT INTO `colors` (`id`, `value`) VALUES (93, '#33cccc');
INSERT INTO `colors` (`id`, `value`) VALUES (94, '#33ffcc');
INSERT INTO `colors` (`id`, `value`) VALUES (95, '#6600cc');
INSERT INTO `colors` (`id`, `value`) VALUES (96, '#6633cc');
INSERT INTO `colors` (`id`, `value`) VALUES (97, '#6666cc');
INSERT INTO `colors` (`id`, `value`) VALUES (98, '#6699cc');
INSERT INTO `colors` (`id`, `value`) VALUES (99, '#66cccc');
INSERT INTO `colors` (`id`, `value`) VALUES (100, '#66ffcc');
INSERT INTO `colors` (`id`, `value`) VALUES (101, '#ffffff');
INSERT INTO `colors` (`id`, `value`) VALUES (102, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (103, '#ff');
INSERT INTO `colors` (`id`, `value`) VALUES (104, '#33ff');
INSERT INTO `colors` (`id`, `value`) VALUES (105, '#66ff');
INSERT INTO `colors` (`id`, `value`) VALUES (106, '#99ff');
INSERT INTO `colors` (`id`, `value`) VALUES (107, '#ccff');
INSERT INTO `colors` (`id`, `value`) VALUES (108, '#ffff');
INSERT INTO `colors` (`id`, `value`) VALUES (109, '#3300ff');
INSERT INTO `colors` (`id`, `value`) VALUES (110, '#3333ff');
INSERT INTO `colors` (`id`, `value`) VALUES (111, '#3366ff');
INSERT INTO `colors` (`id`, `value`) VALUES (112, '#3399ff');
INSERT INTO `colors` (`id`, `value`) VALUES (113, '#33ccff');
INSERT INTO `colors` (`id`, `value`) VALUES (114, '#33ffff');
INSERT INTO `colors` (`id`, `value`) VALUES (115, '#6600ff');
INSERT INTO `colors` (`id`, `value`) VALUES (116, '#6633ff');
INSERT INTO `colors` (`id`, `value`) VALUES (117, '#6666ff');
INSERT INTO `colors` (`id`, `value`) VALUES (118, '#6699ff');
INSERT INTO `colors` (`id`, `value`) VALUES (119, '#66ccff');
INSERT INTO `colors` (`id`, `value`) VALUES (120, '#66ffff');
INSERT INTO `colors` (`id`, `value`) VALUES (121, '#ff0000');
INSERT INTO `colors` (`id`, `value`) VALUES (122, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (123, '#990000');
INSERT INTO `colors` (`id`, `value`) VALUES (124, '#993300');
INSERT INTO `colors` (`id`, `value`) VALUES (125, '#996600');
INSERT INTO `colors` (`id`, `value`) VALUES (126, '#999900');
INSERT INTO `colors` (`id`, `value`) VALUES (127, '#99cc00');
INSERT INTO `colors` (`id`, `value`) VALUES (128, '#99ff00');
INSERT INTO `colors` (`id`, `value`) VALUES (129, '#cc0000');
INSERT INTO `colors` (`id`, `value`) VALUES (130, '#cc3300');
INSERT INTO `colors` (`id`, `value`) VALUES (131, '#cc6600');
INSERT INTO `colors` (`id`, `value`) VALUES (132, '#cc9900');
INSERT INTO `colors` (`id`, `value`) VALUES (133, '#cccc00');
INSERT INTO `colors` (`id`, `value`) VALUES (134, '#ccff00');
INSERT INTO `colors` (`id`, `value`) VALUES (135, '#ff0000');
INSERT INTO `colors` (`id`, `value`) VALUES (136, '#ff3300');
INSERT INTO `colors` (`id`, `value`) VALUES (137, '#ff6600');
INSERT INTO `colors` (`id`, `value`) VALUES (138, '#ff9900');
INSERT INTO `colors` (`id`, `value`) VALUES (139, '#ffcc00');
INSERT INTO `colors` (`id`, `value`) VALUES (140, '#ffff00');
INSERT INTO `colors` (`id`, `value`) VALUES (141, '#ff00');
INSERT INTO `colors` (`id`, `value`) VALUES (142, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (143, '#990033');
INSERT INTO `colors` (`id`, `value`) VALUES (144, '#993333');
INSERT INTO `colors` (`id`, `value`) VALUES (145, '#996633');
INSERT INTO `colors` (`id`, `value`) VALUES (146, '#999933');
INSERT INTO `colors` (`id`, `value`) VALUES (147, '#99cc33');
INSERT INTO `colors` (`id`, `value`) VALUES (148, '#99ff33');
INSERT INTO `colors` (`id`, `value`) VALUES (149, '#cc0033');
INSERT INTO `colors` (`id`, `value`) VALUES (150, '#cc3333');
INSERT INTO `colors` (`id`, `value`) VALUES (151, '#cc6633');
INSERT INTO `colors` (`id`, `value`) VALUES (152, '#cc9933');
INSERT INTO `colors` (`id`, `value`) VALUES (153, '#cccc33');
INSERT INTO `colors` (`id`, `value`) VALUES (154, '#ccff33');
INSERT INTO `colors` (`id`, `value`) VALUES (155, '#ff0033');
INSERT INTO `colors` (`id`, `value`) VALUES (156, '#ff3333');
INSERT INTO `colors` (`id`, `value`) VALUES (157, '#ff6633');
INSERT INTO `colors` (`id`, `value`) VALUES (158, '#ff9933');
INSERT INTO `colors` (`id`, `value`) VALUES (159, '#ffcc33');
INSERT INTO `colors` (`id`, `value`) VALUES (160, '#ffff33');
INSERT INTO `colors` (`id`, `value`) VALUES (161, '#ff');
INSERT INTO `colors` (`id`, `value`) VALUES (162, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (163, '#990066');
INSERT INTO `colors` (`id`, `value`) VALUES (164, '#993366');
INSERT INTO `colors` (`id`, `value`) VALUES (165, '#996666');
INSERT INTO `colors` (`id`, `value`) VALUES (166, '#999966');
INSERT INTO `colors` (`id`, `value`) VALUES (167, '#99cc66');
INSERT INTO `colors` (`id`, `value`) VALUES (168, '#99ff66');
INSERT INTO `colors` (`id`, `value`) VALUES (169, '#cc0066');
INSERT INTO `colors` (`id`, `value`) VALUES (170, '#cc3366');
INSERT INTO `colors` (`id`, `value`) VALUES (171, '#cc6666');
INSERT INTO `colors` (`id`, `value`) VALUES (172, '#cc9966');
INSERT INTO `colors` (`id`, `value`) VALUES (173, '#cccc66');
INSERT INTO `colors` (`id`, `value`) VALUES (174, '#ccff66');
INSERT INTO `colors` (`id`, `value`) VALUES (175, '#ff0066');
INSERT INTO `colors` (`id`, `value`) VALUES (176, '#ff3366');
INSERT INTO `colors` (`id`, `value`) VALUES (177, '#ff6666');
INSERT INTO `colors` (`id`, `value`) VALUES (178, '#ff9966');
INSERT INTO `colors` (`id`, `value`) VALUES (179, '#ffcc66');
INSERT INTO `colors` (`id`, `value`) VALUES (180, '#ffff66');
INSERT INTO `colors` (`id`, `value`) VALUES (181, '#ffff00');
INSERT INTO `colors` (`id`, `value`) VALUES (182, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (183, '#990099');
INSERT INTO `colors` (`id`, `value`) VALUES (184, '#993399');
INSERT INTO `colors` (`id`, `value`) VALUES (185, '#996699');
INSERT INTO `colors` (`id`, `value`) VALUES (186, '#999999');
INSERT INTO `colors` (`id`, `value`) VALUES (187, '#99cc99');
INSERT INTO `colors` (`id`, `value`) VALUES (188, '#99ff99');
INSERT INTO `colors` (`id`, `value`) VALUES (189, '#cc0099');
INSERT INTO `colors` (`id`, `value`) VALUES (190, '#cc3399');
INSERT INTO `colors` (`id`, `value`) VALUES (191, '#cc6699');
INSERT INTO `colors` (`id`, `value`) VALUES (192, '#cc9999');
INSERT INTO `colors` (`id`, `value`) VALUES (193, '#cccc99');
INSERT INTO `colors` (`id`, `value`) VALUES (194, '#ccff99');
INSERT INTO `colors` (`id`, `value`) VALUES (195, '#ff0099');
INSERT INTO `colors` (`id`, `value`) VALUES (196, '#ff3399');
INSERT INTO `colors` (`id`, `value`) VALUES (197, '#ff6699');
INSERT INTO `colors` (`id`, `value`) VALUES (198, '#ff9999');
INSERT INTO `colors` (`id`, `value`) VALUES (199, '#ffcc99');
INSERT INTO `colors` (`id`, `value`) VALUES (200, '#ffff99');
INSERT INTO `colors` (`id`, `value`) VALUES (201, '#ffff');
INSERT INTO `colors` (`id`, `value`) VALUES (202, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (203, '#9900cc');
INSERT INTO `colors` (`id`, `value`) VALUES (204, '#9933cc');
INSERT INTO `colors` (`id`, `value`) VALUES (205, '#9966cc');
INSERT INTO `colors` (`id`, `value`) VALUES (206, '#9999cc');
INSERT INTO `colors` (`id`, `value`) VALUES (207, '#99cccc');
INSERT INTO `colors` (`id`, `value`) VALUES (208, '#99ffcc');
INSERT INTO `colors` (`id`, `value`) VALUES (209, '#cc00cc');
INSERT INTO `colors` (`id`, `value`) VALUES (210, '#cc33cc');
INSERT INTO `colors` (`id`, `value`) VALUES (211, '#cc66cc');
INSERT INTO `colors` (`id`, `value`) VALUES (212, '#cc99cc');
INSERT INTO `colors` (`id`, `value`) VALUES (213, '#cccccc');
INSERT INTO `colors` (`id`, `value`) VALUES (214, '#ccffcc');
INSERT INTO `colors` (`id`, `value`) VALUES (215, '#ff00cc');
INSERT INTO `colors` (`id`, `value`) VALUES (216, '#ff33cc');
INSERT INTO `colors` (`id`, `value`) VALUES (217, '#ff66cc');
INSERT INTO `colors` (`id`, `value`) VALUES (218, '#ff99cc');
INSERT INTO `colors` (`id`, `value`) VALUES (219, '#ffcccc');
INSERT INTO `colors` (`id`, `value`) VALUES (220, '#ffffcc');
INSERT INTO `colors` (`id`, `value`) VALUES (221, '#ff00ff');
INSERT INTO `colors` (`id`, `value`) VALUES (222, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (223, '#9900ff');
INSERT INTO `colors` (`id`, `value`) VALUES (224, '#9933ff');
INSERT INTO `colors` (`id`, `value`) VALUES (225, '#9966ff');
INSERT INTO `colors` (`id`, `value`) VALUES (226, '#9999ff');
INSERT INTO `colors` (`id`, `value`) VALUES (227, '#99ccff');
INSERT INTO `colors` (`id`, `value`) VALUES (228, '#99ffff');
INSERT INTO `colors` (`id`, `value`) VALUES (229, '#cc00ff');
INSERT INTO `colors` (`id`, `value`) VALUES (230, '#cc33ff');
INSERT INTO `colors` (`id`, `value`) VALUES (231, '#cc66ff');
INSERT INTO `colors` (`id`, `value`) VALUES (232, '#cc99ff');
INSERT INTO `colors` (`id`, `value`) VALUES (233, '#ccccff');
INSERT INTO `colors` (`id`, `value`) VALUES (234, '#ccffff');
INSERT INTO `colors` (`id`, `value`) VALUES (235, '#ff00ff');
INSERT INTO `colors` (`id`, `value`) VALUES (236, '#ff33ff');
INSERT INTO `colors` (`id`, `value`) VALUES (237, '#ff66ff');
INSERT INTO `colors` (`id`, `value`) VALUES (238, '#ff99ff');
INSERT INTO `colors` (`id`, `value`) VALUES (239, '#ffccff');
INSERT INTO `colors` (`id`, `value`) VALUES (240, '#ffffff');
INSERT INTO `colors` (`id`, `value`) VALUES (241, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (242, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (243, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (244, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (245, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (246, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (247, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (248, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (249, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (250, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (251, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (252, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (253, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (254, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (255, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (256, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (257, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (258, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (259, '#0');
INSERT INTO `colors` (`id`, `value`) VALUES (260, '#0');
UNLOCK TABLES;


LOCK TABLES `comments` WRITE;
UNLOCK TABLES;


LOCK TABLES `content` WRITE;
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (1, 1, 1, 0, 1, 'Containers', 4, 'Containers', 0, 1, 1, 0, 0, 1, 1, 0, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (2, 1, 1, 0, 2, 'Projects', 4, 'Containers', 0, 1, 1, 0, 1269465079, 1, 1, 1, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (3, 1, 1, 0, 2, 'Posts', 4, 'Containers
', 0, 1, 1, 0, 1269465079, 1, 1, 2, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (4, 2, 1, 0, 3, 'Fitbit Tracker', 4, 'Containers<>Projects', 0, 0, 1, 1267733775, 1270076443, 1, 0, 2, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (5, 2, 1, 0, 3, 'Dell Studio Hybrid', 4, 'Containers<>Projects', 0, 0, 1, 1267733782, 1269960909, 1, 0, 3, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (6, 2, 1, 0, 3, 'Ogo', 4, 'Containers<>Projects', 0, 0, 1, 1267733790, 1269960920, 1, 0, 4, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (7, 2, 1, 0, 3, 'Tana Water Bar', 4, 'Containers<>Projects', 0, 0, 1, 1267733775, 1268923510, 1, 0, 1, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (10, 2, 1, 0, 3, 'Memorex Clock', 4, 'Containers<>Projects', 0, 0, 1, 1269027605, 1269563404, 1, 0, 6, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (11, 2, 1, 0, 3, 'Glide TV', 4, 'Containers<>Projects', 0, 0, 1, 1269032892, 1269046255, 1, 0, 7, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (12, 2, 1, 0, 3, 'Cocoon', 4, 'Containers<>Projects', 0, 0, 1, 1269033310, 1269046255, 1, 0, 8, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (13, 2, 1, 0, 3, 'Fujitsu Phones', 4, 'Containers<>Projects', 0, 0, 1, 1269037352, 1269046255, 1, 0, 9, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (14, 2, 1, 0, 3, 'Dell Latitude', 4, 'Containers<>Projects', 0, 0, 1, 1269039248, 1269622692, 1, 0, 10, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (15, 2, 1, 0, 3, 'Netgear', 4, 'Containers<>Projects', 0, 0, 1, 1269040389, 1269046255, 1, 0, 11, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (16, 2, 1, 0, 3, 'Sling Media', 4, 'Containers<>Projects', 0, 0, 1, 1269044543, 1269046255, 1, 0, 12, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (17, 2, 1, 0, 3, 'Logitech', 4, 'Containers<>Projects', 0, 0, 1, 1269046254, 1269635596, 1, 0, 1, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (177, 3, 1, 0, 4, 'Fire, Agriculture, Design: How Human Creativity Built Society', 4, 'Containers<>Posts', 0, 0, 1, 1267733885, 1269634962, 1, 0, 7, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (178, 3, 1, 0, 4, 'Apple may change the world&#8230; again.', 4, 'Containers<>Posts', 0, 0, 1, 1267733893, 1269642124, 1, 0, 8, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (179, 3, 1, 0, 4, 'Making sense of Design Thinking: Three definitions, two problems and one big question', 4, 'Containers<>Posts', 0, 0, 1, 1267733899, 1269044089, 1, 0, 9, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (180, 3, 1, 0, 4, 'Dear Gadget Reviewers: You Don\\\'t Understand Beauty', 4, 'Containers<>Posts', 0, 0, 1, 1269042460, 1269044089, 1, 0, 6, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (181, 3, 1, 0, 4, 'Team', 1, 'Containers<>Posts', 0, 0, 1, 1269042927, 1269043262, 1, 0, 1, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (182, 3, 1, 0, 4, 'Looking at the Micro vs. the Macro in Design', 4, 'Containers<>Posts', 0, 0, 1, 1269043323, 1269642183, 1, 0, 5, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (183, 3, 1, 0, 4, '\\"Shop Class as Soulcraft\\": A Book That Revels in Alternative Thinking for Designers', 4, 'Containers<>Posts', 0, 0, 1, 1269043499, 1269044089, 1, 0, 4, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (184, 3, 1, 0, 4, 'Body Computing Is a Glimmer of Hope in the Health-Care Chasm', 4, 'Containers<>Posts', 0, 0, 1, 1269043664, 1269044089, 1, 0, 3, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (185, 3, 1, 0, 4, 'In Defense of Slapping a Robot', 4, 'Containers<>Posts', 0, 0, 1, 1269043884, 1269642214, 1, 0, 2, '', '', '', '');
INSERT INTO `content` (`id`, `parentid`, `revisionparentid`, `is_revision`, `templateid`, `migtitle`, `statusid`, `containerpath`, `deleted`, `is_fixed`, `createdby`, `createdate`, `modifieddate`, `modifiedby`, `search_exclude`, `displayorder`, `title`, `description`, `short_description`, `selections`) VALUES (186, 3, 1, 0, 4, 'How Should We Define \\"Design\\"?', 4, 'Containers<>Posts', 0, 0, 1, 1269044089, 1269044230, 1, 0, 1, '', '', '', '');
UNLOCK TABLES;


LOCK TABLES `content_content` WRITE;
UNLOCK TABLES;


LOCK TABLES `content_customfields` WRITE;
UNLOCK TABLES;


LOCK TABLES `content_media` WRITE;
INSERT INTO `content_media` (`id`, `contentid`, `mediaid`, `statusid`, `usage_type`, `credits`, `caption`, `displayorder`) VALUES (1, 4, 1, 4, 'thumb', '', '', 1);
UNLOCK TABLES;


LOCK TABLES `content_terms` WRITE;
UNLOCK TABLES;


LOCK TABLES `content_users` WRITE;
UNLOCK TABLES;


LOCK TABLES `contenttabs` WRITE;
INSERT INTO `contenttabs` (`id`, `name`, `contentview`, `itemview`, `editview`, `dto`, `tablename`, `labelfield`, `createContent`, `retrieveContent`, `updateContent`, `deleteContent`, `vars`) VALUES (1, 'Media', 'org.mig.view.components.content.media.MediaTab', 'org.mig.view.components.content.media.MediaTabAnimatedListRenderer', 'org.mig.view.components.managers.templates.tabs.TemplateMediaTab', 'org.mig.model.vo.relational.ContentMedia', 'content_media', 'name', 'insertRecord', 'getContentMedia', 'updateRecord', 'deleteRecord', 'contentid');
INSERT INTO `contenttabs` (`id`, `name`, `contentview`, `itemview`, `editview`, `dto`, `tablename`, `labelfield`, `createContent`, `retrieveContent`, `updateContent`, `deleteContent`, `vars`) VALUES (2, 'Tags &amp; Categories', 'org.mig.view.components.content.tabs.TagsCategoriesTab', 'com.mapx.view.content.trays.TagView', 'org.mig.view.components.managers.templates.tabs.TemplateTermsTab', 'org.mig.model.vo.content.ContainerData', 'content_terms', 'name', 'insertRecord', 'getContentTags', 'updateContentRecord', 'deleteRecord', 'contentid');
UNLOCK TABLES;


LOCK TABLES `customfieldgroups` WRITE;
INSERT INTO `customfieldgroups` (`id`, `name`) VALUES (1, 'content');
INSERT INTO `customfieldgroups` (`id`, `name`) VALUES (2, 'media');
INSERT INTO `customfieldgroups` (`id`, `name`) VALUES (3, 'terms');
INSERT INTO `customfieldgroups` (`id`, `name`) VALUES (4, 'users');
UNLOCK TABLES;


LOCK TABLES `customfields` WRITE;
INSERT INTO `customfields` (`id`, `typeid`, `groupid`, `name`, `displayname`, `options`, `defaultvalue`, `description`) VALUES (22, 3, 1, 'title', 'Title', '', '', '');
INSERT INTO `customfields` (`id`, `typeid`, `groupid`, `name`, `displayname`, `options`, `defaultvalue`, `description`) VALUES (23, 4, 1, 'description', 'Description', '', '', '');
INSERT INTO `customfields` (`id`, `typeid`, `groupid`, `name`, `displayname`, `options`, `defaultvalue`, `description`) VALUES (24, 7, 1, 'short_description', 'Short Description', '', '', '');
INSERT INTO `customfields` (`id`, `typeid`, `groupid`, `name`, `displayname`, `options`, `defaultvalue`, `description`) VALUES (26, 5, 1, 'selections', 'Selections', '1=Option2,2=Optionf,3=Option4', '1,2', '');
UNLOCK TABLES;


LOCK TABLES `managers` WRITE;
INSERT INTO `managers` (`id`, `name`, `type`, `createContent`, `retrieveContent`, `updateContent`, `deleteContent`, `tablename`, `labelfield`, `customfields`, `cfTablename`, `cfCreateContent`, `cfRetrieveContent`, `cfUpdateContent`, `cfDeleteContent`) VALUES (1, 'Templates', 'templatesConfig', 'insertRecord', 'getData', 'updateRecord', 'deleteRecord', 'templates', 'name', 'true', 'templates_customfields', 'insertCustomField', 'getData', 'updateCustomField', 'deleteCustomField');
INSERT INTO `managers` (`id`, `name`, `type`, `createContent`, `retrieveContent`, `updateContent`, `deleteContent`, `tablename`, `labelfield`, `customfields`, `cfTablename`, `cfCreateContent`, `cfRetrieveContent`, `cfUpdateContent`, `cfDeleteContent`) VALUES (2, 'Tags & Categories', 'termsConfig', 'insertTag', 'getTerms', 'updateTag', 'deleteTag', '', 'name', 'true', 'termtaxonomy_customfields', 'insertRecord', 'getData', 'updateRecord', 'deleteRecord');
INSERT INTO `managers` (`id`, `name`, `type`, `createContent`, `retrieveContent`, `updateContent`, `deleteContent`, `tablename`, `labelfield`, `customfields`, `cfTablename`, `cfCreateContent`, `cfRetrieveContent`, `cfUpdateContent`, `cfDeleteContent`) VALUES (3, 'Media', 'mediaConfig', 'insertRecord', 'getData', 'updateRecord,updateMediaByPath', 'deleteRecord,deleteMediaByPath', 'media', 'name', 'false', '', '', '', '', '');
UNLOCK TABLES;


LOCK TABLES `media` WRITE;
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (1, 'Fitbit_01b.jpg', '', 1, 'jpg', 73728, '', 1500, 900, 0, 2, '/projects/fitbit/', 'Fitbit_01b.jpg', 'false', '', 1, 1276547640, 1, 1276547640);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (2, 'Fitbit_02.jpg', '', 1, 'jpg', 57344, '', 1000, 620, 0, 3, '/projects/fitbit/', 'Fitbit_02.jpg', 'false', '', 1, 1276547641, 1, 1276547641);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (3, 'Fitbit_02b.jpg', '', 1, 'jpg', 81920, '', 1500, 900, 0, 0, '/projects/fitbit/', 'Fitbit_02b.jpg', 'false', '', 1, 1276547642, 1, 1276547642);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (4, 'Fitbit_03.jpg', '', 1, 'jpg', 61440, '', 1000, 620, 0, 1, '/projects/fitbit/', 'Fitbit_03.jpg', 'false', '', 1, 1276547642, 1, 1276547642);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (5, 'Fitbit_03b.jpg', '', 1, 'jpg', 65536, '', 1500, 900, 0, 2, '/projects/fitbit/', 'Fitbit_03b.jpg', 'false', '', 1, 1276547643, 1, 1276547643);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (6, 'Fitbit_04.jpg', '', 1, 'jpg', 372736, '', 1000, 620, 0, 3, '/projects/fitbit/', 'Fitbit_04.jpg', 'false', '', 1, 1276547645, 1, 1276547645);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (7, 'Fitbit_04b.jpg', '', 1, 'jpg', 307200, '', 1500, 900, 0, 3, '/projects/fitbit/', 'Fitbit_04b.jpg', 'false', '', 1, 1276547647, 1, 1276547647);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (8, 'Fitbit_05.jpg', '', 1, 'jpg', 102400, '', 1000, 620, 0, 2, '/projects/fitbit/', 'Fitbit_05.jpg', 'false', '', 1, 1276547648, 1, 1276547648);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (9, 'Fitbit_06.jpg', '', 1, 'jpg', 69632, '', 1000, 620, 0, 5, '/projects/fitbit/', 'Fitbit_06.jpg', 'false', '', 1, 1276547649, 1, 1276547649);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (10, 'Fitbit_06b.jpg', '', 1, 'jpg', 94208, '', 1500, 900, 0, 3, '/projects/fitbit/', 'Fitbit_06b.jpg', 'false', '', 1, 1276547650, 1, 1276547650);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (11, 'fitbit_5156.mov', '', 2, 'mov', 8687616, '', 0, 0, 60, 4, '/projects/fitbit/', '', 'false', '', 1, 1276547688, 1, 1276547688);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (12, 'Fitbit_thumb.jpg', '', 1, 'jpg', 8192, '', 155, 110, 0, 1, '/projects/fitbit/', 'Fitbit_thumb.jpg', 'false', '', 1, 1276547689, 1, 1276547689);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (13, 'glidetv01.jpg', '', 1, 'jpg', 77824, '#3625d1', 1000, 610, 0, 2, '/projects/glidetv/', 'glidetv01.jpg', 'false', '', 1, 1277502878, 1, 1277502878);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (14, 'glidetv02.jpg', '', 1, 'jpg', 69632, '#3625d1', 1000, 610, 0, 1, '/projects/glidetv/', 'glidetv02.jpg', 'false', '', 1, 1277502878, 1, 1277502878);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (15, 'glidetv03.jpg', '', 1, 'jpg', 57344, '#3625d1', 1000, 610, 0, 5, '/projects/glidetv/', 'glidetv03.jpg', 'false', '', 1, 1277502879, 1, 1277502879);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (16, 'glidetv04.jpg', '', 1, 'jpg', 126976, '#3625d1', 1000, 610, 0, 5, '/projects/glidetv/', 'glidetv04.jpg', 'false', '', 1, 1277502880, 1, 1277502880);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (17, 'glidetv05.jpg', '', 1, 'jpg', 69632, '', 1000, 610, 0, 0, '/projects/glidetv/', 'glidetv05.jpg', 'false', '', 1, 1277502880, 1, 1277502880);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (18, 'glidetv06.jpg', '', 1, 'jpg', 69632, '', 1000, 610, 0, 0, '/projects/glidetv/', 'glidetv06.jpg', 'false', '', 1, 1277502881, 1, 1277502881);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (19, 'glidetv_thumb.jpg', '', 1, 'jpg', 8192, '', 155, 110, 0, 0, '/projects/glidetv/', 'glidetv_thumb.jpg', 'false', '', 1, 1277502881, 1, 1277502881);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (20, 'Better_Place02.jpg', '', 1, 'jpg', 245760, '', 1348, 899, 0, 0, '/projects/betterplace/', 'Better_Place02.jpg', 'false', '', 1, 1277826122, 1, 1277826122);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (21, 'Better_Place02b.jpg', '', 1, 'jpg', 69632, '', 1500, 900, 0, 0, '/projects/betterplace/', 'Better_Place02b.jpg', 'false', '', 1, 1277826123, 1, 1277826123);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (22, 'Better_Place03.jpg', '', 1, 'jpg', 110592, '', 1500, 917, 0, 0, '/projects/betterplace/', 'Better_Place03.jpg', 'false', '', 1, 1277826123, 1, 1277826123);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (23, 'Better_Place03B.jpg', '', 1, 'jpg', 49152, '', 1500, 900, 0, 0, '/projects/betterplace/', 'Better_Place03B.jpg', 'false', '', 1, 1277826124, 1, 1277826124);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (24, 'about', '', 8, '', 0, '', 0, 0, 0, 3, '/', '', '', '', 1, 1277826124, 1, 1277826124);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (25, 'projects', '', 8, '', 0, '', 0, 0, 0, 3, '/', '', '', '', 1, 1277826124, 1, 1277826124);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (26, 'folder2', '', 8, '', 0, '', 0, 0, 0, 2, '/about/', '', '', '', 1, 1277826124, 1, 1277826124);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (27, 'about', '', 8, '', 0, '', 0, 0, 0, 3, '/about/', '', '', '', 1, 1277826124, 1, 1277826124);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (28, 'fitbit', '', 8, '', 0, '', 0, 0, 0, 3, '/projects/', '', '', '', 1, 1277826124, 1, 1277826124);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (29, 'betterplace', '', 8, '', 0, '', 0, 0, 0, 3, '/projects/', '', '', '', 1, 1277826124, 1, 1277826124);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (30, 'glidetv', '', 8, '', 0, '', 0, 0, 0, 0, '/projects/', '', '', '', 1, 1277826124, 1, 1277826124);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (31, 'passing', '', 8, '', 0, '', 0, 0, 0, 5, '/', '', '', '', 1, 1277879089, 1, 1277879089);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (32, 'IMG_0008.JPG', '', 1, 'JPG', 438272, '', 1600, 1200, 0, 4, '/passing/', 'IMG_0008.JPG', 'false', '', 1, 1277879133, 1, 1277879133);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (33, 'IMG_0009.JPG', '', 1, 'JPG', 425984, '', 1600, 1200, 0, 0, '/passing/', 'IMG_0009.JPG', 'false', '', 1, 1277879140, 1, 1277879140);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (34, 'IMG_0010.JPG', '', 1, 'JPG', 397312, '', 1600, 1200, 0, 2, '/passing/', 'IMG_0010.JPG', 'false', '', 1, 1277879147, 1, 1277879147);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (35, 'IMG_0011.JPG', '', 1, 'JPG', 323584, '', 1600, 1200, 0, 4, '/passing/', 'IMG_0011.JPG', 'false', '', 1, 1277879153, 1, 1277879153);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (36, 'Memorex_01b.jpg', '', 1, 'jpg', 176128, '', 1500, 900, 0, 0, '/about/folder2/', 'Memorex_01b.jpg', 'false', '', 1, 1277884399, 1, 1277884399);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (37, 'Memorex_02b.jpg', '', 1, 'jpg', 184320, '', 1500, 900, 0, 4, '/', 'Memorex_02b.jpg', 'false', '', 1, 1277884403, 1, 1277884403);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (38, 'Memorex_03b.jpg', '', 1, 'jpg', 49152, '', 1500, 900, 0, 0, '/about/folder2/', 'Memorex_03b.jpg', 'false', '', 1, 1277884404, 1, 1277884404);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (39, 'fujitsu_thumb.jpg', '', 1, 'jpg', 8192, '', 155, 110, 0, 3, '/about/about/', 'fujitsu_thumb.jpg', 'false', '', 1, 1277884439, 1, 1277884439);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (40, 'fujitsu01.jpg', '', 1, 'jpg', 69632, '', 1000, 610, 0, 3, '/about/about/', 'fujitsu01.jpg', 'false', '', 1, 1277884441, 1, 1277884441);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (41, 'fujitsu02.jpg', '', 1, 'jpg', 61440, '', 1000, 610, 0, 5, '/about/about/', 'fujitsu02.jpg', 'false', '', 1, 1277884442, 1, 1277884442);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (42, 'fujitsu03.jpg', '', 1, 'jpg', 45056, '', 1000, 610, 0, 0, '/about/about/', 'fujitsu03.jpg', 'false', '', 1, 1277884443, 1, 1277884443);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (43, 'newfolderBetter_Place02.jpg', '', 1, 'jpg', 245760, '', 1348, 899, 0, 2, '/about/about/', 'newfolderBetter_Place02.jpg', 'false', '', 1, 1277884477, 1, 1277884477);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (44, 'sizing', '', 8, '', 0, '', 0, 0, 0, 0, '/', '', '', '', 1, 1277884547, 1, 1277884547);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (45, 'SO002_e-blast_final_14_1.jpg', '', 1, 'jpg', 20480, '', 400, 400, 0, 0, '/newsize/sizing/', 'SO002_e-blast_final_14_1.jpg', 'false', '', 1, 1277884559, 1, 1277884559);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (46, 'SO002_e-blast_final_14_2.jpg', '', 1, 'jpg', 12288, '', 153, 137, 0, 0, '/newsize/sizing/', 'SO002_e-blast_final_14_2.jpg', 'false', '', 1, 1277884560, 1, 1277884560);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (47, 'SO002_e-blast_final_14_3.jpg', '', 1, 'jpg', 20480, '', 400, 400, 0, 0, '/newsize/sizing/', 'SO002_e-blast_final_14_3.jpg', 'false', '', 1, 1277884560, 1, 1277884560);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (48, 'newsize', '', 8, '', 0, '', 0, 0, 0, 3, '/', '', '', '', 1, 1277885978, 1, 1277885978);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (49, 'cocoon03.jpg', '', 1, 'jpg', 81920, '', 1000, 610, 0, 0, '/newsize/', 'cocoon03.jpg', 'false', '', 1, 1277886110, 1, 1277886110);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (50, 'cocoon04.jpg', '', 1, 'jpg', 49152, '', 1000, 610, 0, 0, '/newsize/', 'cocoon04.jpg', 'false', '', 1, 1277886111, 1, 1277886111);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (51, 'cocoon05.jpg', '', 1, 'jpg', 86016, '', 1000, 610, 0, 0, '/newsize/', 'cocoon05.jpg', 'false', '', 1, 1277886113, 1, 1277886113);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (52, 'Netgear_03.jpg', '', 1, 'jpg', 65536, '', 1000, 610, 0, 0, '/newsize/', 'Netgear_03.jpg', 'false', '', 1, 1277886358, 1, 1277886358);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (53, 'Netgear_04.jpg', '', 1, 'jpg', 65536, '', 1000, 610, 0, 0, '/newsize/', 'Netgear_04.jpg', 'false', '', 1, 1277886359, 1, 1277886359);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (54, 'Netgear_05.jpg', '', 1, 'jpg', 57344, '', 1000, 610, 0, 3, '/newsize/', 'Netgear_05.jpg', 'false', '', 1, 1277886360, 1, 1277886360);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (55, 'glidetv01.jpg', '', 1, 'jpg', 77824, '', 1000, 610, 0, 3, '/passing/', 'glidetv01.jpg', 'false', '', 1, 1277912847, 1, 1277912847);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (56, 'glidetv02.jpg', '', 1, 'jpg', 69632, '', 1000, 610, 0, 5, '/passing/', 'glidetv02.jpg', 'false', '', 1, 1277912848, 1, 1277912848);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (57, 'glidetv03.jpg', '', 1, 'jpg', 57344, '', 1000, 610, 0, 0, '/passing/', 'glidetv03.jpg', 'false', '', 1, 1277912848, 1, 1277912848);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (58, 'sling01.jpg', '', 1, 'jpg', 90112, '', 1000, 610, 0, 5, '/projects/fitbit/', 'sling01.jpg', 'false', '', 1, 1277912866, 1, 1277912866);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (59, 'sling02.jpg', '', 1, 'jpg', 81920, '', 1000, 610, 0, 1, '/projects/fitbit/', 'sling02.jpg', 'false', '', 1, 1277912867, 1, 1277912867);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (60, 'sling03.jpg', '', 1, 'jpg', 61440, '', 1000, 610, 0, 0, '/projects/fitbit/', 'sling03.jpg', 'false', '', 1, 1277912867, 1, 1277912867);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (61, 'sling04.jpg', '', 1, 'jpg', 24576, '', 1000, 610, 0, 3, '/projects/fitbit/', 'sling04.jpg', 'false', '', 1, 1277912868, 1, 1277912868);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (62, 'subfolder1', '', 8, '', 0, '', 0, 0, 0, 0, '/about/about/', '', '', '', 1, 1278389502, 1, 1278389502);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (63, 'subfolder1a', '', 8, '', 0, '', 0, 0, 0, 0, '/about/about/subfolder1/', '', '', '', 1, 1278389512, 1, 1278389512);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (64, 'subfolder1aa', '', 8, '', 0, '', 0, 0, 0, 0, '/about/about/subfolder1/subfolder1a/', '', '', '', 1, 1278389523, 1, 1278389523);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (65, '2010_IDMAG.jpg', '', 1, 'jpg', 180224, '', 340, 450, 0, 0, '/', '2010_IDMAG.jpg', 'false', '', 1, 1284494438, 1, 1284494438);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (66, 'As_we_get_older_we.jpg', '', 1, 'jpg', 69632, '', 750, 512, 0, 0, '/', 'As_we_get_older_we.jpg', 'false', '', 1, 1284494439, 1, 1284494439);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (67, 'Better_Place01.jpg', '', 1, 'jpg', 143360, '', 1000, 667, 0, 0, '/', 'Better_Place01.jpg', 'false', '', 1, 1284494440, 1, 1284494440);
INSERT INTO `media` (`id`, `name`, `title`, `mimetypeid`, `extension`, `size`, `color`, `width`, `height`, `playtime`, `rating`, `path`, `thumb`, `video_proxy`, `url`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (68, 'Better_Place02.jpg', '', 1, 'jpg', 245760, '', 1348, 899, 0, 0, '/', 'Better_Place02.jpg', 'false', '', 1, 1284494441, 1, 1284494441);
UNLOCK TABLES;


LOCK TABLES `media_customfields` WRITE;
UNLOCK TABLES;


LOCK TABLES `media_terms` WRITE;
UNLOCK TABLES;


LOCK TABLES `permgroups` WRITE;
UNLOCK TABLES;


LOCK TABLES `perms` WRITE;
UNLOCK TABLES;


LOCK TABLES `settings` WRITE;
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (1, 'rootURL', 'http://migdev.mig.pentagram.com/', 'content');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (2, 'pendingURL', 'http://migdev.mig.pentagram.com/', 'content');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (3, 'publishedURL', 'http://migdev.mig.pentagram.com/', 'content');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (4, 'textFormat', 'textFieldHTMLFormat', 'content');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (5, 'timeout', '100', 'app');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (6, 'textEditorColor', '0xCCCCCC', 'content');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (7, 'renderer', 'html', 'app');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (8, 'timezone', '-5', 'app');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (9, 'mediaURL', 'http://migdev.mig.pentagram.com/files', 'media');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (10, 'thumbURL', 'http://migdev.mig.pentagram.com/files/migThumbs', 'media');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (11, 'fileDir', 'files', 'media');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (12, 'thumbDir', 'files/migThumbs', 'media');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (19, 'defaultCreateContent', 'insertRecord', 'content');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (20, 'defaultRetrieveContent', 'getContent', 'content');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (21, 'defaultUpdateContent', 'updateRecord', 'content');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (22, 'defaultDeleteContent', 'deleteContent', 'content');
INSERT INTO `settings` (`id`, `key`, `value`, `usage`) VALUES (23, 'defaultTable', 'content', 'content');
UNLOCK TABLES;


LOCK TABLES `statuses` WRITE;
INSERT INTO `statuses` (`id`, `status`, `displayorder`) VALUES (1, 'Draft', 0);
INSERT INTO `statuses` (`id`, `status`, `displayorder`) VALUES (2, 'Awaiting Approval', 0);
INSERT INTO `statuses` (`id`, `status`, `displayorder`) VALUES (3, 'Published (Internal Only)', 0);
INSERT INTO `statuses` (`id`, `status`, `displayorder`) VALUES (4, 'Published', 0);
UNLOCK TABLES;


LOCK TABLES `templates` WRITE;
INSERT INTO `templates` (`id`, `name`, `is_fixed`, `can_have_children`, `nesting`, `orderby`, `orderdirection`, `labelfield`, `contentview`, `generalview`, `generallabel`, `createContent`, `retrieveContent`, `updateContent`, `deleteContent`, `verbosity`) VALUES (1, 'Default', 1, 0, 0, 'displayorder', 'ASC', 'migtitle', 'org.mig.view.components.content.MainMiddleView', 'org.mig.view.components.content.ContentGeneralEditor', 'General', 'insertRecord', 'getContent', 'updateRecord', 'deleteContent', 0);
INSERT INTO `templates` (`id`, `name`, `is_fixed`, `can_have_children`, `nesting`, `orderby`, `orderdirection`, `labelfield`, `contentview`, `generalview`, `generallabel`, `createContent`, `retrieveContent`, `updateContent`, `deleteContent`, `verbosity`) VALUES (2, 'Nav Items2', 1, 0, 0, 'displayorder', 'ASC', 'migtitle', 'org.mig.view.components.content.ContentView', 'org.mig.view.components.content.ContentGeneralEditor', 'General', 'insertRecord', 'getContent', 'updateRecord', 'deleteContent', 0);
INSERT INTO `templates` (`id`, `name`, `is_fixed`, `can_have_children`, `nesting`, `orderby`, `orderdirection`, `labelfield`, `contentview`, `generalview`, `generallabel`, `createContent`, `retrieveContent`, `updateContent`, `deleteContent`, `verbosity`) VALUES (3, 'Projects', 0, 0, 0, 'displayorder', 'ASC', 'migtitle', 'org.mig.view.components.content.ContentView', 'org.mig.view.components.content.ContentGeneralEditor', 'General', 'insertRecord', 'getContent', 'updateRecord', 'deleteContent', 0);
INSERT INTO `templates` (`id`, `name`, `is_fixed`, `can_have_children`, `nesting`, `orderby`, `orderdirection`, `labelfield`, `contentview`, `generalview`, `generallabel`, `createContent`, `retrieveContent`, `updateContent`, `deleteContent`, `verbosity`) VALUES (4, 'Posts', 0, 0, 0, 'displayorder', 'ASC', 'migtitle', 'org.mig.view.components.content.ContentView', 'org.mig.view.components.content.ContentGeneralEditor', 'General', 'insertRecord', 'getContent', 'updateRecord', 'deleteContent', 0);
UNLOCK TABLES;


LOCK TABLES `templates_contenttabs` WRITE;
INSERT INTO `templates_contenttabs` (`id`, `templateid`, `tabid`) VALUES (4, 2, 1);
INSERT INTO `templates_contenttabs` (`id`, `templateid`, `tabid`) VALUES (5, 2, 2);
UNLOCK TABLES;


LOCK TABLES `templates_contenttabs_parameters` WRITE;
INSERT INTO `templates_contenttabs_parameters` (`id`, `templateid`, `tabid`, `is_label`, `name`, `value`, `param1`, `param2`, `param3`) VALUES (1, 2, 1, 0, 'usage', 'Thumb', '1', '158', 1);
INSERT INTO `templates_contenttabs_parameters` (`id`, `templateid`, `tabid`, `is_label`, `name`, `value`, `param1`, `param2`, `param3`) VALUES (3, 2, 2, 0, 'Tags Title', 'Tags', 'false', '', 1);
INSERT INTO `templates_contenttabs_parameters` (`id`, `templateid`, `tabid`, `is_label`, `name`, `value`, `param1`, `param2`, `param3`) VALUES (4, 2, 2, 0, 'Categories Title', 'Categories', 'true', '', 2);
INSERT INTO `templates_contenttabs_parameters` (`id`, `templateid`, `tabid`, `is_label`, `name`, `value`, `param1`, `param2`, `param3`) VALUES (10, 2, 1, 0, 'usage', 'Gallery', '1,2', '32', 3);
INSERT INTO `templates_contenttabs_parameters` (`id`, `templateid`, `tabid`, `is_label`, `name`, `value`, `param1`, `param2`, `param3`) VALUES (11, 2, 1, 1, 'Label', 'Images', '', '', 0);
INSERT INTO `templates_contenttabs_parameters` (`id`, `templateid`, `tabid`, `is_label`, `name`, `value`, `param1`, `param2`, `param3`) VALUES (12, 2, 2, 1, 'Label', 'Metadata', '', '', 0);
UNLOCK TABLES;


LOCK TABLES `templates_customfields` WRITE;
INSERT INTO `templates_customfields` (`id`, `templateid`, `customfieldid`, `displayorder`) VALUES (39, 1, 22, 1);
INSERT INTO `templates_customfields` (`id`, `templateid`, `customfieldid`, `displayorder`) VALUES (40, 3, 23, 2);
INSERT INTO `templates_customfields` (`id`, `templateid`, `customfieldid`, `displayorder`) VALUES (41, 2, 22, 2);
INSERT INTO `templates_customfields` (`id`, `templateid`, `customfieldid`, `displayorder`) VALUES (42, 3, 22, 1);
INSERT INTO `templates_customfields` (`id`, `templateid`, `customfieldid`, `displayorder`) VALUES (43, 3, 24, 3);
INSERT INTO `templates_customfields` (`id`, `templateid`, `customfieldid`, `displayorder`) VALUES (45, 3, 26, 4);
UNLOCK TABLES;


LOCK TABLES `term_taxonomy` WRITE;
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (5, 5, 1, 'category', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (9, 9, 8, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (10, 10, 9, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (11, 11, 10, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (16, 16, 15, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (17, 17, 16, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (18, 18, 17, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (20, 20, 18, 'category', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (21, 21, 18, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (22, 22, 19, 'category', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (23, 23, 19, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (25, 25, 20, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (29, 22, 25, 'category', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (30, 22, 25, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (31, 29, 27, 'category', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (32, 29, 27, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (34, 20, 28, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (36, 36, 30, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (38, 38, 32, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (39, 39, 21, 'tag', '', 0);
INSERT INTO `term_taxonomy` (`id`, `parentid`, `termid`, `taxonomy`, `description`, `displayorder`) VALUES (40, 40, 35, 'tag', '', 0);
UNLOCK TABLES;


LOCK TABLES `terms` WRITE;
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (1, 'Colors', 'colors');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (2, 'Red', 'red');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (3, 'Yellow', 'yellow');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (4, 'Blue', 'blue');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (8, 'White', 'white');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (9, 'Yellow', 'yellow');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (10, 'Green', 'green');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (11, 'Lotus', 'lotus');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (12, 'Tabbing is weird', 'tabbing-is-weird');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (13, 'Oki cool', 'oki-cool');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (14, 'Yeeha', 'yeeha');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (15, 'Magenta', 'magenta');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (16, 'Blue', 'blue');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (17, 'Red', 'red');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (18, 'Food', 'food');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (19, 'Sports', 'sports');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (20, 'Music', 'music');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (21, 'Yes! New', 'yes-new');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (22, 'Fort Greene', 'fort-greene');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (23, 'sadist', 'sadist');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (24, 'Autechre', 'autechre');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (25, 'Soccer', 'soccer');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (26, 'football', 'football');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (27, 'Basketball', 'basketball');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (28, 'Fajitas', 'fajitas');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (29, 'Shrimp', 'shrimp');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (30, 'Ramblings', 'ramblings');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (31, 'Craps', 'craps');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (32, 'ample', 'ample');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (33, 'Dawkins', 'dawkins');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (34, 'Richard', 'richard');
INSERT INTO `terms` (`id`, `name`, `slug`) VALUES (35, 'Ok Ill do that', 'ok-ill-do-that');
UNLOCK TABLES;


LOCK TABLES `termtaxonomy_customfields` WRITE;
UNLOCK TABLES;


LOCK TABLES `user` WRITE;
INSERT INTO `user` (`id`, `miggroup`, `privilegeid`, `firstname`, `lastname`, `username`, `email`, `password`, `lastlogin`, `active`, `createdby`, `createdate`, `modifiedby`, `modifieddate`) VALUES (1, 1, 1, 'Raed', 'Atoui', 'raed', 'raed@themapoffice.com', 'kriohqiriq', 1286221206, 1, 1, 1267733775, 1, 1267733775);
UNLOCK TABLES;


LOCK TABLES `user_customfields` WRITE;
UNLOCK TABLES;


LOCK TABLES `user_notes` WRITE;
UNLOCK TABLES;


LOCK TABLES `user_usercategories` WRITE;
UNLOCK TABLES;


LOCK TABLES `usercategories` WRITE;
UNLOCK TABLES;


LOCK TABLES `usergroup_perms` WRITE;
UNLOCK TABLES;




SET FOREIGN_KEY_CHECKS = 1;


