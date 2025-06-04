# 🔐 Secrets and Environment Variables Guide

## Required Secrets

### TENABLE_ACCESS_KEY (Required)
Your Tenable.io Access Key

**How to get:**
1. Login to https://cloud.tenable.com
2. Go to Settings → My Account → API Keys
3. Copy your Access Key

**Value format:**
```
accessKey=1234567890abcdef1234567890abcdef12345678
```

### TENABLE_SECRET_KEY (Required)  
Your Tenable.io Secret Key

**How to get:**
1. Same location as Access Key
2. Copy your Secret Key

**Value format:**
```
secretKey=abcdef1234567890abcdef1234567890abcdef12
```

## Optional Secrets

### GOREST_API_TOKEN (Optional)
Free API token from GoRest for API testing

**How to get:**
1. Go to https://gorest.co.in/
2. Click "Get Access Token"
3. Sign up with email
4. Copy the token

**Value format:**
```
Bearer_token_here_from_gorest_website
```

### Test Application Credentials (Optional)
```
APP_USERNAME=testuser
APP_PASSWORD=testpass123
DVWA_USERNAME=admin
DVWA_PASSWORD=password
```

## Public Test Endpoints (No secrets needed)

These endpoints work without any API keys:

| Service | URL | Purpose |
|---------|-----|---------|
| HTTPBin Basic Auth | `https://httpbin.org/basic-auth/testuser/testpass123` | Basic authentication testing |
| HTTPBin Digest Auth | `https://httpbin.org/digest-auth/auth/testuser/testpass123` | Digest authentication testing |
| HTTPBin Cookies | `https://httpbin.org/cookies` | Cookie handling testing |
| HTTPBin Bearer | `https://httpbin.org/bearer` | Bearer token testing |
| GoRest Public API | `https://gorest.co.in/public/v2/users` | API testing (read-only) |

## Setting Secrets in GitHub

1. Go to your repository
2. Click Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add name and value
5. Click "Add secret"

## Testing Secrets

After setting secrets, test with the basic auth workflow:
1. Actions → "🔐 Basic Auth Test Only" → "Run workflow"
2. Check logs for authentication success
