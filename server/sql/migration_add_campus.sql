-- Migration à exécuter UNE SEULE FOIS si votre base MySQL existait déjà
-- avant l'ajout du module Campus (c'est-à-dire si la table `ufrs` a encore
-- des colonnes university_id / university_name au lieu de campus_id /
-- campus_name). Si vous repartez d'une base neuve, ignorez ce fichier et
-- utilisez simplement schema.sql.

USE carpoollite;

-- 1. Nouvelle table campus (identique à schema.sql, au cas où elle
--    n'existerait pas encore)
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

-- 2. Renommage des colonnes de la table ufrs : elle référence maintenant un
--    campus, plus directement une université.
ALTER TABLE ufrs
  CHANGE COLUMN university_id campus_id VARCHAR(128),
  CHANGE COLUMN university_name campus_name VARCHAR(255);

-- Les anciennes valeurs de campus_id ne correspondront à aucun campus tant
-- que vous n'aurez pas recréé/modifié vos UFR depuis l'application (ce qui
-- redéclenchera la synchronisation avec les bons id de campus).
