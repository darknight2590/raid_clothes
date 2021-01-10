-- --------------------------------------------------------
-- Sunucu:                       127.0.0.1
-- Sunucu sürümü:                10.4.14-MariaDB - mariadb.org binary distribution
-- Sunucu İşletim Sistemi:       Win64
-- HeidiSQL Sürüm:               11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- rplf için veritabanı yapısı dökülüyor
CREATE DATABASE IF NOT EXISTS `essentialmode` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_turkish_ci */;
USE `essentialmode`;

-- tablo yapısı dökülüyor rplf.character_current
CREATE TABLE IF NOT EXISTS `character_current` (
  `cid` varchar(255) NOT NULL,
  `model` longtext NOT NULL DEFAULT '',
  `drawables` longtext NOT NULL DEFAULT '',
  `props` longtext NOT NULL DEFAULT '',
  `drawtextures` longtext NOT NULL DEFAULT '',
  `proptextures` longtext NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- rplf.character_current: ~0 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `character_current` DISABLE KEYS */;
/*!40000 ALTER TABLE `character_current` ENABLE KEYS */;

-- tablo yapısı dökülüyor rplf.character_face
CREATE TABLE IF NOT EXISTS `character_face` (
  `identifier` varchar(255) NOT NULL,
  `hairColor` varchar(255) NOT NULL DEFAULT '',
  `headBlend` varchar(255) NOT NULL DEFAULT '',
  `headStructure` varchar(255) NOT NULL DEFAULT '',
  `headOverlay` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- rplf.character_face: ~0 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `character_face` DISABLE KEYS */;
/*!40000 ALTER TABLE `character_face` ENABLE KEYS */;

-- tablo yapısı dökülüyor rplf.character_outfits
CREATE TABLE IF NOT EXISTS `character_outfits` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `steamid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slot` varchar(11) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `model` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `drawables` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `props` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `drawtextures` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proptextures` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hairColor` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=1926 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- rplf.character_outfits: ~3 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `character_outfits` DISABLE KEYS */;
INSERT INTO `character_outfits` (`Id`, `steamid`, `name`, `slot`, `model`, `drawables`, `props`, `drawtextures`, `proptextures`, `hairColor`) VALUES

/*!40000 ALTER TABLE `character_outfits` ENABLE KEYS */;

-- tablo yapısı dökülüyor rplf.playerskins
CREATE TABLE IF NOT EXISTS `playerskins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) NOT NULL,
  `model` varchar(255) NOT NULL,
  `skin` text NOT NULL,
  `active` tinyint(2) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `active` (`active`)
) ENGINE=InnoDB AUTO_INCREMENT=43010 DEFAULT CHARSET=latin1;

-- rplf.playerskins: ~0 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `playerskins` DISABLE KEYS */;
/*!40000 ALTER TABLE `playerskins` ENABLE KEYS */;

-- tablo yapısı dökülüyor rplf.playerstattoos
CREATE TABLE IF NOT EXISTS `playerstattoos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `tattoos` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

-- rplf.playerstattoos: ~2 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `playerstattoos` DISABLE KEYS */;
INSERT INTO `playerstattoos` (`id`, `identifier`, `tattoos`) VALUES
/*!40000 ALTER TABLE `playerstattoos` ENABLE KEYS */;

-- tablo yapısı dökülüyor rplf.player_outfits
CREATE TABLE IF NOT EXISTS `player_outfits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `outfitname` varchar(50) NOT NULL,
  `model` varchar(50) DEFAULT NULL,
  `skin` text DEFAULT NULL,
  `outfitId` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `outfitId` (`outfitId`)
) ENGINE=InnoDB AUTO_INCREMENT=8970 DEFAULT CHARSET=utf8mb4;

-- rplf.player_outfits: ~0 rows (yaklaşık) tablosu için veriler indiriliyor
/*!40000 ALTER TABLE `player_outfits` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_outfits` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
