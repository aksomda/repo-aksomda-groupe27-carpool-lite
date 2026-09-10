-- Schéma MySQL pour Carpool Lite : réplique locale des collections
-- Firestore (universities, campus, ufrs, formations, academic_levels).
--
-- Hiérarchie académique : universities -> campus -> ufrs -> formations -> academic_levels
--
-- L'id (VARCHAR) correspond exactement à l'id du document Firestore, ce qui
-- permet des upserts simples (INSERT ... ON DUPLICATE KEY UPDATE) lors de la
-- synchronisation déclenchée par les Cloud Functions.
--
-- La suppression est logique (is_deleted), à l'image de Firestore : aucune
-- ligne n'est jamais supprimée physiquement par la synchronisation.

CREATE DATABASE IF NOT EXISTS carpoollite
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE carpoollite;

CREATE TABLE IF NOT EXISTS universities (
  id VARCHAR(128) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  city VARCHAR(255),
  address VARCHAR(255),
  latitude VARCHAR(64),
  longitude VARCHAR(64),
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS campus (
  id VARCHAR(128) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(64),
  university_id VARCHAR(128),
  university_name VARCHAR(255),
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ufrs (
  id VARCHAR(128) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(64),
  campus_id VARCHAR(128),
  campus_name VARCHAR(255),
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS formations (
  id VARCHAR(128) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(64),
  diploma VARCHAR(64),
  ufr_id VARCHAR(128),
  ufr_name VARCHAR(255),
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS academic_levels (
  id VARCHAR(128) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  academic_year VARCHAR(32),
  formation_id VARCHAR(128),
  formation_name VARCHAR(255),
  is_deleted TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
