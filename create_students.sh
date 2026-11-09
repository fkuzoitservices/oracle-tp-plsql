#!/bin/bash
# Script de création automatique des comptes étudiants Oracle 23ai pour toutes les classes

CONTAINER_NAME="oracle23ai"

# Parcourir automatiquement tous les fichiers CSV de classes présents dans le dossier
for CSV_FILE in student*.csv; do
    if [ ! -f "$CSV_FILE" ]; then
        echo "Aucun fichier de classe trouvé."
        continue
    fi

    echo "=== Traitement du fichier : $CSV_FILE ==="

    while IFS=';' read -r username firstname lastname email password course1 role1 group1 cohort1; do
        # Nettoyage des espaces et retours chariot
        username=$(echo "$username" | tr -d '\r' | xargs)
        password=$(echo "$password" | tr -d '\r' | xargs)

        # Ignorer la ligne d'en-tête ou les lignes vides
        if [ "$username" == "username" ] || [ -z "$username" ]; then
            continue
        fi

        echo "Création du compte Oracle : $username ..."

        # Exécution dans la PDB FREEPDB1
        podman exec -i $CONTAINER_NAME sqlplus -s / as sysdba <<EOF
ALTER SESSION SET CONTAINER = FREEPDB1;
CREATE USER $username IDENTIFIED BY "$password";
GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE PROCEDURE TO $username;
ALTER USER $username QUOTA UNLIMITED ON USERS;
EXIT;
EOF

    done < "$CSV_FILE"
done

echo "Tous les fichiers de classes ont été traités !"
