<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

include('conn.php');

// Vérifier la connexion
if (!$connect) {
    echo json_encode(["status" => "failed", "error" => "Database connection failed"]);
    exit;
}

// Récupération des champs
$noms = $_POST['noms'] ?? null;
$email = $_POST['email'] ?? null;
$sexe = $_POST['sexe'] ?? null;
$code = $_POST['CODE'] ?? null;
$fonction = $_POST['Fonction'] ?? null;
$secteur_id = $_POST['secteur_id'] ?? null;
$service = $_POST['serviceType'] ?? null;
$mot_de_passe = $_POST['mot_de_passe'] ?? null;

// Vérifier les champs obligatoires
if (empty($noms) || empty($email) || empty($sexe) || empty($code) || empty($fonction) || empty($secteur_id) || empty($service) || empty($mot_de_passe)) {
    echo json_encode(["status" => "failed", "error" => "All fields are required."]);
    exit;
}

// Hacher le mot de passe
$hashed_password = password_hash($mot_de_passe, PASSWORD_DEFAULT);

// Préparer le dossier d'upload
$target_dir = "uploads/";
if (!file_exists($target_dir)) {
    mkdir($target_dir, 0777, true);
}

$image_path = null;

// 📷 Gestion de l'image
if (isset($_POST['image_base64'])) {
    // Cas 1: image envoyée en base64
    $base64_image = $_POST['image_base64'];
    $decoded_image = base64_decode($base64_image);

    if ($decoded_image === false) {
        echo json_encode(["status" => "failed", "error" => "Invalid base64 image data"]);
        exit;
    }

    $unique_name = uniqid('', true) . '.png';
    $image_path = $target_dir . $unique_name;

    if (!file_put_contents($image_path, $decoded_image)) {
        echo json_encode(["status" => "failed", "error" => "Error saving base64 image"]);
        exit;
    }
} elseif (isset($_FILES['image']) && $_FILES['image']['error'] === 0) {
    // Cas 2: image envoyée via $_FILES
    $unique_name = uniqid('', true) . '_' . basename($_FILES["image"]["name"]);
    $image_path = $target_dir . $unique_name;

    if (!move_uploaded_file($_FILES["image"]["tmp_name"], $image_path)) {
        echo json_encode(["status" => "failed", "error" => "Error uploading image file"]);
        exit;
    }
} else {
    echo json_encode(["status" => "failed", "error" => "No image uploaded"]);
    exit;
}

// 📄 Enregistrement dans la base de données
$stmt = $connect->prepare("INSERT INTO agents (noms, email, sexe, CODE, Fonction, secteur_id, serviceType, mot_de_passe, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");

if (!$stmt) {
    echo json_encode(["status" => "failed", "error" => "Database prepare failed: " . $connect->error]);
    exit;
}

$stmt->bind_param("sssssssss", $noms, $email, $sexe, $code, $fonction, $secteur_id, $service, $hashed_password, $image_path);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Agent enregistré avec succès",
        "image_path" => $image_path
    ]);
} else {
    echo json_encode(["status" => "failed", "error" => $stmt->error]);
}

$stmt->close();
$connect->close();
?>
