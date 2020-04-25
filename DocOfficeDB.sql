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
  PersonID	varchar(9),
  FirstName	varchar(25) NOT NULL,
  LastName	varchar(25),
  StreetAddress	varchar(50),	
  City	varchar(15),
  State	varchar(15),
  Zipcode	int(5),
  PhoneNumber int(10)	NOT NULL, 
  PRIMARY KEY (PersonID)
);
--
-- Definition of table `Doctor`
--
DROP TABLE IF EXISTS Doctor;
CREATE TABLE Doctor (
  DoctorID	varchar(9),
  MedicalDegrees	char(50),
  PersonID	varchar(9), 
  PRIMARY KEY (DoctorID),
  FOREIGN KEY (PersonID) references Person(PersonID)
);
--
-- Definition of table `Specialty`
--
DROP TABLE IF EXISTS Specialty;
CREATE TABLE Specialty (
  SpecialtyID	varchar(9),
  SpecialtyName	varchar(25),
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
-- Definition of table `Patient`
--
DROP TABLE IF EXISTS Patient;
CREATE TABLE Patient (
  PatientID	varchar(9),
  PhoneNumber	int(10),
  DOB	int(6),
  PersonID    varchar(9),
  PRIMARY KEY (PatientID),
  FOREIGN KEY (PersonID) references Person(PersonID)
);
--
-- Definition of table `PatientVisit`
--
DROP TABLE IF EXISTS PatientVisit;
CREATE TABLE PatientVisit (
  VisitID	varchar(9),
  PatientID	varchar(9),
  DoctorID	varchar(9),
  VisitDate	datetime,
  DocNote	varchar(2000),
  PRIMARY KEY (VisitID),
  FOREIGN KEY (PatientID) references Patient(PatientID),
  FOREIGN KEY (DoctorID) references Doctor(DoctorID)
);
--
-- Definition of table `Test`
--
DROP TABLE IF EXISTS Test;
CREATE TABLE Test (

  TestID	varchar(9),
  TestName	varchar(20),
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
  PrescriptionID	varchar(9),
  PrescriptionName	varchar(15),
  PRIMARY KEY (PrescriptionID)
);
--
-- Definition of table `PVisitPrescription`
--
DROP TABLE IF EXISTS PVisitPrescription;
CREATE TABLE PVisitPrescription (
  VisitID	varchar(9),
  PrescriptionID	varchar(9),
  PrescriptionName	varchar(15),
  FOREIGN KEY (VisitID) references PatientVisit(VisitID),
  FOREIGN KEY (PrescriptionID) references Prescription(PrescriptionID)
);

