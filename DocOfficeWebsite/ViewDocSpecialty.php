<?php include 'HeaderFile.php';?>
<?php include 'ConnectionData.php';?>



<?php
if(isset($_POST['add'])) {
if(! get_magic_quotes_gpc() ) {
	$DoctorID = addslashes ($_POST['DoctorID']);
	$SpecialtyID = addslashes ($_POST['SpecialtyID']);
}else {

    $DoctorID = $_POST['DoctorID'];
	$SpecialtyID = $_POST['SpecialtyID'];
}
            
$sql = "INSERT INTO DoctorSpecialty ". "(DoctorID, SpecialtyID) ". 
"VALUES('$DoctorID','$SpecialtyID')";
       
$result = mysqli_query($conn,$sql);        
    
            
echo "<br><br>Entered data successfully\n<br>";
}else{}
            
?>

<form action="<?php $_PHP_SELF ?>" method="post">
<table width = "auto" border = "0" cellspacing = "2" 
                     cellpadding = "2" style="margin:30px 10px">
                  
                     <tr>
                        <td width = "100">Doctor ID</td>
                        <td><input name = "DoctorID" type = "text" 
                           id = "DoctorID"></td>
                     </tr>                  
                     <tr>
                        <td width = "100">Specialty ID</td>
                        <td><input name = "SpecialtyID" type = "text" 
                           id = "SpecialtyID"></td>
                     </tr>
                     <tr>
                        <td width = "100"> </td>
                        <td><input name = "add" type = "submit" id = "add" 
                              value = "Add Doctor Specialty"></td>
                     </tr>
                  
                  </table>
               </form>



<center>


<?php

$sql = "SELECT * FROM DocSpecialty ORDER BY FirstName asc";
$result = mysqli_query($conn,$sql);

print "<pre>";
print "<table border=1, cellpadding=15px, style=margin:10px 10x>";
print "<tr><td> First Name </td><td> Last Name </td><td> Specialty ID </td>";
while($row = mysqli_fetch_array($result, MYSQLI_BOTH))

{
print "\n";
print "<tr><td> $row[FirstName] </td><td> $row[LastName] </td><td> $row[SpecialtyID] </td></tr>";
}
print "</table>";
print "</pre>";
mysqli_free_result($result);
mysqli_close($conn);
?>

</center>