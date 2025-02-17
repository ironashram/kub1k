import sys
import io
import requests
import hcl2
from semver import VersionInfo

URL = "https://hub.docker.com/v2/repositories/rancher/k3s/tags/?page_size=100"
NOVERSION = VersionInfo.parse("0.0.0")
response = requests.get(URL, timeout=30)
if response.raise_for_status() is not None:
    sys.exit(1)
tags = response.json()["results"]

versions = []
for tag in tags:
    try:
        version = VersionInfo.parse(tag["name"].lstrip("v"))
        if version.prerelease.startswith("k3s") and "-" not in version.prerelease:
            versions.append(version)
    except ValueError:
        pass

if versions:
    latest_str = f"v{str(max(versions))}".replace("-", "+")
    print(f"Latest: v{str(max(versions))}")
else:
    sys.exit(1)

with open("terraform/variables.tf", "r", encoding="utf8") as rfile:
    content = rfile.read()

tfvars = hcl2.load(io.StringIO(content))
lines = content.splitlines(True)
current_version = NOVERSION
for variable in tfvars["variable"]:
    if "k3s_version" in variable:
        current_version = VersionInfo.parse(variable["k3s_version"]["default"].lstrip("v"))
        break
print(f"Current: v{current_version}")

if max(versions) > current_version and current_version != NOVERSION:
    with open("terraform/variables.tf", "w", encoding="utf8") as wfile:
        replace_version = False
        for line in lines:
            if replace_version:
                line = f'  default = "{latest_str}"\n'
                replace_version = False
            elif "k3s_version" in line:
                replace_version = True
            wfile.write(line)
    print(f"Updated: v{str(max(versions))}")
