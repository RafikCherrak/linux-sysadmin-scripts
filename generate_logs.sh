#!/bin/bash
# --- Paramètres ---
SERVICE=$1 # ex: nginx
ENV=$2 # ex: prod
N=$3 # nombre de fichiers
S=$4 # nombre de lignes par fichier


# --- Vérification : on s'assure qu'il y a bien 4 arguments ---
        if [ $# -ne 4 ]; then
        echo "Usage: $0 <service> <env> <N> <S>"
        exit 1
        fi


# --- Création du dossier Logs_ENV ---
    DOSSIER="Logs_${ENV}"
    mkdir -p "$DOSSIER"
# --- Tableaux des niveaux et messages possibles ---
    LEVELS=("INFO" "WARN" "ERROR")
    MESSAGES_INFO=(
        "Service started successfully"
        "Connection established"
        "Request processed in 120ms"
        "Cache refreshed"
    )
    MESSAGES_WARN=(
        "High memory usage detected"
        "Slow query detected"
        "Retry attempt 2 of 3"
        "Disk usage above 80 percent"
    )
    MESSAGES_ERROR=(
        "Connection timeout on port 80"
        "Database unreachable"
        "Authentication failed"
        "Segmentation fault detected"
    )


# --- Boucle : créer N fichiers ---

    for i in $(seq 1 $N); do

# Capturer le timestamp exact au moment de création

    TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S-%3N")
    NOM="${SERVICE}-${TIMESTAMP}.log"
    CHEMIN="${DOSSIER}/${NOM}"
    touch "$CHEMIN"

# Remplir le fichier avec S lignes
    for j in $(seq 1 $S); do

# Choisir un niveau aléatoire (RANDOM % 3 donne 0, 1 ou 2)

    INDEX=$((RANDOM % 3))
    LEVEL=${LEVELS[$INDEX]}
    DATE_LOG=$(date +"%Y-%m-%d %H:%M:%S")

# Choisir un message selon le niveau

    if [ "$LEVEL" = "INFO" ]; then
    MSG_INDEX=$((RANDOM % ${#MESSAGES_INFO[@]}))
    MSG=${MESSAGES_INFO[$MSG_INDEX]}
    elif [ "$LEVEL" = "WARN" ]; then
    MSG_INDEX=$((RANDOM % ${#MESSAGES_WARN[@]}))
    MSG=${MESSAGES_WARN[$MSG_INDEX]}
    else
    MSG_INDEX=$((RANDOM % ${#MESSAGES_ERROR[@]}))
    MSG=${MESSAGES_ERROR[$MSG_INDEX]}
    fi
    echo "[${DATE_LOG}] [${LEVEL}] ${SERVICE} : ${MSG}" >> "$CHEMIN"
    done
    echo "Créé : $CHEMIN"
    sleep $(echo "scale=3; 300/1000" | bc) # attendre 300ms
    done
    echo "✔ $N fichiers log créés dans $DOSSIER"