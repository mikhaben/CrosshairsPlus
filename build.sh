#!/bin/bash

# CrosshairsPlus Build Script
# Creates a clean addon package for CurseForge upload

set -e

PROJECT_NAME="CrosshairsPlus"
ADDON_DIR="${PROJECT_NAME}"
BUILD_DIR="build"
TOC_FILE="${ADDON_DIR}/${PROJECT_NAME}.toc"
STAGE_DIR="${BUILD_DIR}/${PROJECT_NAME}"
VERSION=$(grep "## Version:" "$TOC_FILE" | sed 's/.*Version: *//' | tr -d '\r\n\t ?')
TIMESTAMP=$(date -u +"%Y-%m-%d")
ZIP_NAME="${PROJECT_NAME}_${VERSION}_${TIMESTAMP}.zip"
ZIP_PATH="${BUILD_DIR}/${ZIP_NAME}"
SEPARATOR="======================================"

echo "$SEPARATOR"
echo "Building ${PROJECT_NAME} v${VERSION}"
echo "Build date: ${TIMESTAMP}"
echo "$SEPARATOR"

# Create build directory
echo "Creating build directory..."
rm -rf "${BUILD_DIR}"
mkdir -p "${STAGE_DIR}"

# Core addon files
echo "Copying addon files..."
cp "$TOC_FILE" "${ADDON_DIR}/Core.lua" "${ADDON_DIR}/Crosshair.xml" "${STAGE_DIR}/"
cp -r "${ADDON_DIR}/Crosshair" "${STAGE_DIR}/"
cp -r "${ADDON_DIR}/Settings" "${STAGE_DIR}/"

# Libraries
echo "Copying libraries..."
cp -r "${ADDON_DIR}/Libs" "${STAGE_DIR}/"

# Clean up .DS_Store from all copied directories
find "${STAGE_DIR}" -name ".DS_Store" -delete

# Assets (excluding .DS_Store)
echo "Copying assets..."
mkdir -p "${STAGE_DIR}/Assets"
find "${ADDON_DIR}/Assets" -type f \( -name "*.tga" -o -name "*.blp" \) -exec cp {} "${STAGE_DIR}/Assets/" \;

# LoadOnDemand sub-addon (CrosshairsPlus_Range)
RANGE_ADDON="CrosshairsPlus_Range"
RANGE_STAGE="${BUILD_DIR}/CrosshairsPlus_Range"
if [ -d "${RANGE_ADDON}" ]; then
    echo "Copying CrosshairsPlus_Range sub-addon..."
    mkdir -p "${RANGE_STAGE}"
    cp -r "${RANGE_ADDON}/"* "${RANGE_STAGE}/"
    find "${RANGE_STAGE}" -name ".DS_Store" -delete
fi

# Create ZIP
echo "Creating ZIP package..."
cd "${BUILD_DIR}"
zip -r "${ZIP_NAME}" "${PROJECT_NAME}/" "CrosshairsPlus_Range/" -q
cd ..

# Clean up staging folders
echo "Cleaning up..."
rm -rf "${STAGE_DIR}" "${RANGE_STAGE}"

# Results
echo ""
echo "$SEPARATOR"
echo "Build complete!"
echo "$SEPARATOR"
echo "Package: ${ZIP_PATH}"
echo "Size: $(du -h "${ZIP_PATH}" | cut -f1)"
echo ""
echo "Contents:"
unzip -l "${ZIP_PATH}" | head -30
echo ""
echo "Ready to upload to CurseForge!"
echo "$SEPARATOR"
