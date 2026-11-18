-- MySQL dump 10.13  Distrib 8.4.11, for Linux (x86_64)
--
-- Host: localhost    Database: restaurant_db_Kaunas
-- ------------------------------------------------------
-- Server version	8.4.11

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `darbuotojas`
--

DROP SCHEMA IF EXISTS restaurant_db_Kaunas;
CREATE SCHEMA restaurant_db_Kaunas;
USE restaurant_db_Kaunas;

DROP TABLE IF EXISTS `darbuotojas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `darbuotojas` (
  `darbuotojas_id` int NOT NULL AUTO_INCREMENT,
  `vardas` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pavarde` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pareiga` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `atostogauja` tinyint(1) NOT NULL DEFAULT '0',
  `telefonas` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `el_pastas` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `restoranas_id` int NOT NULL,
  PRIMARY KEY (`darbuotojas_id`),
  KEY `darbuotojas_restoranas_fk` (`restoranas_id`),
  CONSTRAINT `darbuotojas_restoranas_fk` FOREIGN KEY (`restoranas_id`) REFERENCES `restoranas` (`restoranas_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=164 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `darbuotojas`
--

LOCK TABLES `darbuotojas` WRITE;
/*!40000 ALTER TABLE `darbuotojas` DISABLE KEYS */;
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (1,'Jonas','Kazlauskas','Padavėjas',0,'+37060000001','jonas.kazlauskas1@example.com',12);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (2,'Mantas','Petrauskas','Virėjas',0,'+37060000002','mantas.petrauskas2@example.com',45);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (4,'Lukas','Bieliauskas','Padavėjas',0,'+37060000004','lukas.bieliauskas4@example.com',5);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (7,'Tomas','Kairys','Barmenas',1,'+37060000006','tomas.kairys6@example.com',33);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (9,'Paulius','Urbonas','Virėjas',0,'+37060000008','paulius.urbonas8@example.com',12);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (11,'Edgaras','Stankevičius','Padavėjas',1,'+37060000010','edgaras.stankevicius10@example.com',17);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (12,'Simonas','Misevičius','Padavėjas',0,'+37060000101','simonas.misevicius101@example.com',14);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (14,'Rokas','Karpavičius','Barmenas',0,'+37060000103','rokas.karpavicius103@example.com',33);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (15,'Justina','Bartaškaitė','Padavėja',0,'+37060000104','justina.bartaskaite104@example.com',21);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (17,'Gabija','Rimkutė','Administratorė',1,'+37060000106','gabija.rimkute106@example.com',19);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (19,'Arnas','Vaitkus','Padavėjas',0,'+37060000107','arnas.vaitkus107@example.com',22);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (21,'Tadas','Gricius','Virėjas',1,'+37060000109','tadas.gricius109@example.com',4);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (23,'Agnė','Kairytė','Barmenė',0,'+37060000110','agne.kairyte110@example.com',11);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (25,'Edvinas','Kavaliauskas','Virėjas',0,'+37060000112','edvinas.kavaliauskas112@example.com',32);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (26,'Rūta','Žalytė','Administratorė',1,'+37060000113','ruta.zalyte113@example.com',18);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (28,'Austėja','Kvietkauskaitė','Padavėja',0,'+37060000115','austeja.kvietkauskaite115@example.com',9);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (29,'Saulius','Blažys','Virėjas',1,'+37060000116','saulius.blazys116@example.com',42);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (31,'Vytautas','Kuzminas','Padavėjas',0,'+37060000118','vytautas.kuzminas118@example.com',41);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (33,'Mindaugas','Karpis','Virėjas',1,'+37060000120','mindaugas.karpis120@example.com',27);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (34,'Neringa','Jonaitytė','Padavėja',0,'+37060000121','neringa.jonaityte121@example.com',34);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (37,'Darius','Mikalauskas','Virėjas',0,'+37060000124','darius.mikalauskas124@example.com',12);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (39,'Lina','Kvedaraitė','Padavėja',0,'+37060000126','lina.kvedaraite126@example.com',23);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (42,'Giedrius','Varnas','Padavėjas',0,'+37060000129','giedrius.varnas129@example.com',24);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (43,'Justė','Kvietkauskaitė','Administratorė',1,'+37060000130','juste.kvietkauskaite130@example.com',12);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (44,'Arvydas','Kairys','Virėjas',0,'+37060000131','arvydas.kairys131@example.com',7);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (48,'Marius','Karpavičius','Virėjas',0,'+37060000135','marius.karpavicius135@example.com',24);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (49,'Viktorija','Bieliauskaitė','Administratorė',1,'+37060000136','viktorija.bieliauskaite136@example.com',32);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (50,'Lukas','Vasiliauskas','Padavėjas',0,'+37060000137','lukas.vasiliauskas137@example.com',3);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (54,'Evelina','Misevičiūtė','Padavėja',0,'+37060000141','evelina.miseviciute141@example.com',12);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (55,'Raimondas','Kvietkus','Virėjas',1,'+37060000142','raimondas.kvietkus142@example.com',36);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (57,'Danas','Gricius','Padavėjas',0,'+37060000144','danas.gricius144@example.com',18);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (59,'Goda','Kairytė','Padavėja',1,'+37060000145','goda.kairyte145@example.com',21);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (61,'Agnė','Venslovaitė','Barmenė',0,'+37060000147','agne.venslovaite147@example.com',29);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (63,'Ieva','Žalytė','Administratorė',0,'+37060000149','ieva.zalyte149@example.com',28);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (64,'Mantas','Gailius','Virėjas',0,'+37060000150','mantas.gailius150@example.com',11);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (66,'Darius','Blažys','Barmenas',1,'+37060000152','darius.blazys152@example.com',43);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (72,'Lukas','Kuzminas','Virėjas',0,'+37060000154','lukas.kuzminas154@example.com',21);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (74,'Paulius','Stankevičius','Padavėjas',0,'+37060000156','paulius.stankevicius156@example.com',25);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (75,'Greta','Urbonaitė','Padavėja',0,'+37060000157','greta.urbonaite157@example.com',44);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (77,'Justina','Stonienė','Administratorė',0,'+37060000159','justina.stoniene159@example.com',19);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (78,'Edgaras','Kvedaras','Padavėjas',0,'+37060000160','edgaras.kvedaras160@example.com',5);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (79,'Aistė','Sakalauskaitė','Padavėja',1,'+37060000161','aiste.sakalauskaite161@example.com',18);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (80,'Marius','Varnas','Virėjas',0,'+37060000162','marius.varnas162@example.com',34);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (81,'Viktorija','Kvietkauskaitė','Administratorė',0,'+37060000163','viktorija.kvietkauskaite163@example.com',40);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (82,'Gytis','Kairys','Padavėjas',1,'+37060000164','gytis.kairys164@example.com',20);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (84,'Arvydas','Rimkus','Virėjas',0,'+37060000166','arvydas.rimkus166@example.com',22);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (89,'Dovydas','Vasiliauskas','Virėjas',1,'+37060000170','dovydas.vasiliauskas170@example.com',15);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (92,'Agnė','Stankevičiūtė','Padavėja',1,'+37060000173','agne.stankeviciute173@example.com',29);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (93,'Simonas','Misevičius','Virėjas',0,'+37060000174','simonas.misevicius174@example.com',31);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (94,'Eglė','Kvietkutė','Administratorė',0,'+37060000175','egle.kvietkute175@example.com',20);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (95,'Raimondas','Karpavičius','Padavėjas',1,'+37060000176','raimondas.karpavicius176@example.com',44);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (97,'Mindaugas','Gricius','Virėjas',0,'+37060000178','mindaugas.gricius178@example.com',7);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (98,'Neringa','Kairytė','Administratorė',1,'+37060000179','neringa.kairyte179@example.com',17);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (100,'Tadas','Mockus','Padavėjas',0,'+37060000180','tadas.mockus180@example.com',22);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (101,'Gintarė','Venslovaitė','Padavėja',0,'+37060000181','gintare.venslovaite181@example.com',42);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (103,'Laura','Kvietkutė','Administratorė',0,'+37060000183','laura.kvietkute183@example.com',27);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (104,'Mindaugas','Misevičius','Padavėjas',0,'+37060000184','mindaugas.misevicius184@example.com',36);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (105,'Neringa','Bartaškaitė','Padavėja',1,'+37060000185','neringa.bartaskaite185@example.com',28);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (106,'Tadas','Gricius','Virėjas',0,'+37060000186','tadas.gricius186@example.com',24);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (108,'Arnas','Mockus','Padavėjas',1,'+37060000188','arnas.mockus188@example.com',11);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (111,'Greta','Stankevičiūtė','Padavėja',1,'+37060000191','greta.stankeviciute191@example.com',19);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (113,'Monika','Kuzmickaitė','Padavėja',0,'+37060000193','monika.kuzmickaite193@example.com',42);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (114,'Edgaras','Stankevičius','Virėjas',1,'+37060000194','edgaras.stankevicius194@example.com',22);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (115,'Aistė','Rimkutė','Administratorė',0,'+37060000195','aiste.rimkute195@example.com',18);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (116,'Marius','Karpis','Padavėjas',0,'+37060000196','marius.karpis196@example.com',25);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (117,'Viktorija','Žukaitė','Padavėja',1,'+37060000197','viktorija.zukaite197@example.com',33);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (119,'Emilija','Bieliauskaitė','Administratorė',0,'+37060000199','emilija.bieliauskaite199@example.com',44);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (120,'Arvydas','Varnas','Padavėjas',1,'+37060000200','arvydas.varnas200@example.com',12);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (122,'Tautvydas','Karpavičius','Virėjas',0,'+37060000202','tautvydas.karpavicius202@example.com',45);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (125,'Dovydas','Kairys','Padavėjas',0,'+37060000204','dovydas.kairys204@example.com',24);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (129,'Simonas','Misevičius','Padavėjas',0,'+37060000208','simonas.misevicius208@example.com',27);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (130,'Eglė','Kvietkutė','Administratorė',1,'+37060000209','egle.kvietkute209@example.com',32);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (133,'Mindaugas','Gricius','Virėjas',1,'+37060000212','mindaugas.gricius212@example.com',7);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (134,'Neringa','Kairytė','Administratorė',0,'+37060000213','neringa.kairyte213@example.com',17);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (136,'Gintarė','Venslovaitė','Padavėja',1,'+37060000215','gintare.venslovaite215@example.com',42);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (138,'Laura','Kvietkutė','Administratorė',0,'+37060000217','laura.kvietkute217@example.com',27);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (139,'Arnas','Misevičius','Padavėjas',1,'+37060000218','arnas.misevicius218@example.com',36);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (140,'Ieva','Bartaškaitė','Padavėja',0,'+37060000219','ieva.bartaskaite219@example.com',28);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (141,'Tomas','Gricius','Virėjas',0,'+37060000220','tomas.gricius220@example.com',24);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (142,'Gintarė','Venslovaitė','Padavėja',0,'+37060000181','gintare.venslovaite181@example.com',42);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (144,'Laura','Kvietkutė','Administratorė',0,'+37060000183','laura.kvietkute183@example.com',27);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (145,'Mindaugas','Misevičius','Padavėjas',0,'+37060000184','mindaugas.misevicius184@example.com',36);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (146,'Neringa','Bartaškaitė','Padavėja',1,'+37060000185','neringa.bartaskaite185@example.com',28);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (147,'Tadas','Gricius','Virėjas',0,'+37060000186','tadas.gricius186@example.com',24);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (149,'Arnas','Mockus','Padavėjas',1,'+37060000188','arnas.mockus188@example.com',11);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (152,'Greta','Stankevičiūtė','Padavėja',1,'+37060000191','greta.stankeviciute191@example.com',19);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (154,'Monika','Kuzmickaitė','Padavėja',0,'+37060000193','monika.kuzmickaite193@example.com',12);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (155,'Edgaras','Stankevičius','Virėjas',1,'+37060000194','edgaras.stankevicius194@example.com',22);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (156,'Aistė','Rimkutė','Administratorė',0,'+37060000195','aiste.rimkute195@example.com',18);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (157,'Marius','Karpis','Padavėjas',0,'+37060000196','marius.karpis196@example.com',25);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (158,'Viktorija','Žukaitė','Padavėja',1,'+37060000197','viktorija.zukaite197@example.com',33);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (160,'Emilija','Bieliauskaitė','Administratorė',0,'+37060000199','emilija.bieliauskaite199@example.com',44);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (161,'Arvydas','Varnas','Padavėjas',1,'+37060000200','arvydas.varnas200@example.com',12);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (163,'Tautvydas','Karpavičius','Virėjas',0,'+37060000202','tautvydas.karpavicius202@example.com',45);
/*!40000 ALTER TABLE `darbuotojas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dieta`
--

DROP TABLE IF EXISTS `dieta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dieta` (
  `dieta_id` int NOT NULL AUTO_INCREMENT,
  `pavadinimas` varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`dieta_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dieta`
--

LOCK TABLES `dieta` WRITE;
/*!40000 ALTER TABLE `dieta` DISABLE KEYS */;
INSERT INTO `dieta` (`dieta_id`, `pavadinimas`) VALUES (1,'vegetariška');
INSERT INTO `dieta` (`dieta_id`, `pavadinimas`) VALUES (2,'veganiška');
INSERT INTO `dieta` (`dieta_id`, `pavadinimas`) VALUES (3,'viduržemio jūros');
INSERT INTO `dieta` (`dieta_id`, `pavadinimas`) VALUES (4,'ketogeninė');
INSERT INTO `dieta` (`dieta_id`, `pavadinimas`) VALUES (5,'paleodietiška');
INSERT INTO `dieta` (`dieta_id`, `pavadinimas`) VALUES (6,'be glitimo');
INSERT INTO `dieta` (`dieta_id`, `pavadinimas`) VALUES (7,'be laktozės');
/*!40000 ALTER TABLE `dieta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kliento_eilute`
--

DROP TABLE IF EXISTS `kliento_eilute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kliento_eilute` (
  `kliento_eilute_id` int NOT NULL AUTO_INCREMENT,
  `kaina` decimal(8,2) NOT NULL,
  `kiekis` int NOT NULL,
  `kliento_uzsakymas_id` int NOT NULL,
  `porcija_id` int NOT NULL,
  PRIMARY KEY (`kliento_eilute_id`),
  KEY `kliento_eil_kliento_uzs_fk` (`kliento_uzsakymas_id`),
  KEY `kliento_eilute_porcija_fk` (`porcija_id`),
  CONSTRAINT `kliento_eil_kliento_uzs_fk` FOREIGN KEY (`kliento_uzsakymas_id`) REFERENCES `kliento_uzsakymas` (`kliento_uzsakymas_id`) ON DELETE CASCADE,
  CONSTRAINT `kliento_eilute_porcija_fk` FOREIGN KEY (`porcija_id`) REFERENCES `porcija` (`porcija_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=297 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kliento_eilute`
--

LOCK TABLES `kliento_eilute` WRITE;
/*!40000 ALTER TABLE `kliento_eilute` DISABLE KEYS */;
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (1,6.20,1,1,1);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (2,9.80,2,1,2);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (5,25.50,5,3,5);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (6,7.30,1,3,6);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (11,11.20,1,6,11);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (12,31.60,2,6,12);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (13,12.90,3,7,13);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (14,27.60,4,7,14);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (21,4.50,1,11,22);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (22,14.40,2,11,23);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (25,19.50,5,13,26);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (26,6.70,1,13,27);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (31,11.50,1,16,32);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (32,29.60,2,16,33);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (33,25.00,3,17,34);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (34,30.00,4,17,35);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (41,5.50,1,21,42);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (42,16.80,2,21,43);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (45,20.00,5,23,46);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (46,15.60,1,23,47);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (51,10.80,1,26,52);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (52,35.00,2,26,53);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (53,14.10,3,27,54);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (54,19.50,4,27,55);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (61,7.00,1,31,63);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (62,22.00,2,31,64);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (65,41.00,5,33,67);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (66,10.00,1,33,68);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (71,13.70,1,36,73);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (72,11.20,2,36,74);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (73,21.30,3,37,75);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (74,41.60,4,37,76);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (89,18.40,4,45,91);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (90,25.20,5,45,92);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (99,49.20,4,50,102);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (100,21.60,5,50,103);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (109,24.80,4,55,112);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (110,46.50,5,55,113);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (119,51.20,4,60,122);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (120,25.50,5,60,123);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (129,26.80,4,65,132);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (130,48.00,5,65,133);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (139,50.40,4,70,142);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (140,26.00,5,70,143);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (149,24.40,4,75,152);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (150,49.00,5,75,153);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (159,51.60,4,80,162);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (160,26.50,5,80,163);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (161,22.80,1,81,164);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (162,20.20,2,81,165);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (163,44.40,3,82,166);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (164,24.80,4,82,167);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (181,22.20,1,91,184);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (182,20.40,2,91,185);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (183,57.20,3,92,186);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (184,27.60,4,92,187);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (201,23.70,1,101,204);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (202,20.60,2,101,205);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (203,43.50,3,102,206);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (204,30.50,4,102,207);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (216,7.30,1,111,6);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (217,21.80,2,112,7);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (226,7.00,1,121,16);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (236,3.90,1,131,26);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (246,19.80,2,141,36);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (256,4.00,1,151,46);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (266,9.50,1,161,56);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (276,5.10,1,171,66);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (286,10.40,1,181,76);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (296,12.90,1,191,86);
/*!40000 ALTER TABLE `kliento_eilute` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `fkntm_kliento_eilute` BEFORE UPDATE ON `kliento_eilute` FOR EACH ROW BEGIN
    IF OLD.kliento_uzsakymas_id <> NEW.kliento_uzsakymas_id
       OR OLD.porcija_id <> NEW.porcija_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Non Transferable FK constraint on table Kliento_eilute is violated';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `kliento_uzsakymas`
--

DROP TABLE IF EXISTS `kliento_uzsakymas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kliento_uzsakymas` (
  `kliento_uzsakymas_id` int NOT NULL AUTO_INCREMENT,
  `uzsakymo_nr` bigint NOT NULL,
  `kaina` decimal(10,2) NOT NULL DEFAULT '0.00',
  `stalelis` int DEFAULT NULL,
  `telefonas` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pristatymo_adresas` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `restoranas_id` int NOT NULL,
  PRIMARY KEY (`kliento_uzsakymas_id`),
  KEY `kliento_uzs_restoranas_fk` (`restoranas_id`),
  CONSTRAINT `kliento_uzs_restoranas_fk` FOREIGN KEY (`restoranas_id`) REFERENCES `restoranas` (`restoranas_id`)
) ENGINE=InnoDB AUTO_INCREMENT=192 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kliento_uzsakymas`
--

LOCK TABLES `kliento_uzsakymas` WRITE;
/*!40000 ALTER TABLE `kliento_uzsakymas` DISABLE KEYS */;
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (1,1000000000000001,0.00,12,NULL,NULL,45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (3,1000000000000003,0.00,17,NULL,NULL,12);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (6,1000000000000006,0.00,14,NULL,NULL,33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (7,1000000000000007,0.00,2,NULL,NULL,19);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (11,1000000000000011,0.00,NULL,'+37060000011','Kaunas, Studentų g. 12',45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (13,1000000000000013,0.00,NULL,'+37060000013','Kaunas, Taikos pr. 45',12);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (16,1000000000000016,0.00,NULL,'+37060000016','Kaunas, Pramonės pr. 6',33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (17,1000000000000017,0.00,NULL,'+37060000017','Kaunas, Šilainiai, Baltų pr. 55',19);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (21,1000000000000021,0.00,6,NULL,NULL,45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (23,1000000000000023,0.00,15,NULL,NULL,12);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (26,1000000000000026,0.00,1,NULL,NULL,33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (27,1000000000000027,0.00,16,NULL,NULL,19);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (31,1000000000000031,0.00,NULL,'+37060000031','Kaunas, Romainiai, Žemaičių pl. 12',45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (33,1000000000000033,0.00,NULL,'+37060000033','Kaunas, Šančiai, A. Juozapavičiaus pr. 55',12);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (36,1000000000000036,0.00,NULL,'+37060000036','Kaunas, Dainava, Partizanų g. 112',33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (37,1000000000000037,0.00,NULL,'+37060000037','Kaunas, Centras, Laisvės al. 45',19);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (45,1000000000000045,0.00,4,NULL,NULL,33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (50,1000000000000050,0.00,12,NULL,NULL,45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (55,1000000000000055,0.00,NULL,'+37060000055','Kaunas, Pramonės pr. 55',33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (60,1000000000000060,0.00,NULL,'+37060000060','Kaunas, Partizanų g. 88',45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (65,1000000000000065,0.00,5,NULL,NULL,33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (70,1000000000000070,0.00,7,NULL,NULL,45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (75,1000000000000075,0.00,NULL,'+37060000075','Kaunas, Dainava, Partizanų g. 77',33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (80,1000000000000080,0.00,NULL,'+37060000080','Kaunas, Šilainiai, Baltų pr. 99',45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (81,1000000000000081,0.00,4,NULL,NULL,12);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (82,1000000000000082,0.00,6,NULL,NULL,33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (91,1000000000000091,0.00,NULL,'+37060000091','Kaunas, Taikos pr. 12',12);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (92,1000000000000092,0.00,NULL,'+37060000092','Kaunas, Savanorių pr. 77',33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (101,1000000000000101,0.00,2,NULL,NULL,12);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (102,1000000000000102,0.00,4,NULL,NULL,33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (111,1000000000000111,0.00,NULL,'+37060000111','Kaunas, Romainiai, Žemaičių pl. 55',12);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (112,1000000000000112,0.00,NULL,'+37060000112','Kaunas, Petrašiūnai, Kalantos g. 77',33);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (121,1000000000000121,0.00,3,NULL,NULL,45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (131,1000000000000131,0.00,NULL,'+37060000131','Kaunas, Taikos pr. 88',45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (141,1000000000000141,0.00,4,NULL,NULL,45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (151,1000000000000151,0.00,NULL,'+37060000151','Kaunas, Romainiai, Žemaičių pl. 22',45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (161,1000000000000161,0.00,3,NULL,NULL,45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (171,1000000000000171,0.00,NULL,'+37060000171','Kaunas, Taikos pr. 144',45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (181,1000000000000181,0.00,2,NULL,NULL,45);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (191,1000000000000191,0.00,NULL,'+37060000191','Kaunas, Romainiai, Žemaičių pl. 144',45);
/*!40000 ALTER TABLE `kliento_uzsakymas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `fkntm_kliento_uzsakymas` BEFORE UPDATE ON `kliento_uzsakymas` FOR EACH ROW BEGIN
    IF OLD.restoranas_id <> NEW.restoranas_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Non Transferable FK constraint on table Kliento_uzsakymas is violated';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `porcija`
--

DROP TABLE IF EXISTS `porcija`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `porcija` (
  `porcija_id` int NOT NULL AUTO_INCREMENT,
  `kaina` decimal(8,2) NOT NULL,
  `porcijos_dydis_id` int NOT NULL,
  `receptas_id` int NOT NULL,
  PRIMARY KEY (`porcija_id`),
  KEY `porcija_porcijos_dydis_fk` (`porcijos_dydis_id`),
  KEY `porcija_receptas_fk` (`receptas_id`),
  CONSTRAINT `porcija_porcijos_dydis_fk` FOREIGN KEY (`porcijos_dydis_id`) REFERENCES `porcijos_dydis` (`porcijos_dydis_id`),
  CONSTRAINT `porcija_receptas_fk` FOREIGN KEY (`receptas_id`) REFERENCES `receptas` (`receptas_id`)
) ENGINE=InnoDB AUTO_INCREMENT=208 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `porcija`
--

LOCK TABLES `porcija` WRITE;
/*!40000 ALTER TABLE `porcija` DISABLE KEYS */;
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (1,6.20,2,11);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (2,4.90,1,7);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (5,5.10,1,19);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (6,7.30,2,44);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (7,10.90,3,52);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (11,11.20,3,21);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (12,15.80,4,29);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (13,4.30,1,6);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (14,6.90,2,9);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (16,7.00,2,2);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (22,4.50,1,12);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (23,7.20,2,4);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (26,3.90,1,19);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (27,6.70,2,43);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (32,11.50,3,49);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (33,14.80,4,17);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (34,5.00,1,29);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (35,7.50,2,10);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (36,9.90,3,33);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (42,5.50,1,38);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (43,8.40,2,16);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (46,4.00,1,41);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (47,7.80,2,18);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (52,10.80,3,28);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (53,17.50,4,36);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (54,4.70,1,21);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (55,6.50,2,52);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (56,9.50,3,43);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (63,7.00,2,20);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (64,11.00,3,34);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (66,5.10,1,25);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (67,8.20,2,39);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (68,10.00,3,27);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (73,13.70,4,18);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (74,5.60,1,23);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (75,7.10,2,26);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (76,10.40,3,31);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (86,12.90,4,35);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (91,4.60,1,48);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (92,6.30,2,49);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (102,12.30,4,63);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (103,5.40,1,64);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (112,6.20,2,73);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (113,9.30,3,74);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (122,12.80,4,83);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (123,5.10,1,84);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (132,6.70,2,93);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (133,9.60,3,94);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (142,12.60,4,103);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (143,5.20,1,104);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (152,6.10,2,113);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (153,9.80,3,114);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (162,12.90,4,3);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (163,5.30,1,4);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (164,7.60,2,5);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (165,10.10,3,6);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (166,14.80,4,7);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (167,6.20,2,8);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (184,7.40,2,25);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (185,10.20,3,26);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (186,14.30,4,27);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (187,6.90,2,28);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (204,7.90,2,45);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (205,10.30,3,46);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (206,14.50,4,47);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (207,6.10,2,48);
/*!40000 ALTER TABLE `porcija` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `fkntm_porcija` BEFORE UPDATE ON `porcija` FOR EACH ROW BEGIN
    IF OLD.receptas_id <> NEW.receptas_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Non Transferable FK constraint on table Porcija is violated';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `porcijos_dydis`
--

DROP TABLE IF EXISTS `porcijos_dydis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `porcijos_dydis` (
  `porcijos_dydis_id` int NOT NULL AUTO_INCREMENT,
  `dydis` varchar(12) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`porcijos_dydis_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `porcijos_dydis`
--

LOCK TABLES `porcijos_dydis` WRITE;
/*!40000 ALTER TABLE `porcijos_dydis` DISABLE KEYS */;
INSERT INTO `porcijos_dydis` (`porcijos_dydis_id`, `dydis`) VALUES (1,'mažas');
INSERT INTO `porcijos_dydis` (`porcijos_dydis_id`, `dydis`) VALUES (2,'vidutinis');
INSERT INTO `porcijos_dydis` (`porcijos_dydis_id`, `dydis`) VALUES (3,'didelis');
INSERT INTO `porcijos_dydis` (`porcijos_dydis_id`, `dydis`) VALUES (4,'XL');
/*!40000 ALTER TABLE `porcijos_dydis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `receptas`
--

DROP TABLE IF EXISTS `receptas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `receptas` (
  `receptas_id` int NOT NULL AUTO_INCREMENT,
  `pavadinimas` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `instrukcija` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dieta_id` int DEFAULT NULL,
  PRIMARY KEY (`receptas_id`),
  KEY `receptas_dieta_fk` (`dieta_id`),
  CONSTRAINT `receptas_dieta_fk` FOREIGN KEY (`dieta_id`) REFERENCES `dieta` (`dieta_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `receptas`
--

LOCK TABLES `receptas` WRITE;
/*!40000 ALTER TABLE `receptas` DISABLE KEYS */;
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (2,'vištienos kebabas lavaše',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (3,'erienos kebabas lavaše',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (4,'bulvytės fri lėkštėje su česnakiniu padažu',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (5,'bulvytės fri lėkštėje be padažo',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (6,'Krevetės su česnaku',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (7,'Avokado sriuba',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (8,'Vištienos krūtinėlė su brokoliais',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (9,'Grikiai su daržovėmis',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (10,'Lašiša su špinatais',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (11,'Kokoso pieno ryžiai',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (12,'Jautienos steikas su kopūstais',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (16,'Tofu stir fry',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (17,'Kiaulienos kepsnys su bulvėmis',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (18,'Žalieji salotai su alyvuogių aliejumi',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (19,'Kvinoja salotos',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (20,'Jautienos faršas su moliūgais',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (21,'Sūris su obuoliais',NULL,6);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (23,'Vištienos sriuba su ryžiais',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (25,'Kiaulienos karbonadas',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (26,'Riešutų sviestas su obuoliais',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (27,'Lęšiai su pomidorais',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (28,'Jautienos troškinys',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (29,'Kokteilių salotos',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (31,'Vištienos sparneliai',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (33,'Lašišos šašlykai',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (34,'Kiaušinienė su šoninė',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (35,'Burokėlių koldūnai',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (36,'Jautienos mėsainiai',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (38,'Tunos salotos',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (39,'Kopūstų suktinukai',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (41,'Sūrio omletas',NULL,6);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (43,'Jautienos kepsnys su šparagais',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (44,'Bulvių plokštainis',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (45,'Moliūgų pyragas',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (46,'Vištienos šašlykai',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (47,'Rugpjūčio salotos su avokadu',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (48,'Lašišos filė su žalumynais',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (49,'Kalafiorų ryžiai',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (52,'Vištienos burgeris',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (63,'Kiaušinių salotos',NULL,7);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (64,'Špinatų omletas',NULL,6);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (73,'Lašišos tartaras',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (74,'Paleo daržovių sriuba',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (83,'Veganiška moliūgų košė',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (84,'Špinatų salotos su feta',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (93,'Keptų daržovių troškinys',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (94,'Veganiški avinžirnių kepsneliai',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (103,'Krevetės su sviestu ir česnaku',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (104,'Ketogeninis kiaušinių apkepas',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (113,'Paleo jautienos troškinys',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (114,'Grikių košė be glitimo',NULL,6);
/*!40000 ALTER TABLE `receptas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `restoranas`
--

DROP TABLE IF EXISTS `restoranas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restoranas` (
  `restoranas_id` int NOT NULL AUTO_INCREMENT,
  `pavadinimas` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vietove` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefonas` varchar(16) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `svetaine` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`restoranas_id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restoranas`
--

LOCK TABLES `restoranas` WRITE;
/*!40000 ALTER TABLE `restoranas` DISABLE KEYS */;
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (1,'Skanumynų užeiga','Kaunas','+37061234567',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (2,'Pica Express','Kaunas',NULL,'https://picaexpress.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (3,'Bistro 24','Kaunas','+37060011223',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (4,'Gardus Kampas','Kaunas',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (5,'Sultingas Burgeris','Kaunas','+37069988776','https://burgeriai.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (6,'Azijos Skoniai','Kaunas','+37064599887',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (7,'Rytų Virtuvė','Kaunas',NULL,'https://rytuvirtuve.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (8,'Pietų Stotelė','Kaunas','+37061233445',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (9,'Kavos Namai','Kaunas',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (10,'Itališka Virtuvė','Kaunas','+37061122334','https://itališkavirtuve.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (11,'Skanumynų užeiga','Kaunas','+37061234567',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (12,'Pica Express','Kaunas',NULL,'https://picaexpress.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (13,'Bistro 24','Kaunas','+37060011223',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (14,'Gardus Kampas','Kaunas',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (15,'Sultingas Burgeris','Kaunas','+37069988776','https://burgeriai.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (16,'Azijos Skoniai','Kaunas','+37064599887',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (17,'Rytų Virtuvė','Kaunas',NULL,'https://rytuvirtuve.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (18,'Pietų Stotelė','Kaunas','+37061233445',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (19,'Kavos Namai','Kaunas',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (20,'Itališka Virtuvė','Kaunas','+37061122334','https://italiskavirtuve.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (21,'Skanus Taškas','Kaunas',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (22,'Pietūs Greitai','Kaunas','+37061299887',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (23,'Blyninė Pas Močiutę','Kaunas','+37060011221','https://blynine.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (24,'Šeimos Bistro','Kaunas',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (25,'Kebabų Karalius','Kaunas','+37069988712','https://kebabu-karalius.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (26,'Picerija Napoli','Kaunas','+37061233411','https://napoli.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (27,'Burger House','Kaunas',NULL,'https://burgerhouse.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (28,'Sushi Planet','Kaunas','+37061199887',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (29,'Ramen Spot','Kaunas',NULL,'https://ramenspot.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (30,'Kaimiška Virtuvė','Kaunas','+37061233499',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (31,'Pietūs Studentams','Kaunas',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (32,'Vegano Rožė','Kaunas','+37069988700','https://vegano-roze.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (33,'Kavos Studija','Kaunas',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (34,'Pica Milano','Kaunas','+37061233412','https://milano.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (35,'Šašlykų Pašvaistė','Kaunas',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (36,'Kebabinė 24/7','Kaunas','+37061122345',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (37,'Azijos Bistro','Kaunas',NULL,'https://azijosbistro.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (38,'Pietūs Į Namus','Kaunas','+37061233488',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (39,'Skanioji Pica','Kaunas',NULL,'https://skaniapica.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (40,'Burgerio Stotelė','Kaunas','+37069988744',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (41,'Sushi Zen','Kaunas',NULL,'https://sushizen.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (42,'Rytietiški Skoniai','Kaunas','+37061233401',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (43,'Pietų Karštis','Kaunas',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (44,'Kebabų Vila','Kaunas','+37061122399','https://kebabu-vila.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (45,'Picerija Roma','Kaunas',NULL,'https://roma.lt');
/*!40000 ALTER TABLE `restoranas` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-08 13:01:42
