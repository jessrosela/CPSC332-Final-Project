<?php include 'HeaderFile.php';?>
<?php include 'ConnectionData.php';?>


<center>

<form action="<?php $_PHP_SELF ?>" method="POST">
<table width = "auto" border = "0" cellspacing = "2" 
                     cellpadding = "2" style="margin:30px 0px">
                  
                  <tr>
						<td width ="250">Search Prescriptions by Patient ID</td>
                           
                           <td width ="100"><input name = "search" type = "text" 
                           id = "search"></td>
                      
                        <td width = "50"> </td>
                        <td><input type = "submit" value = "Search Prescriptions"></td>
                     </tr>
                     </table>
</form>

<?php


if (isset($_POST['search'])){

$search = $_POST['search'];
$sql = "SELECT * FROM PatientPrescription WHERE PatientID = '$search'";
$result = mysqli_query($conn,$sql);        
  
print "<pre>";
print "<table border=1, cellpadding=15px, style=margin:10px 10px>";
print "<tr><td> Date </td><td> Visit ID </td><td> Prescription Number </td>
<td> Prescription Name </td><td> Patient ID </td>";

while($row = mysqli_fetch_array($result, MYSQLI_BOTH))
{
print "\n";
print "<tr><td> $row[VisitDate] </td><td> $row[VisitID] </td><td> $row[PrescriptionID] </td>
<td> $row[PrescriptionName] </td><td> $row[PatientID] </td></tr>";
}
print "</table>";
print "</pre>";
mysqli_free_result($result);
}

mysqli_close($conn);
            
?>
</center>




