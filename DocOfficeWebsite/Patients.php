<?php include 'HeaderFile.php';?>
<?php include 'ConnectionData.php';?>


<center>

<form action="<?php $_PHP_SELF ?>" method="POST">
<table width = "auto" border = "0" cellspacing = "2" 
                     cellpadding = "2" style="margin:30px 0px">
                  
                  <tr>
						<td width ="250">Enter Patient ID</td>
                           
                           <td width ="100"><input name = "search" type = "text" 
                           id = "search"></td>
                      
                        <td width = "50"> </td>
                        <td><input type = "submit" value = "Search Patient Information"></td>
                     </tr>
                     </table>
</form>

<?php


if (isset($_POST['search']))
{

/* --------------------
Prescriptions
 ---------------------*/
$search = $_POST['search'];
$sql = "SELECT * FROM PatientPrescription WHERE PatientID = '$search'";
$result = mysqli_query($conn,$sql);        
  
print "<pre>";
print "<table border=1, cellpadding=15px, style=margin:10px 10px>";
print "<tr><th colspan=5> Prescriptions </th></tr>";
print "<tr><td> Patient ID </td><td> Visit Date </td><td> Visit Date </td>
<td> PrescriptionID </td><td> Prescription Name </td>";

while($row = mysqli_fetch_array($result, MYSQLI_BOTH))
{
print "\n";
print "<tr><td> $row[PatientID] </td><td> $row[VisitDate] </td><td> $row[VisitID] </td>
<td> $row[PrescriptionID] </td><td> $row[PrescriptionName] </td></tr>";
}
print "</table>";
print "</pre>";
mysqli_free_result($result);


/* --------------------
Appointments
 ---------------------*/
$sql = "SELECT * FROM PatientAppointment WHERE PatientID = '$search' ORDER BY VisitDate asc";
$result = mysqli_query($conn,$sql);        
  
print "<pre>";
print "<table border=1, cellpadding=15px, style=margin:10px 10px>";
print "<tr><th colspan=5> Appointments </th></tr>";
print "<tr><td> PatientID </td><td> Visit Date </td><td> Visit Time </td>
<td> Visit ID </td><td> Doctor </td></tr>";

while($row = mysqli_fetch_array($result, MYSQLI_BOTH))
{
print "<tr><td> $row[PatientID] </td><td> $row[VisitDate] </td><td> $row[VisitTime] </td>
<td> $row[VisitID] </td><td> $row[DoctorName] </td></tr>";
}
{
print "</table>";
print "</pre>";
mysqli_free_result($result);
}


/* --------------------

Tests 
 ---------------------*/
$sql = "SELECT * FROM PatientTest WHERE PatientID = '$search' ORDER BY VisitDate asc";
$result = mysqli_query($conn,$sql);        
  
print "<pre>";
print "<table border=1, cellpadding=15px, style=margin:10px 10px>";
print "<tr><th colspan=5> Tests </th></tr>";
print "<tr><td> Patient ID </td><td> Test Date </td><td> Visit ID </td>
<td> Test ID </td><td> Test Name </td></tr>";

while($row = mysqli_fetch_array($result, MYSQLI_BOTH))
{
print "<tr><td> $row[PatientID] </td><td> $row[VisitDate] </td><td> $row[VisitID] </td>
<td> $row[TestID] </td><td> $row[TestName] </td></tr>";
}
print "</table>";
print "</pre>";
mysqli_free_result($result);
}
            
?>
</center>




