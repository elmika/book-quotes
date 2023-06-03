--
-- Table structure for table `words`
--

DROP TABLE IF EXISTS `words`;
CREATE TABLE `words` (
  `word` varchar(50) NOT NULL,
  `source` varchar(50) NOT NULL default '',
  `offset` int(11) NOT NULL,
  KEY `word` (`word`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COMMENT='Only words';
