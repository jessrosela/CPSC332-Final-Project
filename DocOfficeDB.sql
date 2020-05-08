-- Run this script directly in the MySQL server query window it will automatically create the database and all the database objects.
-- Creating DocOffice Schema

--
-- Create schema DocOffice
--
CREATE DATABASE IF NOT EXISTS DocOffice;
USE DocOffice;
--
-- Definition of table 'Person`
--
DROP TABLE IF EXISTS Person;
CREATE TABLE Person (
  PersonID	int AUTO_INCREMENT,
  FirstName	varchar(25) NOT NULL,
  LastName	varchar(25),
  StreetAddress	varchar(50),	
  City	varchar(25),
  State	char(4),
  Zipcode	char(5),
  PhoneNumber varchar(15)	NOT NULL,
  PhoneNumExt	char(10),
  PRIMARY KEY (PersonID),
  KEY FirstName (FirstName)
);

ALTER TABLE Person AUTO_INCREMENT=10000010;
--
-- Definition of table `Doctor`
--
DROP TABLE IF EXISTS Doctor;
CREATE TABLE Doctor (
  DoctorID	varchar(8) DEFAULT 1,
  MedicalDegrees	char(50),
  PersonID int,
  PRIMARY KEY (DoctorID),
  FOREIGN KEY (PersonID) references Person(PersonID)
);
--
-- Definition of trigger `Trig_DoctorID`
-- creates a new doctor ID before one is inserted by 
-- concatenating the first two characters of the first name and 
-- the last 6 characters of the person ID
--
DROP TRIGGER IF EXISTS TRIG_DoctorID;
CREATE TRIGGER TRIG_DoctorID
BEFORE INSERT ON Doctor 
FOR EACH ROW
    SET NEW.DoctorID=(SELECT CONCAT (UPPER(LEFT(FirstName, 2)),RIGHT(PersonID, 6))
    FROM Person
    WHERE PersonID=NEW.PersonID);
--
-- Definition of table `Specialty`
--
DROP TABLE IF EXISTS Specialty;
CREATE TABLE Specialty (
  SpecialtyID	varchar(9),
  SpecialtyName	varchar(50),
  PRIMARY KEY (SpecialtyID),
  KEY SpecialtyID (SpecialtyID)
);
--
-- Definition of table `DoctorSpecialty`
--
DROP TABLE IF EXISTS DoctorSpecialty;
CREATE TABLE DoctorSpecialty (
  DoctorID	varchar(8),
  SpecialtyID	varchar(9),
  FOREIGN KEY (DoctorID) references Doctor(DoctorID),
  FOREIGN KEY (SpecialtyID) references Specialty(SpecialtyID)
);
--
-- Definition of trigger before insert `DoctorSpecialty`
--
DROP TRIGGER IF EXISTS TRIG_DoctorSpecialty_INSERT;
CREATE TRIGGER TRIG_DoctorSpecialty_INSERT
BEFORE INSERT ON DoctorSpecialty
  FOR EACH ROW 
	INSERT INTO DocSpecialtyAudit(FirstName,AuditAction,SpecialtyID,AuditDate) 
	SELECT FirstName, 'insert', NEW.SpecialtyID, curdate()
    FROM Person
    WHERE PersonID=( SELECT PersonID FROM Doctor WHERE NEW.DoctorID=DoctorID);
--
-- Definition of trigger before update `DoctorSpecialty`
--     
DROP TRIGGER IF EXISTS TRIG_DoctorSpecialty_UPDATE;
CREATE TRIGGER TRIG_DoctorSpecialty_UPDATE
BEFORE UPDATE ON DoctorSpecialty
  FOR EACH ROW 
	INSERT INTO DocSpecialtyAudit(FirstName,AuditAction,SpecialtyID,AuditDate) 
	SELECT FirstName, 'update', NEW.SpecialtyID, curdate()
    FROM Person
    WHERE PersonID=( SELECT PersonID FROM Doctor WHERE NEW.DoctorID=DoctorID);
--
-- Definition of table `Patient`
--
DROP TABLE IF EXISTS Patient;
CREATE TABLE Patient (
  PatientID	varchar(8),
  PhoneNumber	varchar(15),
  PhoneNumExt	char(10),
  DOB	date,
  PersonID    int,
  PRIMARY KEY (PatientID),
  FOREIGN KEY (PersonID) references Person(PersonID)
);
--
-- Definition of trigger `Trig_PatientID`
-- creates a new Patient ID before one is inserted by 
-- concatenating the first two characters of the first name and 
-- the last 6 characters of the person ID
--
DROP TRIGGER IF EXISTS TRIG_PatientID;
CREATE TRIGGER TRIG_PatientID
BEFORE INSERT ON Patient
FOR EACH ROW
    SET NEW.PatientID=(SELECT CONCAT ("P", RIGHT(PersonID, 7))
    FROM Person
    WHERE PersonID=NEW.PersonID);
--
-- Definition of table `PatientVisit`
--
DROP TABLE IF EXISTS PatientVisit;
CREATE TABLE PatientVisit (
  VisitID	int AUTO_INCREMENT,
  PatientID	varchar(8),
  DoctorID	varchar(8),
  VisitDate	date,
  VisitTime time, 
  DocNote	varchar(2000),

	PRIMARY KEY (VisitID),
  FOREIGN KEY (PatientID) references Patient(PatientID),
  FOREIGN KEY (DoctorID) references Doctor(DoctorID),
  CONSTRAINT CHK_PatientVisit CHECK (PatientID != DoctorID),
  UNIQUE (PatientID, VisitDate, DoctorID)
);
ALTER TABLE PatientVisit AUTO_INCREMENT=20000010;
--
-- Definition of table `Test`
--
DROP TABLE IF EXISTS Test;
CREATE TABLE Test (

  TestID	varchar(9),
  TestName	varchar(50),
  PRIMARY KEY (TestID)
);
--
-- Definition of table `PVisitTest`
--
DROP TABLE IF EXISTS PVisitTest;
CREATE TABLE PVisitTest (
  VisitID	int,
  TestID	varchar(9),
  FOREIGN KEY (VisitID) references PatientVisit(VisitID),
  FOREIGN KEY (TestID) references Test(TestID)
);
--
-- Definition of table `Prescription`
--
DROP TABLE IF EXISTS Prescription;
CREATE TABLE Prescription (
  PrescriptionID	varchar(16),
  PrescriptionName	varchar(50),
  PRIMARY KEY (PrescriptionID)
);
--
-- Definition of table `PVisitPrescription`
--
DROP TABLE IF EXISTS PVisitPrescription;
CREATE TABLE PVisitPrescription (
  VisitID	int,
  PrescriptionID	varchar(16),
  FOREIGN KEY (VisitID) references PatientVisit(VisitID),
  FOREIGN KEY (PrescriptionID) references Prescription(PrescriptionID)
);
--
-- Definition of table `DocSpecAudit`
--
DROP TABLE IF EXISTS DocSpecialtyAudit;
CREATE TABLE DocSpecialtyAudit (
  FirstName	varchar(25),
  AuditAction	varchar(10),
  SpecialtyID	varchar(5),
  AuditDate	date,
  FOREIGN KEY (FirstName) references Person(FirstName),
  FOREIGN KEY (SpecialtyID) references Specialty(SpecialtyID)
);
--
-- Definition of view `DocSpecialty`
-- shows First, Last name, and SpecialtyID of all doctors
--
DROP VIEW IF EXISTS DocSpecialty;
CREATE VIEW DocSpecialty AS
SELECT FirstName, LastName, SpecialtyID
FROM Person, DoctorSpecialty, Doctor
WHERE DoctorSpecialty.DoctorID=Doctor.DoctorID AND
Doctor.PersonID=Person.PersonID;
--
-- Definition of view `DocSpecialtyNULL`
-- shows First, Last Name and SpecialtyID's of Doctors
-- includes First and Last Names of Doctors without specialties
--
DROP VIEW IF EXISTS DocSpecialtyNULL;
CREATE VIEW DocSpecialtyNULL AS
SELECT FirstName, LastName, v.SpecialtyID
FROM Person, (
SELECT SpecialtyID, Doctor.PersonID
FROM DoctorSpecialty
RIGHT JOIN Doctor
ON Doctor.DoctorID=DoctorSpecialty.DoctorID) as v
WHERE v.PersonID=Person.PersonID;
--
-- Definition of view `DocVicodin`
-- shows First and Last name of Doctors who prescribed Vicodin
--
DROP VIEW IF EXISTS DocVicodin;
CREATE VIEW DocVicodin AS
SELECT FirstName, LastName
FROM Person, Doctor, PatientVisit, PVisitPrescription
WHERE 
Doctor.PersonID=Person.PersonID AND 
Doctor.DoctorID=PatientVisit.DoctorID AND
PatientVisit.VisitID=PVisitPrescription.VisitID AND
PrescriptionID="rx16908690034987";
--
-- Definition of view `DocStevens`
-- shows First, Last name, and phone number of Doctor Robert Steven's patients
--
DROP VIEW IF EXISTS DocStevens;
CREATE VIEW DocStevens AS
SELECT DISTINCT FirstName, LastName, Patient.PhoneNumber, Patient.PhoneNumExt
FROM Person, PatientVisit, Patient
WHERE 
PatientVisit.DoctorID="RO000049" AND
PatientVisit.PatientID=Patient.PatientID AND
Patient.PersonID=Person.PersonID;
--
-- Definition of view `PatientAppointment`
-- shows Date, Time, VisitID, PatientID, and Doctor's Name
-- of PatientVisits
--
DROP VIEW IF EXISTS PatientAppointment;
CREATE VIEW PatientAppointment AS
SELECT PatientID, VisitDate, VisitTime, VisitID, CONCAT_WS(" ",FirstName,LastName) AS DoctorName
FROM PatientVisit, Doctor, Person
WHERE Person.PersonID=Doctor.PersonID AND 
Doctor.DoctorID=PatientVisit.DoctorID;
--
-- Definition of view `PatientPrescription`
-- shows VisitDate, VisitID, PrescriptionID, PrescriptionName, and PatientID 
-- of Patients
--
DROP VIEW IF EXISTS PatientPrescription;
CREATE VIEW PatientPrescription AS
SELECT PatientID, VisitDate, PatientVisit.VisitID, PVisitPrescription.PrescriptionID, PrescriptionName
FROM PatientVisit, PVisitPrescription, Prescription
WHERE PatientVisit.VisitID=PVisitPrescription.VisitID AND
PVisitPrescription.PrescriptionID=Prescription.PrescriptionID;
--
-- Definition of view `PatientTest`
-- shows the Visit Date, Visit ID, Test ID, Test Name, and Patient ID
-- 
DROP VIEW IF EXISTS PatientTest;
CREATE VIEW PatientTest AS
SELECT PatientID, VisitDate, PatientVisit.VisitID, PVisitTest.TestID, TestName
FROM PatientVisit, PVisitTest, Test
WHERE PatientVisit.VisitID=PVisitTest.VisitID AND
PVisitTest.TestID=Test.TestID;
--
-- Definition of procedure `PrescriptionFullerton`
-- show the name of the prescription and prescription number of patients in the city of Fullerton
--


DROP PROCEDURE IF EXISTS PrescriptionFullerton;
DELIMITER //
CREATE PROCEDURE PrescriptionFullerton()
BEGIN
SELECT PrescriptionName, Prescription.PrescriptionID, v.PatientID, v.City
FROM Prescription
RIGHT JOIN ( 
SELECT PVisitPrescription.PrescriptionID, Patient.PatientID, Person.City
FROM PVisitPrescription
RIGHT JOIN PatientVisit
ON PatientVisit.VisitID=PVisitPrescription.VisitID
RIGHT JOIN Patient
ON Patient.PatientID=PatientVisit.PatientID
RIGHT JOIN Person
ON Person.PersonID=Patient.PersonID
WHERE City = "Fullerton" ) as v
ON v.PrescriptionID=Prescription.PrescriptionID
ORDER BY PrescriptionName asc; 
END;//

-- Insert all records 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber)
VALUES ('Bob','Bender','8794 Garfield', 'Fullerton', 'IL','45321','7148657326');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Kim','Grace','6677 Mills Ave', 'Sacramento', 'CA','60078','3748372614');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('James','Borg','450 Stone', 'Houston', 'TX','92867','3748372342');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Alex','Freed','4333 Pillsbury', 'Milwaukee', 'WI','72954','3748372019');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Evan','Wallis','134 Pelham', 'Milwaukee', 'WI','72954','3748374859');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Jared','James','123 Peachtree', 'Atlanta', 'GA','89324','3748379876');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('John','James','7676 Bloomington', 'Sacramento', 'CA','60078','3748370912');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Andy','Vile','1967 Jordan', 'Milwaukee', 'WI','72954','3748372392');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Brad','Knight','176 Main St.', 'Atlanta', 'GA','89324','3748310293');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Josh','Zell','266 McGrady', 'Milwaukee', 'WI','72954','3748398765');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Justin','Mark','2342 May', 'Atlanta', 'GA','89324','3748091856');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Jon','Jones','111 Allgood', 'Atlanta', 'GA','89324','7142388273');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Ahmad','Jabbar','980 Dallas', 'Houston', 'TX','92867','3395832342');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Joyce','English','5631 Rice', 'Houston', 'TX','92867','7600928114');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Ramesh','Narayan','971 Fire Oak', 'Humble', 'TX','92734','7148182857');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Alicia','Zelaya','3321 Castle', 'Spring', 'TX','92765','7141236357');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('John','Smith','731 Fondren', 'Houston', 'TX','92867','7148372905'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Jennifer','Wallace','291 Berry', 'Bellaire', 'TX','92725','3395832342'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Franklin','Wong','638 Voss', 'Houston', 'TX','92867','9485768293');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Tom','Brand','112 Third St', 'Milwaukee', 'WI','72954','10000029');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Jenny','Vos','263 Mayberry', 'Milwaukee', 'WI','72954','7148271928');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Chris','Carter','565 Jordan', 'Milwaukee', 'WI','72954','7141014211');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber, PhoneNumExt) 
VALUES ('Jeff','Chase','145 Bradbury', 'Sacramento', 'CA','60078','3748371111','678'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber, PhoneNumExt) 
VALUES ('Bonnie','Bays','111 Hollow', 'Milwaukee', 'WI','72954','3748322222','432'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber, PhoneNumExt) 
VALUES ('Alec','Best','233 Solid', 'Milwaukee', 'WI','72954','3743333456','123'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber, PhoneNumExt) 
VALUES ('Sam','Snedden','987 Windy St', 'Milwaukee', 'WI','72954','7148123456','4567'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber, PhoneNumExt) 
VALUES ('Nandita','Ball','222 Howard', 'Sacramento', 'CA','60078','7142132311','78'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber, PhoneNumExt) 
VALUES ('Jill','Jarvis','6234 Lincoln', 'Fullerton', 'IL','45321','3740293888','984'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber, PhoneNumExt) 
VALUES ('Kate','King','1976 Boone Trace', 'Fullerton', 'IL','45321','3748333333','094'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber, PhoneNumExt) 
VALUES ('Lyle','Leslie','417 Hancock Ave', 'Fullerton', 'IL','45321','3748444444','123'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber, PhoneNumExt) 
VALUES ('Billie','King','556 Washington', 'Fullerton', 'IL','45321','3748555555','674'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Jon','Kramer','1988 Windy Creek', 'Seattle', 'WA','92740','3746948477');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Ray','King','213 Delk Road', 'Seattle', 'WA','92704','7140920004');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Gerald','Small','122 Ball Street','Dallas','TX','92869','7143353422');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Arnold','Head','233 Spring St','Dallas','TX','92869','9481232299');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Helga','Pataki','101 Holyoke St','Dallas','TX','92869','3748301010');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Naveen','Drew','198 Elm St','Philadelphia','PA','56219','3742938282'); 
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Carl','Reedy','213 Ball St','Philadelphia','PA','56219','3746666888');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Sammy','Hall','433 Main Street','Miami', 'FL','41390','3746655658');
INSERT INTO Person (FirstName, LastName, StreetAddress, City, State, Zipcode, PhoneNumber) 
VALUES ('Robert','Stevens','196 Elm Street','Miami', 'FL','41390','3749494837');



INSERT INTO Doctor (MedicalDegrees, PersonID) VALUES ('MD, MM','10000028');
INSERT INTO Doctor (MedicalDegrees, PersonID) VALUES ('MD, MS, DS','10000027');
INSERT INTO Doctor (MedicalDegrees, PersonID) VALUES ('MD, DS, DCM','10000012');
INSERT INTO Doctor (MedicalDegrees, PersonID) VALUES ('MD, DO','10000015');
INSERT INTO Doctor (MedicalDegrees, PersonID) VALUES ('MD, MCM','10000013');
INSERT INTO Doctor (MedicalDegrees, PersonID) VALUES ('MD','10000016');
INSERT INTO Doctor (MedicalDegrees, PersonID) VALUES ('MD, DS','10000048'); 
INSERT INTO Doctor (MedicalDegrees, PersonID) VALUES ('MD, DCM','10000049'); 

INSERT INTO Specialty VALUES ('CLI00','Clinical Medicine');
INSERT INTO Specialty VALUES ('FAM00','Family Medicine');
INSERT INTO Specialty VALUES ('OST00','Osteopathic Medicine');
INSERT INTO Specialty VALUES ('SUR00','Surgery');


INSERT INTO DoctorSpecialty VALUES ('JA000015','SUR00');
INSERT INTO DoctorSpecialty VALUES ('JA000012','OST00');
INSERT INTO DoctorSpecialty VALUES ('AL000013','CLI00');
INSERT INTO DoctorSpecialty VALUES ('JO000016','FAM00');
INSERT INTO DoctorSpecialty VALUES ('SA000048','SUR00'); 
INSERT INTO DoctorSpecialty VALUES ('RO000049','FAM00'); 


INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7148657326',NULL,'1968-04-17','10000010');
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748372614',NULL,'1970-10-23','10000011'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748372342',NULL,'1927-11-10','10000012'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748372019',NULL,'1950-10-09','10000013'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748374859',NULL,'1958-01-16','10000014'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748379876',NULL,'1966-10-10','10000015'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748370912',NULL,'1975-06-30','10000016'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748372392',NULL,'1944-06-21','10000017'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748310293',NULL,'1968-02-13','10000018'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748398765',NULL,'1954-05-22','10000019'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748091856',NULL,'1966-01-12','10000020'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7142388273',NULL,'1967-11-14','10000021'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7608323614',NULL,'1959-03-29','10000022'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7600928114',NULL,'1962-07-31','10000023'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7148182857',NULL,'1952-09-15','10000024'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7141236357',NULL,'1958-07-19','10000025'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7148372905',NULL,'1955-01-09','10000026'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3395832342',NULL,'1931-06-20','10000027'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('9485768293',NULL,'1945-12-08','10000028'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('9487829301','45','1966-12-16','10000029'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7148271928','6753','1967-11-11','10000030'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7141014211','7895','1960-03-21','10000031'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748371111','678','1970-01-07','10000032'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748322222','432','1956-06-19','10000033'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3743333456','123','1966-06-18','10000034'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7148123456','4567','1977-07-31','10000035'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7142132311','78','1969-04-16','10000036'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3740293888','984','1966-01-14','10000037'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748333333','094','1966-04-16','10000038'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748444444','123','1963-06-09','10000039'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748555555','674','1960-01-01','10000040'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3746948477',NULL,'1964-08-22','10000041'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7140920004',NULL,'1949-08-16','10000042'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('7143353422',NULL,'1962-05-15','10000043'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('9481232299',NULL,'1967-05-19','10000044'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3748301010',NULL,'1969-03-11','10000045'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3742938282',NULL,'1970-05-23','10000046'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3746666888',NULL,'1977-06-21','10000047'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3746655658',NULL,'1970-01-11','10000048'); 
INSERT INTO Patient (PhoneNumber, PhoneNumExt, DOB, PersonID) VALUES ('3749494837',NULL,'1980-05-21','10000049'); 


INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000010','FR000028','2019-01-01','09:00:00','trouble breathing, feeling depressed because of quarantine loneliness, difficulty breathing may be anxiety induced, no apparent abnormalities present when listening to breathing with stethoscope');
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000011','JA000015','2019-01-01','09:20:00','shoulder pain'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000012','FR000028','2019-01-01','10:15:00','minor skin lesion on ankle'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000013','AL000013','2019-01-01','11:00:00','temporary loss of vision in right eye due to bar fight, patient possible suffering from alcoholism, will review symptoms in future appointments before notifying patient to seek treatment'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000014','FR000028','2019-01-01','11:30:00','tingling feeling in hands due to onset of diabetic neuropathy referred patient to endocrinalogist'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000015','JA000015','2019-01-01','11:45:00','arthritis in knees'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000016','JA000015','2019-01-01','13:30:00','lower back pain'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000017','RO000049','2019-01-01','14:30:00','posibble type two diabetic, patient obese'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000018','JO000016','2019-01-01','15:00:00','possible malignant tumor in abdomen, referred to oncologist'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000019','AL000013','2019-01-02','10:10:00','yearly physical, all clear'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000020','JA000015','2019-01-02','10:20:00','uncomplicated neck pain'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000021','FR000028','2019-01-02','12:00:00','possible exposure to radiation, diarrhea, vomiting, dizziness, headache'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000022','AL000013','2019-01-02','13:00:00','yearly physical, all clear'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000023','FR000028','2019-01-02','13:15:00','possible concussion diarrhea, vomiting, dizziness, headache'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000024','JA000015','2019-01-02','13:30:00','tennis elbow'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000025','FR000028','2019-01-02','14:20:00','minor head wound from skate boarding, advised patient to wear protective gear'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000026','FR000028','2019-01-03','09:45:00','difficulty hearing in left ear'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000027','FR000028','2019-01-03','10:50:00','yearly physical, all clear'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000028','FR000028','2019-01-03','12:30:00','yearly physical, all clear'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000029','AL000013','2019-01-03','17:15:00','trouble breathing, difficulty breathing may be anxiety induced, no apparent abnormalities present when listening to breathing with stethoscope'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000030','FR000028','2019-01-04','09:30:00','minor skin lesion on underside of hands and knees due to skateboarding accident'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000031','RO000049','2019-01-04','11:20:00','patient suffering with asthma due to the changing of the seasons'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000032','FR000028','2019-01-04','14:00:00','workers comp exam, patient experiencing severe muscle pain in lower back'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000033','JE000027','2019-01-04','15:45:00','Appendectomy'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000034','SA000048','2019-01-07','14:30:00','performed cataract surgery, went well'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000035','JO000016','2019-01-09','13:00:00','difficulty breathing and major headaches, treated for asthma'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000036','SA000048','2019-01-12','15:20:00','performed a cholecystectomy due to cancer'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000037','JO000016','2019-01-12','16:00:00','minor lesion on calf from sports related accident'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000038','JO000016','2019-01-13','13:30:00','yearly physical, all clear'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000039','JE000027','2019-01-14','09:15:00','Appendectomy'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000040','JA000012','2019-01-14','11:20:00','FREE SKIN GRAFT, TOTAL TIME: 1 HR'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000041','JE000027','2019-01-15','11:00:00','Breast biopsy, two lumps on right chest'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000042','RO000049','2019-01-15','12:00:00','stroke treatment, referred to speech therapist'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000043','RO000049','2019-01-18','12:50:00','yearly physical, all clear'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000044','JA000012','2019-01-20','12:50:00','DEBRIDEMENT OF WOUND, TOTAL TIME: 1 HR'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000045','SA000048','2019-01-23','08:10:00','perormed extensive cataract surgery, went very well, patient likely to have total vision restored'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000046','RO000049','2019-01-23','13:30:00','yearly physical, possible cancerous growth detected, referred to oncologist'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000047','SA000048','2019-01-24','11:50:00','performed an appendectomy, high chance of infection, patient left against advisement and removed bandages early'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000048','SA000048','2019-01-25','09:45:00','performed an appendectomy, patient stayed in the hospital the entire recommended time (unlike yesterdays patient), should heal completely'); 
INSERT INTO PatientVisit (PatientID, DoctorID, VisitDate, VisitTime, DocNote) VALUES ('P0000049','JE000027','2019-01-26','09:00:00','Debridement of wound'); 

INSERT INTO Test VALUES ('AH000','Adrenocorticotropic Hormone'); 
INSERT INTO Test VALUES ('ABG00','Arterial Blood Gases'); 
INSERT INTO Test VALUES ('ACL00','Anterior Cruciate Ligament'); 
INSERT INTO Test VALUES ('BCMO0','Blood Carbon Monoxide Level'); 
INSERT INTO Test VALUES ('BS000','Bone Scan'); 
INSERT INTO Test VALUES ('BB000','Breast Biopsy'); 
INSERT INTO Test VALUES ('DC000','Dilation and Curettage'); 
INSERT INTO Test VALUES ('DE000','Doppler Echocardiography'); 
INSERT INTO Test VALUES ('DU000','Doppler Ultrasound'); 
INSERT INTO Test VALUES ('FBP00','Fetal Biophysical Profile'); 
INSERT INTO Test VALUES ('MRI00','Magnetic Resonance Imaging'); 
INSERT INTO Test VALUES ('MHA00','Mental Health Assessment'); 
INSERT INTO Test VALUES ('NE000','Neurological Examination'); 
INSERT INTO Test VALUES ('NJ000','Nose Job'); 
INSERT INTO Test VALUES ('NPT00','Nocturnal Penile Tumescence'); 
INSERT INTO Test VALUES ('NMRI0','Nuclear Magnetic Resonance Imaging'); 
INSERT INTO Test VALUES ('PC000','Partial Colectomy'); 
INSERT INTO Test VALUES ('PTA00','Pure Tone Audiometry'); 
INSERT INTO Test VALUES ('PTT00','Partial Thromboplastin Time'); 
INSERT INTO Test VALUES ('PU000','Pregnancy Ultrasound'); 
INSERT INTO Test VALUES ('RTS00','Radioactive Thyroid Scan'); 
INSERT INTO Test VALUES ('SPE00','Serum Protein Electrophoresis'); 
INSERT INTO Test VALUES ('SCL00','Serum Catecholamines Levels'); 

INSERT INTO PVisitTest VALUES ('20000010','RTS00');
INSERT INTO PVisitTest VALUES ('20000011','AH000'); 
INSERT INTO PVisitTest VALUES ('20000012','ABG00'); 
INSERT INTO PVisitTest VALUES ('20000013','NPT00'); 
INSERT INTO PVisitTest VALUES ('20000014','MHA00'); 
INSERT INTO PVisitTest VALUES ('20000015','FBP00'); 
INSERT INTO PVisitTest VALUES ('20000016','ABG00'); 
INSERT INTO PVisitTest VALUES ('20000017','MHA00');
INSERT INTO PVisitTest VALUES ('20000018','FBP00');
INSERT INTO PVisitTest VALUES ('20000019','NPT00');
INSERT INTO PVisitTest VALUES ('20000020','PU000');
INSERT INTO PVisitTest VALUES ('20000021','AH000');
INSERT INTO PVisitTest VALUES ('20000022','FBP00');
INSERT INTO PVisitTest VALUES ('20000023','PU000');
INSERT INTO PVisitTest VALUES ('20000024','AH000');
INSERT INTO PVisitTest VALUES ('20000025','MHA00'); 
INSERT INTO PVisitTest VALUES ('20000026','FBP00');
INSERT INTO PVisitTest VALUES ('20000027','DE000');
INSERT INTO PVisitTest VALUES ('20000028','PU000');
INSERT INTO PVisitTest VALUES ('20000029','AH000');
INSERT INTO PVisitTest VALUES ('20000030','PU000');
INSERT INTO PVisitTest VALUES ('20000031','PU000');
INSERT INTO PVisitTest VALUES ('20000032','AH000');
INSERT INTO PVisitTest VALUES ('20000033','FBP00');
INSERT INTO PVisitTest VALUES ('20000034','NJ000');
INSERT INTO PVisitTest VALUES ('20000035','MRI00');
INSERT INTO PVisitTest VALUES ('20000036','MHA00');
INSERT INTO PVisitTest VALUES ('20000037','RTS00');
INSERT INTO PVisitTest VALUES ('20000038','PTA00');
INSERT INTO PVisitTest VALUES ('20000039','NJ000');
INSERT INTO PVisitTest VALUES ('20000040','AH000');
INSERT INTO PVisitTest VALUES ('20000040','NJ000');
INSERT INTO PVisitTest VALUES ('20000040','MRI00');
INSERT INTO PVisitTest VALUES ('20000040','MRI00');
INSERT INTO PVisitTest VALUES ('20000040','DE000');
INSERT INTO PVisitTest VALUES ('20000040','DE000');
INSERT INTO PVisitTest VALUES ('20000040','NPT00');
INSERT INTO PVisitTest VALUES ('20000040','RTS00');
INSERT INTO PVisitTest VALUES ('20000040','PTA00');
INSERT INTO PVisitTest VALUES ('20000040','FBP00');


INSERT INTO Prescription VALUES ('rx12308340034987','Adderall'); 
INSERT INTO Prescription VALUES ('rx12308350034987','Alprazolam'); 
INSERT INTO Prescription VALUES ('rx12308360034987','Amitriptyline'); 
INSERT INTO Prescription VALUES ('rx12308693734987','Amlodipine'); 
INSERT INTO Prescription VALUES ('rx12308692834987','Amoxicillin'); 
INSERT INTO Prescription VALUES ('rx12308692134987','Codeine'); 
INSERT INTO Prescription VALUES ('rx12308612034987','Doxycycline'); 
INSERT INTO Prescription VALUES ('rx12308623034987','Gabapentin'); 
INSERT INTO Prescription VALUES ('rx12308634034987','Hydrochlorothiazide'); 
INSERT INTO Prescription VALUES ('rx12308645034987','Ibuprofen'); 
INSERT INTO Prescription VALUES ('rx12308656034987','Lexapro'); 
INSERT INTO Prescription VALUES ('rx12308667034987','Lisinopril'); 
INSERT INTO Prescription VALUES ('rx12308697834987','Loratadine'); 
INSERT INTO Prescription VALUES ('rx12308690894987','Lorazepam'); 
INSERT INTO Prescription VALUES ('rx12308690034911','Losartan'); 
INSERT INTO Prescription VALUES ('rx12308690034912','Lyrica'); 
INSERT INTO Prescription VALUES ('rx12308690034913','Meloxicam'); 
INSERT INTO Prescription VALUES ('rx12308690034245','Metoprolol'); 
INSERT INTO Prescription VALUES ('rx12308690036787','Naproxen'); 
INSERT INTO Prescription VALUES ('rx10908690034987','Omeprazole'); 
INSERT INTO Prescription VALUES ('rx12308690067842','Olaparib'); 
INSERT INTO Prescription VALUES ('rx12308691209845','Olmesartan'); 
INSERT INTO Prescription VALUES ('rx88308690234678','Omnicef'); 
INSERT INTO Prescription VALUES ('rx16778690034987','Opdivo'); 
INSERT INTO Prescription VALUES ('rx12458690034987','Opium'); 
INSERT INTO Prescription VALUES ('rx12678690034987','Oxycontin'); 
INSERT INTO Prescription VALUES ('rx13408690034987','Pantoprazole'); 
INSERT INTO Prescription VALUES ('rx09808690034987','Prednisone'); 
INSERT INTO Prescription VALUES ('rx07308690034987','Seroquel'); 
INSERT INTO Prescription VALUES ('rx12307090034987','Sertraline'); 
INSERT INTO Prescription VALUES ('rx12300090034987','Sevelamer'); 
INSERT INTO Prescription VALUES ('rx12303090034987','Shingrix'); 
INSERT INTO Prescription VALUES ('rx34308690034987','Sildenafil'); 
INSERT INTO Prescription VALUES ('rx67808690034987','Simethicone'); 
INSERT INTO Prescription VALUES ('rx91508690034987','Simvastatin'); 
INSERT INTO Prescription VALUES ('rx99908691034987','Sinemet'); 
INSERT INTO Prescription VALUES ('rx67808690224987','Tramadol'); 
INSERT INTO Prescription VALUES ('rx94308690034987','Trazadone'); 
INSERT INTO Prescription VALUES ('rx16908690034987','Vicodin'); 
INSERT INTO Prescription VALUES ('rx12343090034987','Wellbutrin'); 
INSERT INTO Prescription VALUES ('rx12312943777787','Xanax'); 
INSERT INTO Prescription VALUES ('rx09384086923487','Zoloft'); 
INSERT INTO Prescription VALUES ('rx12308692222223','Zaditor'); 
INSERT INTO Prescription VALUES ('rx12308692224455','Zaleplon'); 
INSERT INTO Prescription VALUES ('rx12308690024555','Zarxio'); 
INSERT INTO Prescription VALUES ('rx12308690034211','Zestril'); 
INSERT INTO Prescription VALUES ('rx18748690034987','Zestoretic'); 
INSERT INTO Prescription VALUES ('rx15398690034987','Ziac'); 
INSERT INTO Prescription VALUES ('rx07608690034987','Zidovudine'); 
INSERT INTO Prescription VALUES ('rx07530690034987','Zinc'); 
INSERT INTO Prescription VALUES ('rx12308692934987','Zosyn'); 

INSERT INTO PVisitPrescription VALUES ('20000010','rx12308340034987'); 
INSERT INTO PVisitPrescription VALUES ('20000011','rx12458690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000012','rx12678690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000013','rx13408690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000014','rx09808690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000015','rx12308350034987'); 
INSERT INTO PVisitPrescription VALUES ('20000016','rx12308360034987'); 
INSERT INTO PVisitPrescription VALUES ('20000017','rx12308612034987'); 
INSERT INTO PVisitPrescription VALUES ('20000018','rx12308623034987'); 
INSERT INTO PVisitPrescription VALUES ('20000019','rx12308667034987'); 
INSERT INTO PVisitPrescription VALUES ('20000020','rx12308697834987'); 
INSERT INTO PVisitPrescription VALUES ('20000021','rx12308690894987'); 
INSERT INTO PVisitPrescription VALUES ('20000022','rx12303090034987'); 
INSERT INTO PVisitPrescription VALUES ('20000023','rx34308690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000024','rx67808690224987'); 
INSERT INTO PVisitPrescription VALUES ('20000025','rx09384086923487'); 
INSERT INTO PVisitPrescription VALUES ('20000026','rx12308692222223'); 
INSERT INTO PVisitPrescription VALUES ('20000027','rx12308692224455'); 
INSERT INTO PVisitPrescription VALUES ('20000028','rx12308690034911'); 
INSERT INTO PVisitPrescription VALUES ('20000029','rx12458690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000030','rx12678690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000031','rx13408690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000032','rx16908690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000033','rx12308350034987'); 
INSERT INTO PVisitPrescription VALUES ('20000034','rx12308360034987'); 
INSERT INTO PVisitPrescription VALUES ('20000035','rx12308612034987'); 
INSERT INTO PVisitPrescription VALUES ('20000036','rx99908691034987'); 
INSERT INTO PVisitPrescription VALUES ('20000037','rx12308690034912'); 
INSERT INTO PVisitPrescription VALUES ('20000038','rx12308690034913'); 
INSERT INTO PVisitPrescription VALUES ('20000039','rx12308690034245'); 
INSERT INTO PVisitPrescription VALUES ('20000040','rx12308690036787'); 
INSERT INTO PVisitPrescription VALUES ('20000040','rx16908690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000040','rx12308690067842'); 
INSERT INTO PVisitPrescription VALUES ('20000040','rx12308693734987'); 
INSERT INTO PVisitPrescription VALUES ('20000040','rx12308692834987'); 
INSERT INTO PVisitPrescription VALUES ('20000040','rx12308692134987'); 
INSERT INTO PVisitPrescription VALUES ('20000040','rx12308634034987'); 
INSERT INTO PVisitPrescription VALUES ('20000040','rx91508690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000039','rx99908691034987'); 
INSERT INTO PVisitPrescription VALUES ('20000039','rx67808690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000039','rx94308690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000039','rx16908690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000038','rx12343090034987'); 
INSERT INTO PVisitPrescription VALUES ('20000038','rx12312943777787'); 
INSERT INTO PVisitPrescription VALUES ('20000038','rx10908690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000038','rx12308690067842'); 
INSERT INTO PVisitPrescription VALUES ('20000037','rx12308693734987'); 
INSERT INTO PVisitPrescription VALUES ('20000037','rx12308692834987'); 
INSERT INTO PVisitPrescription VALUES ('20000037','rx12308645034987'); 
INSERT INTO PVisitPrescription VALUES ('20000037','rx12308690024555'); 
INSERT INTO PVisitPrescription VALUES ('20000037','rx12308690034211'); 
INSERT INTO PVisitPrescription VALUES ('20000036','rx18748690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000036','rx15398690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000036','rx99908691034987'); 
INSERT INTO PVisitPrescription VALUES ('20000036','rx07530690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000035','rx16908690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000035','rx12308691209845'); 
INSERT INTO PVisitPrescription VALUES ('20000034','rx88308690234678'); 
INSERT INTO PVisitPrescription VALUES ('20000035','rx16778690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000036','rx07308690034987'); 
INSERT INTO PVisitPrescription VALUES ('20000033','rx12307090034987'); 
INSERT INTO PVisitPrescription VALUES ('20000033','rx12308634034987'); 
INSERT INTO PVisitPrescription VALUES ('20000033','rx12308645034987'); 
INSERT INTO PVisitPrescription VALUES ('20000032','rx12308656034987'); 
INSERT INTO PVisitPrescription VALUES ('20000031','rx12300090034987'); 


