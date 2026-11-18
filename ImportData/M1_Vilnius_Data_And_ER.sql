-- MySQL dump 10.13  Distrib 8.4.11, for Linux (x86_64)
--
-- Host: localhost    Database: restaurant_db_Vilnius
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

DROP SCHEMA IF EXISTS restaurant_db_Vilnius;
CREATE SCHEMA restaurant_db_Vilnius;
USE restaurant_db_Vilnius;


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
) ENGINE=InnoDB AUTO_INCREMENT=163 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `darbuotojas`
--

LOCK TABLES `darbuotojas` WRITE;
/*!40000 ALTER TABLE `darbuotojas` DISABLE KEYS */;
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (3,'Aistė','Jankauskaitė','Administratorė',1,'+37060000003','aiste.jankauskaite3@example.com',77);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (6,'Karolina','Žukauskaitė','Virėja',0,'+37060000005','karolina.zukauskaite5@example.com',90);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (8,'Greta','Vasiliauskaitė','Padavėja',0,'+37060000007','greta.vasiliauskaite7@example.com',88);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (10,'Monika','Kuzmickaitė','Administratorė',0,'+37060000009','monika.kuzmickaite9@example.com',64);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (13,'Eglė','Kvietkutė','Virėja',1,'+37060000102','egle.kvietkute102@example.com',87);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (16,'Dovydas','Šimkus','Virėjas',0,'+37060000105','dovydas.simkus105@example.com',56);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (20,'Ieva','Kundrotaitė','Padavėja',0,'+37060000108','ieva.kundrotaite108@example.com',77);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (24,'Milda','Paulauskaitė','Padavėja',0,'+37060000111','milda.paulauskaite111@example.com',65);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (27,'Martynas','Gailius','Padavėjas',0,'+37060000114','martynas.gailius114@example.com',52);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (30,'Gintarė','Mockutė','Barmenė',0,'+37060000117','gintare.mockute117@example.com',88);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (32,'Laura','Venslovaitė','Administratorė',0,'+37060000119','laura.venslovaite119@example.com',73);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (35,'Tautvydas','Rakauskas','Barmenas',0,'+37060000122','tautvydas.rakauskas122@example.com',58);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (36,'Sandra','Kvietinaitė','Padavėja',1,'+37060000123','sandra.kvietinaite123@example.com',91);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (38,'Aurelija','Stonienė','Administratorė',0,'+37060000125','aurelija.stoniene125@example.com',84);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (40,'Andrius','Pocius','Virėjas',1,'+37060000127','andrius.pocius127@example.com',76);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (41,'Erika','Sakalauskaitė','Barmenė',0,'+37060000128','erika.sakalauskaite128@example.com',55);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (45,'Emilija','Žukaitė','Padavėja',0,'+37060000132','emilija.zukaite132@example.com',66);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (46,'Gytis','Rimkus','Barmenas',1,'+37060000133','gytis.rimkus133@example.com',49);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (47,'Aistė','Kundrotaitė','Padavėja',0,'+37060000134','aiste.kundrotaite134@example.com',91);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (51,'Monika','Kuzmickaitė','Padavėja',0,'+37060000138','monika.kuzmickaite138@example.com',78);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (52,'Paulius','Urbonavičius','Virėjas',1,'+37060000139','paulius.urbonavicius139@example.com',66);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (53,'Greta','Stankevičiūtė','Barmenė',0,'+37060000140','greta.stankeviciute140@example.com',50);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (56,'Aurelija','Bartaškaitė','Administratorė',0,'+37060000143','aurelija.bartaskaite143@example.com',47);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (60,'Ričardas','Mockus','Virėjas',0,'+37060000146','ricardas.mockus146@example.com',72);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (62,'Tomas','Karpavičius','Padavėjas',1,'+37060000148','tomas.karpavicius148@example.com',54);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (65,'Karina','Kvietkauskaitė','Padavėja',0,'+37060000151','karina.kvietkauskaite151@example.com',62);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (71,'Ema','Rimkutė','Padavėja',0,'+37060000153','ema.rimkute153@example.com',90);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (73,'Monika','Vasiliauskaitė','Administratorė',1,'+37060000155','monika.vasiliauskaite155@example.com',68);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (76,'Arnas','Mikalauskas','Virėjas',1,'+37060000158','arnas.mikalauskas158@example.com',82);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (83,'Emilija','Žukaitė','Padavėja',0,'+37060000165','emilija.zukaite165@example.com',63);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (85,'Giedrė','Kundrotaitė','Barmenė',1,'+37060000167','giedre.kundrotaite167@example.com',48);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (86,'Tautvydas','Karpis','Padavėjas',0,'+37060000168','tautvydas.karpis168@example.com',76);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (88,'Sandra','Bieliauskaitė','Administratorė',0,'+37060000169','sandra.bieliauskaite169@example.com',83);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (90,'Goda','Kuzmickaitė','Padavėja',0,'+37060000171','goda.kuzmickaite171@example.com',87);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (91,'Rokas','Urbonavičius','Barmenas',0,'+37060000172','rokas.urbonavicius172@example.com',61);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (96,'Justė','Bartaškaitė','Padavėja',0,'+37060000177','juste.bartaskaite177@example.com',58);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (102,'Vytautas','Karpavičius','Virėjas',1,'+37060000182','vytautas.karpavicius182@example.com',61);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (107,'Agnė','Kairytė','Barmenė',0,'+37060000187','agne.kairyte187@example.com',52);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (109,'Ieva','Vasiliauskaitė','Administratorė',0,'+37060000189','ieva.vasiliauskaite189@example.com',73);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (110,'Tomas','Kuzminas','Virėjas',0,'+37060000190','tomas.kuzminas190@example.com',84);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (112,'Paulius','Urbonas','Barmenas',0,'+37060000192','paulius.urbonas192@example.com',67);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (118,'Gytis','Kvietkus','Virėjas',0,'+37060000198','gytis.kvietkus198@example.com',77);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (121,'Giedrė','Kundrotaitė','Padavėja',0,'+37060000201','giedre.kundrotaite201@example.com',66);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (124,'Sandra','Venslovaitė','Administratorė',1,'+37060000203','sandra.venslovaite203@example.com',88);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (126,'Goda','Mockutė','Padavėja',0,'+37060000205','goda.mockute205@example.com',63);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (127,'Rokas','Urbonavičius','Virėjas',1,'+37060000206','rokas.urbonavicius206@example.com',51);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (128,'Agnė','Stankevičiūtė','Barmenė',0,'+37060000207','agne.stankeviciute207@example.com',89);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (131,'Raimondas','Karpavičius','Virėjas',0,'+37060000210','raimondas.karpavicius210@example.com',54);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (132,'Justė','Bartaškaitė','Padavėja',0,'+37060000211','juste.bartaskaite211@example.com',76);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (135,'Tadas','Mockus','Padavėjas',0,'+37060000214','tadas.mockus214@example.com',72);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (137,'Vytautas','Karpavičius','Virėjas',0,'+37060000216','vytautas.karpavicius216@example.com',61);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (143,'Vytautas','Karpavičius','Virėjas',1,'+37060000182','vytautas.karpavicius182@example.com',61);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (148,'Agnė','Kairytė','Barmenė',0,'+37060000187','agne.kairyte187@example.com',52);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (150,'Ieva','Vasiliauskaitė','Administratorė',0,'+37060000189','ieva.vasiliauskaite189@example.com',73);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (151,'Tomas','Kuzminas','Virėjas',0,'+37060000190','tomas.kuzminas190@example.com',84);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (153,'Paulius','Urbonas','Barmenas',0,'+37060000192','paulius.urbonas192@example.com',67);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (159,'Gytis','Kvietkus','Virėjas',0,'+37060000198','gytis.kvietkus198@example.com',77);
INSERT INTO `darbuotojas` (`darbuotojas_id`, `vardas`, `pavarde`, `pareiga`, `atostogauja`, `telefonas`, `el_pastas`, `restoranas_id`) VALUES (162,'Giedrė','Kundrotaitė','Padavėja',0,'+37060000201','giedre.kundrotaite201@example.com',66);
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
) ENGINE=InnoDB AUTO_INCREMENT=301 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kliento_eilute`
--

LOCK TABLES `kliento_eilute` WRITE;
/*!40000 ALTER TABLE `kliento_eilute` DISABLE KEYS */;
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (3,29.40,3,2,3);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (4,49.60,4,2,4);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (9,26.80,4,5,9);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (10,42.00,5,5,10);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (15,47.50,5,8,15);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (16,7.00,1,8,16);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (19,8.00,4,10,19);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (20,19.00,5,10,20);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (23,29.40,3,12,24);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (24,50.00,4,12,25);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (29,16.80,4,15,30);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (30,40.50,5,15,31);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (35,49.50,5,18,36);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (36,14.80,1,18,37);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (39,42.00,4,20,40);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (40,83.50,5,20,41);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (43,36.00,3,22,44);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (44,72.80,4,22,45);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (49,26.00,4,25,50);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (50,44.50,5,25,51);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (55,47.50,5,28,56);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (56,5.80,1,28,58);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (59,79.20,4,30,61);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (60,17.20,5,30,62);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (63,46.50,3,32,65);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (64,25.50,4,32,66);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (69,27.20,4,35,71);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (70,46.00,5,35,72);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (75,64.80,5,38,77);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (76,4.80,1,38,78);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (79,46.80,4,40,81);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (80,74.50,5,40,82);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (83,29.40,3,42,85);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (84,51.60,4,42,86);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (85,30.50,5,43,87);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (86,16.40,1,43,88);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (97,13.60,2,49,100);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (98,27.30,3,49,101);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (103,43.20,3,52,106);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (104,26.00,4,52,107);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (105,40.50,5,53,108);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (106,11.40,1,53,109);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (117,13.20,2,59,120);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (118,27.60,3,59,121);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (123,44.10,3,62,126);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (124,25.60,4,62,127);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (125,41.50,5,63,128);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (126,11.10,1,63,129);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (137,13.80,2,69,140);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (138,28.20,3,69,141);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (143,56.80,3,72,146);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (144,25.20,4,72,147);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (145,42.50,5,73,148);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (146,11.60,1,73,149);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (157,13.00,2,79,160);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (158,29.10,3,79,161);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (165,42.00,5,83,168);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (166,11.90,1,83,169);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (167,30.40,2,84,170);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (168,13.80,3,84,171);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (169,27.20,4,85,172);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (170,46.50,5,85,173);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (185,40.50,5,93,188);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (186,11.30,1,93,189);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (187,31.20,2,94,190);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (188,14.10,3,94,191);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (189,25.20,4,95,192);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (190,47.50,5,95,193);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (205,12.40,1,103,1);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (206,14.70,2,103,2);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (207,29.40,3,104,3);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (208,49.60,4,104,4);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (209,25.50,5,105,5);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (210,14.60,1,105,8);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (218,14.60,1,113,8);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (219,20.10,3,114,9);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (220,8.40,1,115,10);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (227,12.00,2,122,17);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (228,4.00,1,123,18);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (229,6.00,3,124,19);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (230,3.80,1,125,20);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (237,13.40,2,132,27);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (238,10.20,1,133,28);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (239,30.00,2,134,29);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (240,4.20,1,135,30);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (247,13.20,1,142,37);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (248,4.80,1,143,38);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (249,13.80,2,144,39);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (250,10.50,1,145,40);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (257,15.60,2,152,47);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (258,11.20,1,153,48);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (259,29.00,2,154,49);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (260,5.20,1,155,50);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (267,27.80,2,162,57);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (268,5.80,1,163,58);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (269,15.80,2,164,59);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (270,12.50,1,165,60);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (277,16.40,2,172,67);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (278,10.00,1,173,68);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (279,28.00,2,174,69);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (280,4.90,1,175,70);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (287,16.20,1,182,77);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (288,4.80,1,183,78);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (289,12.80,2,184,79);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (290,26.70,3,185,80);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (297,6.10,1,192,87);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (298,16.40,2,193,88);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (299,10.50,1,194,89);
INSERT INTO `kliento_eilute` (`kliento_eilute_id`, `kaina`, `kiekis`, `kliento_uzsakymas_id`, `porcija_id`) VALUES (300,15.10,1,195,90);
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
) ENGINE=InnoDB AUTO_INCREMENT=196 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kliento_uzsakymas`
--

LOCK TABLES `kliento_uzsakymas` WRITE;
/*!40000 ALTER TABLE `kliento_uzsakymas` DISABLE KEYS */;
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (2,1000000000000002,0.00,5,NULL,NULL,88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (5,1000000000000005,0.00,9,NULL,NULL,77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (8,1000000000000008,0.00,11,NULL,NULL,54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (10,1000000000000010,0.00,8,NULL,NULL,66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (12,1000000000000012,0.00,NULL,'+37060000012','Kaunas, Savanorių pr. 100',88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (15,1000000000000015,0.00,NULL,'+37060000015','Kaunas, Kovo 11-osios g. 33',77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (18,1000000000000018,0.00,NULL,'+37060000018','Kaunas, Panemunė, Vaidoto g. 12',54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (20,1000000000000020,0.00,NULL,'+37060000020','Kaunas, Aleksotas, Veiverių g. 88',66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (22,1000000000000022,0.00,10,NULL,NULL,88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (25,1000000000000025,0.00,13,NULL,NULL,77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (28,1000000000000028,0.00,18,NULL,NULL,54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (30,1000000000000030,0.00,22,NULL,NULL,66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (32,1000000000000032,0.00,NULL,'+37060000032','Kaunas, Petrašiūnai, R. Kalantos g. 88',88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (35,1000000000000035,0.00,NULL,'+37060000035','Kaunas, Žemieji Šančiai, Kranto al. 7',77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (38,1000000000000038,0.00,NULL,'+37060000038','Kaunas, Senamiestis, Muitinės g. 12',54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (40,1000000000000040,0.00,NULL,'+37060000040','Kaunas, Marvelė, J. Lukšos g. 22',66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (42,1000000000000042,0.00,3,NULL,NULL,54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (43,1000000000000043,0.00,11,NULL,NULL,76);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (49,1000000000000049,0.00,6,NULL,NULL,77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (52,1000000000000052,0.00,NULL,'+37060000052','Kaunas, Taikos pr. 98',54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (53,1000000000000053,0.00,NULL,'+37060000053','Kaunas, Kovo 11-osios g. 17',76);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (59,1000000000000059,0.00,NULL,'+37060000059','Kaunas, Veiverių g. 101',77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (62,1000000000000062,0.00,2,NULL,NULL,54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (63,1000000000000063,0.00,8,NULL,NULL,76);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (69,1000000000000069,0.00,20,NULL,NULL,77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (72,1000000000000072,0.00,NULL,'+37060000072','Kaunas, Petrašiūnai, Kalantos g. 55',54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (73,1000000000000073,0.00,NULL,'+37060000073','Kaunas, Šančiai, Juozapavičiaus pr. 12',76);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (79,1000000000000079,0.00,NULL,'+37060000079','Kaunas, Marvelė, J. Lukšos g. 44',77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (83,1000000000000083,0.00,9,NULL,NULL,54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (84,1000000000000084,0.00,11,NULL,NULL,76);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (85,1000000000000085,0.00,13,NULL,NULL,88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (93,1000000000000093,0.00,NULL,'+37060000093','Kaunas, Birželio 23-osios g. 3',54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (94,1000000000000094,0.00,NULL,'+37060000094','Kaunas, Kovo 11-osios g. 55',76);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (95,1000000000000095,0.00,NULL,'+37060000095','Kaunas, Pramonės pr. 88',88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (103,1000000000000103,0.00,6,NULL,NULL,54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (104,1000000000000104,0.00,8,NULL,NULL,76);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (105,1000000000000105,0.00,10,NULL,NULL,88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (113,1000000000000113,0.00,NULL,'+37060000113','Kaunas, Šančiai, Juozapavičiaus pr. 88',54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (114,1000000000000114,0.00,NULL,'+37060000114','Kaunas, Vilijampolė, Varnių g. 12',76);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (115,1000000000000115,0.00,NULL,'+37060000115','Kaunas, Dainava, Partizanų g. 33',88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (122,1000000000000122,0.00,5,NULL,NULL,54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (123,1000000000000123,0.00,7,NULL,NULL,66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (124,1000000000000124,0.00,9,NULL,NULL,77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (125,1000000000000125,0.00,11,NULL,NULL,88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (132,1000000000000132,0.00,NULL,'+37060000132','Kaunas, Savanorių pr. 55',54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (133,1000000000000133,0.00,NULL,'+37060000133','Kaunas, Birželio 23-osios g. 12',66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (134,1000000000000134,0.00,NULL,'+37060000134','Kaunas, Kovo 11-osios g. 77',77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (135,1000000000000135,0.00,NULL,'+37060000135','Kaunas, Pramonės pr. 44',88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (142,1000000000000142,0.00,6,NULL,NULL,54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (143,1000000000000143,0.00,8,NULL,NULL,66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (144,1000000000000144,0.00,10,NULL,NULL,77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (145,1000000000000145,0.00,12,NULL,NULL,88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (152,1000000000000152,0.00,NULL,'+37060000152','Kaunas, Petrašiūnai, Kalantos g. 101',54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (153,1000000000000153,0.00,NULL,'+37060000153','Kaunas, Šančiai, Juozapavičiaus pr. 44',66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (154,1000000000000154,0.00,NULL,'+37060000154','Kaunas, Vilijampolė, Varnių g. 55',77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (155,1000000000000155,0.00,NULL,'+37060000155','Kaunas, Dainava, Partizanų g. 66',88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (162,1000000000000162,0.00,6,NULL,NULL,54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (163,1000000000000163,0.00,9,NULL,NULL,66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (164,1000000000000164,0.00,12,NULL,NULL,77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (165,1000000000000165,0.00,15,NULL,NULL,88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (172,1000000000000172,0.00,NULL,'+37060000172','Kaunas, Savanorių pr. 201',54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (173,1000000000000173,0.00,NULL,'+37060000173','Kaunas, Birželio 23-osios g. 88',66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (174,1000000000000174,0.00,NULL,'+37060000174','Kaunas, Kovo 11-osios g. 12',77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (175,1000000000000175,0.00,NULL,'+37060000175','Kaunas, Pramonės pr. 33',88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (182,1000000000000182,0.00,4,NULL,NULL,54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (183,1000000000000183,0.00,6,NULL,NULL,66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (184,1000000000000184,0.00,8,NULL,NULL,77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (185,1000000000000185,0.00,10,NULL,NULL,88);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (192,1000000000000192,0.00,NULL,'+37060000192','Kaunas, Petrašiūnai, Kalantos g. 201',54);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (193,1000000000000193,0.00,NULL,'+37060000193','Kaunas, Šančiai, Juozapavičiaus pr. 144',66);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (194,1000000000000194,0.00,NULL,'+37060000194','Kaunas, Vilijampolė, Varnių g. 201',77);
INSERT INTO `kliento_uzsakymas` (`kliento_uzsakymas_id`, `uzsakymo_nr`, `kaina`, `stalelis`, `telefonas`, `pristatymo_adresas`, `restoranas_id`) VALUES (195,1000000000000195,0.00,NULL,'+37060000195','Kaunas, Dainava, Partizanų g. 144',88);
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
) ENGINE=InnoDB AUTO_INCREMENT=194 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `porcija`
--

LOCK TABLES `porcija` WRITE;
/*!40000 ALTER TABLE `porcija` DISABLE KEYS */;
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (1,6.20,2,11);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (2,4.90,1,7);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (3,9.80,3,28);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (4,12.40,4,33);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (5,5.10,1,19);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (8,14.60,4,8);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (9,6.70,2,14);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (10,8.40,2,17);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (15,9.50,3,12);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (16,7.00,2,2);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (17,6.00,3,3);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (18,4.00,3,4);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (19,2.00,2,4);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (20,3.80,3,5);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (24,9.80,3,26);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (25,12.50,4,8);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (27,6.70,2,43);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (28,10.20,3,6);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (29,15.00,4,10);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (30,4.20,1,23);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (31,8.10,2,31);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (36,9.90,3,33);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (37,13.20,4,40);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (38,4.80,1,11);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (39,6.90,2,46);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (40,10.50,3,9);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (41,16.70,4,22);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (44,12.00,3,30);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (45,18.20,4,5);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (47,7.80,2,18);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (48,11.20,3,32);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (49,14.50,4,7);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (50,5.20,1,48);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (51,8.90,2,14);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (56,9.50,3,43);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (57,13.90,4,24);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (58,5.80,1,35);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (59,7.90,3,2);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (60,12.50,3,42);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (61,19.80,4,15);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (62,4.30,1,47);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (65,15.50,4,45);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (66,5.10,1,25);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (67,8.20,2,39);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (68,10.00,3,27);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (69,14.00,4,50);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (70,4.90,1,37);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (71,6.80,2,53);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (72,9.20,3,55);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (77,16.20,4,41);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (78,4.80,1,3);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (79,6.40,2,5);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (80,8.90,2,10);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (81,11.70,3,13);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (82,14.90,4,22);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (85,9.80,3,30);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (86,12.90,4,35);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (87,6.10,2,38);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (88,8.20,2,40);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (89,10.50,3,43);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (90,15.10,4,46);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (100,6.80,2,61);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (101,9.10,3,62);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (106,14.40,4,67);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (107,6.50,2,68);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (108,8.10,2,69);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (109,11.40,3,70);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (120,6.60,2,81);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (121,9.20,3,82);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (126,14.70,4,87);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (127,6.40,2,88);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (128,8.30,2,89);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (129,11.10,3,90);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (140,6.90,2,101);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (141,9.40,3,102);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (146,14.20,4,107);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (147,6.30,2,108);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (148,8.50,2,109);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (149,11.60,3,110);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (160,6.50,2,1);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (161,9.70,3,2);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (168,8.40,2,9);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (169,11.90,3,10);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (170,15.20,4,11);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (171,4.60,1,12);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (172,6.80,2,13);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (173,9.30,3,14);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (188,8.10,2,29);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (189,11.30,3,30);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (190,15.60,4,31);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (191,4.70,1,32);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (192,6.30,2,33);
INSERT INTO `porcija` (`porcija_id`, `kaina`, `porcijos_dydis_id`, `receptas_id`) VALUES (193,9.50,3,34);
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
) ENGINE=InnoDB AUTO_INCREMENT=111 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `receptas`
--

LOCK TABLES `receptas` WRITE;
/*!40000 ALTER TABLE `receptas` DISABLE KEYS */;
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (1,'Bulvių košė su krapais',NULL,NULL);
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
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (13,'Falafelis su humusu',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (14,'Kvietinė pica',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (15,'Migdolų miltų blynai',NULL,6);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (17,'Kiaulienos kepsnys su bulvėmis',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (18,'Žalieji salotai su alyvuogių aliejumi',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (19,'Kvinoja salotos',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (22,'Avižų košė su bananais',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (23,'Vištienos sriuba su ryžiais',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (24,'Chumuso keptos morkos',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (25,'Kiaulienos karbonadas',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (26,'Riešutų sviestas su obuoliais',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (27,'Lęšiai su pomidorais',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (28,'Jautienos troškinys',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (29,'Kokteilių salotos',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (30,'Sojos kepsnys',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (31,'Vištienos sparneliai',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (32,'Moliūgų sriuba',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (33,'Lašišos šašlykai',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (34,'Kiaušinienė su šoninė',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (35,'Burokėlių koldūnai',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (37,'Avokado ir kiaušinio sumuštinis',NULL,7);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (38,'Tunos salotos',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (39,'Kopūstų suktinukai',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (40,'Vištienos faršas su cukinijomis',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (41,'Sūrio omletas',NULL,6);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (42,'Daržovių curry',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (43,'Jautienos kepsnys su šparagais',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (45,'Moliūgų pyragas',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (46,'Vištienos šašlykai',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (47,'Rugpjūčio salotos su avokadu',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (48,'Lašišos filė su žalumynais',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (50,'Varškės apkepas',NULL,6);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (53,'Ryžių makaronai su daržovėmis',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (55,'Tofu kepsneliai su sezamu',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (61,'Kiaulienos suktinukai su daržovėmis',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (62,'Grikių blyneliai',NULL,6);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (67,'Krevetės su citrina ir čili',NULL,3);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (68,'Paleo vištienos troškinys',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (69,'Ketogeninė kiaušinių lazanija',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (70,'Veganiški ryžių rutuliukai',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (81,'Paleo jautienos kepsnys',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (82,'Ketogeninė lašiša su sviestu',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (87,'Paleo kalakutienos kepsnys',NULL,5);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (88,'Ketogeninė kiaušinių sriuba',NULL,4);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (89,'Veganiškas tofu curry',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (90,'Grikių salotos su daržovėmis',NULL,6);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (101,'Ryžių makaronai su tofu ir sezamu',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (102,'Brokolių ir žiedinių kopūstų apkepas',NULL,1);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (107,'Varškės sūreliai be laktozės',NULL,7);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (108,'Jautienos kepsnys su svogūnais',NULL,NULL);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (109,'Veganiška daržovių sriuba',NULL,2);
INSERT INTO `receptas` (`receptas_id`, `pavadinimas`, `instrukcija`, `dieta_id`) VALUES (110,'Kvinojos troškinys su paprika',NULL,1);
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
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restoranas`
--

LOCK TABLES `restoranas` WRITE;
/*!40000 ALTER TABLE `restoranas` DISABLE KEYS */;
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (46,'Burgerio Karalius','Vilnius','+37069988733',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (47,'Sushi Box','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (48,'Ramen Garden','Vilnius','+37061233466','https://ramengarden.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (49,'Kaimo Virtuvėlė','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (50,'Pietūs Biurams','Vilnius','+37061122377',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (51,'Vegano Kampas','Vilnius',NULL,'https://veganokampas.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (52,'Kavos Kultūra','Vilnius','+37061233422',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (53,'Pica Toscana','Vilnius',NULL,'https://toscana.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (54,'Šašlykų Karčema','Vilnius','+37069988711',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (55,'Kebabinė Max','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (56,'Azijos Virtuvėlė','Vilnius','+37061233455','https://azijosvirtuvele.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (57,'Pietūs Greiti','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (58,'Skanioji Picerija','Vilnius','+37061122366','https://skaniapicerija.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (59,'Burgerio Garažas','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (60,'Sushi Master','Vilnius','+37061233477','https://sushimaster.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (61,'Rytų Skonio Namai','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (62,'Pietų Džiazas','Vilnius','+37069988755',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (63,'Kebabų Oazė','Vilnius',NULL,'https://kebabuoaze.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (64,'Picerija Sicilija','Vilnius','+37061233444','https://sicilija.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (65,'Burgerio Loftas','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (66,'Sushi Wave','Vilnius','+37061122388',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (67,'Ramen House','Vilnius',NULL,'https://ramenhouse.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (68,'Kaimo Skoniai','Vilnius','+37061233433',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (69,'Pietūs Visiems','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (70,'Vegano Sodas','Vilnius','+37069988722','https://veganosodas.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (71,'Kavos Baras','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (72,'Pica Verona','Vilnius','+37061233400','https://verona.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (73,'Šašlykų Užeiga','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (74,'Kebabinė Stop','Vilnius','+37061122322',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (75,'Azijos Karštis','Vilnius',NULL,'https://azijoskarstis.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (76,'Pietūs Centras','Vilnius','+37061233490',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (77,'Skanioji Virtuvė','Vilnius',NULL,'https://skaniavirtuve.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (78,'Burgerio Zona','Vilnius','+37069988799',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (79,'Sushi Point','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (80,'Rytų Bistro','Vilnius','+37061233410',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (81,'Pietų Sala','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (82,'Kebabų Stotis','Vilnius','+37061122311','https://kebabustotis.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (83,'Picerija Toscana','Vilnius',NULL,'https://toscana-pizza.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (84,'Burgerio Fabrikas','Vilnius','+37069988788',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (85,'Sushi Cloud','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (86,'Ramen Lab','Vilnius','+37061233413','https://ramenlab.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (87,'Kaimo Bistro','Vilnius',NULL,NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (88,'Pietūs Profsąjungoms','Vilnius','+37061122333',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (89,'Vegano Erdvė','Vilnius',NULL,'https://veganoerdve.lt');
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (90,'Kavos Studija 2','Vilnius','+37061233414',NULL);
INSERT INTO `restoranas` (`restoranas_id`, `pavadinimas`, `vietove`, `telefonas`, `svetaine`) VALUES (91,'Pica Roma','Vilnius',NULL,NULL);
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
