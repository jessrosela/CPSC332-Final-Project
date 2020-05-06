<?php include 'HeaderFile.php';?>
<?php include 'ConnectionData.php';?>


<center>

<form action="<?php $_PHP_SELF ?>" method="POST">
<table width = "auto" border = "0" cellspacing = "2" 
                     cellpadding = "2" style="margin:30px 0px">
                  
                  <tr>
						<td width ="250">Search Appointments by Patient ID</td>
                           
                           <td width ="100"><input name = "search" type = "text" 
                           id = "search"></td>
                      
                        <td width = "50"> </td>
                        <td><input type = "submit" value = "Search Appointments"></td>
                     </tr>
                     </table>
</form>

<?php

if (isset($_POST['search'])){

$search = $_POST['search'];
$sql = "SELECT * FROM PatientAppointment WHERE PatientID = '$search' ORDER BY VisitDate asc";
$result = mysqli_query($conn,$sql);        
  
print "<pre>";
print "<table border=1, cellpadding=15px, style=margin:10px 10px>";
print "<tr><td> Visit ID </td><td> Patient ID </td><td> Date </td>
<td> Time </td><td> Doctor </td></tr>";

while($row = mysqli_fetch_array($result, MYSQLI_BOTH))
{
print "<tr><td> $row[VisitID] </td><td> $row[PatientID] </td><td> $row[VisitDate] </td>
<td> $row[VisitTime] </td><td> $row[DoctorName] </td></tr>";
}
print "</table>";
print "</pre>";
mysqli_free_result($result);
}

else{
$sql = "SELECT * FROM PatientAppointment ORDER BY VisitID asc";
$result = mysqli_query($conn,$sql);      

print "<pre>";
print "<table border=1, cellpadding=15px, style=margin:10px 10x>";
print "<tr><td> Visit ID </td><td> Patient ID </td><td> Date </td>
<td> Time </td><td> Doctor </td></tr>";
while($row = mysqli_fetch_array($result, MYSQLI_BOTH))

{
print "<tr><td> $row[VisitID] </td><td> $row[PatientID] </td><td> $row[VisitDate] </td>
<td> $row[VisitTime] </td><td> $row[DoctorName] </td></tr>";
}
print "</table>";
print "</pre>";
mysqli_free_result($result); 
}

mysqli_close($conn);
            
?>
</center>


