#!/bin/sh
# Mirrors the shared scenes, assets and project config into the 9:16 sibling project.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="$HERE/../slack-integration-vertical"
mkdir -p "$DEST"
rsync -a --delete "$HERE/compositions/" "$DEST/compositions/"
rsync -a --delete "$HERE/assets/" "$DEST/assets/"
cp "$HERE/hyperframes.json" "$HERE/package.json" "$HERE/frame.md" "$DEST/"
cp "$HERE/.hf-shared/index-vertical.html" "$DEST/index.html"
sed 's/"slack-integration"/"slack-integration-vertical"/g' "$HERE/meta.json" > "$DEST/meta.json"
echo "synced -> $DEST"
# The runtime stamps each scene root's data-width/height as pixels, so the 9:16 copy needs portrait roots.
sed -i '' 's/data-width="1920" data-height="1080"/data-width="1080" data-height="1920"/' "$DEST"/compositions/frames/*.html
echo "portrait roots stamped"
