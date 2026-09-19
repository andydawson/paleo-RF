#!/usr/bin/env bash
# Download the albedo radiative kernels read by scripts/8_radiative.R.
# Provenance, licences, sizes and the variables used: see the data assets
# table in README.md. Run from the repository root:
#   bash tools/download_kernels.sh
set -euo pipefail

DEST="data/radiative-kernels"
mkdir -p "$DEST/CAM5" "$DEST/CACKv1.0"

fetch () {  # fetch <url> <path> <description>
  if [ -s "$2" ]; then
    echo "already present, skipping: $2"
  else
    echo "downloading $3 -> $2"
    curl -L --fail --progress-bar -o "$2.part" "$1" && mv "$2.part" "$2"
  fi
}

# Smith (2019), HadGEM3-GA7.1 radiative kernels, CC-BY-4.0
# doi:10.5281/zenodo.3594673  (157 MB)
fetch "https://zenodo.org/api/records/3594673/files/HadGEM3-GA7.1_TOA_kernel_L19.nc/content" \
      "$DEST/HadGEM3-GA7.1_TOA_kernel_L19.nc" "HadGEM3-GA7.1 TOA kernel (L19)"

# Pendergrass (2017), CAM5 radiative kernels, CC-BY-4.0
# doi:10.5065/D6F47MT6  (21 MB, plus the 3 KB README)
fetch "https://zenodo.org/api/records/997902/files/alb.kernel.nc/content" \
      "$DEST/CAM5/alb.kernel.nc" "CAM5 albedo kernel"
fetch "https://zenodo.org/api/records/997902/files/README.txt/content" \
      "$DEST/CAM5/README.txt" "CAM5 kernel README"

# Bright and O'Halloran (2019), CACKv1.0, Environmental Data Initiative
# doi:10.6073/pasta/d77b84b11be99ed4d5376d77fe0043d8 (package edi.396.1)
# The EDI portal is behind a human-verification check and its anonymous API
# returns 403, so this one cannot be scripted. Download it by hand from
#   https://portal.edirepository.org/nis/mapbrowse?packageid=edi.396.1
# and save it as $DEST/CACKv1.0/CACKv1.0.nc
if [ ! -s "$DEST/CACKv1.0/CACKv1.0.nc" ]; then
  echo
  echo "MANUAL STEP: CACKv1.0.nc cannot be downloaded automatically."
  echo "  Get it from https://portal.edirepository.org/nis/mapbrowse?packageid=edi.396.1"
  echo "  and save it as $DEST/CACKv1.0/CACKv1.0.nc"
fi

echo
echo "Kernels present:"
find "$DEST" -name '*.nc' -size +0 -exec du -h {} + 2>/dev/null | sed 's/^/  /'
