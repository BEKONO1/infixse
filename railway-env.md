# Variables d'environnement Railway - Infix LMS

## 1. Variables OBLIGATOIRES (à copier dans Railway)

```
APP_NAME=Infix LMS
APP_ENV=production
APP_DEBUG=false
APP_URL=${RAILWAY_STATIC_URL}
APP_KEY=
```

> Pour APP_KEY : exécutez `php artisan key:generate --show` localement et copiez le résultat

---

## 2. Base de données MySQL

### Dans Railway :
1. Cliquez sur **New** → **Database** → **MySQL**
2. Railway génère automatiquement : `MYSQLHOST`, `MYSQLPORT`, `MYSQLDATABASE`, `MYSQLUSER`, `MYSQLPASSWORD`
3. Les variables sont automatiquement disponibles pour votre app

---

## 3. Variables de session et cache

```
SESSION_DRIVER=file
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
LOG_CHANNEL=stack
BROADCAST_DRIVER=null
SESSION_LIFETIME=120
```

---

## 4. Timezone

```
TIME_ZONE=Europe/Paris
```

---

## 5. Email (SMTP Gmail)

```
MAIL_DRIVER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=votre-email@gmail.com
MAIL_PASSWORD=votre-mot-de-passe-application
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@votre-domaine.com
MAIL_FROM_NAME="Infix LMS"
```

> Pour Gmail : activez l'authentification à 2 facteurs et créez un "mot de passe d'application"

---

## 6. Redis (optionnel - pour les performances)

Dans Railway : **New** → **Database** → **Redis**

Railway génère automatiquement : `REDISHOST`, `REDISPORT`, `REDIS_PASSWORD`

```
CACHE_DRIVER=redis
SESSION_DRIVER=redis
```

---

## 7. AWS S3 (optionnel - pour le stockage)

```
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_DEFAULT_REGION=eu-west-3
AWS_BUCKET=your-bucket-name
```

---

## 8. Stripe (paiements)

```
STRIPE_KEY=pk_live_xxx
STRIPE_SECRET=sk_live_xxx
```

---

## 9. PayPal (paiements)

```
PAYPAL_CLIENT_ID=your-client-id
PAYPAL_CLIENT_SECRET=your-client-secret
IS_PAYPAL_LOCALHOST=false
```

---

## 10. Zoom (vidéoconférence)

```
ZOOM_CLIENT_KEY=your-zoom-key
ZOOM_CLIENT_SECRET=your-zoom-secret
```

---

## 11. BigBlueButton (vidéoconférence)

```
BBB_SECURITY_SALT=your-salt
BBB_SERVER_BASE_URL=https://your-bbb-server.com/bigbluebutton/
```

---

## 12. Pusher (WebSockets temps réel)

```
PUSHER_APP_ID=your-app-id
PUSHER_APP_KEY=your-app-key
PUSHER_APP_SECRET=your-app-secret
PUSHER_APP_CLUSTER=eu
```

---

## 13. Vimeo (vidéos)

```
VIMEO_CLIENT=your-vimeo-client
VIMEO_SECRET=your-vimeo-secret
VIMEO_ACCESS=your-vimeo-access
VIMEO_COMMON_USE=true
```

---

## ✅ Checklist de déploiement

- [ ] Base de données MySQL ajoutée dans Railway
- [ ] APP_KEY générée et ajoutée
- [ ] Variables obligatoires configurées
- [ ] Email SMTP configuré (optionnel)
- [ ] Services de paiement configurés (optionnel)
- [ ] Redémarrer le service après les changements

---

## 🔧 Commandes utiles après déploiement

Dans Railway Console :

```bash
# Migrer la base de données
php artisan migrate --force

# Vider le cache
php artisan cache:clear
php artisan config:clear

# Optimiser pour la production
php artisan optimize
```

---

## 📌 Note importante

Remplacez `${RAILWAY_STATIC_URL}` par votre URL Railway réelle si nécessaire, ou laissez Railway gérer automatiquement cette variable.
