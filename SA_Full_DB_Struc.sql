CREATE TABLE IF NOT EXISTS `applications` (
  `steamid` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `faction` int(11) NOT NULL,
  `text` text NOT NULL,
  `score` varchar(255) NOT NULL,
  `playtime` varchar(255) NOT NULL,
  PRIMARY KEY (`name`),
  KEY `steamid` (`steamid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `chat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `steamid` varchar(64) NOT NULL,
  `text` text NOT NULL,
  `time` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `time` (`time`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `factionmodels` (
  `modelid` int(255) NOT NULL AUTO_INCREMENT,
  `model` varchar(255) DEFAULT NULL,
  `factionid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`modelid`),
  UNIQUE KEY `model` (`model`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `factions` (
  `name` text NOT NULL,
  `bank` int(255) NOT NULL,
  `score` bigint(20) NOT NULL,
  `buyscore` bigint(20) NOT NULL,
  PRIMARY KEY (`name`(20))
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `goodies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `steamid` varchar(64) NOT NULL,
  `intid` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `lastips` (
  `ip` varchar(16) NOT NULL,
  `steamid` varchar(255) NOT NULL,
  `server` varchar(255) NOT NULL,
  `time` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `log` (
  `logid` bigint(10) unsigned NOT NULL AUTO_INCREMENT,
  `steamid` varchar(255) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `level` varchar(100) DEFAULT NULL,
  `time` int(11) unsigned NOT NULL,
  `message` longtext NOT NULL,
  PRIMARY KEY (`logid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `lotteries` (
  `lid` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `news` (
  `time` int(11) NOT NULL,
  `content` text NOT NULL,
  PRIMARY KEY (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `paidinvoices` (
  `id` int(255) NOT NULL AUTO_INCREMENT,
  `txn_id` varchar(255) NOT NULL,
  `SteamID` varchar(255) DEFAULT NULL,
  `Item` varchar(255) DEFAULT NULL,
  `Amount` float unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `txn_id` (`txn_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `players` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `score` bigint(20) DEFAULT '0',
  `capacity` bigint(20) DEFAULT '0',
  `isleader` tinyint(1) DEFAULT '0',
  `miningyield` int(11) DEFAULT '0',
  `steamid` varchar(255) DEFAULT NULL,
  `stationres` blob,
  `name` varchar(255) DEFAULT NULL,
  `groupname` varchar(50) DEFAULT NULL,
  `miningyield_ii` int(11) DEFAULT '0',
  `miningyield_iii` int(11) DEFAULT '0',
  `miningyield_v` int(11) DEFAULT '0',
  `miningtheory` int(11) DEFAULT '0',
  `rtadevice` int(11) DEFAULT '0',
  `oremod` int(11) DEFAULT '0',
  `oremod_ii` int(11) DEFAULT '0',
  `oremanage` int(11) DEFAULT '0',
  `miningenergy` int(11) DEFAULT '0',
  `credits` bigint(20) DEFAULT '0',
  `fighterenergy` int(11) DEFAULT '0',
  `miningyield_iv` int(11) DEFAULT '0',
  `terracredits` bigint(20) DEFAULT '0',
  `gcombat` int(11) DEFAULT '0',
  `miningyield_vi` int(11) DEFAULT '0',
  `oremod_iii` int(11) DEFAULT '0',
  `oremod_iv` int(11) DEFAULT '0',
  `oremod_v` int(11) DEFAULT '0',
  `hdpower` int(11) DEFAULT '0',
  `tiberiummod` int(11) DEFAULT '0',
  `tiberiumyield` int(11) DEFAULT '0',
  `icerefinerymod` int(11) NOT NULL DEFAULT '0',
  `icelasermod` int(11) NOT NULL DEFAULT '0',
  `iceproductmod` int(11) NOT NULL DEFAULT '0',
  `icerawmod` int(11) NOT NULL DEFAULT '0',
  `tibdrillmod` int(11) NOT NULL DEFAULT '0',
  `tibstoragemod` int(11) NOT NULL DEFAULT '0',
  `tiberiummod_ii` int(11) NOT NULL DEFAULT '0',
  `tiberiumyield_ii` int(11) NOT NULL DEFAULT '0',
  `auth` varchar(255) NOT NULL DEFAULT '',
  `rank` int(11) DEFAULT '0',
  `browser` tinyint(1) NOT NULL DEFAULT '0',
  `devlimit` int(11) NOT NULL DEFAULT '1',
  `allyuntil` int(11) DEFAULT '0',
  PRIMARY KEY (`uid`),
  UNIQUE KEY `steamid` (`steamid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sa_players` (
  `pid` int(11) NOT NULL AUTO_INCREMENT,
  `steamid` varchar(40) NOT NULL,
  `score` int(80) unsigned NOT NULL DEFAULT '0',
  `credits` int(40) unsigned NOT NULL DEFAULT '0',
  `faction` int(11) NOT NULL DEFAULT '1',
  `factionrank` int(11) NOT NULL DEFAULT '0',
  `allyuntil` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`pid`),
  UNIQUE KEY `steamid` (`steamid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sa_playerxresearch` (
  `pid` int(11) NOT NULL,
  `name` varchar(100) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `value` int(11) NOT NULL,
  PRIMARY KEY (`pid`,`name`),
  KEY `pid` (`pid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_admins` (
  `aid` int(6) NOT NULL AUTO_INCREMENT,
  `user` varchar(64) NOT NULL,
  `authid` varchar(64) NOT NULL DEFAULT '',
  `password` varchar(128) NOT NULL,
  `gid` int(6) NOT NULL,
  `email` varchar(128) NOT NULL,
  `validate` varchar(128) NOT NULL,
  `extraflags` int(10) NOT NULL,
  `immunity` int(10) NOT NULL DEFAULT '0',
  `srv_group` varchar(128) DEFAULT NULL,
  `srv_flags` varchar(64) DEFAULT NULL,
  `srv_password` varchar(128) DEFAULT NULL,
  `lastvisit` int(11) DEFAULT NULL,
  PRIMARY KEY (`aid`),
  UNIQUE KEY `user` (`user`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_admins_servers_groups` (
  `admin_id` int(10) NOT NULL,
  `group_id` int(10) NOT NULL,
  `srv_group_id` int(10) NOT NULL,
  `server_id` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_banlog` (
  `sid` int(6) NOT NULL,
  `time` int(11) NOT NULL,
  `name` varchar(128) NOT NULL,
  `bid` int(6) NOT NULL,
  PRIMARY KEY (`sid`,`time`,`bid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_bans` (
  `bid` int(6) NOT NULL AUTO_INCREMENT,
  `ip` varchar(32) DEFAULT NULL,
  `authid` varchar(64) NOT NULL DEFAULT '',
  `name` varchar(128) NOT NULL DEFAULT 'unnamed',
  `created` int(11) NOT NULL DEFAULT '0',
  `ends` int(11) NOT NULL DEFAULT '0',
  `length` int(10) NOT NULL DEFAULT '0',
  `reason` text NOT NULL,
  `aid` int(6) NOT NULL DEFAULT '0',
  `adminIp` varchar(32) NOT NULL DEFAULT '',
  `sid` int(6) NOT NULL DEFAULT '0',
  `country` varchar(4) DEFAULT NULL,
  `RemovedBy` int(8) DEFAULT NULL,
  `RemoveType` varchar(3) DEFAULT NULL,
  `RemovedOn` int(10) DEFAULT NULL,
  `type` tinyint(4) NOT NULL DEFAULT '0',
  `ureason` text,
  `audit` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`bid`),
  KEY `sid` (`sid`),
  FULLTEXT KEY `reason` (`reason`),
  FULLTEXT KEY `authid_2` (`authid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_comments` (
  `cid` int(6) NOT NULL AUTO_INCREMENT,
  `bid` int(6) NOT NULL,
  `type` varchar(1) NOT NULL,
  `aid` int(6) NOT NULL,
  `commenttxt` longtext NOT NULL,
  `added` int(11) NOT NULL,
  `editaid` int(6) DEFAULT NULL,
  `edittime` int(11) DEFAULT NULL,
  KEY `cid` (`cid`),
  FULLTEXT KEY `commenttxt` (`commenttxt`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_demos` (
  `demid` int(6) NOT NULL,
  `demtype` varchar(1) NOT NULL,
  `filename` varchar(128) NOT NULL,
  `origname` varchar(128) NOT NULL,
  PRIMARY KEY (`demid`,`demtype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_groups` (
  `gid` int(6) NOT NULL AUTO_INCREMENT,
  `type` smallint(6) NOT NULL DEFAULT '0',
  `name` varchar(128) NOT NULL DEFAULT 'unnamed',
  `flags` int(10) NOT NULL,
  PRIMARY KEY (`gid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_log` (
  `lid` int(11) NOT NULL AUTO_INCREMENT,
  `type` enum('m','w','e') NOT NULL,
  `title` varchar(512) NOT NULL,
  `message` text NOT NULL,
  `function` text NOT NULL,
  `query` text NOT NULL,
  `aid` int(11) NOT NULL,
  `host` text NOT NULL,
  `created` int(11) NOT NULL,
  PRIMARY KEY (`lid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_mods` (
  `mid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `icon` varchar(128) NOT NULL,
  `modfolder` varchar(64) NOT NULL,
  `enabled` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`mid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_protests` (
  `pid` int(6) NOT NULL AUTO_INCREMENT,
  `bid` int(6) NOT NULL,
  `datesubmitted` int(11) NOT NULL,
  `reason` text NOT NULL,
  `email` varchar(128) NOT NULL,
  `archiv` tinyint(1) DEFAULT '0',
  `archivedby` int(11) DEFAULT NULL,
  `pip` varchar(64) NOT NULL,
  PRIMARY KEY (`pid`),
  KEY `bid` (`bid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_servers` (
  `sid` int(6) NOT NULL AUTO_INCREMENT,
  `ip` varchar(64) NOT NULL,
  `port` int(5) NOT NULL,
  `rcon` varchar(64) NOT NULL,
  `modid` int(10) NOT NULL,
  `enabled` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`sid`),
  UNIQUE KEY `ip` (`ip`,`port`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_servers_groups` (
  `server_id` int(10) NOT NULL,
  `group_id` int(10) NOT NULL,
  PRIMARY KEY (`server_id`,`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_settings` (
  `setting` varchar(128) NOT NULL,
  `value` text NOT NULL,
  UNIQUE KEY `setting` (`setting`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_srvgroups` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `flags` varchar(30) NOT NULL,
  `immunity` int(10) unsigned NOT NULL,
  `name` varchar(120) NOT NULL,
  `groups_immune` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `sb_submissions` (
  `subid` int(6) NOT NULL AUTO_INCREMENT,
  `submitted` int(11) NOT NULL,
  `ModID` int(6) NOT NULL,
  `SteamId` varchar(64) NOT NULL DEFAULT 'unnamed',
  `name` varchar(128) NOT NULL,
  `email` varchar(128) NOT NULL,
  `reason` text NOT NULL,
  `ip` varchar(64) NOT NULL,
  `subname` varchar(128) DEFAULT NULL,
  `sip` varchar(64) DEFAULT NULL,
  `archiv` tinyint(1) DEFAULT '0',
  `archivedby` int(11) DEFAULT NULL,
  `server` tinyint(3) DEFAULT NULL,
  PRIMARY KEY (`subid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `userdata` (
  `id` int(50) unsigned NOT NULL AUTO_INCREMENT,
  `steamid` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `level` int(11) NOT NULL DEFAULT '0',
  `dev` tinyint(1) NOT NULL DEFAULT '0',
  `furry` tinyint(1) NOT NULL DEFAULT '0',
  `donator` tinyint(1) NOT NULL DEFAULT '0',
  `buddies` text,
  `serverlevels` text,
  `ruleslastaccepted` int(11) NOT NULL DEFAULT '0',
  `auth` varchar(255) DEFAULT NULL,
  `dj` tinyint(1) NOT NULL DEFAULT '0',
  `browser` tinyint(1) NOT NULL DEFAULT '0',
  `playtime` int(11) NOT NULL DEFAULT '0',
  `lastseen` int(11) NOT NULL DEFAULT '0',
  `pdata` longtext,
  `lastip` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `steamid` (`steamid`),
  FULLTEXT KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;
