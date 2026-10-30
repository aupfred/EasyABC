#!/bin/bash
# Build a universal2 (arm64 + x86_64) wxPython installation inside the current venv.
# wxPython does not publish universal2 wheels, so we download both native wheels
# and fuse every .so/.dylib with lipo (standard workaround for py2app universal builds).
# Prerequisite: active venv + requirements.txt already installed (or --no-deps).
# Usage: source venv/bin/activate && ./stitch_wxpython.sh
set -euo pipefail

if [ -z "${VIRTUAL_ENV:-}" ]; then
    echo "ERROR: run inside an active venv" >&2
    exit 1
fi

WX=$(python -c "import importlib.metadata as m; print(m.version('wxPython'))" 2>/dev/null || echo 4.2.4)
echo "Building universal2 wxPython ${WX}"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

python -m pip download "wxPython==${WX}" --platform macosx_11_0_arm64    --only-binary=:all: --dest "$T/arm"
python -m pip download "wxPython==${WX}" --platform macosx_10_10_x86_64 --only-binary=:all: --dest "$T/intel"

unzip -o "$T"/arm/*wxPython*.whl   -d "$T/a" >/dev/null
unzip -o "$T"/intel/*wxPython*.whl -d "$T/i" >/dev/null

SITE=$(python -c "import site; print(site.getsitepackages()[0])")

# Start from the arm64 wheel (arm64 and x86_64 wheels share the same file layout)
rm -rf "$SITE/wx" "$SITE"/wxPython*.dist-info
cp -R "$T/a/wx" "$SITE/"
if [ -d "$T"/a/wxPython*.dist-info ]; then
    cp -R "$T"/a/wxPython*.dist-info "$SITE/"
fi

# Fuse every native extension with its x86_64 counterpart
cd "$SITE/wx"
find . -type f \( -name "*.so" -o -name "*.dylib" \) | while read -r f; do
    if [ -f "$T/i/wx/$f" ]; then
        echo "  lipo: $f"
        lipo -create "$T/i/wx/$f" "$f" -output "$f"
    else
        echo "  WARNING: no x86_64 counterpart for $f (left arm64-only)" >&2
    fi
done

python -c "import wx; print('wxPython OK:', wx.version())"
echo "Universal2 wxPython installed in $SITE"