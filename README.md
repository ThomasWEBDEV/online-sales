# 🛒 Marketplace - Vente en Ligne

Plateforme de vente en ligne construite avec Ruby on Rails 7, permettant aux utilisateurs d'acheter et vendre des produits avec paiement sécurisé via Stripe.

## 📋 Fonctionnalités

- ✅ Authentification utilisateur sécurisée (Devise)
- 🛍️ Gestion des produits (CRUD complet)
- ⭐ Système de favoris
- 💳 Paiement sécurisé via Stripe
- 📧 Notifications email (achat, vente)
- 📦 Gestion des commandes (statuts, livraison)
- 📸 Upload d'images via Cloudinary
- 🔍 Recherche et filtres avancés
- 📱 Interface responsive

## 🚀 Technologies

- **Backend** : Ruby 3.3.5, Rails 7.1.5
- **Base de données** : PostgreSQL
- **Frontend** : Turbo, Stimulus, Bootstrap
- **Paiement** : Stripe
- **Upload** : Cloudinary
- **Email** : ActionMailer

## 📦 Installation

### Prérequis

- Ruby 3.3.5
- PostgreSQL
- Node.js et Yarn
- Compte Stripe (clés API test)
- Compte Cloudinary

### Étapes d'installation
```bash
# 1. Cloner le projet
git clone https://github.com/votre-username/vente-en-ligne.git
cd vente-en-ligne

# 2. Installer les dépendances
bundle install
yarn install

# 3. Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos vraies clés API

# 4. Créer et initialiser la base de données
rails db:create
rails db:migrate
rails db:seed  # (optionnel : données de test)

# 5. Lancer le serveur
rails server
```

Accéder à l'application : http://localhost:3000

## 🔒 Configuration Sécurité

### Variables d'environnement

**⚠️ NE JAMAIS committer le fichier `.env` !**

Créez un fichier `.env` à la racine avec :
```bash
# Cloudinary
CLOUDINARY_URL=cloudinary://YOUR_API_KEY:YOUR_API_SECRET@YOUR_CLOUD_NAME

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_KEY
STRIPE_SECRET_KEY=sk_test_YOUR_KEY
STRIPE_WEBHOOK_SECRET=whsec_YOUR_SECRET

# Email (production uniquement)
MAILER_FROM=noreply@votreapp.com
SMTP_ADDRESS=smtp.gmail.com
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

### Stripe Webhooks (Local)

Pour tester les webhooks Stripe en local :
```bash
# Installer Stripe CLI
brew install stripe/stripe-cli/stripe  # macOS
# ou télécharger depuis https://stripe.com/docs/stripe-cli

# Se connecter
stripe login

# Écouter les webhooks
stripe listen --forward-to localhost:3000/webhooks/stripe
```

### Credentials Rails

Les secrets sensibles sont stockés dans `config/credentials.yml.enc` :
```bash
# Éditer les credentials
EDITOR="code --wait" rails credentials:edit
```

## 🧪 Tests
```bash
# Lancer tous les tests
bundle exec rspec

# Tests avec couverture
bundle exec rspec --format documentation
```

## 📦 Déploiement

### Heroku
```bash
# Créer l'application
heroku create votre-app-name

# Ajouter PostgreSQL
heroku addons:create heroku-postgresql:mini

# Configurer les variables d'environnement
heroku config:set CLOUDINARY_URL=...
heroku config:set STRIPE_PUBLISHABLE_KEY=...
heroku config:set STRIPE_SECRET_KEY=...
heroku config:set STRIPE_WEBHOOK_SECRET=...

# Déployer
git push heroku main

# Migrer la base de données
heroku run rails db:migrate

# Configurer le webhook Stripe pour production
# Dans le dashboard Stripe, ajouter :
# https://votre-app.herokuapp.com/webhooks/stripe
```

## 📂 Structure du Projet
```
app/
├── controllers/       # Contrôleurs
├── models/            # Modèles (User, Product, Order, Favorite)
├── views/             # Vues ERB
├── mailers/           # Emails
└── assets/            # CSS, JS, images

config/
├── routes.rb          # Routes
├── database.yml       # Configuration BDD
└── initializers/      # Initialisateurs (Devise, Stripe, etc.)

db/
├── migrate/           # Migrations
└── schema.rb          # Schéma BDD

spec/                  # Tests RSpec
```

## 🔐 Sécurité

- ✅ Authentification Devise avec validation email
- ✅ Protection CSRF activée
- ✅ Paramètres strong params sur tous les contrôleurs
- ✅ SSL forcé en production
- ✅ Variables sensibles dans `.env` (gitignored)
- ✅ Webhooks Stripe avec signature vérifiée
- ✅ Uploads sécurisés via Cloudinary

## 📧 Email en Développement

Les emails sont capturés par Letter Opener Web :

http://localhost:3000/letter_opener

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 License

Ce projet est sous licence MIT.

## 👨‍💻 Auteur

Thomas Feret - [GitHub](https://github.com/votre-username)

---

**Version** : 1.0.0
**Dernière mise à jour** : Décembre 2025
