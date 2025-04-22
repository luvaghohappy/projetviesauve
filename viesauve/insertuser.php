<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
include('conn.php');

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
    http_response_code(405);
    echo json_encode(["status" => "failed", "error" => "Méthode non autorisée."]);
    exit;
}

// Filtrage des entrées
$noms = trim(htmlspecialchars($_POST["noms"]));
$sexe = trim(htmlspecialchars($_POST["sexe"]));
$date_naissance = trim($_POST["date_naissance"]);
$adresse = trim(htmlspecialchars($_POST["adresse"]));
$secteur_id = trim(htmlspecialchars($_POST["secteur_id"]));
$telephone = trim($_POST["telephone"]);
$email = trim($_POST["email"]);
$etat_civil = trim(htmlspecialchars($_POST["etat_civil"]));
$groupe_sanguin = trim(htmlspecialchars($_POST["groupe_sanguin"]));
$allergies = trim(htmlspecialchars($_POST["allergies"] ?? ''));
$maladies = trim(htmlspecialchars($_POST["maladies"] ?? ''));
$medicaments = trim(htmlspecialchars($_POST["medicaments"] ?? ''));
$enfants = isset($_POST["enfants"]) ? json_decode($_POST["enfants"], true) : [];
$contact_urgence_nom = trim(htmlspecialchars($_POST["contact_urgence_nom"] ?? ''));
$contact_urgence_lien = trim(htmlspecialchars($_POST["contact_urgence_lien"] ?? ''));
$contact_urgence_tel = trim($_POST["contact_urgence_tel"]);
$mot_de_passe = trim($_POST["mot_de_passe"]);
$conf_passe = trim($_POST["conf_passe"]);

// Vérification des champs obligatoires
if (empty($noms) || empty($sexe) || empty($date_naissance) || empty($adresse) || empty($secteur_id) || empty($telephone) || empty($email) || empty($etat_civil) || empty($groupe_sanguin) || empty($mot_de_passe) || empty($conf_passe)) {
    http_response_code(400);
    echo json_encode(["status" => "failed", "error" => "Tous les champs obligatoires doivent être remplis."]);
    exit;
}

// Validation de l'email et du téléphone
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(["status" => "failed", "error" => "Format d'email invalide."]);
    exit;
}
if (!ctype_digit($telephone)) {
    http_response_code(400);
    echo json_encode(["status" => "failed", "error" => "Numéro de téléphone invalide."]);
    exit;
}

// Vérification de l'unicité de l'email et du téléphone
$checkQuery = "SELECT id_user FROM utilisateurs WHERE email = ? OR telephone = ?";
$stmt = $connect->prepare($checkQuery);
$stmt->bind_param("ss", $email, $telephone);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    http_response_code(409);
    echo json_encode(["status" => "failed", "error" => "L'email ou le téléphone est déjà utilisé."]);
    exit;
}
$stmt->close();

// Vérification des mots de passe
if ($mot_de_passe !== $conf_passe) {
    http_response_code(400);
    echo json_encode(["status" => "failed", "error" => "Les mots de passe ne correspondent pas."]);
    exit;
}

// Hachage du mot de passe
$hashed_password = password_hash($mot_de_passe, PASSWORD_DEFAULT);

// Gestion du téléchargement de l'image
$upload_dir = "uploads/";
if (!file_exists($upload_dir)) {
    mkdir($upload_dir, 0777, true);
}

$target_file = $upload_dir . basename($_FILES["image"]["name"]);
$imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

$check = getimagesize($_FILES["image"]["tmp_name"]);
if ($check !== false) {
    if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
        try {
            // Insertion des données utilisateur
            $stmt = $connect->prepare("INSERT INTO utilisateurs (noms, sexe, date_naissance, adresse, secteur_id, telephone, email, etat_civil, groupe_sanguin,allergies, maladies, medicaments, contact_urgence_nom, contact_urgence_lien, contact_urgence_tel, mot_de_passe, image_path)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            
            if ($stmt === false) {
                die("Erreur dans la requête prepare: " . $connect->error);
            }
            
            $stmt->bind_param("sssssssssssssssss", $noms, $sexe, $date_naissance, $adresse, $secteur_id, $telephone, $email, $etat_civil, $groupe_sanguin, $allergies, $maladies, $medicaments, $contact_urgence_nom, $contact_urgence_lien, $contact_urgence_tel, $hashed_password, $target_file);
            
               if ($stmt->execute()) {
                 $id_user = $connect->insert_id;

               // Insertion des enfants
               if (!empty($enfants)) {
                // Préparer la requête SQL pour insérer les enfants
                $stmt_child = $connect->prepare("INSERT INTO enfants (fk_id_user, noms, date_naissance, sexe) VALUES (?, ?, ?, ?)");
                
                // Vérifier si la préparation a échoué
                if ($stmt_child === false) {
                    // Afficher l'erreur si la préparation échoue
                    die('Erreur de préparation de la requête : ' . $connect->error);
                }
            
                // Boucler à travers les enfants et insérer les données
                foreach ($enfants as $enfant) {
                    $nom_enfant = trim(htmlspecialchars($enfant["noms"]));
                    $sexe_enfant = trim(htmlspecialchars($enfant["sexe"]));
                    $date_naissance_enfant = trim($enfant["date_naissance"]);
                    if (!empty($nom_enfant) && !empty($date_naissance_enfant)) {
            
                        $stmt_child->bind_param("isss", $id_user, $nom_enfant, $date_naissance_enfant, $sexe_enfant);
                        
                        if (!$stmt_child->execute()) {
                         
                            die('Erreur lors de l\'exécution de la requête : ' . $stmt_child->error);
                        }
                    }
                }
                   $stmt_child->close();
                }     
                echo json_encode([
                    "success" => true,
                    "id_user" => $id_user,
                    "secteur_id" => $secteur_id
                  ]);                  
                } else {
                http_response_code(500);
                echo json_encode(["status" => "failed", "error" => "Erreur lors de l'insertion dans la base de données."]);
                }
            
            $stmt->close();
        } catch (Exception $e) {
            echo json_encode(["status" => "failed", "error" => $e->getMessage()]);
        }
    } else {
        echo json_encode(["status" => "failed", "error" => "Erreur lors du téléchargement de l'image."]);
    }
} else {
    echo json_encode(["status" => "failed", "error" => "Le fichier n'est pas une image valide."]);
}

$connect->close();
?>
