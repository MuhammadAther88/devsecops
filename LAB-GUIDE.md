# DevSecOps Workshop - Student Lab Guide

Bahria University Karachi | 3-hour workshop | Facilitator: Muhammad Ather

> This app is **intentionally vulnerable**. Use it only for this workshop. Never deploy it.
> All keys in this repo are fake.

You need: a GitHub account and a browser. Nothing to install. All scans run on GitHub Actions.

Pattern for every lab: **break it, detect it, fix it.**

---

## Lab 0: Setup (10 min)

1. Fork the workshop repo to your account (top right, Fork).
2. In your fork: **Actions** tab, click "I understand my workflows, enable them".
3. Make any small edit (e.g. add a line to README) and commit to `main`.
4. Go to **Actions** and confirm the `CI` workflow runs green (it runs the 2 tests).

Done when: green tick on `CI`.

---

## Lab 1: Secrets scanning (25 min)

**Break:** open `app/app.py`. Find `INTERNAL_API_KEY`. A key is hardcoded in source. Anyone with repo access has it, and it also lives forever in git history.

**Detect:**
1. Create `.github/workflows/secrets.yml` (copy from `solutions/lab1-secrets.yml` if stuck).
2. Commit to `main`. Open the run in the Actions tab.
3. The job fails. Read the log: file, line, rule name (secret value is redacted).

**Fix:**
1. In `app.py` replace the key with `os.environ["INTERNAL_API_KEY"]` (add `import os`).
2. Commit. Run again. Does it still fail? Yes: the key is still in **git history**.
3. Discussion: deleting a leaked secret is not enough. Correct response = **rotate/revoke the key first**, then clean up code (and history if needed).
4. To get green in class: add a `.gitleaksignore` entry with the fingerprint from the log (only acceptable because the key is fake).

Bonus: GitHub **Settings > Code security** > enable Secret scanning and Push protection.

---

## Lab 2: SAST, code scanning (30 min)

**Break:** `app.py` has 3 bugs: SQL injection in `/search`, XSS in `/hello`, `debug=True`.

**Detect:**
1. Create `.github/workflows/sast.yml` (see `solutions/lab2-sast.yml`).
2. Commit. Check the run: Semgrep lists each finding with file, line and rule.

**Exploit (safe, local to your own fork's code only):** read the code and explain how `/search?q=' OR '1'='1` changes the SQL query.

**Fix:**
1. SQLi: use a parameterized query: `_conn.execute("SELECT title, body FROM notes WHERE title LIKE ?", (f"%{term}%",))`
2. XSS: `from markupsafe import escape` then `"<h1>Hello " + str(escape(name)) + "</h1>"`
3. `debug=True` becomes `debug=False`, and bind to `127.0.0.1`.
4. Commit and confirm the job goes green and tests still pass.

---

## Lab 3: Dependency scanning, SCA (25 min)

**Break:** `requirements.txt` pins old versions (e.g. `requests==2.19.1`, `PyYAML==5.3.1`).

**Detect:**
1. Create `.github/workflows/sca.yml` (see `solutions/lab3-sca.yml`). `pip-audit` lists CVE IDs and the fixed version.
2. Look up one CVE ID on https://osv.dev and read what it means.

**Automate:**
1. Add `.github/dependabot.yml` (see `solutions/dependabot.yml`).
2. In **Settings > Code security**, enable Dependabot alerts and security updates.
3. Look at the **Security** tab and the Dependabot PRs.

**Fix:** bump versions, e.g. `requests>=2.32`, `PyYAML>=6.0.1`, `Flask>=3.0`. Run the tests. If a bump breaks something, that is the real cost of old dependencies.

---

## Lab 4: Container security (20 min)

**Mini Docker primer:** an image is a packaged app plus its OS libraries. If the base OS layer is old, you ship its vulnerabilities.

**Break:** open the `Dockerfile`: old `python:3.8` base, runs as root.

**Detect:**
1. Create `.github/workflows/container.yml` (see `solutions/lab4-container.yml`).
2. Trivy reports Dockerfile misconfigurations (e.g. no `USER`) and OS/library CVEs.

**Fix:**
1. Use `FROM python:3.12-slim`.
2. Add a non-root user before `CMD`: `RUN useradd -m appuser` then `USER appuser`.
3. Commit and re-run. Compare the number of findings before and after.

---

## Wrap-up: security gate (10 min)

1. **Settings > Branches > Add rule** for `main`: require a pull request and require status checks (secrets, sast, sca, container).
2. Open a PR that adds a new fake secret. Watch the check block the merge.

You now have a pipeline: **commit > secrets scan > SAST > SCA > container scan > merge gate.**

Take-home ideas: DAST with OWASP ZAP, IaC scanning, SBOM generation, signing images.
