<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header('Content-Type: application/json');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include('conn.php');
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

try {
    $secteurId = isset($_POST['secteur_id']) ? intval($_POST['secteur_id']) : 0;
    $fonction = isset($_POST['fonction']) ? $_POST['fonction'] : '';

    if ($secteurId === 0 || $fonction === '') {
        throw new Exception("Secteur ID ou fonction manquante");
    }

    // Récupérer les utilisateurs de ce secteur
    $stmt = $connect->prepare("
        SELECT 
            u.id_user, u.noms, u.sexe, u.date_naissance, u.adresse, u.telephone, u.email,
            u.etat_civil, u.groupe_sanguin, u.allergies, u.maladies, u.medicaments,
            u.contact_urgence_nom, u.contact_urgence_lien, u.contact_urgence_tel,
            s.nom_secteur
        FROM utilisateurs u
        INNER JOIN secteurs s ON u.secteur_id = s.id_secteur
        WHERE u.secteur_id = ?
    ");
    $stmt->bind_param("i", $secteurId);
    $stmt->execute();
    $result = $stmt->get_result();

    $utilisateurs = [];

    while ($user = $result->fetch_assoc()) {
        $userId = $user['id_user'];

        // Récupérer les enfants pour cet utilisateur
        $stmtChildren = $connect->prepare("SELECT * FROM enfants WHERE fk_id_user = ?");
        $stmtChildren->bind_param("i", $userId);
        $stmtChildren->execute();
        $resultChildren = $stmtChildren->get_result();

        $children = [];
        while ($child = $resultChildren->fetch_assoc()) {
            $children[] = $child;
        }

        $user['enfants'] = $children;
        $utilisateurs[] = $user;
    }

    echo json_encode($utilisateurs);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
}
