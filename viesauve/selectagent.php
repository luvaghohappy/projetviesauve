<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

include('conn.php');

// Récupération des données
$secteur_id = isset($_POST['secteur_id']) ? intval($_POST['secteur_id']) : 0;
$fonction = isset($_POST['fonction']) ? $_POST['fonction'] : '';

// Logs pour débogage
error_log("secteur_id reçu: " . $secteur_id);
error_log("fonction reçue: " . $fonction);

// Vérification de la fonction
if ($fonction === '') {
    echo json_encode(["error" => "Fonction non spécifiée"]);
    exit;
}

$result = array();

if ($fonction === "SuperAdmin") {
    // SuperAdmin : tous les agents
    $query = "SELECT 
                a.noms, 
                a.email, 
                a.sexe, 
                a.Fonction, 
                a.CODE, 
                a.serviceType,
                s.nom_secteur 
              FROM agents a
              INNER JOIN secteurs s ON a.secteur_id = s.id_secteur";

    $stmt = $connect->prepare($query);
} else {
    // Administrateur ou autre : filtrer par secteur
    if ($secteur_id === 0) {
        echo json_encode(["error" => "Secteur ID manquant ou invalide"]);
        exit;
    }

    $query = "SELECT 
                a.noms, 
                a.email, 
                a.sexe, 
                a.Fonction, 
                a.CODE, 
                a.serviceType,
                s.nom_secteur 
              FROM agents a
              INNER JOIN secteurs s ON a.secteur_id = s.id_secteur
              WHERE a.secteur_id = ?";

    $stmt = $connect->prepare($query);
    $stmt->bind_param("i", $secteur_id);
}

// Exécution
if ($stmt->execute()) {
    $resultData = $stmt->get_result();
    while ($row = $resultData->fetch_assoc()) {
        $result[] = $row;
    }
    echo json_encode($result);
} else {
    echo json_encode(["error" => "Erreur d'exécution : " . $stmt->error]);
}

$stmt->close();
$connect->close();
?>
