#!/bin/bash
# snapper-cleanup.sh
# Mantiene solo l'ultimo snapshot snapper (escluso lo snapshot 0 = sistema live)
# Uso: sudo ./snapper-cleanup.sh [--dry-run] [--config NOME]
#usa sudo snapper list per vedere tutti i snap presenti
set -euo pipefail

CONFIG="root"
DRY_RUN=false
MIN_SNAPSHOTS=2   # Minimo di snapshot prima di fare pulizia

# Parsing argomenti
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --config) CONFIG="$2"; shift ;;
        *) echo "Uso: $0 [--dry-run] [--config NOME]"; exit 1 ;;
    esac
    shift
done

echo "=== Snapper Cleanup ==="
echo "Config: $CONFIG"
$DRY_RUN && echo "MODALITA' DRY-RUN: nessuno snapshot verrà eliminato"
echo ""

# Ottieni la lista degli snapshot (escludi riga 0 = current e le intestazioni)
# Prende solo la prima colonna (ID) saltando le prime 4 righe di header
SNAPSHOT_IDS=$(snapper -c "$CONFIG" list | awk 'NR>4 && $1 != "0" {print $1}' | grep -E '^[0-9]+$' | sort -n)

if [[ -z "$SNAPSHOT_IDS" ]]; then
    echo "Nessuno snapshot trovato (escluso 0). Niente da fare."
    exit 0
fi

COUNT=$(echo "$SNAPSHOT_IDS" | wc -l)
echo "Snapshot trovati (escluso 0): $COUNT"
echo "IDs: $(echo $SNAPSHOT_IDS | tr '\n' ' ')"
echo ""

# Controlla se ci sono abbastanza snapshot da giustificare la pulizia
if [[ $COUNT -lt $MIN_SNAPSHOTS ]]; then
    echo "Meno di $MIN_SNAPSHOTS snapshot presenti. Niente da cancellare."
    exit 0
fi

# L'ultimo (più recente) = il numero più alto
LAST_ID=$(echo "$SNAPSHOT_IDS" | tail -n 1)

# Tutti tranne l'ultimo
TO_DELETE=$(echo "$SNAPSHOT_IDS" | head -n -1)

echo "Snapshot da MANTENERE: $LAST_ID"
echo ""
echo "Snapshot da ELIMINARE:"
echo "$TO_DELETE"
echo ""

if $DRY_RUN; then
    echo "[DRY-RUN] Comando che verrebbe eseguito:"
    echo "  snapper -c $CONFIG delete $(echo $TO_DELETE | tr '\n' ' ')"
    exit 0
fi

# Chiedi conferma
read -rp "Procedere con l'eliminazione? [s/N] " CONFIRM
if [[ ! "$CONFIRM" =~ ^[sSyY]$ ]]; then
    echo "Operazione annullata."
    exit 0
fi

# Elimina tutti tranne l'ultimo
echo ""
echo "Eliminazione in corso..."
snapper -c "$CONFIG" delete $(echo "$TO_DELETE" | tr '\n' ' ')

echo ""
echo "=== Fatto! ==="
snapper -c "$CONFIG" list

