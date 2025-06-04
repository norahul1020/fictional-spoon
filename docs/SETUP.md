# 🚀 Tenable WAS POC - Setup Guide

## Prerequisites

- GitHub repository with Actions enabled
- Docker installed locally (for testing)
- Tenable.io account with WAS license
- Your Tenable Access Key and Secret Key

## Quick Setup

### 1. Repository Setup

1. Create a new GitHub repository
2. Clone this POC package to your repository
3. Push to GitHub

### 2. Configure GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions

Add these **required** secrets:
```
TENABLE_ACCESS_KEY=your_tenable_access_key
TENABLE_SECRET_KEY=your_tenable_secret_key
```

Add these **optional** secrets:
```
GOREST_API_TOKEN=your_gorest_token_from_gorest.co.in
APP_USERNAME=testuser
APP_PASSWORD=testpass123
```

### 3. Run Your First Test

1. Go to Actions tab in your GitHub repository
2. Select "🔐 Basic Auth Test Only"
3. Click "Run workflow"
4. Watch the scan execute and download results

## Available Workflows

| Workflow | Purpose | Authentication Method |
|----------|---------|----------------------|
| `test-all-auth-methods.yml` | Complete test suite | All methods |
| `test-basic-auth.yml` | Basic auth only | HTTPBin Basic Auth |
| `test-form-auth.yml` | Form auth only | DVWA Form Login |
| `test-api-auth.yml` | API auth only | GoRest API |

## Local Testing

Run test applications locally:
```bash
cd test-apps
docker-compose up -d
```

This starts:
- DVWA on http://localhost:8080
- Simple login app on http://localhost:5000  
- Nginx basic auth on http://localhost:8081

## Validation

Test all endpoints:
```bash
./scripts/validate-endpoints.sh
```

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.
