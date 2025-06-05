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
1234567890abcdef1234567890abcdef12345678
```

### TENABLE_SECRET_KEY (Required)  
Your Tenable.io Secret Key

**How to get:**
1. Same location as Access Key
2. Copy your Secret Key

**Value format:**
```
abcdef1234567890abcdef1234567890abcdef12
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
your_token_from_gorest_website
```

## Public Test Endpoints (No secrets needed)

These endpoints work without any API keys:

| Service | URL | Credentials | Config File |
|---------|-----|-------------|-------------|
| HTTPBin Basic Auth | `https://httpbin.org/basic-auth/testuser/testpass123` | testuser/testpass123 | `basic-auth.conf` |
| HTTPBin Digest Auth | `https://httpbin.org/digest-auth/auth/testuser/testpass123` | testuser/testpass123 | `digest-auth.conf` |
| HTTPBin Cookies | `https://httpbin.org/cookies` | Pre-set cookie | `cookie-auth.conf` |
| HTTPBin Bearer | `https://httpbin.org/bearer` | Test token | `bearer-token.conf` |
| GoRest Public API | `https://gorest.co.in/public/v2/users` | Optional token | `api-key.conf` |

## Setting Secrets in GitHub

1. Go to your repository
2. Click Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add name and value
5. Click "Add secret"

**Screenshot locations:**
```
Repository → Settings → Secrets and variables → Actions → New repository secret
```

## Using Secrets in Configuration Files

### Method 1: Environment Variable Replacement
Configuration file with placeholder:
```hocon
# config/api-key.conf
credentials {
  api_key {
    auth_headers = {
      Authorization = "Bearer ${GOREST_API_TOKEN}"
    }
  }
}
```

Workflow replacement:
```yaml
- name: Process Config
  run: |
    cp config/api-key.conf tenable_was.conf
    sed -i "s/\${GOREST_API_TOKEN}/${{ secrets.GOREST_API_TOKEN }}/g" tenable_was.conf
```

### Method 2: Docker Environment Variables
Pass secrets as environment variables to the scanner:
```yaml
- name: Run Scan
  run: |
    docker run \
      -v $(pwd):/scanner \
      -e WAS_MODE=cicd \
      -e ACCESS_KEY="${{ secrets.TENABLE_ACCESS_KEY }}" \
      -e SECRET_KEY="${{ secrets.TENABLE_SECRET_KEY }}" \
      -e API_TOKEN="${{ secrets.GOREST_API_TOKEN }}" \
      tenable/was-scanner:latest
```

## Security Best Practices

### ✅ Do This
- Store all sensitive data in GitHub Secrets
- Use environment variable placeholders in config files
- Rotate API keys regularly
- Use minimal permissions for API tokens
- Test with dummy credentials first

### ❌ Don't Do This
- Never commit real credentials to git
- Don't use production credentials for testing
- Don't share secrets in plain text
- Don't use the same credentials across multiple environments

## Testing Secrets

### Test Tenable Credentials
```bash
# Test API connectivity (replace with your real keys)
curl -X GET \
  "https://cloud.tenable.com/users" \
  -H "X-ApiKeys: accessKey=YOUR_ACCESS_KEY;secretKey=YOUR_SECRET_KEY"
```

### Test GoRest Token
```bash
# Test API token (replace with your real token)
curl -X GET \
  "https://gorest.co.in/public/v2/users" \
  -H "Authorization: Bearer YOUR_GOREST_TOKEN"
```

### Validate in Workflow
After setting secrets, test with the minimal workflow:
1. Actions → "🧪 Minimal Test" → "Run workflow"
2. Check logs for authentication success
3. Verify scan results are generated

## Troubleshooting Secrets

### Secret Not Found
```
Error: Secret TENABLE_ACCESS_KEY not found
```
**Solution:** Verify secret name matches exactly in repository settings

### Invalid Credentials
```
Error: Authentication failed
```
**Solution:** 
1. Verify credentials are correct in Tenable.io
2. Check account has WAS license
3. Ensure no extra spaces in secret values

### Token Expired
```
Error: Token is expired or invalid
```
**Solution:**
1. Generate new API token
2. Update GitHub secret with new value
3. Re-run workflow

## Configuration Examples

### Simple App with Form Login
```hocon
# Store these in GitHub Secrets:
# APP_USERNAME=your_app_user
# APP_PASSWORD=your_app_pass

credentials {
  login_form {
    login_parameters = {
      username = "${APP_USERNAME}"
      password = "${APP_PASSWORD}"
    }
  }
}
```

### API with Multiple Headers
```hocon
# Store these in GitHub Secrets:
# API_TOKEN=your_api_token
# CLIENT_ID=your_client_id

credentials {
  api_key {
    auth_headers = {
      Authorization = "Bearer ${API_TOKEN}"
      X-Client-ID = "${CLIENT_ID}"
      X-API-Version = "v2"
    }
  }
}
```

### Cookie Authentication
```hocon
# Store in GitHub Secrets:
# SESSION_COOKIE=sessionid=abc123;csrf=xyz789

credentials {
  cookie_auth {
    cookie = "${SESSION_COOKIE}"
  }
}
```

## Managing Multiple Environments

### Development Secrets
```
TENABLE_ACCESS_KEY_DEV=dev_access_key
TENABLE_SECRET_KEY_DEV=dev_secret_key
APP_USERNAME_DEV=dev_user
```

### Production Secrets  
```
TENABLE_ACCESS_KEY_PROD=prod_access_key
TENABLE_SECRET_KEY_PROD=prod_secret_key
APP_USERNAME_PROD=prod_user
```

### Environment-Specific Workflows
```yaml
# Use different secrets based on branch
env:
  ACCESS_KEY: ${{ github.ref == 'refs/heads/main' && secrets.TENABLE_ACCESS_KEY_PROD || secrets.TENABLE_ACCESS_KEY_DEV }}
```

## Quick Reference

| Secret Name | Required | Purpose | Where to Get |
|-------------|----------|---------|--------------|
| `TENABLE_ACCESS_KEY` | ✅ Yes | Tenable API access | cloud.tenable.com → Settings → API Keys |
| `TENABLE_SECRET_KEY` | ✅ Yes | Tenable API secret | cloud.tenable.com → Settings → API Keys |
| `GOREST_API_TOKEN` | ❌ No | GoRest API testing | gorest.co.in → Get Access Token |
| `APP_USERNAME` | ❌ No | Test app credentials | Your test application |
| `APP_PASSWORD` | ❌ No | Test app credentials | Your test application |

## Next Steps

1. ✅ Set up required Tenable secrets
2. ✅ Test with minimal workflow
3. ✅ Add optional secrets as needed
4. ✅ Create custom configurations using secrets
5. ✅ Set up environment-specific secrets if needed
