<?php include 'HeaderFile.php';?>
<?php include 'ConnectionData.php';?>

<center>
<?php

$sql = "SELECT * FROM DocVicodin ORDER BY FirstName";
$result = mysqli_query($conn,$sql);

print "<pre>";
print "<table border=1, cellpadding=15px, style=margin:150px 10px>";
print "<tr><td>First Name </td><td> Last Name </td>";
while($row = mysqli_fetch_array($result, MYSQLI_BOTH))
{
print "\n";
print "<tr><td>$row[FirstName] </td><td> $row[LastName]  </td></tr>	";
}
print "</table>";
print "</pre>";
mysqli_free_result($result);
mysqli_close($conn);
?>

</center>



