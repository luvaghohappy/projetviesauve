-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : sam. 12 avr. 2025 à 18:25
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `sauvevie_db`
--

-- --------------------------------------------------------

--
-- Structure de la table `agents`
--

CREATE TABLE `agents` (
  `id_agent` int(11) NOT NULL,
  `noms` varchar(100) NOT NULL,
  `sexe` enum('F','M') NOT NULL,
  `email` varchar(50) NOT NULL,
  `CODE` varchar(100) NOT NULL,
  `Fonction` enum('SuperAdmin','Administrateur','Operateur','Agent') NOT NULL,
  `serviceType` enum('pompier','police','ambulance','chat') NOT NULL,
  `mot_de_passe` varchar(50) NOT NULL,
  `createdAT` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `alertes`
--

CREATE TABLE `alertes` (
  `id_alerte` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `messages` text NOT NULL,
  `locations` point NOT NULL,
  `serviceType` enum('ambulance','police','pompier','chat') NOT NULL,
  `etat` enum('nouvelle','en cours','déjà résolue') DEFAULT 'nouvelle',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `alertes`
--

INSERT INTO `alertes` (`id_alerte`, `user_id`, `messages`, `locations`, `serviceType`, `etat`, `created_at`) VALUES
(1, 1, 'Il y a un voleur', 0x0000000001010000005a400d84090e3e40dc7f098101a9febf, 'police', 'nouvelle', '2025-04-12 15:39:06');

-- --------------------------------------------------------

--
-- Structure de la table `enfants`
--

CREATE TABLE `enfants` (
  `id_enfant` int(11) NOT NULL,
  `fk_id_user` int(11) DEFAULT NULL,
  `noms` varchar(100) DEFAULT NULL,
  `date_naissance` date DEFAULT NULL,
  `sexe` enum('M','F') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `enfants`
--

INSERT INTO `enfants` (`id_enfant`, `fk_id_user`, `noms`, `date_naissance`, `sexe`) VALUES
(1, 1, 'abiga luvagho', '2025-04-12', 'F');

-- --------------------------------------------------------

--
-- Structure de la table `utilisateurs`
--

CREATE TABLE `utilisateurs` (
  `id_user` int(11) NOT NULL,
  `noms` varchar(100) NOT NULL,
  `sexe` enum('Masculin','Féminin') NOT NULL,
  `date_naissance` date NOT NULL,
  `adresse` text NOT NULL,
  `telephone` varchar(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `etat_civil` enum('Célibataire','Marié(e)','Divorcé(e)','Veuf(ve)') NOT NULL,
  `groupe_sanguin` enum('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
  `allergies` text DEFAULT NULL,
  `maladies` text DEFAULT NULL,
  `medicaments` text DEFAULT NULL,
  `contact_urgence_nom` varchar(100) DEFAULT NULL,
  `contact_urgence_lien` varchar(50) DEFAULT NULL,
  `contact_urgence_tel` varchar(20) DEFAULT NULL,
  `mot_de_passe` varchar(255) NOT NULL,
  `image_path` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `utilisateurs`
--

INSERT INTO `utilisateurs` (`id_user`, `noms`, `sexe`, `date_naissance`, `adresse`, `telephone`, `email`, `etat_civil`, `groupe_sanguin`, `allergies`, `maladies`, `medicaments`, `contact_urgence_nom`, `contact_urgence_lien`, `contact_urgence_tel`, `mot_de_passe`, `image_path`, `created_at`) VALUES
(1, 'Kasoki luvagho furaha', 'Féminin', '2025-04-01', 'Majengo', '0999582152', 'happyluvagho@gmail.com', 'Marié(e)', 'A+', 'Aucune', 'Aucune', 'Aucune', 'Martin', 'frère', '09876545', '$2y$10$vSeMlLky2ctQoUZGG6WLx..zRzFbxW/FEN5KpIAhcda51V8Jfo4C.', 'uploads/20250318_104115.jpg', '2025-04-12 15:05:07');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `agents`
--
ALTER TABLE `agents`
  ADD PRIMARY KEY (`id_agent`);

--
-- Index pour la table `alertes`
--
ALTER TABLE `alertes`
  ADD PRIMARY KEY (`id_alerte`),
  ADD KEY `user_id` (`user_id`);

--
-- Index pour la table `enfants`
--
ALTER TABLE `enfants`
  ADD PRIMARY KEY (`id_enfant`),
  ADD KEY `fk_id_user` (`fk_id_user`);

--
-- Index pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  ADD PRIMARY KEY (`id_user`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `agents`
--
ALTER TABLE `agents`
  MODIFY `id_agent` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `alertes`
--
ALTER TABLE `alertes`
  MODIFY `id_alerte` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `enfants`
--
ALTER TABLE `enfants`
  MODIFY `id_enfant` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `alertes`
--
ALTER TABLE `alertes`
  ADD CONSTRAINT `alertes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `utilisateurs` (`id_user`);

--
-- Contraintes pour la table `enfants`
--
ALTER TABLE `enfants`
  ADD CONSTRAINT `enfants_ibfk_1` FOREIGN KEY (`fk_id_user`) REFERENCES `utilisateurs` (`id_user`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
