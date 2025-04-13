<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

include('conn.php');

if (isset($_GET['id_user'])) {
    $id_user = intval($_GET['id_user']);

    $stmt = $connect->prepare("SELECT image_path, email FROM utilisateurs WHERE id_user = ?");
    $stmt->bind_param("i", $id_user);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($data = $result->fetch_assoc()) {
        echo json_encode($data);
    } else {
        echo json_encode(["error" => "Utilisateur introuvable."]);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Paramètre 'id_user' manquant."]);
}
?>
