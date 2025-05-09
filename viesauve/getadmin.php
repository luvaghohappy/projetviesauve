<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

include('conn.php');

// Requête avec jointure + filtre sur la fonction
$rqt = "SELECT 
            a.noms, 
            a.email, 
            a.sexe, 
            a.Fonction, 
            a.CODE, 
            s.nom_secteur 
        FROM administrateurs a
        INNER JOIN secteurs s ON a.secteur_id = s.id_secteur
        WHERE a.Fonction = 'Administrateur'";

$rqt2 = mysqli_query($connect, $rqt) OR die("Erreur d'exécution de la requête : " . mysqli_error($connect));

$result = array();

while ($fetchData = $rqt2->fetch_assoc()) {
    $result[] = $fetchData;
}

echo json_encode($result);
?>
