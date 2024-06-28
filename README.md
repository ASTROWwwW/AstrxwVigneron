# 🍇 Script Vigneron pour ESX LEGACY 🍷

## Introduction

Ce script ajoute un métier complet pour les vignerons dans le framework ESX pour FiveM. Il inclut des fonctionnalités pour commencer les services, vendre des produits, et gérer les employés avec des intégrations de webhook Discord pour les notifications.

## Vidéo 
📺 Une vidéo YouTube est disponble pour vous montrer une preview!
lien : https://www.youtube.com/watch?v=WhlAe9L0Muw


## Fonctionnalités

### Fonctionnalités Générales

- 🚗 **Exigence de Véhicule**: Commencez à vendre des produits uniquement lorsque vous êtes dans un véhicule spécifié.
- 📍 **Points de Vente Aléatoires**: Génère des points de vente aléatoires pour un gameplay plus dynamique.
- 💸 **Gains**: Les joueurs gagnent de l'argent pour chaque vente qu'ils réalisent.
- 🔔 **Notifications**: Notifications en jeu pour guider le joueur.
- 🛡️ **Permissions**: Seuls les joueurs ayant le job `vigneron` peuvent accéder aux fonctionnalités du métier.

### Gestion des Employés

- 📋 **Liste des Employés**: Affiche tous les employés avec leurs grades de travail.
- ⬆️ **Promouvoir des Employés**: Promouvoir les employés à des grades de travail plus élevés.
- ⬇️ **Rétrograder des Employés**: Rétrograder les employés à des grades de travail inférieurs.
- ❌ **Licencier des Employés**: Licencier des employés de l'entreprise.
### Récolte et Traitement
- 🌿 **Récolte**: Points de récolte pour cueillir des raisins.
- 🏭 **Traitement**: Points de traitement pour transformer les raisins en bouteilles de vin.

### Intégration de Webhook Discord
- 🔗 **Webhooks**: Notifications envoyées aux webhooks Discord configurés pour les actions importantes comme la prise de service, le démarrage des ventes, et la fin des ventes.
- 📝 **Embeds**: Messages formatés en embed pour une meilleure lisibilité sur Discord.

## Installation

1. **Ajouter les Fichiers**:
   - Placez les scripts client et serveur dans votre répertoire de ressources.
   - Assurez-vous d'avoir `es_extended` installé sur votre serveur.

2. **Configurer le `config.lua`**:
   - Remplacez `"TON WEBHOOK"` par l'URL de votre webhook Discord.
   - Configurez les points de vente et les véhicules de vente selon vos besoins.

3. **Exécuter les Requêtes SQL**:
   - Créez les tables nécessaires dans votre base de données en utilisant les commandes SQL fournies dans le astrxwvigneron.sql.



4. **Démarrer la Ressource**:
   - Ajoutez la ressource dans votre fichier `server.cfg` et démarrez le serveur.
   ```bash
   start vigneron
   ```

## Utilisation

- **Prendre le service**: Utilisez la touche F6 pour ouvrir le menu et prendre le service.
- **Vente de produits**: Allez au point de vente marqué sur la carte pour vendre vos produits.
- **Gestion des employés**: Utilisez le menu de gestion pour promouvoir, rétrograder, ou licencier des employés.
- **Récolte et traitement**: Rendez-vous aux points de récolte pour cueillir des raisins et aux points de traitement pour transformer les raisins en bouteilles de vin.



Profitez de votre nouveau métier de vigneron dans vos serveurs ! 🍷
