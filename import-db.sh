#!/bin/bash
# Script d'import de base de données vers Railway MySQL
# Usage: ./import-db.sh [chemin_vers_fichier_sql]

set -e

echo "🗄️  Import de la base de données vers Railway MySQL..."

# Détecte si on est dans l'environnement Railway ou local
if [ -n "$RAILWAY_ENVIRONMENT" ]; then
    echo "✅ Environnement Railway détecté"
    IN_RAILWAY=true
else
    echo "ℹ️  Environnement local - Utilisation de Railway CLI"
    IN_RAILWAY=false
fi

# Vérifie Railway CLI si on est en local
if [ "$IN_RAILWAY" = false ]; then
    if ! command -v railway &> /dev/null; then
        echo "❌ Erreur: Railway CLI n'est pas installé"
        echo "Installez-le avec: npm install -g @railway/cli"
        echo "Ou visitez: https://docs.railway.app/develop/cli"
        exit 1
    fi
    
    # Vérifie la connexion
    if ! railway status &> /dev/null; then
        echo "❌ Erreur: Non connecté à Railway"
        echo "Exécutez: railway login"
        exit 1
    fi
fi

# Détermine le fichier SQL à importer
SQL_FILE="${1:-database/infixlms.sql}"

if [ ! -f "$SQL_FILE" ]; then
    # Essaie avec extension .gz
    if [ -f "${SQL_FILE}.gz" ]; then
        SQL_FILE="${SQL_FILE}.gz"
        echo "📦 Fichier compressé trouvé: $SQL_FILE"
    else
        echo "❌ Erreur: Fichier SQL non trouvé: $SQL_FILE"
        echo "Usage: $0 [chemin_vers_fichier_sql]"
        exit 1
    fi
fi

echo "📁 Fichier source: $SQL_FILE"

# Récupère les variables Railway
if [ "$IN_RAILWAY" = true ]; then
    DB_HOST="$MYSQLHOST"
    DB_PORT="$MYSQLPORT"
    DB_NAME="$MYSQLDATABASE"
    DB_USER="$MYSQLUSER"
    DB_PASS="$MYSQLPASSWORD"
else
    echo "🔍 Récupération des variables Railway..."
    DB_HOST=$(railway variables get MYSQLHOST 2>/dev/null || echo "")
    DB_PORT=$(railway variables get MYSQLPORT 2>/dev/null || echo "3306")
    DB_NAME=$(railway variables get MYSQLDATABASE 2>/dev/null || echo "")
    DB_USER=$(railway variables get MYSQLUSER 2>/dev/null || echo "")
    DB_PASS=$(railway variables get MYSQLPASSWORD 2>/dev/null || echo "")
fi

# Vérifie les variables
if [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ]; then
    echo "❌ Erreur: Variables MySQL Railway non trouvées"
    echo "Assurez-vous d'avoir créé un service MySQL dans Railway"
    exit 1
fi

echo "📊 Connexion à: $DB_HOST:$DB_PORT"
echo "🗃️  Base de données: $DB_NAME"

# Fonction d'import
import_database() {
    echo "📥 Import en cours..."
    
    if [[ "$SQL_FILE" == *.gz ]]; then
        # Fichier compressé
        if command -v pv &> /dev/null; then
            pv "$SQL_FILE" | gunzip | mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME"
        else
            echo "⏳ Décompression et import (sans barre de progression)..."
            zcat "$SQL_FILE" | mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME"
        fi
    else
        # Fichier non compressé
        if command -v pv &> /dev/null; then
            pv "$SQL_FILE" | mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME"
        else
            echo "⏳ Import en cours (sans barre de progression)..."
            mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SQL_FILE"
        fi
    fi
}

# Exécute l'import
if import_database; then
    echo ""
    echo "✅ Import terminé avec succès !"
    echo ""
    echo "📊 Statistiques de la base de données:"
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
        SELECT 
            table_name AS 'Table',
            ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)',
            table_rows AS 'Rows'
        FROM information_schema.TABLES 
        WHERE table_schema = '$DB_NAME'
        ORDER BY (data_length + index_length) DESC
        LIMIT 10;
    " 2>/dev/null || echo "Impossible d'afficher les statistiques"
    
    echo ""
    echo "🎉 Base de données prête !"
    echo "🚀 Vous pouvez maintenant déployer votre application"
else
    echo ""
    echo "❌ Erreur lors de l'import"
    echo "Vérifiez les logs ci-dessus"
    exit 1
fi
