<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json"); // Important pour la réponse JSON

include('conn.php');

// Récupération des paramètres
$serviceType = $_GET['serviceType'] ?? '';
$secteurId = $_GET['secteur_id'] ?? '';

if (empty($serviceType) || empty($secteurId)) {
    http_response_code(400);
    echo json_encode(["error" => "Paramètres manquants"]);
    exit;
}

// Log de debug (peut être consulté dans error_log du serveur)
error_log("serviceType reçu: $serviceType | secteurId reçu: $secteurId");

// Requête SQL
$rqt = "SELECT user_id, messages, ST_AsText(locations) as locations, etat, created_at 
        FROM alertes 
        WHERE serviceType = ? AND secteur_id = ?
        ORDER BY id_alerte DESC";

$stmt = $connect->prepare($rqt);

if (!$stmt) {
    http_response_code(500);
    echo json_encode(["error" => "Erreur préparation SQL"]);
    exit;
}

$stmt->bind_param("si", $serviceType, $secteurId);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode(["error" => "Erreur exécution SQL"]);
    exit;
}

$resultat = $stmt->get_result();

$result = [];
while ($fetchData = $resultat->fetch_assoc()) {
    $result[] = $fetchData;
}

// Log du nombre de résultats
error_log("Nombre d'alertes trouvées : " . count($result));

echo json_encode($result);
?>
