<?php

$servername= '127.0.0.1';
$username= "root";
$password= "";


$conn=mysqli_connect($servername,$username,$password) or die("Unable to connect to host $servername"); 

$dbName= "DocOffice";
mysqli_select_db($conn, $dbName) or die ("Unable to select database $dbName");

?> 
