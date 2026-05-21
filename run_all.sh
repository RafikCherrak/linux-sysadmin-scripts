#!/bin/bash
# ============================================
# Script principal : lance tout le TP en 1 commande
# ============================================
SCRIPT_GENERATION="./generate_logs.sh"
SCRIPT_PROCESS="./process_logs.sh"
N=4 # nombre de fichiers par service
S=6 # nombre de lignes par fichier
# --- Vérifier que les 2 scripts existent ---
if [ ! -f "$SCRIPT_GENERATION" ]; then
echo "Erreur : generate_logs.sh introuvable"
exit 1
fi
if [ ! -f "$SCRIPT_PROCESS" ]; then
echo "Erreur : process_logs.sh introuvable"
exit 1
fi
# ============================================
echo "=========================================="
echo " ÉTAPE 1 : Génération des logs"
echo "=========================================="
echo "--- Logs_prod ---"
$SCRIPT_GENERATION nginx prod $N $S
$SCRIPT_GENERATION mysql prod $N $S
$SCRIPT_GENERATION apache prod $N $S
echo "--- Logs_staging ---"
$SCRIPT_GENERATION nginx staging $N $S
$SCRIPT_GENERATION mysql staging $N $S
$SCRIPT_GENERATION apache staging $N $S
echo "--- Logs_dev ---"
$SCRIPT_GENERATION nginx dev $N $S
$SCRIPT_GENERATION mysql dev $N $S
$SCRIPT_GENERATION apache dev $N $S
# ============================================
echo ""
echo "=========================================="
echo " ÉTAPE 2 : Traitement et archivage"
echo "=========================================="
$SCRIPT_PROCESS Logs_prod
$SCRIPT_PROCESS Logs_staging
$SCRIPT_PROCESS Logs_dev
# ============================================
echo ""
echo "=========================================="
echo " ÉTAPE 3 : Vérification finale"
echo "=========================================="
echo "--- Arborescence Archive/ ---"
find Archive/ -type f
echo ""
echo "--- Permissions des fichiers ---"
find Archive/ -type f -name "*.log" | head -5 | xargs ls -l
echo ""
echo "--- Contenu d'un fichier exemple ---"
EXEMPLE=$(find Archive/ -type f -name "*.log" | head -1)
echo "Fichier : $EXEMPLE"
cat "$EXEMPLE"
echo ""
echo "✔ TP terminé avec succès !"