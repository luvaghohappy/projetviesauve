<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    include('conn.php');

    // Récupération des données envoyées par la requête POST
    $data = json_decode(file_get_contents('php://input'), true);

    $id_user = $data['user_id'] ?? null;
    $message = $data['messages'] ?? null;
    $latitude = $data['latitude'] ?? null;
    $longitude = $data['longitude'] ?? null;
    $servicetype = $data['serviceType'] ?? null;
    $secteur_id = $data['secteur_id'] ?? null;
    $etat = 'nouvelle';  // Valeur par défaut

    // Vérification des données reçues
    if ($id_user && $message && $latitude && $longitude && $servicetype && $secteur_id) {
        
        // Préparation de la requête SQL
        $stmt = $connect->prepare("INSERT INTO alertes (user_id, messages, locations, serviceType, secteur_id, etat) VALUES (?, ?, ST_GeomFromText(?), ?, ?, ?)");
        
        // Création de la géométrie point pour la localisation
        $point = "POINT($longitude $latitude)";
        
        // Lier les paramètres
        $stmt->bind_param("ssssss", $id_user, $message, $point, $servicetype, $secteur_id, $etat);
        
        // Exécution de la requête
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'id' => $stmt->insert_id]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Erreur lors de l\'insertion']);
        }

        $stmt->close();
    } else {
        // Retourner une erreur si les données sont manquantes
        echo json_encode(['success' => false, 'message' => 'Données manquantes ou invalides']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Méthode de requête non autorisée']);
}
?>
