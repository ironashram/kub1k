import sys
import requests
import hcl2
from semver import VersionInfo
ver = VersionInfo.parse


def find(lst, key):
    for i, dic in enumerate(lst):
        if dic.get(key) is not None:
            return i
    return -1


K3S_RELEASE_URL = "https://api.github.com/repos/k3s-io/k3s/releases"
TF_VARIABLES = "terraform/variables.tf"
NOVERSION = ver("0.0.0")

response = requests.get(K3S_RELEASE_URL, timeout=30)
if response.raise_for_status() is not None:
    sys.exit(1)
tags = response.json()

versions = []
for tag in tags:
    try:
        version = ver(tag["tag_name"].lstrip("v"))
        if version.prerelease is None:
            versions.append(version)
    except ValueError:
        pass

if versions:
    latest = f"v{str(max(versions))}"
    print(f"Latest: {latest}")
else:
    sys.exit(1)

with open(TF_VARIABLES, "r", encoding="utf8") as rfile:
    tfvars = hcl2.load(rfile, with_meta=True)

current_version = NOVERSION

try:
    k3s_version_index = find(tfvars["variable"], "k3s_version")
except ValueError:
    print("k3s_version variable not found")
    sys.exit(1)


current_version = ver(tfvars["variable"][k3s_version_index]["k3s_version"]["default"].lstrip("v"))

print(f"Current: v{current_version}")

if max(versions) > current_version and current_version != NOVERSION:
    tfvars["variable"][k3s_version_index]["k3s_version"]["default"] = latest

    with open(TF_VARIABLES, "w", encoding="utf8") as wfile:
        ast_out = hcl2.reverse_transform(tfvars)
        wfile.write(hcl2.writes(ast_out))

    print(f"Updated: v{current_version} -> {latest}")
