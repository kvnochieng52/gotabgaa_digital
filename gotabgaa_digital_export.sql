-- ============================================================
-- Gotabgaa Digital — full schema + content export
-- Target: MySQL 5.7+ / MariaDB 10.3+
-- Import into an empty database called `gotabgaa`.
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = '+00:00';

-- === SCHEMA ===
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `articles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `remote_id` bigint unsigned DEFAULT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `excerpt` text COLLATE utf8mb4_unicode_ci,
  `body` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` bigint unsigned NOT NULL,
  `author_id` bigint unsigned DEFAULT NULL,
  `author_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `youtube_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_short` tinyint(1) NOT NULL DEFAULT '0',
  `view_count` bigint unsigned NOT NULL DEFAULT '0',
  `like_count` int unsigned NOT NULL DEFAULT '0',
  `comment_count` int unsigned NOT NULL DEFAULT '0',
  `share_count` int unsigned NOT NULL DEFAULT '0',
  `featured` tinyint(1) NOT NULL DEFAULT '0',
  `breaking` tinyint(1) NOT NULL DEFAULT '0',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'published',
  `published_at` timestamp NULL DEFAULT NULL,
  `reading_time` int unsigned NOT NULL DEFAULT '3',
  `tags` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `articles_slug_unique` (`slug`),
  UNIQUE KEY `articles_remote_id_unique` (`remote_id`),
  KEY `articles_category_id_foreign` (`category_id`),
  KEY `articles_author_id_foreign` (`author_id`),
  KEY `articles_published_at_category_id_index` (`published_at`,`category_id`),
  KEY `articles_breaking_index` (`breaking`),
  KEY `articles_featured_index` (`featured`),
  KEY `articles_is_short_index` (`is_short`),
  CONSTRAINT `articles_author_id_foreign` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `articles_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `breaking_news` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `headline` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `link_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `icon` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `color` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int unsigned NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_messages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `source` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `contact_messages_read_created_at_index` (`read`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `poll_votes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `poll_id` bigint unsigned NOT NULL,
  `option_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `voter_fingerprint` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `voted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `poll_votes_poll_id_voter_fingerprint_unique` (`poll_id`,`voter_fingerprint`),
  KEY `poll_votes_poll_id_option_id_index` (`poll_id`,`option_id`),
  CONSTRAINT `poll_votes_poll_id_foreign` FOREIGN KEY (`poll_id`) REFERENCES `polls` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `polls` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `question` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` json NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `closes_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `polls_slug_unique` (`slug`),
  KEY `polls_active_index` (`active`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `programmes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `remote_id` bigint unsigned DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `thumbnail` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'General',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `programmes_slug_unique` (`slug`),
  UNIQUE KEY `programmes_remote_id_unique` (`remote_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `programs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `host` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('tv','radio') COLLATE utf8mb4_unicode_ci NOT NULL,
  `day` enum('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_time` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `end_time` varchar(5) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `programs_slug_unique` (`slug`),
  KEY `programs_type_day_start_time_index` (`type`,`day`,`start_time`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
  `group` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `settings_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shorts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `remote_id` bigint unsigned DEFAULT NULL,
  `article_id` bigint unsigned DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `caption` text COLLATE utf8mb4_unicode_ci,
  `source` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cloudinary',
  `video_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `thumbnail` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration_seconds` int unsigned DEFAULT NULL,
  `is_sponsored` tinyint(1) NOT NULL DEFAULT '0',
  `sponsor_label` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT '1',
  `view_count` bigint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `shorts_remote_id_unique` (`remote_id`),
  KEY `shorts_article_id_foreign` (`article_id`),
  KEY `shorts_is_published_created_at_index` (`is_published`,`created_at`),
  CONSTRAINT `shorts_article_id_foreign` FOREIGN KEY (`article_id`) REFERENCES `articles` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `remote_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci,
  `is_visible` tinyint(1) NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `staff_remote_id_unique` (`remote_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `videos` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `category_id` bigint unsigned DEFAULT NULL,
  `duration` varchar(12) COLLATE utf8mb4_unicode_ci NOT NULL,
  `video_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `aired_at` timestamp NULL DEFAULT NULL,
  `views` bigint unsigned NOT NULL DEFAULT '0',
  `published` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `videos_slug_unique` (`slug`),
  KEY `videos_published_aired_at_index` (`published`,`aired_at`),
  KEY `videos_category_id_index` (`category_id`),
  CONSTRAINT `videos_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

-- === Data for: users ===
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `users` VALUES (1,'Gotabgaa Admin','admin@gotabgaa.digital','2026-09-11 09:33:32','$2y$12$Nzn8lxwldKjJOmTkNKo6p.bEWru2mYiXJfy6G7nfCXdAiUpZ7X46u',NULL,'2026-09-11 09:33:32','2026-09-11 09:33:32');

-- === Data for: categories ===
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `categories` VALUES (8,'Education',NULL,'education',NULL,'#0891b2',0,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(9,'News','Newspaper','news',NULL,'#E63329',1,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(10,'Sports','Trophy','sports',NULL,'#16A34A',2,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(11,'Politics','Landmark','politics',NULL,'#2563EB',3,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(12,'Business','TrendingUp','business',NULL,'#D97706',4,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(13,'Health','HeartPulse','health',NULL,'#DC2626',5,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(14,'Agriculture','Sprout','agriculture',NULL,'#be185d',6,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(15,'Entertainment','Tv','entertainment',NULL,'#9333EA',7,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(16,'Culture','Globe','culture',NULL,'#0891B2',8,1,'2026-09-11 09:33:59','2026-09-11 09:33:59');

-- === Data for: staff ===
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `staff` VALUES (1,1,'Beaconlight Admin','254715154170','admin@gotabgaa.co.ke','Super Admin',NULL,NULL,0,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(2,2,'Allan Ngeno','254795794949',NULL,'Presenter',NULL,NULL,0,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(3,3,'Beatrice Ngeno','254793710718',NULL,'Producer','gotabgaa/staff/li8xeh1imqiyczyokiea',NULL,0,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(4,4,'Mercy Chepkemoi Sugutit','254704655996',NULL,'Admin',NULL,NULL,0,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(5,5,'Yvonne Chepkoech','254710788243',NULL,'Admin',NULL,NULL,0,1,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(6,6,'EDDAH CHEPKEMOI','254704821035',NULL,'Admin',NULL,NULL,0,1,'2026-09-11 09:33:59','2026-09-11 09:33:59');

-- === Data for: programs ===
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `programs` VALUES (1,'morning-bulletin-monday-0600','Morning Bulletin','Start your day with the latest headlines from around the world.','Cherotich Bett','tv','Monday','06:00','09:00','#E63946|#FF7A1A',1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(2,'midday-brief-monday-1200','Midday Brief','A quick update on stories developing throughout the morning.','Kip Chumba','tv','Monday','12:00','13:00','#FFA31A|#E63946',1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(3,'prime-time-news-monday-2000','Prime Time News','The definitive evening news broadcast for the diaspora.','Kipchumba Lang\'at','tv','Monday','20:00','21:00','#FF7A1A|#FFA31A',1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(4,'business-focus-wednesday-1900','Business Focus','Deep dives into East African markets, startups and investment.','Kipkoech Mutai','tv','Wednesday','19:00','20:00','#E63946|#FFA31A',1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(5,'weekend-culture-show-saturday-1000','Weekend Culture Show','Music, art, and stories from across the Kalenjin community.','Chebet Kiplagat','tv','Saturday','10:00','12:00','#FFA31A|#FF7A1A',1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(6,'youth-forum-friday-1700','Youth Forum','The next generation debates the issues that matter most.','Sarah Kimeli','tv','Friday','17:00','18:30','#FF7A1A|#E63946',1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(7,'morning-vibes-monday-0600','Morning Vibes','Wake up to the best of East African and international music.','DJ Kimutai','radio','Monday','06:00','10:00','#E63946|#FF7A1A',1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(8,'talk-music-tuesday-1400','Talk & Music','Conversation and curated music from around the world.','Faith Chepkorir','radio','Tuesday','14:00','17:00','#FFA31A|#E63946',1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(9,'sunday-sanctuary-sunday-0900','Sunday Sanctuary','Spiritual reflections and inspirational music.','Elder Kiplangat','radio','Sunday','09:00','12:00','#FF7A1A|#FFA31A',1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(10,'night-cruise-friday-2200','Night Cruise','Late night mixes to close out your week.','DJ Cherop','radio','Friday','22:00','01:00','#E63946|#FFA31A',1,'2026-09-11 09:33:32','2026-09-11 09:33:32');

-- === Data for: programmes ===
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `programmes` VALUES (1,1,'News','news-hxoy','News',NULL,'News',1,'2026-09-11 09:33:59','2026-09-11 09:33:59');

-- === Data for: videos ===
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `videos` VALUES (1,'prime-time-weekly-roundup','Prime Time News — Weekly Roundup','The stories that mattered most this week.',NULL,'1:12:30',NULL,'#E63946|#FF7A1A','2026-09-07 09:33:32',12400,1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(2,'kalenjin-sacred-rituals','Kalenjin Cultural Special: Sacred Rituals','An immersive look at initiation ceremonies preserved for generations.',NULL,'48:22',NULL,'#FFA31A|#FF7A1A','2026-09-05 09:33:32',8900,1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(3,'east-african-trade-corridor','Business Focus: East African Trade Corridor','How Kenya, Uganda and Tanzania are re-imagining regional commerce.',NULL,'32:15',NULL,'#FF7A1A|#E63946','2026-09-04 09:33:32',5100,1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(4,'marathon-highlights','Sports Rewind: Marathon Highlights','The best moments from a record-breaking marathon season.',NULL,'24:08',NULL,'#E63946|#FFA31A','2026-09-03 09:33:32',15600,1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(5,'diaspora-voices-boston','Diaspora Voices: Boston Community Chat','Boston\'s Kalenjin community shares stories of migration and belonging.',NULL,'58:45',NULL,'#FFA31A|#E63946','2026-09-02 09:33:32',3400,1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(6,'late-night-kip-chumba','Late Night Talk with Kip Chumba','Comedy, culture, and conversation.',NULL,'1:05:12',NULL,'#FF7A1A|#FFA31A','2026-09-01 09:33:32',9800,1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(7,'youth-forum-debate','Youth Forum: Great Diaspora Debate','Next-generation leaders discuss identity, work, and going home.',NULL,'44:20',NULL,'#E63946|#FF7A1A','2026-08-31 09:33:32',4200,1,'2026-09-11 09:33:32','2026-09-11 09:33:32'),(8,'election-analysis-special','Election Analysis Special','A panel of experts break down the latest polling.',NULL,'1:22:00',NULL,'#FFA31A|#FF7A1A','2026-08-30 09:33:32',21500,1,'2026-09-11 09:33:32','2026-09-11 09:33:32');

-- === Data for: articles ===
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `articles` VALUES (11,6,'learners-receive-guidance-on-managing-menstruation-with-dignity','LEARNERS RECEIVE GUIDANCE ON MANAGING MENSTRUATION WITH DIGNITY','LEARNERS RECEIVE GUIDANCE ON MANAGING MENSTRUATION WITH DIGNITY','LEARNERS RECEIVE GUIDANCE ON MANAGING MENSTRUATION WITH DIGNITY',8,NULL,'Beaconlight Admin',NULL,'https://youtu.be/44DQGTjjHKc',1,24,2,5,0,0,0,'published','2026-05-29 10:08:04',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(12,7,'busia-medics-urge-county-government-to-address-their-grievances','BUSIA MEDICS URGE COUNTY GOVERNMENT TO ADDRESS THEIR GRIEVANCES','BUSIA MEDICS URGE COUNTY GOVERNMENT TO ADDRESS THEIR GRIEVANCES','BUSIA MEDICS URGE COUNTY GOVERNMENT TO ADDRESS THEIR GRIEVANCES',13,NULL,'Yvonne Chepkoech',NULL,'https://youtu.be/OEAcxlbd-Fk',0,22,2,0,0,0,0,'published','2026-05-29 12:26:17',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(13,8,'community-asked-to-support-former-prisoners-after-release','COMMUNITY ASKED TO SUPPORT FORMER PRISONERS AFTER RELEASE','COMMUNITY ASKED TO SUPPORT FORMER PRISONERS AFTER RELEASE','COMMUNITY ASKED TO SUPPORT FORMER PRISONERS AFTER RELEASE',9,NULL,'Yvonne Chepkoech',NULL,NULL,0,12,2,0,0,0,0,'published','2026-05-29 12:06:09',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(14,9,'directorate-of-criminal-investigations-begins-probe-into-cause-of-fire-at-utumishi-academy','DIRECTORATE OF CRIMINAL INVESTIGATIONS BEGINS PROBE INTO CAUSE OF FIRE AT UTUMISHI ACADEMY','DIRECTORATE OF CRIMINAL INVESTIGATIONS BEGINS PROBE INTO CAUSE OF FIRE AT UTUMISHI ACADEMY','DIRECTORATE OF CRIMINAL INVESTIGATIONS BEGINS PROBE INTO CAUSE OF FIRE AT UTUMISHI ACADEMY',8,NULL,'Yvonne Chepkoech',NULL,'https://youtu.be/DUTXGoTMPF0',0,8,1,0,0,0,0,'published','2026-05-29 12:23:17',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(15,10,'high-court-halts-establishment-of-ebola-quarantine-facility-in-kenya','HIGH COURT HALTS ESTABLISHMENT OF EBOLA QUARANTINE FACILITY IN KENYA','HIGH COURT HALTS ESTABLISHMENT OF EBOLA QUARANTINE FACILITY IN KENYA','HIGH COURT HALTS ESTABLISHMENT OF EBOLA QUARANTINE FACILITY IN KENYA',13,NULL,'Yvonne Chepkoech',NULL,'https://youtu.be/8VQBboJaTTw',1,7,3,0,0,0,0,'published','2026-05-29 12:22:55',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(16,11,'residents-celebrate-receipt-of-land-titles-in-samburu-county','RESIDENTS CELEBRATE RECEIPT OF LAND TITLES IN SAMBURU COUNTY','RESIDENTS CELEBRATE RECEIPT OF LAND TITLES IN SAMBURU COUNTY','RESIDENTS CELEBRATE RECEIPT OF LAND TITLES IN SAMBURU COUNTY',9,NULL,'Yvonne Chepkoech',NULL,'https://youtu.be/FQEqnBh0bZc',0,11,0,0,0,0,0,'published','2026-05-29 12:25:53',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(17,13,'former-deputy-president-calls-on-legislators-to-oppose-finance-bill','FORMER DEPUTY PRESIDENT CALLS ON LEGISLATORS TO OPPOSE FINANCE BILL','FORMER DEPUTY PRESIDENT CALLS ON LEGISLATORS TO OPPOSE FINANCE BILL','FORMER DEPUTY PRESIDENT CALLS ON LEGISLATORS TO OPPOSE FINANCE BILL',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/MsRZYGQBzkg',0,1,0,0,0,0,0,'published','2026-06-18 16:09:57',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(18,14,'former-kilgoris-mp-gedion-konchella-to-be-laid-to-rest-as-plans-progress','FORMER KILGORIS MP GEDION KONCHELLA TO BE LAID TO REST AS PLANS PROGRESS','FORMER KILGORIS MP GEDION KONCHELLA TO BE LAID TO REST AS PLANS PROGRESS','FORMER KILGORIS MP GEDION KONCHELLA TO BE LAID TO REST AS PLANS PROGRESS',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/LG-zUE8KBLk',0,1,0,0,0,0,0,'published','2026-06-18 16:11:41',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(19,15,'mosop-residents-celebrate-completion-of-76-kilometre-road','MOSOP RESIDENTS CELEBRATE COMPLETION OF 76 KILOMETRE ROAD','MOSOP RESIDENTS CELEBRATE COMPLETION OF 76 KILOMETRE ROAD','MOSOP RESIDENTS CELEBRATE COMPLETION OF 76 KILOMETRE ROAD',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/Pl_r4Qcip-E',0,1,0,0,0,0,0,'published','2026-06-18 16:12:44',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(20,16,'medical-officers-trained-on-snakebite-management-and-treatment','MEDICAL OFFICERS TRAINED ON SNAKEBITE MANAGEMENT AND TREATMENT','MEDICAL OFFICERS TRAINED ON SNAKEBITE MANAGEMENT AND TREATMENT','MEDICAL OFFICERS TRAINED ON SNAKEBITE MANAGEMENT AND TREATMENT',13,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/H63UkaaBcKs',0,1,0,0,0,0,0,'published','2026-06-18 16:13:39',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(21,17,'opposition-asked-to-avoid-spreading-misinformation-on-proposed-tax-measures-in-finance-bill','OPPOSITION ASKED TO AVOID SPREADING MISINFORMATION ON PROPOSED TAX MEASURES IN FINANCE BILL','OPPOSITION ASKED TO AVOID SPREADING MISINFORMATION ON PROPOSED TAX MEASURES IN FINANCE BILL','OPPOSITION ASKED TO AVOID SPREADING MISINFORMATION ON PROPOSED TAX MEASURES IN FINANCE BILL',11,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/YJyk5ztdunU',0,1,0,0,0,0,0,'published','2026-06-18 16:14:42',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(22,18,'president-ruto-officially-closes-11th-our-ocean-conference','PRESIDENT RUTO OFFICIALLY CLOSES 11TH OUR OCEAN CONFERENCE','PRESIDENT RUTO OFFICIALLY CLOSES 11TH OUR OCEAN CONFERENCE','PRESIDENT RUTO OFFICIALLY CLOSES 11TH OUR OCEAN CONFERENCE',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/-gWJA0Qf-o8',0,4,0,0,0,0,0,'published','2026-06-18 16:15:32',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(23,19,'iebc-raises-concern-over-rising-cases-of-goonism','IEBC RAISES CONCERN OVER RISING CASES OF GOONISM','IEBC RAISES CONCERN OVER RISING CASES OF GOONISM IN THE COUNTRY','IEBC RAISES CONCERN OVER RISING CASES OF GOONISM IN THE COUNTRY',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/MA2bEqLtmyM',0,2,0,0,0,0,0,'published','2026-06-18 16:17:23',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(24,20,'government-launches-new-initiative-to-boost-coffee-production','GOVERNMENT LAUNCHES NEW INITIATIVE TO BOOST COFFEE PRODUCTION','GOVERNMENT LAUNCHES NEW INITIATIVE TO BOOST COFFEE PRODUCTION','GOVERNMENT LAUNCHES NEW INITIATIVE TO BOOST COFFEE PRODUCTION',14,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/GWDOyfhteF0',0,0,0,0,0,0,0,'published','2026-06-22 16:34:08',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(25,21,'joy-fills-the-air-in-kapseret-as-residents-celebrate-fathers-day','JOY FILLS THE AIR IN KAPSERET AS RESIDENTS CELEBRATE FATHER\'S DAY','JOY FILLS THE AIR IN KAPSERET AS RESIDENTS CELEBRATE FATHER\'S DAY','JOY FILLS THE AIR IN KAPSERET AS RESIDENTS CELEBRATE FATHER\'S DAY',15,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/2izYLeDKrwk',0,4,0,0,0,0,0,'published','2026-06-22 16:34:54',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(26,22,'nandi-county-officials-face-tough-task-explaining-new-land-rates','NANDI COUNTY OFFICIALS FACE TOUGH TASK EXPLAINING NEW LAND RATES','NANDI COUNTY OFFICIALS FACE TOUGH TASK EXPLAINING NEW LAND RATES','NANDI COUNTY OFFICIALS FACE TOUGH TASK EXPLAINING NEW LAND RATES',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/Q3R6pIS6kqo',0,1,0,0,0,0,0,'published','2026-06-22 16:35:45',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(27,23,'fear-grips-narok-residents-amid-ongoing-clashes','FEAR GRIPS NAROK RESIDENTS AMID ONGOING CLASHES','FEAR GRIPS NAROK RESIDENTS AMID ONGOING CLASHES','FEAR GRIPS NAROK RESIDENTS AMID ONGOING CLASHES',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/8prqfCafnYA',0,2,0,0,0,0,0,'published','2026-06-22 16:36:43',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(28,24,'narok-south-residents-encouraged-to-focus-on-development-oriented-leaders','NAROK SOUTH RESIDENTS ENCOURAGED TO FOCUS ON DEVELOPMENT ORIENTED LEADERS','NAROK SOUTH RESIDENTS ENCOURAGED TO FOCUS ON DEVELOPMENT ORIENTED LEADERS','NAROK SOUTH RESIDENTS ENCOURAGED TO FOCUS ON DEVELOPMENT ORIENTED LEADERS',11,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/eQxJnPzf49c',0,5,0,0,0,0,0,'published','2026-06-22 16:37:39',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(29,25,'dp-kindiki-rallies-citizens-to-back-president-rutos-development-plans','DP KINDIKI RALLIES CITIZENS TO BACK PRESIDENT RUTO\'S DEVELOPMENT PLANS','DP KINDIKI RALLIES CITIZENS TO BACK PRESIDENT RUTO\'S DEVELOPMENT PLANS','DP KINDIKI RALLIES CITIZENS TO BACK PRESIDENT RUTO\'S DEVELOPMENT PLANS',11,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/iudV5bnAbqU',0,4,0,0,0,0,0,'published','2026-06-22 16:38:36',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(30,26,'dcp-party-leader-rigathi-gachagua-warns-youths-against-participation-in-thursday-protests','DCP PARTY LEADER RIGATHI GACHAGUA WARNS YOUTHS AGAINST PARTICIPATION IN THURSDAY PROTESTS','DCP PARTY LEADER RIGATHI GACHAGUA WARNS YOUTHS AGAINST PARTICIPATION IN THURSDAY PROTESTS','DCP PARTY LEADER RIGATHI GACHAGUA WARNS YOUTHS AGAINST PARTICIPATION IN THURSDAY PROTESTS',11,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/NVWjHSZRoc8',0,3,0,0,0,0,0,'published','2026-06-23 16:13:16',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(31,27,'farmers-advised-to-invest-in-dairy-goats-for-better-returns','FARMERS ADVISED TO INVEST IN DAIRY GOATS FOR BETTER RETURNS','FARMERS ADVISED TO INVEST IN DAIRY GOATS FOR BETTER RETURNS','FARMERS ADVISED TO INVEST IN DAIRY GOATS FOR BETTER RETURNS',14,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/t-Vls_j_c0w',0,3,0,0,0,0,0,'published','2026-06-23 16:14:31',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(32,28,'finance-bill-2026-becomes-law-after-president-rutos-approval','FINANCE BILL 2026 BECOMES LAW AFTER PRESIDENT RUTO\'S APPROVAL','FINANCE BILL 2026 BECOMES LAW AFTER PRESIDENT RUTO\'S APPROVAL','FINANCE BILL 2026 BECOMES LAW AFTER PRESIDENT RUTO\'S APPROVAL',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/dUq9bBFGZec',0,5,0,0,0,0,0,'published','2026-06-23 16:15:24',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(33,29,'kuresoi-north-lawmaker-released-as-court-sets-ksh50000-bail-and-ksh100000-bond','KURESOI NORTH LAWMAKER RELEASED AS COURT SETS KSH50,000 BAIL AND KSH100,000 BOND','KURESOI NORTH LAWMAKER RELEASED AS COURT SETS KSH50,000 BAIL AND KSH100,000 BOND','KURESOI NORTH LAWMAKER RELEASED AS COURT SETS KSH50,000 BAIL AND KSH100,000 BOND',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/clHw8_r5b8k',0,0,0,0,0,0,0,'published','2026-06-23 16:16:13',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(34,30,'youths-urged-to-maintain-peace-during-demonstrations','YOUTHS URGED TO MAINTAIN PEACE DURING DEMONSTRATIONS','YOUTHS URGED TO MAINTAIN PEACE DURING DEMONSTRATIONS','YOUTHS URGED TO MAINTAIN PEACE DURING DEMONSTRATIONS',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/CcZUAOeFxvg',0,1,0,0,0,0,0,'published','2026-06-23 16:17:11',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(35,31,'compensation-issued-to-victims-of-human-wildlife-conflict-in-kingwal-nandi-county','COMPENSATION ISSUED TO VICTIMS OF HUMAN WILDLIFE CONFLICT IN KINGWAL, NANDI COUNTY','COMPENSATION ISSUED TO VICTIMS OF HUMAN WILDLIFE CONFLICT IN KINGWAL, NANDI COUNTY','COMPENSATION ISSUED TO VICTIMS OF HUMAN WILDLIFE CONFLICT IN KINGWAL, NANDI COUNTY',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/vxaXPILyXCc',0,6,0,0,0,0,0,'published','2026-06-26 16:04:39',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(36,32,'dairy-farming-touted-as-key-to-increasing-milk-production-in-trans-nzoia-county','DAIRY FARMING TOUTED AS KEY TO INCREASING MILK PRODUCTION IN TRANS NZOIA COUNTY','DAIRY FARMING TOUTED AS KEY TO INCREASING MILK PRODUCTION IN TRANS NZOIA COUNTY','DAIRY FARMING TOUTED AS KEY TO INCREASING MILK PRODUCTION IN TRANS NZOIA COUNTY',14,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/ey2C0WAboFA',0,2,0,0,0,0,0,'published','2026-06-26 16:05:29',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(37,33,'fear-of-unrest-led-some-youths-to-skip-anniversary-demonstrations','FEAR OF UNREST LED SOME YOUTHS TO SKIP ANNIVERSARY DEMONSTRATIONS','FEAR OF UNREST LED SOME YOUTHS TO SKIP ANNIVERSARY DEMONSTRATIONS','FEAR OF UNREST LED SOME YOUTHS TO SKIP ANNIVERSARY DEMONSTRATIONS',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/HTUgd5g0CtU',0,1,0,0,0,0,0,'published','2026-06-26 16:06:23',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(38,34,'ncck-opposes-government-compensation-initiative-for-demonstration-victims','NCCK OPPOSES GOVERNMENT COMPENSATION INITIATIVE FOR DEMONSTRATION VICTIMS','NCCK OPPOSES GOVERNMENT COMPENSATION INITIATIVE FOR DEMONSTRATION VICTIMS','NCCK OPPOSES GOVERNMENT COMPENSATION INITIATIVE FOR DEMONSTRATION VICTIMS',11,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/lopDASBj3-I',0,3,0,0,0,0,0,'published','2026-06-26 16:07:12',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(39,35,'aviation-sector-backs-climate-fight-with-16000-mangrove-trees-in-kwale','AVIATION SECTOR BACKS CLIMATE FIGHT WITH 16,000 MANGROVE TREES IN KWALE','AVIATION SECTOR BACKS CLIMATE FIGHT WITH 16,000 MANGROVE TREES IN KWALE','AVIATION SECTOR BACKS CLIMATE FIGHT WITH 16,000 MANGROVE TREES IN KWALE',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/B0g4FB-lauY',0,4,0,0,0,0,0,'published','2026-06-26 16:08:05',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(40,36,'angata-barrikoi-residents-encouraged-to-surrender-weapons-to-enhance-security','ANG\'ATA BARRIKOI RESIDENTS ENCOURAGED TO SURRENDER WEAPONS TO ENHANCE SECURITY','ANG\'ATA BARRIKOI RESIDENTS ENCOURAGED TO SURRENDER WEAPONS TO ENHANCE SECURITY','ANG\'ATA BARRIKOI RESIDENTS ENCOURAGED TO SURRENDER WEAPONS TO ENHANCE SECURITY',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/K7lNYDRfs0s',0,6,1,0,0,0,0,'published','2026-07-01 10:08:18',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(41,37,'court-hears-case-involving-eight-utumishi-girls-students-charged-over-school-fire','COURT HEARS CASE INVOLVING EIGHT UTUMISHI GIRLS STUDENTS CHARGED OVER SCHOOL FIRE','COURT HEARS CASE INVOLVING EIGHT UTUMISHI GIRLS STUDENTS CHARGED OVER SCHOOL FIRE','COURT HEARS CASE INVOLVING EIGHT UTUMISHI GIRLS STUDENTS CHARGED OVER SCHOOL FIRE',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/qSgX-7CLU_Q',0,6,0,0,0,0,0,'published','2026-07-01 10:09:17',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(42,38,'residents-join-tree-planting-campaign-in-sengwer-elgeyo-marakwet','RESIDENTS JOIN TREE PLANTING CAMPAIGN IN SENGWER, ELGEYO MARAKWET','RESIDENTS JOIN TREE PLANTING CAMPAIGN IN SENGWER, ELGEYO MARAKWET','RESIDENTS JOIN TREE PLANTING CAMPAIGN IN SENGWER, ELGEYO MARAKWET',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/wBsFLwenHIM',0,6,0,0,0,0,0,'published','2026-07-01 10:11:01',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(43,39,'kericho-senator-urges-residents-to-back-rutos-development-projects','KERICHO SENATOR URGES RESIDENTS TO BACK RUTO\'S DEVELOPMENT PROJECTS','KERICHO SENATOR URGES RESIDENTS TO BACK RUTO\'S DEVELOPMENT PROJECTS','KERICHO SENATOR URGES RESIDENTS TO BACK RUTO\'S DEVELOPMENT PROJECTS',11,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/rdYyTyVy0z4',0,6,0,0,0,0,0,'published','2026-07-01 10:11:54',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(44,40,'utumishi-girls-secondary-school-students-return-for-the-new-term','UTUMISHI GIRLS SECONDARY SCHOOL STUDENTS RETURN FOR THE NEW TERM','UTUMISHI GIRLS SECONDARY SCHOOL STUDENTS RETURN FOR THE NEW TERM','UTUMISHI GIRLS SECONDARY SCHOOL STUDENTS RETURN FOR THE NEW TERM',8,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/oSfwaSjCyiU',0,2,0,0,0,0,0,'published','2026-07-02 10:47:18',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(45,41,'ugandan-leadership-urged-to-protect-democratic-and-constitutional-values','UGANDAN LEADERSHIP URGED TO PROTECT DEMOCRATIC AND CONSTITUTIONAL VALUES','UGANDAN LEADERSHIP URGED TO PROTECT DEMOCRATIC AND CONSTITUTIONAL VALUES','UGANDAN LEADERSHIP URGED TO PROTECT DEMOCRATIC AND CONSTITUTIONAL VALUES',11,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/qWuoJwEkjgA',0,5,0,0,0,0,0,'published','2026-07-02 10:48:02',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(46,42,'prime-cs-advocates-for-quality-education-and-responsible-leadership','PRIME CS ADVOCATES FOR QUALITY EDUCATION AND RESPONSIBLE LEADERSHIP','PRIME CS ADVOCATES FOR QUALITY EDUCATION AND RESPONSIBLE LEADERSHIP','PRIME CS ADVOCATES FOR QUALITY EDUCATION AND RESPONSIBLE LEADERSHIP',8,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/h7uFhm580HA',0,3,0,0,0,0,0,'published','2026-07-02 10:48:42',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(47,43,'plans-underway-to-restore-peace-in-marashi-busia-county','PLANS UNDERWAY TO RESTORE PEACE IN MARASHI, BUSIA COUNTY','PLANS UNDERWAY TO RESTORE PEACE IN MARASHI, BUSIA COUNTY','PLANS UNDERWAY TO RESTORE PEACE IN MARASHI, BUSIA COUNTY',9,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/UaSB17g9V8w',0,5,1,0,0,0,0,'published','2026-07-02 10:49:21',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59'),(48,44,'plans-underway-to-promote-peace-among-learners-in-nandi-county','PLANS UNDERWAY TO PROMOTE PEACE AMONG LEARNERS IN NANDI COUNTY','PLANS UNDERWAY TO PROMOTE PEACE AMONG LEARNERS IN NANDI COUNTY','PLANS UNDERWAY TO PROMOTE PEACE AMONG LEARNERS IN NANDI COUNTY',8,NULL,'EDDAH CHEPKEMOI',NULL,'https://youtu.be/aBiGq6rPlv0',0,3,1,0,0,0,0,'published','2026-07-02 10:49:53',1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59');

-- === Data for: shorts ===
SET FOREIGN_KEY_CHECKS = 0;

-- === Data for: breaking_news ===
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `breaking_news` VALUES (1,'Welcome to Gotabgaa TV Digital Platform — Watch Live, Read News, Engage with Your Community',NULL,1,NULL,'2026-09-11 09:33:59','2026-09-11 09:33:59');

-- === Data for: polls ===
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `polls` VALUES (3,'best-harambee-stars-2026','Who deserves to lead Harambee Stars in 2026?','[{\"id\": \"olunga\", \"label\": \"Michael Olunga\", \"votes\": 1284}, {\"id\": \"wanyama\", \"label\": \"Victor Wanyama\", \"votes\": 967}, {\"id\": \"omurwa\", \"label\": \"Ismail Omurwa\", \"votes\": 342}, {\"id\": \"wafula\", \"label\": \"John Avire\", \"votes\": 118}]',1,'2026-09-14 09:34:44','2026-09-11 09:34:44','2026-09-11 09:34:44'),(4,'devolution-15-years','Has devolution delivered for your county?','[{\"id\": \"yes\", \"label\": \"Yes, real change\", \"votes\": 512}, {\"id\": \"somewhat\", \"label\": \"Somewhat — mixed record\", \"votes\": 1247}, {\"id\": \"no\", \"label\": \"Not at all\", \"votes\": 891}, {\"id\": \"unsure\", \"label\": \"Too early to say\", \"votes\": 203}]',1,'2026-09-16 09:34:44','2026-09-11 09:34:44','2026-09-11 09:34:44'),(5,'kalenjin-music-awards','Top Kalenjin artist of the year?','[{\"id\": \"kipchamba\", \"label\": \"Kipchamba\", \"votes\": 1876}, {\"id\": \"chebaibai\", \"label\": \"Chebaibai\", \"votes\": 1420}, {\"id\": \"ekitala\", \"label\": \"Ekitala\", \"votes\": 735}, {\"id\": \"monori\", \"label\": \"Monori\", \"votes\": 412}, {\"id\": \"jane-chelagat\", \"label\": \"Jane Chelagat\", \"votes\": 289}]',1,'2026-09-13 09:34:44','2026-09-11 09:34:44','2026-09-11 09:34:44'),(6,'biggest-story-this-week','What\'s the biggest story of the week?','[{\"id\": \"peace-nandi\", \"label\": \"Peace plans for learners in Nandi County\", \"votes\": 456}, {\"id\": \"peace-marashi\", \"label\": \"Peace restored in Marashi, Busia County\", \"votes\": 318}, {\"id\": \"utumishi\", \"label\": \"Utumishi Girls return for new term\", \"votes\": 274}, {\"id\": \"kericho-devt\", \"label\": \"Kericho Senator on Ruto\'s development projects\", \"votes\": 502}]',1,'2026-09-12 21:34:44','2026-09-11 09:34:44','2026-09-11 09:34:44');

-- === Data for: poll_votes ===
SET FOREIGN_KEY_CHECKS = 0;

-- === Data for: settings ===
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `settings` VALUES (1,'tv_title','Gotabgaa TV','stream','2026-09-11 09:33:32','2026-09-11 09:33:32'),(2,'tv_stream_url','https://staging.gotabgaa.co.ke/api/proxy.php','stream','2026-09-11 09:33:32','2026-09-11 09:33:59'),(3,'radio_title','Gotabgaa Radio','stream','2026-09-11 09:33:32','2026-09-11 09:33:32'),(4,'radio_frequency','102.5 FM','stream','2026-09-11 09:33:32','2026-09-11 09:33:32'),(5,'radio_stream_url','','stream','2026-09-11 09:33:32','2026-09-11 09:33:32'),(6,'stream_is_live','1','stream','2026-09-11 09:33:59','2026-09-11 09:33:59'),(7,'social_whatsapp',NULL,'social','2026-09-11 09:33:59','2026-09-11 09:33:59'),(8,'social_facebook','https://facebook.com/GotabgaaTV','social','2026-09-11 09:33:59','2026-09-11 09:33:59'),(9,'social_youtube','http://www.youtube.com/@GotabgaaTelevision','social','2026-09-11 09:33:59','2026-09-11 09:33:59'),(10,'social_tiktok','https://www.tiktok.com/@gotabgaatv?is_from_webapp=1&sender_device=pc','social','2026-09-11 09:33:59','2026-09-11 09:33:59'),(11,'social_instagram',NULL,'social','2026-09-11 09:33:59','2026-09-11 09:33:59'),(12,'station_name','Gotabgaa Digital','general','2026-09-11 09:33:59','2026-09-11 09:33:59'),(13,'station_tagline','The Pride of Kalenjin','general','2026-09-11 09:33:59','2026-09-11 09:33:59'),(14,'contact_phone','+254713176146','general','2026-09-11 09:33:59','2026-09-11 09:33:59'),(15,'contact_email','gotabgaatelevision@gmail.com','general','2026-09-11 09:33:59','2026-09-11 09:33:59'),(16,'contact_address','Kericho County, Kenya','general','2026-09-11 09:33:59','2026-09-11 09:33:59'),(17,'ga_measurement_id',NULL,'analytics','2026-09-11 09:33:59','2026-09-11 09:33:59');

-- === Data for: contact_messages ===
SET FOREIGN_KEY_CHECKS = 0;

SET FOREIGN_KEY_CHECKS = 1;
SET UNIQUE_CHECKS = 1;
