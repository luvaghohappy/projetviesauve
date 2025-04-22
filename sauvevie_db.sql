-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : mar. 22 avr. 2025 à 12:54
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
-- Structure de la table `administrateurs`
--

CREATE TABLE `administrateurs` (
  `id_admin` int(11) NOT NULL,
  `noms` varchar(100) NOT NULL,
  `sexe` enum('F','M') NOT NULL,
  `email` varchar(50) NOT NULL,
  `CODE` varchar(100) NOT NULL,
  `Fonction` enum('SuperAdmin','Administrateur') NOT NULL,
  `secteur_id` int(11) NOT NULL,
  `image_path` varchar(1000) NOT NULL,
  `mot_de_passe` varchar(255) NOT NULL,
  `createdAT` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `administrateurs`
--

INSERT INTO `administrateurs` (`id_admin`, `noms`, `sexe`, `email`, `CODE`, `Fonction`, `secteur_id`, `image_path`, `mot_de_passe`, `createdAT`) VALUES
(1, 'Happy Luvagho', '', 'happy@gmail.com', 'H23', 'SuperAdmin', 11, 'uploads/67ff9c18a1419.png', '$2y$10$52sHjjM062uRsDRD0vj7SuGGjaceFjrBioQ5H7FHS7BFhVwVmj9BG', '2025-04-16 12:01:29'),
(3, 'Martin Bahati', 'M', 'martin@gmail.com', 'H20', 'Administrateur', 8, 'uploads/680003b60a027.png', '$2y$10$I6wNEWqZHONdnESBcRgBzOBB01NVSAVM8U5ITU.2j8cXzj5Z6aw26', '2025-04-16 19:23:34'),
(4, 'Moise Muhindo', 'M', 'moise@gmail.com', 'H56', 'Administrateur', 5, 'uploads/680636b5e2366.png', '$2y$10$o7Eym1r/YAuskkorMsZQrOm25DIS/ks4.OHWUqRPO2DX3CWoz4zMy', '2025-04-21 12:14:46');

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
  `Fonction` enum('Operateur','Agent') NOT NULL,
  `serviceType` enum('Pompier','Police','Ambulancier','Chat') NOT NULL,
  `secteur_id` int(11) NOT NULL,
  `image_path` varchar(1000) DEFAULT NULL,
  `mot_de_passe` varchar(255) NOT NULL,
  `createdAT` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `agents`
--

INSERT INTO `agents` (`id_agent`, `noms`, `sexe`, `email`, `CODE`, `Fonction`, `serviceType`, `secteur_id`, `image_path`, `mot_de_passe`, `createdAT`) VALUES
(1, 'Furaha Kasoki', 'F', 'furaha@gmail.com', 'H17', 'Operateur', 'Police', 8, 'uploads/6801004c16ed1.png', '$2y$10$pA4oInvk59Y2UESMYHC8veLSvJgJeiSmAdQ5YfTXG8Ver86Dm5hkO', '2025-04-17 13:21:16'),
(2, 'Nathan Kibampe', 'M', 'nathan@gmail.com', 'H43', 'Operateur', 'Pompier', 5, 'uploads/6806382ed9aaa.png', '$2y$10$ZyjFOem2N6E6ZZGxLiGxWu/ghjUJaiI5J.aJRfPsYTa1in3FFUhZi', '2025-04-21 12:21:02');

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
  `secteur_id` int(11) NOT NULL,
  `etat` enum('nouvelle','en cours','déjà résolue') DEFAULT 'nouvelle',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `alertes`
--

INSERT INTO `alertes` (`id_alerte`, `user_id`, `messages`, `locations`, `serviceType`, `secteur_id`, `etat`, `created_at`) VALUES
(1, 3, 'Il y a un feu', 0x0000000001010000009a609390a30c3e401781b1be81a9febf, 'pompier', 5, 'nouvelle', '2025-04-21 11:44:06');

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

-- --------------------------------------------------------

--
-- Structure de la table `secteurs`
--

CREATE TABLE `secteurs` (
  `id_secteur` int(11) NOT NULL,
  `nom_secteur` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `secteurs`
--

INSERT INTO `secteurs` (`id_secteur`, `nom_secteur`) VALUES
(1, 'Kinshasa'),
(2, 'Lubumbashi'),
(3, 'Goma'),
(4, 'Butembo'),
(5, 'Lubero_Nord'),
(6, 'Lubero_Sud'),
(7, 'Beni'),
(8, 'Bunia'),
(9, 'Kisangani'),
(10, 'Bandundu'),
(11, 'RDC');

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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `secteur_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `utilisateurs`
--

INSERT INTO `utilisateurs` (`id_user`, `noms`, `sexe`, `date_naissance`, `adresse`, `telephone`, `email`, `etat_civil`, `groupe_sanguin`, `allergies`, `maladies`, `medicaments`, `contact_urgence_nom`, `contact_urgence_lien`, `contact_urgence_tel`, `mot_de_passe`, `image_path`, `created_at`, `secteur_id`) VALUES
(3, 'Abiga luvagho', 'Féminin', '2025-04-02', 'kirumba,zone', '09896325', 'abiga@gmail.com', 'Célibataire', 'B+', 'aucune', 'aucune', 'aucune', 'furaha', 'soeur', '098976543', '$2y$10$z4QUBT0./KV4Bxns7J72deBN/654VQP0N1Yt8RWNLWZzKfgpTK41G', 'uploads/Screenshot_20250325-203919.jpg', '2025-04-21 11:43:15', 5);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `administrateurs`
--
ALTER TABLE `administrateurs`
  ADD PRIMARY KEY (`id_admin`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `CODE` (`CODE`),
  ADD KEY `secteur_id` (`secteur_id`);

--
-- Index pour la table `agents`
--
ALTER TABLE `agents`
  ADD PRIMARY KEY (`id_agent`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `CODE` (`CODE`),
  ADD KEY `secteur_id` (`secteur_id`);

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
-- Index pour la table `secteurs`
--
ALTER TABLE `secteurs`
  ADD PRIMARY KEY (`id_secteur`);

--
-- Index pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  ADD PRIMARY KEY (`id_user`),
  ADD KEY `fk_secteur` (`secteur_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `administrateurs`
--
ALTER TABLE `administrateurs`
  MODIFY `id_admin` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `agents`
--
ALTER TABLE `agents`
  MODIFY `id_agent` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
-- AUTO_INCREMENT pour la table `secteurs`
--
ALTER TABLE `secteurs`
  MODIFY `id_secteur` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `administrateurs`
--
ALTER TABLE `administrateurs`
  ADD CONSTRAINT `administrateurs_ibfk_1` FOREIGN KEY (`secteur_id`) REFERENCES `secteurs` (`id_secteur`) ON DELETE CASCADE;

--
-- Contraintes pour la table `agents`
--
ALTER TABLE `agents`
  ADD CONSTRAINT `agents_ibfk_1` FOREIGN KEY (`secteur_id`) REFERENCES `secteurs` (`id_secteur`) ON DELETE CASCADE;

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

--
-- Contraintes pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  ADD CONSTRAINT `fk_secteur` FOREIGN KEY (`secteur_id`) REFERENCES `secteurs` (`id_secteur`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
