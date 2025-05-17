#!/usr/bin/env zsh
ART=artifacts
README="README.md"
SCRIPT="./scripts/update_readme.py"
export GZIP=-9
VERSIONS=(67)
declare -A platforms
platforms[mac_x64]='MacIntel_OSX_AppleC_64bit/packages/cspice.tar.Z'
platforms[mac_arm]='MacM1_OSX_clang_64bit/packages/cspice.tar.Z'
platforms[lin_x64]='PC_Linux_GCC_64bit/packages/cspice.tar.Z'
platforms[cyg_x64]='PC_Cygwin_GCC_64bit/packages/cspice.tar.gz'
platforms[win_x64]='PC_Windows_VisualC_64bit/packages/cspice.zip'

for key value in ${(kv)platforms}; do
  echo "$key -> $value"
  plat="${value}"
  url="https://naif.jpl.nasa.gov/pub/naif/misc/toolkit_N0067/C/${plat}"
  base="N67_${key}_${url##*/}"
  echo "downloading $url to $base with ext ${base##*.}"
  curl -fsSL "$url" -o "$ART/$base"
  if [[ "${base##*.}" == "Z" ]]; then
    echo "converting $base to ${base%.tar.Z}.tar.gz"
    gunzip -c "$ART/$base" | gzip -9 > "$ART/${base%.tar.Z}.tar.gz"
    echo "cleaning up $base"
    rm $ART/$base
    base="${base%.tar.Z}.tar.gz"
  fi
  echo "checksumming $base"
  openssl dgst -md5 -r "$ART/$base"   | awk '{print $1}' > "$ART/$base.md5"
  openssl dgst -sha256 -r "$ART/$base" | awk '{print $1}' > "$ART/$base.sha256"
done

echo "updating $README"
python3 "$SCRIPT" "$ART" "$README"
