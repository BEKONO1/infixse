# 🚂 Configuration Railway Complète - Infix LMS

Ce document résume toute la configuration nécessaire pour déployer Infix LMS avec sa base de données sur Railway.

---

## 📁 Structure des fichiers de configuration

```
InfixLMS/
├── railway.json          ✅ Configuration déploiement Railway
├── nixpacks.toml         ✅ Configuration build (PHP, Nginx, Node)
├── start.sh             ✅ Script de démarrage
├── nginx.conf           ✅ Configuration serveur web
├── import-db.sh         ✅ Script import base de données
├── .env                 ✅ Variables d'environnement (configuré pour Railway)
├── RAILWAY_DEPLOY.md    📖 Guide déploiement application
├── RAILWAY_DATABASE.md  📖 Guide déploiement base de données
└── RAILWAY.md          📖 Ce fichier - Résumé complet
```

---

## 🚀 Déploiement Rapide (5 minutes)

### 1. Préparation (Local)

```bash
# 1. Commit les fichiers de configuration
git add .
git commit -m "Configuration Railway complète"
git push origin main

# 2. Compressez la base de données (optionnel mais recommandé)
gzip -k database/infixlms.sql
```

### 2. Création sur Railway (Dashboard)

```
1. https://railway.app/new
2. "Deploy from GitHub repo"
3. Sélectionnez votre repository
4. "Add MySQL" (Database)
5. "Add Redis" (Database - optionnel)
```

### 3. Configuration Variables

Dans Railway Dashboard → Variables du service app :

```bash
# Générez une APP_KEY sécurisée
php artisan key:generate --show

# Ajoutez ces variables:
APP_KEY=base64:votre-cle-generee
APP_DEBUG=false

# Configuration Email (obligatoire pour les notifications)
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=votre-email@gmail.com
MAIL_PASSWORD=votre-mot-de-passe-app
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@infixlms.com
MAIL_FROM_NAME="Infix LMS"
```

### 4. Import Base de Données

```bash
# Méthode 1: Via script (recommandé)
./import-db.sh

# Méthode 2: Via Railway CLI
railway connect mysql < database/infixlms.sql

# Méthode 3: Via Dashboard
# Railway Dashboard → MySQL → Connect → Import
```

### 5. Déploiement

```bash
# Push déclenche le déploiement automatique
git push origin main

# Ou manuellement
railway up
```

---

## 🎯 Architecture sur Railway

```
┌─────────────────────────────────────────────────────────┐
│                    RAILWAY PROJECT                       │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   SERVICE    │  │   SERVICE    │  │   SERVICE    │  │
│  │     APP      │  │    MySQL     │  │    Redis     │  │
│  │              │  │              │  │   (optionnel)│  │
│  │ ┌──────────┐ │  │              │  │              │  │
│  │ │  Nginx   │ │  │   Railway    │  │   Railway    │  │
│  │ │  + PHP   │ │  │    Managed   │  │    Managed   │  │
│  │ │ 8.1-FPM  │ │  │              │  │              │  │
│  │ └──────────┘ │  │              │  │              │  │
│  │              │  │              │  │              │  │
│  │ Health: /health│ │              │  │              │  │
│  │ Port: $PORT  │  │              │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                          │
│  Variables partagées via Railway:                        │
│  - MYSQLHOST, MYSQLPORT, MYSQLDATABASE...               │
│  - REDISHOST, REDISPORT, REDIS_PASSWORD...              │
│  - RAILWAY_STATIC_URL (URL publique)                    │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Spécifications techniques

### Configuration PHP (nixpacks.toml)
- **PHP 8.1** avec extensions requises
- **Nginx** comme serveur web
- **Node.js** pour build des assets

### Extensions PHP installées
```
php81Extensions.pdo_mysql
php81Extensions.redis
php81Extensions.gd
php81Extensions.mbstring
php81Extensions.xml
php81Extensions.zip
php81Extensions.curl
php81Extensions.fileinfo
php81Extensions.openssl
php81Extensions.intl
php81Extensions.bcmath
php81Extensions.exif
php81Extensions.ctype
php81Extensions.tokenizer
php81Extensions.json
```

### Configuration Nginx
- **Port dynamique** via variable `$PORT`
- **Upload max** : 100MB (pour vidéos)
- **Gzip** activé
- **Cache** fichiers statiques 1 an
- **Healthcheck** sur `/health`

### Processus de build
```bash
# 1. Installation dépendances
composer install --no-dev --optimize-autoloader
npm ci
npm run production

# 2. Cache Laravel
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
```

### Processus de démarrage (start.sh)
```bash
# 1. Attente services
- Wait MySQL
- Wait Redis

# 2. Database
- Run migrations
- (Optionnel) Run seeders

# 3. Optimisation
- Laravel cache commands
- Storage:link
- Permissions

# 4. Démarrage
- PHP-FPM (port 9000)
- Nginx (port $PORT)
```

---

## 🔐 Variables d'environnement

### Variables Railway (Auto-générées)
```
MYSQLHOST=mysql.railway.internal
MYSQLPORT=3306
MYSQLDATABASE=railway
MYSQLUSER=root
MYSQLPASSWORD=xxxxx

REDISHOST=redis.railway.internal
REDISPORT=6379
REDIS_PASSWORD=xxxxx

RAILWAY_STATIC_URL=https://votre-app.up.railway.app
```

### Variables à configurer manuellement
```
# Application
APP_KEY=base64:xxxxx  # Générer avec: php artisan key:generate
APP_DEBUG=false
APP_ENV=production

# Cache/Queue/Session
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis

# Email
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=xxx
MAIL_PASSWORD=xxx
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=xxx
MAIL_FROM_NAME="Infix LMS"

# Payment Gateways (si utilisés)
STRIPE_KEY=pk_xxx
STRIPE_SECRET=sk_xxx
PAYPAL_CLIENT_ID=xxx
PAYPAL_CLIENT_SECRET=xxx

# Storage (si S3 utilisé)
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx
AWS_DEFAULT_REGION=eu-west-1
AWS_BUCKET=xxx
```

---

## ✅ Checklist pré-déploiement

- [ ] Fichiers de configuration Railway commités sur GitHub
- [ ] Base de données exportée (`database/infixlms.sql`)
- [ ] APP_KEY générée et notée
- [ ] Variables email configurées
- [ ] Variables payment gateways configurées (si nécessaire)

## ✅ Checklist post-déploiement

- [ ] Health check OK : `https://votre-app.up.railway.app/health`
- [ ] Base de données importée avec succès
- [ ] Migrations exécutées
- [ ] Connexion admin fonctionnelle
- [ ] Emails de test envoyés
- [ ] Upload fichiers testé

---

## 🛠️ Commandes utiles

### Railway CLI
```bash
# Installation
npm install -g @railway/cli

# Connexion
railway login

# Lier un projet
railway link

# Déploiement
railway up

# Logs
railway logs

# Variables
railway variables
railway variables set KEY=value

# Connexion base de données
railway connect mysql
railway connect redis

# Status
railway status
```

### Vérification application
```bash
# Health check
curl https://votre-app.up.railway.app/health

# Logs
curl https://votre-app.up.railway.app
```

### Base de données
```bash
# Import
./import-db.sh

# Export
echo "SELECT * FROM users" | railway connect mysql

# Structure
railway connect mysql -e "SHOW TABLES;"
```

---

## 💰 Coûts estimés

### Plan Starter (Gratuit)
- **500 MB** stockage MySQL
- **512 MB** RAM
- **$5** crédits mensuels
- ✅ Suffisant pour test/démo

### Plan Production
- **MySQL Pro** : $5/mois + $0.50/GB
- **Redis Pro** : $5/mois + $0.50/GB  
- **App** : $5/mois + usage CPU/RAM
- 💡 Coût total estimé : $15-30/mois pour une app moyenne

---

## 🆘 Support & Dépannage

### Documentation
- 📖 [Railway Docs](https://docs.railway.app/)
- 📖 [Guide déploiement app](RAILWAY_DEPLOY.md)
- 📖 [Guide base de données](RAILWAY_DATABASE.md)

### Support Railway
- 💬 [Discord](https://discord.gg/railway)
- 🐦 [Twitter @Railway](https://twitter.com/railway)
- 📧 Email : support@railway.app

### Logs & Debugging
```bash
# Logs en temps réel
railway logs -f

# Logs spécifiques au build
railway logs --deployment

# SSH dans le container
railway ssh
```

---

## 🎉 Vous êtes prêt !

Votre application Infix LMS est maintenant entièrement configurée pour Railway avec :
- ✅ Application PHP/Laravel
- ✅ Base de données MySQL gérée
- ✅ Cache Redis (optionnel)
- ✅ Health checks
- ✅ Migrations automatiques
- ✅ Build optimisé

**Prochaine étape** : Suivez les instructions dans [RAILWAY_DEPLOY.md](RAILWAY_DEPLOY.md) pour le déploiement final !

---

Développé avec ❤️ pour Infix LMS
Dernière mise à jour : 2024
