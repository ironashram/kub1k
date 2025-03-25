import sys
import io
import requests
import hcl2
from semver import VersionInfo

K3S_RELEASE_URL = "https://api.github.com/repos/k3s-io/k3s/releases"
TF_VARIABLES = "../terraform/variables.tf"
NOVERSION = VersionInfo.parse("0.0.0")

response = requests.get(K3S_RELEASE_URL, timeout=30)
if response.raise_for_status() is not None:
    sys.exit(1)
tags = response.json()

versions = []
for tag in tags:
    try:
        version = VersionInfo.parse(tag["tag_name"].lstrip("v"))
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
    with open(TF_VARIABLES, "w", encoding="utf8") as wfile:
        replace_flag = False
        for line in lines:
            if replace_flag:
                line = f'  default = "{latest}"\n'
                replace_flag = False
            elif "k3s_version" in line:
                replace_flag = True
            wfile.write(line)
    print(f"Updated: v{current_version} -> {latest}")
