<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

include('conn.php');

$rqt = "SELECT nom_secteur FROM secteurs ORDER BY id_secteur DESC";
$rqt2 = mysqli_query($connect, $rqt) OR die("Erreur d'exécution : " . mysqli_error($connect));

$result = array();
while ($fetchData = $rqt2->fetch_assoc()) {
    $result[] = $fetchData['nom_secteur'];
}

echo json_encode($result);
?>
