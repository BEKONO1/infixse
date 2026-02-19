# 🚀 RÉCAPITULATIF - Commandes Essentielles

## Avant de commencer (sur ton ordinateur)

```bash
# 1. Se placer dans le dossier du projet
cd "C:\Users\Antoine\Music\InfixLMS"

# 2. Ajouter les fichiers Railway
git add railway.json nixpacks.toml start.sh nginx.conf .env.railway .railwayignore README-RAILWAY.md create-admin.sh GUIDE-DEPLOIEMENT.md

# 3. Commit
git commit -m "Add Railway deployment configuration"

# 4. Push
git push origin main
```

## Sur Railway (dans le navigateur)

### Étape 1 : Créer le projet
- Va sur https://railway.app
- New Project → Deploy from GitHub repo
- Choisis ton repo InfixLMS

### Étape 2 : Ajouter les services
- New → Database → MySQL
- New → Database → Redis  
- New → Volume → Nom: storage → Mount: /app/storage

### Étape 3 : Configurer les variables
- Clique sur ton service → Onglet "Variables"
- Bulk Add → Copie le contenu de `.env.railway`
- New Variable → APP_KEY = [générer une clé]

### Étape 4 : Déployer (automatique !)
- Attends que le build soit vert
- L'URL apparaît en haut à droite

### Étape 5 : Créer l'admin
- Clique sur ton service → Onglet "Shell"
- Tape : `bash create-admin.sh`
- Remplis les infos demandées

### Étape 6 : Se connecter
- Ouvre l'URL
- Login avec l'email et mot de passe créés

---

## Commandes utiles dans le terminal Railway

```bash
# Voir les logs
tail -f storage/logs/laravel.log

# Vider le cache
php artisan cache:clear
php artisan config:clear

# Relancer les migrations
php artisan migrate --force

# Créer un nouvel admin
php artisan tinker
>>> App\Models\User::create(['name'=>'Admin','email'=>'test@test.com','password'=>bcrypt('password'),'role_id'=>1]);
```
