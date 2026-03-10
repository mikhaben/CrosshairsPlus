#!/bin/bash

# CrosshairsPlus Deploy Script
# Builds the addon and deploys it to the local WoW AddOns folder

set -e

ADDONS_DIR="/Volumes/Main-500GB-SamsT7/Games/World of Warcraft/_retail_/Interface/AddOns"
BUILD_DIR="build"
ADDON_NAME="CrosshairsPlus"
RANGE_NAME="CrosshairsPlus_Range"

# Verify the AddOns directory exists
if [ ! -d "$ADDONS_DIR" ]; then
    echo "Error: AddOns directory not found. Is the drive mounted?"
    echo "  $ADDONS_DIR"
    exit 1
fi

# Build
./build.sh

# Find the zip that was just created
ZIP_FILE=$(ls -t "${BUILD_DIR}"/*.zip 2>/dev/null | head -1)
if [ -z "$ZIP_FILE" ]; then
    echo "Error: No zip file found in ${BUILD_DIR}/"
    exit 1
fi

# Remove old addons from AddOns folder
echo "Removing old ${ADDON_NAME}..."
rm -rf "${ADDONS_DIR}/${ADDON_NAME}"
rm -rf "${ADDONS_DIR}/${RANGE_NAME}"

# Unzip into AddOns folder
echo "Deploying to WoW AddOns..."
unzip -qo "$ZIP_FILE" -d "$ADDONS_DIR"

echo "Deployed: ${ADDONS_DIR}/${ADDON_NAME}"
echo "Deployed: ${ADDONS_DIR}/${RANGE_NAME}"
