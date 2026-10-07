#!/usr/bin/env bash
# Instructor lab setup for Kali Linux. Installs the scanners locally so you can
# rehearse every lab before the workshop. Students do NOT need this: their
# scans run on GitHub-hosted runners.
set -euo pipefail

GITLEAKS_VERSION="8.18.4"

echo "[1/5] System packages"
sudo apt-get update -y
sudo apt-get install -y git curl python3 python3-venv python3-pip docker.io gh || true

echo "[2/5] Python venv with scanners (semgrep, pip-audit, pytest)"
python3 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate
pip install --upgrade pip
pip install semgrep pip-audit pytest

echo "[3/5] Gitleaks ${GITLEAKS_VERSION}"
if ! command -v gitleaks >/dev/null; then
  curl -sSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" | tar -xz gitleaks
  sudo mv gitleaks /usr/local/bin/
fi

echo "[4/5] Trivy (runs as a container, nothing to install)"
sudo docker pull aquasec/trivy:latest

echo "[5/5] Versions"
gitleaks version
semgrep --version
pip-audit --version
sudo docker --version
echo
echo "Done. Activate the venv with:  source .venv/bin/activate"
echo "Trivy usage: sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v \$PWD:/src aquasec/trivy image workshop-app:local"
