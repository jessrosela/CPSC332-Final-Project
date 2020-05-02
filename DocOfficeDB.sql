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
--
-- Definition of table `Doctor`
--
DROP TABLE IF EXISTS Doctor;
CREATE TABLE Doctor (
  DoctorID	varchar(9),
  MedicalDegrees	char(50),
  PersonID int, 
  PRIMARY KEY (DoctorID),
  FOREIGN KEY (PersonID) references Person(PersonID)
);
--
-- Definition of table `Specialty`
--
DROP TABLE IF EXISTS Specialty;
CREATE TABLE Specialty (
  SpecialtyID	varchar(9),
  SpecialtyName	varchar(50),
  PRIMARY KEY (SpecialtyID)
);
--
-- Definition of table `DoctorSpecialty`
--
DROP TABLE IF EXISTS DoctorSpecialty;
CREATE TABLE DoctorSpecialty (
  DoctorID	varchar(9),
  SpecialtyID	varchar(9),
  FOREIGN KEY (DoctorID) references Doctor(DoctorID),
  FOREIGN KEY (SpecialtyID) references Specialty(SpecialtyID)
);
--
-- Definition of trigger before insert `DoctorSpecialty`
--
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
-- Definition of table `PatientVisit`
--
DROP TABLE IF EXISTS PatientVisit;
CREATE TABLE PatientVisit (
  VisitID	varchar(12),
  PatientID	varchar(8),
  DoctorID	varchar(9),
  VisitDate	date,
  VisitTime time, 
  DocNote	varchar(2000),
  PRIMARY KEY (VisitID),
  FOREIGN KEY (PatientID) references Patient(PatientID),
  FOREIGN KEY (DoctorID) references Doctor(DoctorID),
  CONSTRAINT CHK_PatientVisit CHECK (PatientID != DoctorID)
);
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
  VisitID	varchar(9),
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
  VisitID	varchar(9),
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

CREATE VIEW DocSpecialty AS
SELECT FirstName, LastName, SpecialtyID
FROM Person, DoctorSpecialty, Doctor
WHERE Doctor.PersonID=Person.PersonID;

sf

-- Insert all records 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Bob','Bender','8794 Garfield', 'Chicago', 'IL','45321','7148657326',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Kim','Grace','6677 Mills Ave', 'Sacramento', 'CA','60078','3748372614',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('James','Borg','450 Stone', 'Houston', 'TX','92867','3748372342',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Alex','Freed','4333 Pillsbury', 'Milwaukee', 'WI','72954','3748372019',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Evan','Wallis','134 Pelham', 'Milwaukee', 'WI','72954','3748374859',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Jared','James','123 Peachtree', 'Atlanta', 'GA','89324','3748379876',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('John','James','7676 Bloomington', 'Sacramento', 'CA','60078','3748370912',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Andy','Vile','1967 Jordan', 'Milwaukee', 'WI','72954','3748372392',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Brad','Knight','176 Main St.', 'Atlanta', 'GA','89324','3748310293',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Josh','Zell','266 McGrady', 'Milwaukee', 'WI','72954','3748398765',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Justin','Mark','2342 May', 'Atlanta', 'GA','89324','3748091856',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Jon','Jones','111 Allgood', 'Atlanta', 'GA','89324','7142388273',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Ahmad','Jabbar','980 Dallas', 'Houston', 'TX','92867','3395832342',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Joyce','English','5631 Rice', 'Houston', 'TX','92867','7600928114',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Ramesh','Narayan','971 Fire Oak', 'Humble', 'TX','92734','7148182857',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Alicia','Zelaya','3321 Castle', 'Spring', 'TX','92765','7141236357',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('John','Smith','731 Fondren', 'Houston', 'TX','92867','7148372905',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Jennifer','Wallace','291 Berry', 'Bellaire', 'TX','92725','3395832342',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Franklin','Wong','638 Voss', 'Houston', 'TX','92867','9485768293',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Tom','Brand','112 Third St', 'Milwaukee', 'WI','72954','7147711656',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Jenny','Vos','263 Mayberry', 'Milwaukee', 'WI','72954','7148271928',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Chris','Carter','565 Jordan', 'Milwaukee', 'WI','72954','7141014211',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Jeff','Chase','145 Bradbury', 'Sacramento', 'CA','60078','3748371111','678'); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Bonnie','Bays','111 Hollow', 'Milwaukee', 'WI','72954','374832','432'); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Alec','Best','233 Solid', 'Milwaukee', 'WI','72954','3743333456','123'); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Sam','Snedden','987 Windy St', 'Milwaukee', 'WI','72954','7148123456','4567'); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Nandita','Ball','222 Howard', 'Sacramento', 'CA','60078','7142132311','78'); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Jill','Jarvis','6234 Lincoln', 'Chicago', 'IL','45321','3740293888','984'); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Kate','King','1976 Boone Trace', 'Chicago', 'IL','45321','3748333333','094'); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Lyle','Leslie','417 Hancock Ave', 'Chicago', 'IL','45321','3748444444','123'); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Billie','King','556 Washington', 'Chicago', 'IL','45321','3748555555','674'); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Jon','Kramer','1988 Windy Creek', 'Seattle', 'WA','92740','3746948477',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Ray','King','213 Delk Road', 'Seattle', 'WA','92704','7140920004',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Gerald','Small','122 Ball Street','Dallas','TX','92869','7143353422',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Arnold','Head','233 Spring St','Dallas','TX','92869','9481232299',NULL);
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Helga','Pataki','101 Holyoke St','Dallas','TX','92869','3748301010',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Naveen','Drew','198 Elm St','Philadelphia','PA','56219','3742938282',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Carl','Reedy','213 Ball St','Philadelphia','PA','56219','3746666888',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Sammy','Hall','433 Main Street','Miami', 'FL','41390','3746655658',NULL); 
INSERT INTO Person(FirstName,LastName,StreetAddress,City,State,Zipcode,PhoneNumber,PhoneNumExt) VALUES ('Robert','Stevens','196 Elm Street','Miami', 'FL','41390','3749494837',NULL); 


INSERT INTO Doctor VALUES ('FR5847226','MD, MM','19');
INSERT INTO Doctor VALUES ('JE1029384','MD, MS, DS','18');
INSERT INTO Doctor VALUES ('JA9584732','MD, DS, DCM','3');
INSERT INTO Doctor VALUES ('JA6748392','MD, DO','6');
INSERT INTO Doctor VALUES ('AL0987736','MD, MCM','4');
INSERT INTO Doctor VALUES ('JO3459681','MD','7');
INSERT INTO Doctor VALUES ('SA6699912','MD, DS','39'); 
INSERT INTO Doctor VALUES ('RO1666613','MD, DCM','40'); 

INSERT INTO Specialty VALUES ('CLI00','Clinical Medicine');
INSERT INTO Specialty VALUES ('FAM00','Family Medicine');
INSERT INTO Specialty VALUES ('OST00','Osteopathic Medicine');
INSERT INTO Specialty VALUES ('SUR00','Surgery');

INSERT INTO DoctorSpecialty VALUES ('FR5847226','FAM00');
INSERT INTO DoctorSpecialty VALUES ('JE1029384','SUR00');
INSERT INTO DoctorSpecialty VALUES ('JA9584732','SUR00');
INSERT INTO DoctorSpecialty VALUES ('JA6748392','OST00');
INSERT INTO DoctorSpecialty VALUES ('AL0987736','CLI00');
INSERT INTO DoctorSpecialty VALUES ('JO3459681','FAM00');
INSERT INTO DoctorSpecialty VALUES ('SA6699912','SUR00'); 
INSERT INTO DoctorSpecialty VALUES ('RO1666613','FAM00'); 

INSERT INTO Patient VALUES ('PA666600','7148657326',NULL,'1968-04-17','1');
INSERT INTO Patient VALUES ('PA333300','3748372614',NULL,'1970-10-23','2'); 
INSERT INTO Patient VALUES ('PA665555','3748372342',NULL,'1927-11-10','3'); 
INSERT INTO Patient VALUES ('PA444400','3748372019',NULL,'1950-10-09','4'); 
INSERT INTO Patient VALUES ('PA222200','3748374859',NULL,'1958-01-16','5'); 
INSERT INTO Patient VALUES ('PA111100','3748379876',NULL,'1966-10-10','6'); 
INSERT INTO Patient VALUES ('PA555500','3748370912',NULL,'1975-06-30','7'); 
INSERT INTO Patient VALUES ('PA222202','3748372392',NULL,'1944-06-21','8'); 
INSERT INTO Patient VALUES ('PA111103','3748310293',NULL,'1968-02-13','9'); 
INSERT INTO Patient VALUES ('PA222201','3748398765',NULL,'1954-05-22','10'); 
INSERT INTO Patient VALUES ('PA111102','3748091856',NULL,'1966-01-12','11'); 
INSERT INTO Patient VALUES ('PA111101','7142388273',NULL,'1967-11-14','12'); 
INSERT INTO Patient VALUES ('PA987987','7608323614',NULL,'1959-03-29','13'); 
INSERT INTO Patient VALUES ('PA453453','7600928114',NULL,'1962-07-31','14'); 
INSERT INTO Patient VALUES ('PA884444','7148182857',NULL,'1952-09-15','15'); 
INSERT INTO Patient VALUES ('PA887777','7141236357',NULL,'1958-07-19','16'); 
INSERT INTO Patient VALUES ('PA456789','7148372905',NULL,'1955-01-09','17'); 
INSERT INTO Patient VALUES ('PA654321','3395832342',NULL,'1931-06-20','18'); 
INSERT INTO Patient VALUES ('PA445555','9485768293',NULL,'1945-12-08','19'); 
INSERT INTO Patient VALUES ('PA222203','9487829301','45','1966-12-16','20'); 
INSERT INTO Patient VALUES ('PA222204','7148271928','6753','1967-11-11','21'); 
INSERT INTO Patient VALUES ('PA222205','7141014211','7895','1960-03-21','22'); 
INSERT INTO Patient VALUES ('PA333301','3748371111','678','1970-01-07','23'); 
INSERT INTO Patient VALUES ('PA444401','3748322222','432','1956-06-19','24'); 
INSERT INTO Patient VALUES ('PA444402','3743333456','123','1966-06-18','25'); 
INSERT INTO Patient VALUES ('PA444403','7148123456','4567','1977-07-31','26'); 
INSERT INTO Patient VALUES ('PA555501','7142132311','78','1969-04-16','27'); 
INSERT INTO Patient VALUES ('PA666601','3740293888','984','1966-01-14','28'); 
INSERT INTO Patient VALUES ('PA666602','3748333333','094','1966-04-16','29'); 
INSERT INTO Patient VALUES ('PA666603','3748444444','123','1963-06-09','30'); 
INSERT INTO Patient VALUES ('PA666604','3748555555','674','1960-01-01','31'); 
INSERT INTO Patient VALUES ('PA666605','3746948477',NULL,'1964-08-22','32'); 
INSERT INTO Patient VALUES ('PA666606','7140920004',NULL,'1949-08-16','33'); 
INSERT INTO Patient VALUES ('PA666607','7143353422',NULL,'1962-05-15','34'); 
INSERT INTO Patient VALUES ('PA666608','9481232299',NULL,'1967-05-19','35'); 
INSERT INTO Patient VALUES ('PA666609','3748301010',NULL,'1969-03-11','36'); 
INSERT INTO Patient VALUES ('PA666610','3742938282',NULL,'1970-05-23','37'); 
INSERT INTO Patient VALUES ('PA666611','3746666888',NULL,'1977-06-21','38'); 
INSERT INTO Patient VALUES ('PA666612','3746655658',NULL,'1970-01-11','39'); 
INSERT INTO Patient VALUES ('PA666613','3749494837',NULL,'1980-05-21','40'); 


INSERT INTO PatientVisit VALUES ('PV0000001','PA666600','FR5847226','2019-01-01','09:00:00','trouble breathing, feeling depressed because of quarantine loneliness, difficulty breathing may be anxiety induced, no apparent abnormalities present when listening to breathing with stethoscope');
INSERT INTO PatientVisit VALUES ('PV0000002','PA456789','JA6748392','2019-01-01','09:20:00','shoulder pain'); 
INSERT INTO PatientVisit VALUES ('PV0000003','PA333300','FR5847226','2019-01-01','10:15:00','minor skin lesion on ankle'); 
INSERT INTO PatientVisit VALUES ('PV0000004','PA111101','AL0987736','2019-01-01','11:00:00','temporary loss of vision in right eye due to bar fight, patient possible suffering from alcoholism, will review symptoms in future appointments before notifying patient to seek treatment'); 
INSERT INTO PatientVisit VALUES ('PV0000005','PA665555','FR5847226','2019-01-01','11:30:00','tingling feeling in hands due to onset of diabetic neuropathy referred patient to endocrinalogist'); 
INSERT INTO PatientVisit VALUES ('PV0000006','PA654321','JA6748392','2019-01-01','11:45:00','arthritis in knees'); 
INSERT INTO PatientVisit VALUES ('PV0000007','PA887777','JA6748392','2019-01-01','13:30:00','lower back pain'); 
INSERT INTO PatientVisit VALUES ('PV0000008','PA444402','RO1666613','2019-01-01','14:30:00','posibble type two diabetic, patient obese'); 
INSERT INTO PatientVisit VALUES ('PV0000009','PA666608','JO3459681','2019-01-01','15:00:00','possible malignant tumor in abdomen, referred to oncologist'); 
INSERT INTO PatientVisit VALUES ('PV0000010','PA453453','AL0987736','2019-01-02','10:10:00','yearly physical, all clear'); 
INSERT INTO PatientVisit VALUES ('PV0000011','PA445555','JA6748392','2019-01-02','10:20:00','uncomplicated neck pain'); 
INSERT INTO PatientVisit VALUES ('PV0000012','PA444400','FR5847226','2019-01-02','12:00:00','possible exposure to radiation, diarrhea, vomiting, dizziness, headache'); 
INSERT INTO PatientVisit VALUES ('PV0000013','PA987987','AL0987736','2019-01-02','13:00:00','yearly physical, all clear'); 
INSERT INTO PatientVisit VALUES ('PV0000014','PA222200','FR5847226','2019-01-02','13:15:00','possible concussion diarrhea, vomiting, dizziness, headache'); 
INSERT INTO PatientVisit VALUES ('PV0000015','PA222203','JA6748392','2019-01-02','13:30:00','tennis elbow'); 
INSERT INTO PatientVisit VALUES ('PV0000016','PA111100','FR5847226','2019-01-02','14:20:00','minor head wound from skate boarding, advised patient to wear protective gear'); 
INSERT INTO PatientVisit VALUES ('PV0000017','PA555500','FR5847226','2019-01-03','09:45:00','difficulty hearing in left ear'); 
INSERT INTO PatientVisit VALUES ('PV0000018','PA222202','FR5847226','2019-01-03','10:50:00','yearly physical, all clear'); 
INSERT INTO PatientVisit VALUES ('PV0000019','PA111103','FR5847226','2019-01-03','12:30:00','yearly physical, all clear'); 
INSERT INTO PatientVisit VALUES ('PV0000020','PA884444','AL0987736','2019-01-03','17:15:00','trouble breathing, difficulty breathing may be anxiety induced, no apparent abnormalities present when listening to breathing with stethoscope'); 
INSERT INTO PatientVisit VALUES ('PV0000021','PA222201','FR5847226','2019-01-04','09:30:00','minor skin lesion on underside of hands and knees due to skateboarding accident'); 
INSERT INTO PatientVisit VALUES ('PV0000022','PA444403','RO1666613','2019-01-04','11:20:00','patient suffering with asthma due to the changing of the seasons'); 
INSERT INTO PatientVisit VALUES ('PV0000023','PA111102','FR5847226','2019-01-04','14:00:00','workers comp exam, patient experiencing severe muscle pain in lower back'); 
INSERT INTO PatientVisit VALUES ('PV0000024','PA222204','JE1029384','2019-01-04','15:45:00','Appendectomy'); 
INSERT INTO PatientVisit VALUES ('PV0000025','PA666607','SA6699912','2019-01-07','14:30:00','performed cataract surgery, went well'); 
INSERT INTO PatientVisit VALUES ('PV0000026','PA666609','JO3459681','2019-01-09','13:00:00','difficulty breathing and major headaches, treated for asthma'); 
INSERT INTO PatientVisit VALUES ('PV0000027','PA666603','SA6699912','2019-01-12','15:20:00','performed a cholecystectomy due to cancer'); 
INSERT INTO PatientVisit VALUES ('PV0000028','PA666610','JO3459681','2019-01-12','16:00:00','minor lesion on calf from sports related accident'); 
INSERT INTO PatientVisit VALUES ('PV0000029','PA666611','JO3459681','2019-01-13','13:30:00','yearly physical, all clear'); 
INSERT INTO PatientVisit VALUES ('PV0000030','PA444401','JE1029384','2019-01-14','09:15:00','Appendectomy'); 
INSERT INTO PatientVisit VALUES ('PV0000031','PA666612','JA9584732','2019-01-14','11:20:00','FREE SKIN GRAFT, TOTAL TIME: 1 HR'); 
INSERT INTO PatientVisit VALUES ('PV0000032','PA222205','JE1029384','2019-01-15','11:00:00','Breast biopsy, two lumps on right chest'); 
INSERT INTO PatientVisit VALUES ('PV0000033','PA555501','RO1666613','2019-01-15','12:00:00','stroke treatment, referred to speech therapist'); 
INSERT INTO PatientVisit VALUES ('PV0000034','PA666601','RO1666613','2019-01-18','12:50:00','yearly physical, all clear'); 
INSERT INTO PatientVisit VALUES ('PV0000035','PA666613','JA9584732','2019-01-20','12:50:00','DEBRIDEMENT OF WOUND, TOTAL TIME: 1 HR'); 
INSERT INTO PatientVisit VALUES ('PV0000036','PA666604','SA6699912','2019-01-23','08:10:00','perormed extensive cataract surgery, went very well, patient likely to have total vision restored'); 
INSERT INTO PatientVisit VALUES ('PV0000037','PA666602','RO1666613','2019-01-23','13:30:00','yearly physical, possible cancerous growth detected, referred to oncologist'); 
INSERT INTO PatientVisit VALUES ('PV0000038','PA666605','SA6699912','2019-01-24','11:50:00','performed an appendectomy, high chance of infection, patient left against advisement and removed bandages early'); 
INSERT INTO PatientVisit VALUES ('PV0000039','PA666606','SA6699912','2019-01-25','09:45:00','performed an appendectomy, patient stayed in the hospital the entire recommended time (unlike yesterdays patient), should heal completely'); 
INSERT INTO PatientVisit VALUES ('PV0000040','PA333301','JE1029384','2019-01-26','09:00:00','Debridement of wound'); 

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

INSERT INTO PVisitTest VALUES ('PV0000001','RTS00');
INSERT INTO PVisitTest VALUES ('PV0000002','AH000'); 
INSERT INTO PVisitTest VALUES ('PV0000003','ABG00'); 
INSERT INTO PVisitTest VALUES ('PV0000004','NPT00'); 
INSERT INTO PVisitTest VALUES ('PV0000005','MHA00'); 
INSERT INTO PVisitTest VALUES ('PV0000006','FBP00'); 
INSERT INTO PVisitTest VALUES ('PV0000007','ABG00'); 
INSERT INTO PVisitTest VALUES ('PV0000008','MHA00');
INSERT INTO PVisitTest VALUES ('PV0000009','FBP00');
INSERT INTO PVisitTest VALUES ('PV0000010','NPT00');
INSERT INTO PVisitTest VALUES ('PV0000011','PU000');
INSERT INTO PVisitTest VALUES ('PV0000012','AH000');
INSERT INTO PVisitTest VALUES ('PV0000013','FBP00');
INSERT INTO PVisitTest VALUES ('PV0000014','PU000');
INSERT INTO PVisitTest VALUES ('PV0000015','AH000');
INSERT INTO PVisitTest VALUES ('PV0000016','MHA00'); 
INSERT INTO PVisitTest VALUES ('PV0000017','FBP00');
INSERT INTO PVisitTest VALUES ('PV0000018','DE000');
INSERT INTO PVisitTest VALUES ('PV0000019','PU000');
INSERT INTO PVisitTest VALUES ('PV0000020','AH000');
INSERT INTO PVisitTest VALUES ('PV0000021','PU000');
INSERT INTO PVisitTest VALUES ('PV0000022','PU000');
INSERT INTO PVisitTest VALUES ('PV0000023','AH000');
INSERT INTO PVisitTest VALUES ('PV0000024','FBP00');
INSERT INTO PVisitTest VALUES ('PV0000025','NJ000');
INSERT INTO PVisitTest VALUES ('PV0000026','MRI00');
INSERT INTO PVisitTest VALUES ('PV0000027','MHA00');
INSERT INTO PVisitTest VALUES ('PV0000028','RTS00');
INSERT INTO PVisitTest VALUES ('PV0000029','PTA00');
INSERT INTO PVisitTest VALUES ('PV0000030','NJ000');
INSERT INTO PVisitTest VALUES ('PV0000031','AH000');
INSERT INTO PVisitTest VALUES ('PV0000032','NJ000');
INSERT INTO PVisitTest VALUES ('PV0000033','MRI00');
INSERT INTO PVisitTest VALUES ('PV0000034','MRI00');
INSERT INTO PVisitTest VALUES ('PV0000035','DE000');
INSERT INTO PVisitTest VALUES ('PV0000036','DE000');
INSERT INTO PVisitTest VALUES ('PV0000037','NPT00');
INSERT INTO PVisitTest VALUES ('PV0000038','RTS00');
INSERT INTO PVisitTest VALUES ('PV0000039','PTA00');
INSERT INTO PVisitTest VALUES ('PV0000040','FBP00');


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

INSERT INTO PVisitPrescription VALUES ('PV0000001','rx12308340034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000001','rx12458690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000001','rx12678690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000002','rx13408690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000003','rx09808690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000004','rx12308350034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000005','rx12308360034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000005','rx12308612034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000005','rx12308623034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000005','rx12308667034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000006','rx12308697834987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000006','rx12308690894987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000007','rx12303090034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000008','rx34308690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000009','rx67808690224987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000010','rx09384086923487'); 
INSERT INTO PVisitPrescription VALUES ('PV0000010','rx12308692222223'); 
INSERT INTO PVisitPrescription VALUES ('PV0000011','rx12308692224455'); 
INSERT INTO PVisitPrescription VALUES ('PV0000012','rx12308690034911'); 
INSERT INTO PVisitPrescription VALUES ('PV0000013','rx12458690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000014','rx12678690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000014','rx13408690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000015','rx16908690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000016','rx12308350034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000017','rx12308360034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000018','rx12308612034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000018','rx99908691034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000019','rx12308690034912'); 
INSERT INTO PVisitPrescription VALUES ('PV0000020','rx12308690034913'); 
INSERT INTO PVisitPrescription VALUES ('PV0000021','rx12308690034245'); 
INSERT INTO PVisitPrescription VALUES ('PV0000022','rx12308690036787'); 
INSERT INTO PVisitPrescription VALUES ('PV0000023','rx16908690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000023','rx12308690067842'); 
INSERT INTO PVisitPrescription VALUES ('PV0000023','rx12308693734987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000023','rx12308692834987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000024','rx12308692134987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000024','rx12308634034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000024','rx91508690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000025','rx99908691034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000025','rx67808690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000025','rx94308690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000025','rx16908690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000026','rx12343090034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000027','rx12312943777787'); 
INSERT INTO PVisitPrescription VALUES ('PV0000027','rx10908690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000028','rx12308690067842'); 
INSERT INTO PVisitPrescription VALUES ('PV0000029','rx12308693734987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000030','rx12308692834987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000030','rx12308645034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000030','rx12308690024555'); 
INSERT INTO PVisitPrescription VALUES ('PV0000031','rx12308690034211'); 
INSERT INTO PVisitPrescription VALUES ('PV0000031','rx18748690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000032','rx15398690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000032','rx99908691034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000033','rx07530690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000034','rx16908690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000034','rx12308691209845'); 
INSERT INTO PVisitPrescription VALUES ('PV0000034','rx88308690234678'); 
INSERT INTO PVisitPrescription VALUES ('PV0000035','rx16778690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000036','rx07308690034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000036','rx12307090034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000037','rx12308634034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000038','rx12308645034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000039','rx12308656034987'); 
INSERT INTO PVisitPrescription VALUES ('PV0000040','rx12300090034987'); 


