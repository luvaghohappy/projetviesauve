<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
header('Content-Type: application/json');

ini_set('display_errors', 1);
error_reporting(E_ALL);

include('conn.php');
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

$table = $_GET['table'] ?? null;
$secteur = $_GET['secteur'] ?? null;
$allowedTables = ['utilisateurs', 'agents', 'alertes', 'administrateurs'];

if (!$table || !in_array($table, $allowedTables)) {
    echo json_encode(['error' => 'Table invalide ou manquante']);
    exit;
}

$data = [];

try {
    if ($table === 'utilisateurs') {
        $query = "
            SELECT 
                u.id_user, u.noms, u.sexe, u.date_naissance, u.adresse, u.telephone, u.email,
                u.etat_civil, u.groupe_sanguin, u.allergies, u.maladies, u.medicaments,
                u.contact_urgence_nom, u.contact_urgence_lien, u.contact_urgence_tel, u.created_at,
                s.nom_secteur
            FROM utilisateurs u
            LEFT JOIN secteurs s ON u.secteur_id = s.id_secteur
        ";

        if ($secteur) {
            $query .= " WHERE s.nom_secteur = ?";
            $stmt = $connect->prepare($query);
            $stmt->bind_param("s", $secteur);
            $stmt->execute();
            $result = $stmt->get_result();
        } else {
            $result = $connect->query($query);
        }

        $stmtEnfants = $connect->prepare("SELECT * FROM enfants WHERE fk_id_user = ?");

        while ($user = $result->fetch_assoc()) {
            $userId = $user['id_user'];
            unset($user['id_user']); // Masquer l'id_user

            // Récupérer enfants
            $stmtEnfants->bind_param("i", $userId);
            $stmtEnfants->execute();
            $resEnfants = $stmtEnfants->get_result();
            $enfants = [];

            while ($child = $resEnfants->fetch_assoc()) {
                $enfants[] = $child;
            }

            $user['enfants'] = $enfants;
            $data[] = $user;
        }

    } elseif ($table === 'agents') {
        $query = "
            SELECT 
                a.id_agent, a.noms, a.email, a.sexe, a.Fonction, a.CODE, a.serviceType,
                s.nom_secteur
            FROM agents a
            LEFT JOIN secteurs s ON a.secteur_id = s.id_secteur
        ";

        if ($secteur) {
            $query .= " WHERE s.nom_secteur = ?";
            $stmt = $connect->prepare($query);
            $stmt->bind_param("s", $secteur);
            $stmt->execute();
            $result = $stmt->get_result();
        } else {
            $result = $connect->query($query);
        }

        while ($agent = $result->fetch_assoc()) {
            unset($agent['mot_de_passe']);
            $data[] = $agent;
        }

    } elseif ($table === 'alertes') {
        $query = "
          SELECT al.user_id, al.messages, ST_AsText(locations) as location, al.etat, al.created_at, s.nom_secteur
          FROM alertes al
          LEFT JOIN secteurs s ON al.secteur_id = s.id_secteur
        ";

        if ($secteur) {
            $query .= " WHERE s.nom_secteur = ?";
            $stmt = $connect->prepare($query);
            $stmt->bind_param("s", $secteur);
            $stmt->execute();
            $result = $stmt->get_result();
        } else {
            $result = $connect->query($query);
        }

        while ($alerte = $result->fetch_assoc()) {
            $data[] = $alerte;
        }

    } elseif ($table === 'administrateurs') {
        $query = "
            SELECT  ad.noms, ad.email, ad.sexe, ad.CODE, ad.Fonction,
            FROM administrateurs ad
            WHERE Fonction != 'SuperAdmin'
            LEFT JOIN secteurs s ON ad.secteur_id = s.id_secteur
        ";

        if ($secteur) {
            $query .= " WHERE s.nom_secteur = ?"; 
            $stmt = $connect->prepare($query);
            $stmt->bind_param("s", $secteur);
            $stmt->execute();
            $result = $stmt->get_result();
        } else {
            $result = $connect->query($query);
        }

        while ($admin = $result->fetch_assoc()) {
            // Ne pas inclure mot_de_passe
            $data[] = $admin;
        }
    }

    echo json_encode($data);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
