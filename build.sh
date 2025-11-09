#!/bin/bash

# CrosshairsPlus Build Script
# Creates a clean addon package for CurseForge upload

set -e

PROJECT_NAME="CrosshairsPlus"
BUILD_DIR="build"
VERSION=$(grep "## Version:" CrosshairsPlus.toc | cut -d' ' -f3)

echo "======================================"
echo "Building ${PROJECT_NAME} v${VERSION}"
echo "======================================"

# Create build directory
echo "Creating build directory..."
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/${PROJECT_NAME}"

# Copy necessary files
echo "Copying addon files..."

# Core addon files
cp CrosshairsPlus.toc "${BUILD_DIR}/${PROJECT_NAME}/"
cp Core.lua "${BUILD_DIR}/${PROJECT_NAME}/"
cp Utils.lua "${BUILD_DIR}/${PROJECT_NAME}/"
cp Crosshair.lua "${BUILD_DIR}/${PROJECT_NAME}/"
cp Crosshair.xml "${BUILD_DIR}/${PROJECT_NAME}/"
cp Settings.lua "${BUILD_DIR}/${PROJECT_NAME}/"

# Copy Assets folder (excluding .DS_Store)
echo "Copying assets..."
mkdir -p "${BUILD_DIR}/${PROJECT_NAME}/Assets"
find Assets -type f \( -name "*.tga" -o -name "*.blp" \) -exec cp {} "${BUILD_DIR}/${PROJECT_NAME}/Assets/" \;

# Create ZIP file
echo "Creating ZIP package..."
cd "${BUILD_DIR}"
zip -r "${PROJECT_NAME}-${VERSION}.zip" "${PROJECT_NAME}/" -q
cd ..

# Clean up temporary folder
echo "Cleaning up..."
rm -rf "${BUILD_DIR}/${PROJECT_NAME}"

# Show results
echo ""
echo "======================================"
echo "Build complete!"
echo "======================================"
echo "Package: ${BUILD_DIR}/${PROJECT_NAME}-${VERSION}.zip"
echo "Size: $(du -h "${BUILD_DIR}/${PROJECT_NAME}-${VERSION}.zip" | cut -f1)"
echo ""
echo "Contents:"
unzip -l "${BUILD_DIR}/${PROJECT_NAME}-${VERSION}.zip" | head -20
echo ""
echo "Ready to upload to CurseForge!"
echo "======================================"
