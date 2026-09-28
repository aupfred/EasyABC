#!/bin/bash
set -e

ARCH="$1"

case "$ARCH" in
  arm64)
    BIN_DIR="mac_arm64"
    DMG_SUFFIX="arm64"
    ;;
  x86_64)
    BIN_DIR="mac_x86_64"
    DMG_SUFFIX="x86_64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

VERSION=$(grep "^program_version[[:space:]]*=" easy_abc.py | sed -E "s/.*'([^']+)'.*/\1/")
VOL_NAME="EasyABC ${VERSION}"
DMG_NAME="EasyABC_${VERSION}_${DMG_SUFFIX}.dmg"
echo "DMG_NAME=${DMG_NAME}" >> "$GITHUB_ENV"

echo "Start application building"
echo "Building py2app"
python setup.py py2app

echo "Creating lproj files to enable translations"
for file in `ls -1 locale/`; do 
   mkdir "dist/EasyABC.app/Contents/Resources/$file.lproj" 
done
mkdir "dist/EasyABC.app/Contents/Resources/English.lproj"   

echo "Copying binaries to Helpers"
mkdir -p dist/EasyABC.app/Contents/Helpers
#cp -f bin/$BIN_DIR/* dist/EasyABC.app/Contents/Helpers/
#find bin/$BIN_DIR -maxdepth 1 -type f -exec cp {} dist/EasyABC.app/Contents/Helpers \;
echo "Fusing architecture-specific helper binaries into Universal Binaries..."
for file in bin/mac_arm64/*; do
    filename=$(basename "$file")
    if [ -f "bin/mac_x86_64/$filename" ]; then
        lipo -create "bin/mac_arm64/$filename" "bin/mac_x86_64/$filename" -output "dist/EasyABC.app/Contents/Helpers/$filename"
        echo "  Created universal binary for: $filename"
    fi
done

echo "Helpers content:"
ls -lh dist/EasyABC.app/Contents/Helpers

echo "Start generation of DMG: ${DMG_NAME}"

rm -rf dmg_staging
mkdir -p dmg_staging

if [ -d "dmg" ]; then
  cp -R dmg/* dmg_staging/
fi

if [ ! -f "dmg_staging/Ghostscript.pkg" ]; then
    echo "  Warning: Ghostscript.pkg not present, downloading it from https://pages.uoregon.edu/koch/"
    curl -L https://pages.uoregon.edu/koch/Ghostscript-10.07.1.pkg -o "dmg_staging/Ghostscript.pkg"
fi

cp -R dist/EasyABC.app dmg_staging/
#xattr -cr dmg_staging/EasyABC.app
#codesign --force --deep --sign - dmg_staging/EasyABC.app

echo "Creating DMG for arch: $ARCH"
echo "Using EasyABC version: $VERSION"
create-dmg \
  --volname "$VOL_NAME" \
  --background "img/abclogo.png" \
  --window-pos 200 120 \
  --window-size 450 420 \
  --text-size 12 \
  --icon-size 40 \
  --icon "EasyABC.app" 50 120 \
  --app-drop-link 150 120 \
  --icon "README" 50 250 \
  --icon "Ghostscript.pkg" 150 250 \
  --icon "Install_Ghostscript.webloc" 300 250 \
  "$DMG_NAME" \
  "dmg_staging/"

echo "Generated DMG: ${DMG_NAME}"
ls -lh "$DMG_NAME"