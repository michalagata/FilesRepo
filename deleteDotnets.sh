#!/bin/bash

# Check if a parameter was provided
if [ -z "$1" ]; then
    echo "Usage: $0 [dotnet_major_version]"
    echo "Example: $0 6"
    exit 1
fi

DOTNET_MAJOR_VERSION=$1

# Known .NET installation locations
LOCATIONS=(
    "/usr/share/dotnet"
    "$HOME/.dotnet"
)

echo "Searching for all .NET versions matching major version $DOTNET_MAJOR_VERSION in known locations..."

for LOCATION in "${LOCATIONS[@]}"; do
    if [ -d "$LOCATION" ]; then
        echo "Checking location: $LOCATION"
        remove_dotnet_version "$LOCATION"
    else
        echo "Skipping non-existent location: $LOCATION"
    fi
done

echo "Operation completed."

remove_dotnet_version() {
    TARGET_FOLDER=$1
    SHARED_PATH="$TARGET_FOLDER/shared"

    if [ ! -d "$SHARED_PATH" ]; then
        echo "No shared folder found in $TARGET_FOLDER"
        return
    fi

    # Find and delete folders matching the specified major version
    find "$SHARED_PATH" -type d -name "$DOTNET_MAJOR_VERSION.*" | while read -r DIR; do
        echo "Found matching folder: $DIR"
        rm -rf "$DIR" && echo "Successfully deleted $DIR" || echo "Failed to delete $DIR"
    done
}