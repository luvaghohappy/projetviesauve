<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: *");

include('conn.php');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $secteur_id = $_POST['secteur_id'] ?? null;
    $fonction = $_POST['fonction'] ?? '';

    if (!$secteur_id || $fonction !== 'Administrateur') {
        echo json_encode([
            "status" => "error",
            "message" => "Accès non autorisé ou données manquantes"
        ]);
        exit;
    }

    // Compter les utilisateurs du secteur
    $sqlUtilisateurs = "SELECT COUNT(*) as total_utilisateurs FROM utilisateurs WHERE secteur_id = ?";
    $stmtU = $connect->prepare($sqlUtilisateurs);
    $stmtU->bind_param("i", $secteur_id);
    $stmtU->execute();
    $resU = $stmtU->get_result()->fetch_assoc();

    // Compter les agents du secteur
    $sqlAgents = "SELECT COUNT(*) as total_agents FROM agents WHERE secteur_id = ?";
    $stmtA = $connect->prepare($sqlAgents);
    $stmtA->bind_param("i", $secteur_id);
    $stmtA->execute();
    $resA = $stmtA->get_result()->fetch_assoc();

    // Compter les alertes du secteur
    $sqlAlertes = "SELECT COUNT(*) as total_alertes FROM alertes WHERE secteur_id = ?";
    $stmtAl = $connect->prepare($sqlAlertes);
    $stmtAl->bind_param("i", $secteur_id);
    $stmtAl->execute();
    $resAl = $stmtAl->get_result()->fetch_assoc();

    // Résultat final
    $result = [
        "status" => "success",
        "utilisateurs" => $resU['total_utilisateurs'],
        "agents" => $resA['total_agents'],
        "alertes" => $resAl['total_alertes']
    ];

    echo json_encode($result);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Méthode non autorisée"
    ]);
}
?>
