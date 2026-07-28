# ☁️ Cloud Security IaC Scanning

Detect cloud misconfigurations in **Terraform** before they ever reach an environment, using
**[Checkov](https://www.checkov.io/)** and **[tfsec](https://aquasecurity.github.io/tfsec/)** in a
GitHub Actions pipeline. This is a lightweight, open-source stand-in for enterprise cloud posture
tools such as **Prisma Cloud** — the same "shift-left" idea applied to Infrastructure as Code.

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat-square&logo=amazonwebservices&logoColor=white)
![Checkov](https://img.shields.io/badge/Checkov-6E4C9E?style=flat-square)
![tfsec](https://img.shields.io/badge/tfsec-1904DA?style=flat-square)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=githubactions&logoColor=white)

> ⚠️ **For education / demonstration only.** The [`insecure/`](insecure/) configuration contains
> deliberate misconfigurations so the scanners have something to flag. **Do not apply it.**

---

## 🎯 What this demonstrates

- Scanning Terraform for insecure cloud configuration with **Checkov** and **tfsec**
- A clear **insecure vs. remediated** comparison of the same resources
- Wiring IaC scanning into **CI** so misconfigurations are caught on every push/PR

---

## 🔍 Misconfigurations demonstrated → fixes

| # | Misconfiguration (`insecure/main.tf`) | Remediation (`secure/main.tf`) |
|---|----------------------------------------|--------------------------------|
| 1 | S3 bucket with **public-read** ACL | Private ACL + **S3 Public Access Block** |
| 2 | S3 bucket with **no encryption** | **SSE (AES256)** enabled by default |
| 3 | Security group open to **0.0.0.0/0** on port 22 | Ingress restricted to a **variable CIDR** |
| 4 | **Unencrypted** EBS volume | EBS volume with **encryption enabled** |
| 5 | No **versioning** on the bucket | **Versioning** enabled |

---

## ▶️ Run the scans locally

```bash
# Checkov (scans every .tf in the repo)
pip install checkov
checkov -d .

# tfsec
brew install tfsec        # or: docker run --rm -v "$PWD:/src" aquasec/tfsec /src
tfsec .
```

You should see findings in [`insecure/`](insecure/) and a clean(er) result in [`secure/`](secure/).

---

## 🗂️ Structure

```
cloud-security-iac-scan/
├── insecure/main.tf     # intentionally misconfigured (demo target)
├── secure/main.tf       # remediated equivalent
├── .checkov.yaml        # Checkov configuration
└── .github/workflows/iac-scan.yml
```

---

## 👤 Author

**Dileep Kumar Tamminana** — Cybersecurity Engineer
🔗 [github.com/DileepKumarTamminana](https://github.com/DileepKumarTamminana)

## 📄 License

MIT — see [LICENSE](LICENSE).
