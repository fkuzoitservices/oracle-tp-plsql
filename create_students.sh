#!/bin/bash
# Script de création automatique des 99 comptes étudiants Oracle 23ai
# Source : students.csv (format: username,password)

CONTAINER_NAME="oracle23ai"
CSV_FILE="students.csv"

if [ ! -f "$CSV_FILE" ]; then
    echo "Erreur : Le fichier $CSV_FILE est introuvable."
    exit 1
fi

while IFS=',' read -r username password; do
    # Nettoyage des espaces et retours chariot
    username=$(echo "$username" | tr -d '\r' | xargs)
    password=$(echo "$password" | tr -d '\r' | xargs)

    # Ignorer la ligne d'en-tête du fichier CSV
    if [ "$username" == "username" ] || [ -z "$username" ]; then
        continue
    fi

    echo "Création du compte Oracle : $username ..."

    # Exécution des commandes SQL dans la PDB FREEPDB1 du conteneur Podman
    podman exec -i $CONTAINER_NAME sqlplus -s / as sysdba <<EOF
ALTER SESSION SET CONTAINER = FREEPDB1;
CREATE USER $username IDENTIFIED BY "$password";
GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE PROCEDURE TO $username;
ALTER USER $username QUOTA UNLIMITED ON USERS;
EXIT;
EOF

done < "$CSV_FILE"

echo "Provisionnement des 99 comptes étudiants effectué avec succès."
