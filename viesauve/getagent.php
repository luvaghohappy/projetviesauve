<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include('conn.php');

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode([
        "success" => false,
        "message" => "Aucune donnée reçue ou JSON invalide."
    ]);
    exit;
}

$code_ou_noms = $data['identifiant'];
$mot_de_passe = $data['mot_de_passe'];

// Recherche dans agents
$stmt1 = $connect->prepare("SELECT * FROM agents WHERE LOWER(noms) = LOWER(?) OR LOWER(CODE) = LOWER(?)");
$stmt1->bind_param("ss", $code_ou_noms, $code_ou_noms);
$stmt1->execute();
$result1 = $stmt1->get_result();
$agent = $result1->fetch_assoc();

// Recherche dans administrateurs
$stmt2 = $connect->prepare("SELECT * FROM administrateurs WHERE LOWER(noms) = LOWER(?) OR LOWER(CODE) = LOWER(?)");
$stmt2->bind_param("ss", $code_ou_noms, $code_ou_noms);
$stmt2->execute();
$result2 = $stmt2->get_result();
$admin = $result2->fetch_assoc();

if ($agent && password_verify($mot_de_passe, $agent['mot_de_passe'])) {
    if (strtolower($agent["Fonction"]) === "operateur") {
        echo json_encode([
            "success" => true,
            "role" => $agent["Fonction"],
            "user" => $agent
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Accès réservé aux opérateurs uniquement."
        ]);
    }
} elseif ($admin && password_verify($mot_de_passe, $admin['mot_de_passe'])) {
    echo json_encode([
        "success" => true,
        "role" => $admin["Fonction"],
        "user" => $admin
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Identifiants incorrects."
    ]);
}

$connect->close();
?>
