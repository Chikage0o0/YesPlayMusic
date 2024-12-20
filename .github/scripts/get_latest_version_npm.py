import os
import sys
import requests

if len(sys.argv) < 2:
    print("Usage: python script.py <package_name>")
    sys.exit(1)

# 从命令行参数获取npm包名
package_name = sys.argv[1]
api_url = f"https://registry.npmjs.org/{package_name}"

response = requests.get(api_url)
if response.status_code != 200:
    print("Package not found")
    sys.exit(1)

data = response.json()
latest_version = data.get('dist-tags', {}).get('latest')

if latest_version:
    github_output = os.getenv("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a") as f:
            f.write(f"version={latest_version}\n")
    else:
        print(f"version={latest_version}")
else:
    print("No suitable version found")
    sys.exit(1)