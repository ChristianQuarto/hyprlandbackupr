#!/bin/bash
#!/bin/bash

cartella="/home/chris/.config/fastfetch/icons"

# Verifica che la cartella esista
if [ ! -d "$cartella" ]; then
    echo "ERRORE: La cartella '$cartella' non esiste"
    ls -la /home/chris/.config/fastfetch/
    exit 1
fi


# Conta le immagini trovate


# Seleziona immagine casuale
immagine=$(find "$cartella" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" \) | shuf -n 1)

if [ -z "$immagine" ]; then
    echo "NESSUNA immagine trovata con le estensioni supportate"
    exit 1
fi

echo "$immagine"
