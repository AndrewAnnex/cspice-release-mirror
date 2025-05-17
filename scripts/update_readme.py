#!/usr/bin/env python3
import sys, os, re

ART_DIR, README = sys.argv[1], sys.argv[2]

# read current README
with open(README, 'r') as f:
    text = f.read()

# build table header + rows
lines = []
lines.append("| Version | Platform | CPU Arch | File | MD5 | SHA256 |")
lines.append("|---------|----------|----------|------|-----|--------|")

# for each artifact
for fname in sorted(os.listdir(ART_DIR)):
    if not (fname.endswith('.zip') or fname.endswith('.tar.gz')):
        continue
    base = fname
    
    version  = base.split('_')[0]
    platform = base.split('_')[1]
    arch     = base.split('_')[2]

    with open(os.path.join(ART_DIR, base + '.md5')) as f:
        md5 = f.read().strip()
    with open(os.path.join(ART_DIR, base + '.sha256')) as f:
        sha256 = f.read().strip()
    download_url = f"https://raw.githubusercontent.com/AndrewAnnex/cspice-release-mirror/refs/heads/main/artifacts/{base}"
    print(download_url)
    lines.append(f"| {version} | {platform} | {arch} | [{base}]({download_url}) | `{md5}` | `{sha256}` |")

# replace the block between <!-- ARTIFACTS-START --> and <!-- ARTIFACTS-END -->
new_block = "\n".join(lines)
text = re.sub(
    r"<!-- ARTIFACTS-START -->.*?<!-- ARTIFACTS-END -->",
    f"<!-- ARTIFACTS-START -->\n{new_block}\n<!-- ARTIFACTS-END -->",
    text, flags=re.S
)

# write back
with open(README, 'w') as f:
    f.write(text)
