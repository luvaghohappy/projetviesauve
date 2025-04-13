<?php
// Informations de connexion à la base de données
$dbuser = "root";      // Nom d'utilisateur MySQL
$dbpass = "";          // Mot de passe MySQL
$host = "localhost";   // Nom d'hôte du serveur MySQL
$dbname = "sauvevie_db";  // Nom de la base de données

// Création d'une nouvelle connexion à la base de données
$connect = mysqli_connect($host, $dbuser, $dbpass, $dbname);

// Vérification de la réussite de la connexion
if ($connect->connect_error) {
    // Affichage d'un message d'erreur et arrêt du script en cas d'échec de connexion
    die("Connexion echoué: " . $connect->connect_error);
}

?>