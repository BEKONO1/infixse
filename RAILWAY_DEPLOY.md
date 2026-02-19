# 🚂 Guide de Déploiement Railway - Infix LMS

Ce guide explique comment déployer Infix LMS sur Railway.app

---

## ✅ Prérequis

1. Compte Railway (https://railway.app)
2. Repository GitHub avec le code du projet
3. Git installé localement

---

## 📋 Configuration déjà incluse

Le projet est déjà configuré pour Railway avec les fichiers suivants :

- **`railway.json`** - Configuration du déploiement
- **`nixpacks.toml`** - Configuration build (PHP 8.1 + Nginx + Node)
- **`start.sh`** - Script de démarrage
- **`nginx.conf`** - Configuration serveur web
- **`.env`** - Variables d'environnement configurées pour Railway

---

## 🚀 Étapes de déploiement

### 1. Créer un projet Railway

```bash
# Se connecter à Railway (si CLI installé)
railway login

# Ou créer via l'interface web
# https://railway.app/new
```

### 2. Créer les services nécessaires

Dans votre projet Railway, ajoutez :

#### **Service MySQL**
1. Cliquez sur "New" → "Database" → "Add MySQL"
2. Railway générera automatiquement les variables :
   - `MYSQLHOST`
   - `MYSQLPORT`
   - `MYSQLDATABASE`
   - `MYSQLUSER`
   - `MYSQLPASSWORD`

#### **Service Redis** (Optionnel mais recommandé)
1. Cliquez sur "New" → "Database" → "Add Redis"
2. Variables générées :
   - `REDISHOST`
   - `REDISPORT`
   - `REDIS_PASSWORD`

#### **Service Application**
1. Cliquez sur "New" → "GitHub Repo"
2. Sélectionnez votre repository contenant Infix LMS
3. Railway détectera automatiquement les fichiers de configuration

### 3. Variables d'environnement requises

Configurez ces variables dans Railway Dashboard → Variables :

**⚠️ IMPORTANT : Ne modifiez pas ces variables (Railway les gère)**
- `MYSQLHOST`, `MYSQLPORT`, `MYSQLDATABASE`, `MYSQLUSER`, `MYSQLPASSWORD`
- `REDISHOST`, `REDISPORT`, `REDIS_PASSWORD`
- `RAILWAY_STATIC_URL`

**✅ Variables à configurer manuellement :**
```
APP_KEY=base64:votre-cle-app
APP_DEBUG=false
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis

# Configuration Email
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=votre-email@gmail.com
MAIL_PASSWORD=votre-mot-de-passe
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@votre-domaine.com
MAIL_FROM_NAME="Infix LMS"

# AWS S3 (Optionnel - pour le stockage fichiers)
AWS_ACCESS_KEY_ID=votre-cle
AWS_SECRET_ACCESS_KEY=votre-secret
AWS_DEFAULT_REGION=eu-west-1
AWS_BUCKET=votre-bucket

# Payment Gateways (Optionnel)
STRIPE_KEY=pk_test_...
STRIPE_SECRET=sk_test_...
PAYPAL_CLIENT_ID=...
PAYPAL_CLIENT_SECRET=...
```

### 4. Déployer

```bash
# Si vous utilisez Railway CLI
git add .
git commit -m "Configuration Railway"
git push

# Railway déploiera automatiquement
```

---

## 🔍 Vérification du déploiement

### Health Check
Une fois déployé, vérifiez que l'application fonctionne :
```
https://votre-app.railway.app/health
```
Doit retourner : `healthy`

### Migrations
Les migrations s'exécutent automatiquement au démarrage grâce à `start.sh`.

### Logs
```bash
# Via Railway CLI
railway logs

# Via Dashboard
Railway Dashboard → Service → Deployments → Logs
```

---

## 🔧 Dépannage

### Problème : "Waiting for MySQL"
- Vérifiez que le service MySQL est bien créé et en cours d'exécution
- Vérifiez les variables d'environnement MySQL

### Problème : "502 Bad Gateway"
- Vérifiez les logs avec `railway logs`
- Vérifiez que PHP-FPM et Nginx démarrent correctement

### Problème : Permissions
- Le script `start.sh` définit automatiquement les permissions
- Vérifiez que `storage/` et `bootstrap/cache` sont accessibles

### Problème : Fichiers statiques non chargés
- Vérifiez que `npm run production` s'est bien exécuté
- Vérifiez les logs de build

---

## 📊 Performance & Optimisation

### Cache activé automatiquement
Le script `start.sh` exécute automatiquement :
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
```

### Uploads volumineux
La configuration Nginx permet les uploads jusqu'à **100MB** (pour les vidéos de cours).

---

## 🔗 Ressources utiles

- Documentation Railway : https://docs.railway.app/
- Variables Railway : https://docs.railway.app/reference/variables
- Nixpacks : https://nixpacks.com/

---

## 💡 Astuces

1. **Custom Domain** : Dashboard → Service → Settings → Domains
2. **Auto-deploy** : Activé par défaut sur push vers main/master
3. **Environnements** : Utilisez les environnements Railway pour dev/staging/prod

---

Développé avec ❤️ pour Infix LMS
