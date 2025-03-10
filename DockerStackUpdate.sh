#!/bin/bash

# Sprawdzenie, czy podano nazwę pliku docker-compose
if [ -z "$1" ]; then
    echo "Użycie: $0 <plik-docker-compose.yml>"
    exit 1
fi

COMPOSE_FILE="$1"

# Sprawdzenie, czy plik istnieje
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "Błąd: Plik $COMPOSE_FILE nie istnieje!"
    exit 1
fi

# Pobranie nazwy katalogu stosu Docker Compose
COMPOSE_DIR=$(dirname "$COMPOSE_FILE")

echo "Identyfikacja działających kontenerów na podstawie pliku $COMPOSE_FILE..."
RUNNING_CONTAINERS=$(docker-compose -f "$COMPOSE_FILE" ps -q)

if [ -z "$RUNNING_CONTAINERS" ]; then
    echo "Brak uruchomionych kontenerów dla tego stosu."
else
    echo "Zatrzymywanie i usuwanie kontenerów..."
    docker-compose -f "$COMPOSE_FILE" down
fi

echo "Aktualizacja obrazów do najnowszych wersji..."
docker-compose -f "$COMPOSE_FILE" pull

echo "Identyfikacja katalogów overlay związanych z kontenerami tego stosu..."
for CONTAINER_ID in $RUNNING_CONTAINERS; do
    # Pobranie ścieżki warstwy overlay dla danego kontenera
    OVERLAY_DIR=$(docker inspect --format='{{.GraphDriver.Data.UpperDir}}' "$CONTAINER_ID" 2>/dev/null)

    if [ -n "$OVERLAY_DIR" ]; then
        # Pobranie głównego katalogu overlay
        OVERLAY_SUBDIR=$(echo "$OVERLAY_DIR" | awk -F'/upper' '{print $1}')
        
        if [ -d "$OVERLAY_SUBDIR" ]; then
            echo "Usuwanie plików diff i merged w katalogu: $OVERLAY_SUBDIR"
            sudo rm -rf "$OVERLAY_SUBDIR/diff" "$OVERLAY_SUBDIR/merged"
        fi
    else
        echo "Nie znaleziono katalogu overlay dla kontenera: $CONTAINER_ID"
    fi
done

echo "Usuwanie starych wersji obrazów Docker..."
docker image prune -a -f

echo "Uruchamianie stosu na najnowszych obrazach..."
docker-compose -f "$COMPOSE_FILE" up -d

echo "Gotowe! Stos został zaktualizowany i ponownie uruchomiony."