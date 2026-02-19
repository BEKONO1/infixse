# 🗄️ Guide Déploiement Base de Données Railway

Ce guide explique comment déployer la base de données Infix LMS sur Railway.app

---

## 🎯 Options disponibles

Railway propose **deux façons** de gérer votre base de données :

### Option 1 : Service MySQL géré par Railway (✅ RECOMMANDÉ)
- MySQL entièrement géré
- Backups automatiques
- Scaling automatique
- Pas de maintenance requise

### Option 2 : Base de données externe
- Vous utilisez votre propre serveur MySQL
- Configurez juste les variables d'environnement

---

## 📦 Option 1 : MySQL géré par Railway

### Étape 1 : Créer le service MySQL

#### Via Dashboard Web :
1. Allez sur https://railway.app/dashboard
2. Cliquez sur **"New Project"** ou ouvrez votre projet existant
3. Cliquez sur **"New"** → **"Database"** → **"Add MySQL"**
4. Railway crée automatiquement le service et génère les variables

#### Via CLI Railway :
```bash
# Se connecter
railway login

# Se connecter au projet
railway link

# Créer un service MySQL
railway add --database mysql
```

### Étape 2 : Variables générées automatiquement

Railway crée automatiquement ces variables d'environnement :

```
MYSQLHOST=mysql.railway.internal
MYSQLPORT=3306
MYSQLDATABASE=railway
MYSQLUSER=root
MYSQLPASSWORD=xxxxxxxxxxxxx
MYSQL_URL=mysql://root:xxxxxxxxxxxxx@mysql.railway.internal:3306/railway
```

**💡 Important :** Votre fichier `.env` utilise déjà ces variables !

### Étape 3 : Importer votre base de données existante

#### Méthode A : Via Railway Dashboard (Recommandée pour les gros fichiers)

1. **Téléchargez votre fichier SQL** :
   ```bash
   # Compressez le fichier SQL pour accélérer le transfert
   gzip -k database/infixlms.sql
   ```

2. **Dans Railway Dashboard** :
   - Allez dans votre service MySQL
   - Onglet **"Connect"**
   - Cliquez sur **"New Connection"**
   - Copiez la commande de connexion

3. **Importez via CLI** :
   ```bash
   # Connectez-vous à MySQL Railway
   mysql -h mysql.railway.internal -u root -p railway < database/infixlms.sql
   
   # Ou avec le mot de passe Railway
   mysql -h MYSQLHOST -u MYSQLUSER -p'MYSQLPASSWORD' MYSQLDATABASE < database/infixlms.sql
   ```

#### Méthode B : Via le plugin MySQL de Railway

1. Installez l'extension Railway MySQL :
   ```bash
   railway plugins
   ```

2. Accédez au shell MySQL :
   ```bash
   railway mysql
   ```

3. Importez le fichier SQL :
   ```sql
   source database/infixlms.sql;
   ```

#### Méthode C : Utiliser le script d'import automatique

Créez un fichier `import-db.sh` :

```bash
#!/bin/bash
# Script d'import de base de données vers Railway

set -e

echo "🗄️ Import de la base de données vers Railway..."

# Vérifie les variables Railway
if [ -z "$MYSQL_URL" ]; then
    echo "❌ Erreur: MYSQL_URL non définie"
    echo "Assurez-vous d'être connecté à Railway"
    exit 1
fi

# Extrait les infos de connexion depuis MYSQL_URL
# Format: mysql://user:password@host:port/database
DB_URL="${MYSQL_URL#mysql://}"
DB_USER="${DB_URL%%:*}"
DB_REST="${DB_URL#*:}"
DB_PASS="${DB_REST%%@*}"
DB_REST2="${DB_REST#*@}"
DB_HOST="${DB_REST2%%:*}"
DB_REST3="${DB_REST2#*:}"
DB_PORT="${DB_REST3%%/*}"
DB_NAME="${DB_REST3#*/}"

echo "📊 Connexion à: $DB_HOST:$DB_PORT"
echo "🗃️  Base de données: $DB_NAME"

# Importe la base de données
if [ -f "database/infixlms.sql" ]; then
    echo "📥 Import de database/infixlms.sql..."
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < database/infixlms.sql
    echo "✅ Import terminé avec succès !"
elif [ -f "database/infixlms.sql.gz" ]; then
    echo "📥 Import de database/infixlms.sql.gz (compressé)..."
    zcat database/infixlms.sql.gz | mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME"
    echo "✅ Import terminé avec succès !"
else
    echo "⚠️  Aucun fichier SQL trouvé dans database/"
    exit 1
fi

echo ""
echo "🎉 Base de données importée !"
echo "📊 Tables importées:"
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES;"
```

Rendez-le exécutable et utilisez-le :
```bash
chmod +x import-db.sh
./import-db.sh
```

---

## 🔄 Option 2 : Redis pour Cache/Sessions/Queues

### Créer le service Redis

#### Via Dashboard :
1. **"New"** → **"Database"** → **"Add Redis"**
2. Railway génère automatiquement les variables

#### Variables créées :
```
REDISHOST=redis.railway.internal
REDISPORT=6379
REDIS_PASSWORD=xxxxxxxxxxxxx
REDIS_URL=redis://default:xxxxxxxxxxxxx@redis.railway.internal:6379
```

### Configuration Redis dans .env

Votre fichier `.env` est déjà configuré :
```env
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

REDIS_HOST="${REDISHOST}"
REDIS_PASSWORD="${REDIS_PASSWORD}"
REDIS_PORT="${REDISPORT}"
```

---

## 🔐 Sécurité & Bonnes pratiques

### 1. Variables sensibles
**Ne commitez jamais** de vraies credentials dans Git :
```bash
# Le fichier .env est déjà dans .gitignore
# Utilisez uniquement les variables Railway
```

### 2. Backups automatiques
Railway effectue des backups automatiques de MySQL :
- Daily backups conservés 7 jours
- Weekly backups conservés 4 semaines
- Via Dashboard : Service MySQL → Backups

### 3. Créer un backup manuel
```bash
# Via Railway CLI
railway connect mysql

# Puis dans MySQL
mysqldump -h $MYSQLHOST -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE > backup_$(date +%Y%m%d).sql
```

---

## 🚀 Déploiement complet étape par étape

### 1. Préparation locale
```bash
# Compressez votre base de données pour un upload plus rapide
gzip -k database/infixlms.sql

# Commit les changements
git add .
git commit -m "Configuration Railway prête"
git push origin main
```

### 2. Création sur Railway

#### Via Dashboard Web :
1. Allez sur https://railway.app/new
2. Choisissez **"Deploy from GitHub repo"**
3. Sélectionnez votre repository
4. Cliquez sur **"Add a database"** → **MySQL**
5. Cliquez sur **"Add a database"** → **Redis** (optionnel)

#### Ou via CLI :
```bash
# Créer un nouveau projet
railway init

# Ajouter MySQL
railway add --database mysql

# Ajouter Redis
railway add --database redis

# Lier le repo GitHub
railway link
```

### 3. Configuration des variables

Dans Railway Dashboard → Variables :

```bash
# Générez une nouvelle APP_KEY
php artisan key:generate --show

# Copiez la valeur et créez la variable dans Railway :
APP_KEY=base64:votre-nouvelle-cle

# Autres variables importantes
APP_DEBUG=false
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
```

### 4. Import de la base de données

```bash
# Connectez-vous à Railway
railway login
railway link

# Méthode 1: Via Railway shell
railway connect mysql < database/infixlms.sql

# Méthode 2: Utiliser le script
./import-db.sh

# Méthode 3: Manuel avec les variables
mysql -h $(railway variables get MYSQLHOST) \
      -u $(railway variables get MYSQLUSER) \
      -p"$(railway variables get MYSQLPASSWORD)" \
      $(railway variables get MYSQLDATABASE) \
      < database/infixlms.sql
```

### 5. Déploiement de l'application

```bash
# Push sur GitHub déclenche le déploiement automatique
git push origin main

# Ou via CLI
railway up
```

---

## 📊 Vérification du déploiement

### 1. Vérifier la connexion MySQL
```bash
# Dans Railway Dashboard → Service MySQL → Connect
# Ou via CLI
railway connect mysql

# Testez :
SHOW DATABASES;
USE railway;
SHOW TABLES;
SELECT COUNT(*) FROM users;
```

### 2. Vérifier Redis
```bash
railway connect redis

# Testez :
PING
INFO
```

### 3. Vérifier l'application
```bash
# Health check
curl https://votre-app.railway.app/health

# Logs
railway logs
```

---

## 🛠️ Dépannage

### Problème : "Access denied for user"
```bash
# Vérifiez les variables
echo $MYSQLUSER
echo $MYSQLPASSWORD

# Réinitialisez le mot de passe si nécessaire
# Railway Dashboard → MySQL → Settings → Reset Password
```

### Problème : "Can't connect to MySQL server"
```bash
# Vérifiez que le service MySQL est en cours d'exécution
railway status

# Redémarrez le service si nécessaire
railway restart
```

### Problème : Import SQL trop lent
```bash
# Compressez le fichier
gzip database/infixlms.sql

# Utilisez pv pour voir la progression
pv database/infixlms.sql.gz | gunzip | railway connect mysql

# Ou divisez en plusieurs fichiers
split -l 10000 database/infixlms.sql part_
for f in part_*; do railway connect mysql < $f; done
```

### Problème : "Table already exists"
```bash
# Ajoutez IF NOT EXISTS dans votre SQL
# Ou supprimez les tables existantes d'abord
railway connect mysql -e "DROP DATABASE railway; CREATE DATABASE railway;"
```

---

## 💰 Coûts

Railway propose un **Starter Plan gratuit** avec :
- **500 MB** de stockage MySQL
- **512 MB** de RAM
- **$5** de crédits mensuels gratuits

Pour un usage production, envisagez le plan Pro à **$5/mois** par service.

---

## 📚 Ressources

- 📖 [Documentation Railway MySQL](https://docs.railway.app/databases/mysql)
- 📖 [Documentation Railway Redis](https://docs.railway.app/databases/redis)
- 💬 [Communauté Railway Discord](https://discord.gg/railway)

---

✅ **Votre base de données est maintenant prête pour Railway !**
