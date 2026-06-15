#!/bin/sh
set -eu

# Xcode Cloud's actool (Xcode 26.2) crashes when compiling Icon Composer .icon
# bundles alongside AppIcon.appiconset. Keep the source in the repo for local
# Liquid Glass builds, but move it out of the synchronized Shuowen/ folder
# before CI compiles asset catalogs.
icon_path="Shuowen/Resources/AppIcon.icon"
staging_path="Design/AppIcon.icon"

if [ ! -d "$icon_path" ]; then
  exit 0
fi

mkdir -p Design
mv "$icon_path" "$staging_path"
echo "Moved AppIcon.icon to Design/ for Xcode Cloud actool compatibility."
