<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: *");
header('Content-Type: application/json');

include('conn.php');

error_reporting(E_ALL);
ini_set('display_errors', 1);

$data = json_decode(file_get_contents("php://input"));

$noms = $data->noms;
$password = $data->mot_de_passe;

$rqt = "SELECT id_user, noms, email, image_path, mot_de_passe FROM utilisateurs WHERE noms = ?";
$stmt = mysqli_prepare($connect, $rqt);
mysqli_stmt_bind_param($stmt, "s", $noms);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if ($user = mysqli_fetch_assoc($result)) {
    $hashed_password = $user['mot_de_passe'];

    if (password_verify($password, $hashed_password)) {
        unset($user['mot_de_passe']); // Sécurité

        $response = [
            "success" => true,
            "message" => "Authentification réussie",
            "id_user" => $user["id_user"],
            "noms" => $user["noms"],
            "email" => $user["email"],
            "image_path" => $user["image_path"] ?? null
        ];
    } else {
        $response = ["success" => false, "message" => "Nom ou mot de passe incorrect"];
    }
} else {
    $response = ["success" => false, "message" => "Nom ou mot de passe incorrect"];
}

echo json_encode($response);
?>
