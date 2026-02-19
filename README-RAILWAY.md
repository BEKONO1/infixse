# Déploiement Infix LMS sur Railway 🚂

Ce guide vous explique comment déployer Infix LMS sur Railway en quelques étapes.

## 💾 Base de Données - Pas de Fichier SQL Nécessaire !

**Bonne nouvelle : Vous n'avez pas besoin de fichier SQL pour importer !**

Laravel utilise un système de **migrations** qui crée automatiquement toute la structure de la base de données :

- ✅ **84 migrations** sont incluses dans le projet (`database/migrations/`)
- ✅ Au premier démarrage, le script `start.sh` exécute : `php artisan migrate --force`
- ✅ Toutes les tables sont créées automatiquement
- ✅ Vous n'avez qu'à créer un administrateur (voir étape 6)

### Architecture de la Base de Données

Les migrations créent automatiquement :
- Tables des utilisateurs et rôles
- Tables des cours et catégories
- Tables des paiements et wallets
- Tables des quizzes et certificats
- Tables des paramètres système
- Et bien plus encore...

## 📁 Fichiers de Configuration Créés

- `railway.json` - Configuration Railway
- `nixpacks.toml` - Configuration du build (PHP 8.1, Nginx, Node.js)
- `start.sh` - Script de démarrage
- `nginx.conf` - Configuration Nginx
- `.env.railway` - Template des variables d'environnement
- `.railwayignore` - Fichiers à ignorer lors du build
- `create-admin.sh` - Script helper pour créer un administrateur (Option A)

## 🚀 Étapes de Déploiement

### 1. Préparer le Repository Git

```bash
# Initialiser Git (si pas déjà fait)
git init

# Ajouter les fichiers Railway
git add railway.json nixpacks.toml start.sh nginx.conf .env.railway .railwayignore README-RAILWAY.md
git commit -m "Add Railway deployment configuration"

# Pousser sur GitHub
git push origin main
```

### 2. Créer un Projet Railway

1. Allez sur [Railway](https://railway.app) et connectez-vous
2. Cliquez sur "New Project"
3. Sélectionnez "Deploy from GitHub repo"
4. Choisissez votre repository InfixLMS

### 3. Ajouter les Services Requis

Dans votre projet Railway, ajoutez :

#### MySQL Database
- Cliquez sur "New" → "Database" → "Add MySQL"
- Railway créera automatiquement la base de données

#### Redis
- Cliquez sur "New" → "Database" → "Add Redis"
- Utilisé pour le cache, les sessions et les queues

#### Volume (Stockage Persistant)
- Cliquez sur "New" → "Volume"
- Nom : `storage`
- Mount Path : `/app/storage`

### 4. Configurer les Variables d'Environnement

Dans l'onglet "Variables" de votre service :

1. Cliquez sur "New Variable" → "Bulk Add"
2. Copiez-collez le contenu de `.env.railway`
3. Générez une clé APP_KEY :
   ```bash
   # En local, exécutez :
   php artisan key:generate --show
   ```
4. Ajoutez la clé générée dans les variables Railway : `APP_KEY=base64:xxxxx`

### 5. Déployer

1. Railway détectera automatiquement les fichiers de configuration
2. Le build démarrera automatiquement
3. Surveillez les logs dans l'onglet "Deploys"

### 6. Post-Déploiement (Option A - Installation Propre)

**✅ Bonne nouvelle : Les migrations ont déjà créé toutes les tables automatiquement !**

Pas besoin de fichier SQL - Laravel a créé la structure de la base de données avec les 84 migrations.

#### Créer un Administrateur

Une fois le déploiement terminé, utilisez le script helper :

**Méthode 1 - Script Helper (Recommandé) :**
```bash
# Dans le terminal Railway, exécutez :
bash create-admin.sh

# Le script vous demandera :
# - Nom de l'administrateur
# - Email
# - Mot de passe
```

**Méthode 2 - Manuellement avec Tinker :**
```bash
# Dans le terminal Railway
php artisan tinker

# Puis dans tinker :
>>> $user = new App\Models\User();
>>> $user->name = 'Votre Nom';
>>> $user->email = 'votre@email.com';
>>> $user->password = bcrypt('votre_mot_de_passe_securise');
>>> $user->role_id = 1;
>>> $user->email_verified_at = now();
>>> $user->save();
>>> exit;
```

## ✅ Vérification

1. **Health Check** : Visitez `https://votre-app.railway.app/health`
   - Devrait retourner "healthy"

2. **Page d'accueil** : Visitez `https://votre-app.railway.app/`

3. **Connexion Admin** :
   - URL : `https://votre-app.railway.app/login`
   - Email : admin@example.com
   - Mot de passe : celui que vous avez défini

## 🔧 Modules Actifs

Les modules suivants sont configurés comme actifs :

**Core** : Setting, ModuleManager, Localization, RolePermission, Appearance  
**Cours** : CourseSetting, Quiz, VirtualClass, Zoom  
**Paiements** : Payment, Wallet, BankPayment, OfflinePayment, Razorpay, Paytm, PayStack  
**Contenu** : FrontendManage, Blog, FooterSetting, PopupContent  
**Système** : SystemSetting, StudentSetting, Backup, Certificate

Vérifiez avec :
```bash
php artisan module:list
```

## 🛠️ Commandes Utiles

### Logs
```bash
# Via Railway CLI
railway logs

# Ou via le dashboard Railway
```

### Exécuter des Commandes Artisan
```bash
railway run php artisan migrate
railway run php artisan cache:clear
railway run php artisan config:clear
```

### Redéploiement
```bash
# Faites un commit et poussez
git add .
git commit -m "Update"
git push
# Railway redéploiera automatiquement
```

## 🐛 Dépannage

### Erreur de Connexion MySQL
- Vérifiez que MySQL est bien ajouté comme service
- Attendez 2-3 minutes après le premier déploiement
- Vérifiez les logs : `railway logs`

### Erreur 500
- Vérifiez que APP_KEY est définie
- Vérifiez les logs : `railway logs`
- Essayez : `railway run php artisan optimize:clear`

### Permissions de Stockage
- Assurez-vous que le volume est monté sur `/app/storage`
- Le script start.sh configure automatiquement les permissions

### Module Manquant
```bash
railway run php artisan module:enable NomDuModule
```

## 📊 Architecture

```
┌─────────────────────────────────────┐
│         Railway Project             │
├─────────────────────────────────────┤
│  Service: Web (Laravel + Nginx)     │
│  ├── PHP 8.1 + Extensions           │
│  ├── Nginx Web Server               │
│  ├── Node.js (Build assets)         │
│  └── Volume: /app/storage           │
├─────────────────────────────────────┤
│  Service: MySQL (Managed)           │
│  └── Base de données automatique    │
├─────────────────────────────────────┤
│  Service: Redis (Managed)           │
│  └── Cache, Sessions, Queues        │
└─────────────────────────────────────┘
```

## 🔒 Sécurité

- **APP_DEBUG** : Toujours `false` en production
- **APP_KEY** : Générer une nouvelle clé unique
- **HTTPS** : Activé automatiquement par Railway
- **Variables sensibles** : Stockées de manière sécurisée dans Railway

## 📚 Ressources

- [Documentation Railway](https://docs.railway.app/)
- [Documentation Laravel](https://laravel.com/docs/10.x)
- [Infix LMS Documentation](https://spondonit.com/docs/infixlms)

---

**Besoin d'aide ?** Consultez les logs Railway ou ouvrez une issue sur GitHub.
