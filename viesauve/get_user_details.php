<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

ini_set('display_errors', 1);
error_reporting(E_ALL);

include('conn.php'); // ce fichier doit initialiser $connect (mysqli)

$user_id = $_POST['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(['error' => 'Paramètre user_id manquant']);
    exit;
}

// Requête pour obtenir les détails de l'utilisateur
$stmtUser = $connect->prepare("SELECT noms, sexe, date_naissance, adresse, telephone, email, etat_civil, groupe_sanguin,allergies, maladies, medicaments, contact_urgence_nom, contact_urgence_lien, contact_urgence_tel, image_path FROM utilisateurs WHERE id_user = ?");
$stmtUser->bind_param("i", $user_id);
$stmtUser->execute();
$resultUser = $stmtUser->get_result();
$user = $resultUser->fetch_assoc();

// Requête pour obtenir les enfants de l'utilisateur
$stmtChildren = $connect->prepare("SELECT * FROM enfants WHERE fk_id_user = ?");
$stmtChildren->bind_param("i", $user_id);
$stmtChildren->execute();
$resultChildren = $stmtChildren->get_result();
$children = [];

while ($row = $resultChildren->fetch_assoc()) {
    $children[] = $row;
}

// Retourner les données en JSON
echo json_encode([
    'utilisateur' => $user,
    'enfants' => $children
]);
?>
