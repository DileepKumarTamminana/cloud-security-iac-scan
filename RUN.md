# ▶️ How to Run — Cloud Security IaC Scanning

Scans Terraform for cloud misconfigurations with **Checkov** and **tfsec**, comparing an `insecure/` config against a remediated `secure/` one.

> **Static analysis only — you never run `terraform apply`.** No AWS account or credentials are needed.

## Prerequisites
- Python (for Checkov) and/or the tfsec binary
- (Optional) Docker, to run either scanner without installing it

## Run the scans
```bash
# Checkov
pip install checkov
checkov -d .

# tfsec (native install)
tfsec .
```

### Run via Docker (no local install)
```bash
# Checkov
docker run --rm -v "$(pwd):/tf" bridgecrew/checkov -d /tf

# tfsec
docker run --rm -v "$(pwd):/src" aquasec/tfsec /src
```
> On Windows PowerShell replace `$(pwd)` with `${PWD}`; in cmd use `%cd%`.

## What you'll see
- **`insecure/main.tf`** → multiple failures: public-read S3 bucket, no encryption, no versioning, security group open to `0.0.0.0/0` on SSH, unencrypted EBS.
- **`secure/main.tf`** → the remediated equivalent (private + encrypted + versioned S3, restricted CIDR, encrypted EBS).

## Misconfiguration → fix reference
| Misconfiguration (insecure) | Fix (secure) |
|-----------------------------|--------------|
| Public-read S3 ACL | Private ACL + Public Access Block |
| No bucket encryption | SSE (AES256) enabled |
| No versioning | Versioning enabled |
| SSH open to `0.0.0.0/0` | Restricted to a variable CIDR |
| Unencrypted EBS | Encryption enabled |

## CI
`.github/workflows/iac-scan.yml` runs Checkov and tfsec on every push/PR and weekly. It uses **soft-fail** so the intentionally-insecure findings stay visible in the run and the Security tab. In a real repo you would gate (`soft_fail: false`) on `main`.
