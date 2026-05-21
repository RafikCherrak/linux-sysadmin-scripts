#!/bin/bash
# --- Paramètre : dossier à traiter ---
    DOSSIER=$1


# --- Vérifications ---
    if [ $# -ne 1 ]; then
    echo "Usage: $0 <Logs_env>"
    exit 1
    fi

    if [ ! -d "$DOSSIER" ]; then
    echo "Erreur : le dossier '$DOSSIER' n'existe pas."
    exit 1
    fi

    # --- Extraire l'environnement (Logs_prod → prod) ---

    ENV=$(echo "$DOSSIER" | cut -d'_' -f2)


# --- Créer le dossier Archive ---

    mkdir -p "Archive"

# --- Parcourir tous les fichiers .log ---

    for FILEPATH in "${DOSSIER}"/*.log; do
    [ -f "$FILEPATH" ] || continue # sécurité si dossier vide
    FILENAME=$(basename "$FILEPATH")
    SANS_EXT="${FILENAME%.log}"

# Extraire le service (avant le premier "-")

    SERVICE=$(echo "$SANS_EXT" | cut -d'-' -f1)

# Extraire les composantes de la date

        DATE_PART=$(echo "$SANS_EXT" | cut -d'-' -f2-)
        ANNEE=$(echo "$DATE_PART" | cut -d'-' -f1) # 2024
        MOIS=$(echo "$DATE_PART" | cut -d'-' -f2) # 01
        JOUR=$(echo "$DATE_PART" | cut -d'-' -f3) # 15
        HEURE=$(echo "$DATE_PART" | cut -d'-' -f4) # 10
        MINUTE=$(echo "$DATE_PART" | cut -d'-' -f5) # 23
        SECONDE=$(echo "$DATE_PART" | cut -d'-' -f6) # 45
        MS=$(echo "$DATE_PART" | cut -d'-' -f7) # 123

# Nouveau nom : HHMMSSms.log

    NOUVEAU_NOM="${HEURE}${MINUTE}${SECONDE}${MS}.log"

# Dossier destination dans Archive/

    DEST_DIR="Archive/${DOSSIER}/${SERVICE}/${ANNEE}/${MOIS}/${JOUR}"
    mkdir -p "$DEST_DIR"

# Chemin absolu de l'ancien fichier

    ANCIEN_CHEMIN=$(realpath "$FILEPATH")

# Lire le contenu original

    CONTENU=$(cat "$FILEPATH")

# Compter les niveaux de log

        NB_INFO=$(echo "$CONTENU" | grep -c "\[INFO\]")
        NB_WARN=$(echo "$CONTENU" | grep -c "\[WARN\]")
        NB_ERROR=$(echo "$CONTENU" | grep -c "\[ERROR\]")
        NB_TOTAL=$((NB_INFO + NB_WARN + NB_ERROR))

# Déplacer le fichier vers sa destination

    mv "$FILEPATH" "${DEST_DIR}/${NOUVEAU_NOM}"

# Réécrire le contenu enrichi (4 lignes entête + contenu + résumé)

        {
        echo "SOURCE: ${FILENAME}"
        echo "PATH: ${ANCIEN_CHEMIN}"
        echo "ENV: ${ENV}"
        echo "GENERATOR: generate_logs.sh"
        echo "---"
        echo "$CONTENU"
        echo "--- SUMMARY ---"
        echo "INFO: ${NB_INFO}"
        echo "WARN: ${NB_WARN}"
        echo "ERROR: ${NB_ERROR}"
        echo "TOTAL: ${NB_TOTAL}"
        } > "${DEST_DIR}/${NOUVEAU_NOM}"

# Permissions : prop + groupe lisent, autres rien

    chmod 440 "${DEST_DIR}/${NOUVEAU_NOM}"
    echo "✔ ${FILENAME} → ${DEST_DIR}/${NOUVEAU_NOM}"
    done
    echo ""
    echo "✔ Traitement de '$DOSSIER' terminé dans Archive/"