-- MySQL dump 10.13
--
-- Host: 20.235.14.88    Database: d003_srtprd
-- ------------------------------------------------------

DROP TABLE IF EXISTS `c027_servicetype`;
CREATE TABLE `c027_servicetype` (
  `ServiceType_Id` varchar(10) NOT NULL,
  `ServiceType_Name` varchar(45) DEFAULT NULL,
  `Sevice_Image` text,
  `Service_Description` varchar(150) DEFAULT NULL,
  `Is_Active` int DEFAULT '1',
  `Is_Deleted` int DEFAULT '0',
  PRIMARY KEY (`ServiceType_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `c027_servicetype` VALUES('C026001','Veterinary Services','https://img.freepik.com/free-vector/online-doctor-talking-about-treatment-pills_23-2148541247.jpg?w=740&t=st=1699269252~exp=1699269852~hmac=2af35720e1414af6789c836a02eecc80a947e3d54e6c5d4f49d48b5bb240cf69','Veterinary Services',1,0);
INSERT INTO `c027_servicetype` VALUES('C026002','Financial services','https://img.freepik.com/free-vector/online-doctor-talking-about-treatment-pills_23-2148541247.jpg?w=740&t=st=1699269252~exp=1699269852~hmac=2af35720e1414af6789c836a02eecc80a947e3d54e6c5d4f49d48b5bb240cf69','Finaance Services',1,0);
INSERT INTO `c027_servicetype` VALUES('C026003','Material Sales','https://img.freepik.com/free-vector/online-doctor-talking-about-treatment-pills_23-2148541247.jpg?w=740&t=st=1699269252~exp=1699269852~hmac=2af35720e1414af6789c836a02eecc80a947e3d54e6c5d4f49d48b5bb240cf69','Material Services',1,0);

-- Dump completed on 2026-05-12 17:14:39
