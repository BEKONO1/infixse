# 🎯 Guide de Déploiement Railway - Étape par Étape

## ÉTAPE 4 : Configurer les Variables d'Environnement 🔧

### 4.1 Ouvrir le panneau Variables

1. Dans Railway, clique sur ton service (l'icône avec le nom de ton projet)
2. En haut de la page, clique sur l'onglet **"Variables"**
3. Tu verras un bouton **"New Variable"** ou **"+"**

### 4.2 Ajouter les variables en bloc

1. Clique sur **"New Variable"**
2. Sélectionne **"Bulk Add"** ou **"Raw Editor"**
3. Copie-colle TOUT ce texte :

```
APP_NAME=Infix LMS
APP_ENV=production
APP_DEBUG=false
APP_URL=https://votre-app.up.railway.app
APP_LOCALE=fr
APP_FALLBACK_LOCALE=en
APP_TIMEZONE=Europe/Paris
DB_CONNECTION=mysql
DB_HOST=${MYSQLHOST}
DB_PORT=${MYSQLPORT}
DB_DATABASE=${MYSQLDATABASE}
DB_USERNAME=${MYSQLUSER}
DB_PASSWORD=${MYSQLPASSWORD}
REDIS_HOST=${REDISHOST}
REDIS_PORT=${REDISPORT}
REDIS_PASSWORD=${REDISPASSWORD}
REDIS_CLIENT=predis
QUEUE_CONNECTION=redis
CACHE_DRIVER=redis
SESSION_DRIVER=redis
SESSION_LIFETIME=120
FILESYSTEM_DISK=local
LOG_CHANNEL=stderr
LOG_LEVEL=info
```

### 4.3 Générer la clé APP_KEY (IMPORTANT !)

Cette clé est obligatoire pour la sécurité :

**Option A - Si tu as PHP en local :**
```bash
php artisan key:generate --show
```
Copie la clé générée (elle commence par `base64:`)

**Option B - Sans PHP local :**
1. Va sur https://generate-random.org/laravel-key-generator
2. Copie la clé générée

**Option C - Dans Railway directement :**
1. Va dans l'onglet "Shell" de ton service
2. Tape : `php artisan key:generate --show`
3. Copie le résultat

### 4.4 Ajouter la clé APP_KEY

1. Dans le panneau Variables, clique sur **"New Variable"**
2. Nom : `APP_KEY`
3. Valeur : colle la clé générée (ex: `base64:ABC123...`)
4. Clique sur **"Add"**

### 4.5 Vérification

Tu dois avoir ces variables (au minimum) :
- ✅ APP_NAME
- ✅ APP_KEY (remplie avec ta clé)
- ✅ APP_ENV = production
- ✅ DB_HOST, DB_PORT, etc. (Railway les remplit auto)
- ✅ REDIS_HOST, REDIS_PORT, etc. (Railway les remplit auto)

---

## ÉTAPE 5 : Déployer l'Application 🚀

### 5.1 Le déploiement est automatique !

**Bonne nouvelle :** Tu n'as RIEN à faire de spécial !

Dès que tu as configuré les variables :

1. Railway détecte automatiquement les fichiers :
   - `railway.json`
   - `nixpacks.toml`
   - `start.sh`

2. Le build commence automatiquement

3. Tu verras :
   - Un spinner jaune = en cours de build
   - Un point vert = déployé avec succès
   - Un point rouge = erreur (clique pour voir les logs)

### 5.2 Surveiller le déploiement

1. Va dans l'onglet **"Deploys"** de ton service
2. Clique sur le dernier déploiement
3. Tu verras les logs en temps réel :
   - Installation des dépendances
   - Compilation des assets
   - Migrations de la base de données
   - Démarrage du serveur

### 5.3 Attendre la fin du build

⏱️ **Temps estimé :** 5-10 minutes

Tu verras dans les logs :
```
✅ Installing PHP extensions...
✅ Running npm ci...
✅ Building assets...
✅ Running migrations...
✅ Starting web server...
```

### 5.4 Vérifier que c'est déployé

Quand tu vois :
```
🌐 Starting web server...
```

C'est bon ! L'application est en ligne.

### 5.5 Trouver l'URL de ton application

1. Dans Railway, regarde en haut à droite de ton service
2. Tu verras une URL du type : `https://mon-projet.up.railway.app`
3. Clique dessus ou copie-la dans ton navigateur

---

## ÉTAPE 6 : Créer un Administrateur 👤

### 6.1 Ouvrir le terminal Railway

1. Dans ton projet Railway, clique sur ton service
2. En haut, clique sur l'onglet **"Shell"** (icône `>_`)
3. Une fenêtre de terminal s'ouvre

### 6.2 Créer l'administrateur

**Méthode simple (avec le script) :**

Dans le terminal, tape :
```bash
bash create-admin.sh
```

Le script te demandera :
- Nom : `Admin` (ou ton nom)
- Email : `admin@tonemail.com`
- Mot de passe : `TonMotDePasse123!`

Puis il créera automatiquement l'utilisateur.

**Méthode manuelle (si le script ne marche pas) :**

Dans le terminal, tape :
```bash
php artisan tinker
```

Puis copie-colle ligne par ligne :
```php
$user = new App\Models\User();
$user->name = 'Admin';
$user->email = 'admin@tonemail.com';
$user->password = bcrypt('TonMotDePasse123!');
$user->role_id = 1;
$user->email_verified_at = now();
$user->save();
exit;
```

### 6.3 Vérifier la création

Tu dois voir un message comme :
```
=> App\Models\User {#1234}
```

Cela signifie que l'utilisateur est créé !

### 6.4 Se connecter

1. Ouvre l'URL de ton application : `https://mon-projet.up.railway.app`
2. Clique sur **"Login"** ou **"Connexion"**
3. Email : `admin@tonemail.com`
4. Mot de passe : `TonMotDePasse123!`
5. Clique sur **"Se connecter"**

🎉 **Félicitations !** Tu es connecté en tant qu'administrateur !

---

## ✅ CHECKLIST FINALE

Avant de dire que c'est terminé, vérifie :

- [ ] Étape 4 : Les variables sont configurées (surtout APP_KEY)
- [ ] Étape 5 : Le déploiement est vert (pas rouge)
- [ ] Étape 5 : L'URL affiche la page d'accueil
- [ ] Étape 6 : L'administrateur est créé
- [ ] Étape 6 : Tu peux te connecter au panneau admin

---

## 🆘 Problèmes Fréquents

### "APP_KEY missing"
→ Tu as oublié d'ajouter la variable APP_KEY. Retourne à l'étape 4.3

### "Database connection failed"
→ Attends 2-3 minutes que MySQL démarre, puis redéploie

### Page blanche ou erreur 500
→ Clique sur "View Logs" dans Railway pour voir l'erreur exacte

### "Permission denied" sur create-admin.sh
→ Tape : `chmod +x create-admin.sh` puis relance

---

## 📞 Besoin d'Aide ?

Si tu es bloqué :
1. Prends une capture d'écran de l'erreur
2. Montre-moi les logs Railway (onglet Deploys → Logs)
3. Dis-moi à quelle étape tu es

Je suis là pour t'aider ! 💪
