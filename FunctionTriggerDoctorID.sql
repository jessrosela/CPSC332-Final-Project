USE DocOffice;

DROP FUNCTION IF EXISTS CreateDoctorID
DELIMITER $$
CREATE FUNCTION CreateDoctorID(DocPersonID varchar(9))
RETURNS varchar(9) DETERMINISTIC
BEGIN 
DECLARE NEWDoctorID varchar(9);
DECLARE FirstName varchar(25);

SET FirstName=( 
SELECT
Person.FirstName FROM Person
WHERE PersonID=DocPersonID
);
SET NEWDoctorID=CONCAT (LEFT(FirstName, 2),RIGHT(DocPersonID,7));

RETURN (NEWDoctorID);
END$$
DELIMITER ;


DROP TRIGGER IF EXISTS TRIG_DoctorID;
CREATE TRIGGER TRIG_DoctorID
BEFORE INSERT ON Doctor 
FOR EACH ROW
    INSERT INTO Doctor(DoctorID, MedicalDegrees, PersonID)
    VALUES  (SET DoctorID=(CreateDoctorID(NEW.PersonID), SET MedicalDegrees=NEW.MedicalDegrees, SET PersonID=NEW.PersonID);
    
    
INSERT INTO Doctor(MedicalDegrees, PersonID) VALUES ("MD", 222222201);

SELECT *
FROM Doctor;
    
