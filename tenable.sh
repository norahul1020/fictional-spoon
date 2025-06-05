cat > docs/CONFIGURATION-GUIDE.md << 'EOF'
# 🔧 Configuration Files Guide

This guide explains how to use and customize the separate configuration files for Tenable WAS scans.

## 📁 Available Configuration Files

| File | Purpose | Target | Authentication |
|------|---------|--------|----------------|
| `basic-auth.conf` | Basic HTTP Authentication | HTTPBin.org | Username/Password |
| `digest-auth.conf` | Digest HTTP Authentication | HTTPBin.org | Username/Password |
| `form-auth.conf` | Simple Form Login | Local Flask App | Form Submission |
| `dvwa-form-auth.conf` | DVWA Form Login | DVWA Application | Form Submission |
| `cookie-auth.conf` | Cookie Authentication | HTTPBin.org | Session Cookie |
| `api-key.conf` | API Key Authentication | GoRest API | Bearer Token |
| `bearer-token.conf` | Bearer Token Auth | HTTPBin.org | Authorization Header |
| `minimal-test.conf` | Quick Test | HTTPBin.org | Basic Auth (minimal) |
| `base-config.conf` | Template | Variable | Template for custom configs |

## 🎯 How to Use Configuration Files

### Method 1: GitHub Actions (Recommended)
The workflows automatically use the appropriate configuration files:

```bash
# Automatically uses config/basic-auth.conf
run: cp config/basic-auth.conf tenable_was.conf
```

### Method 2: Local Testing
Copy any configuration file and use it directly:

```bash
# Use basic authentication config
cp config/basic-auth.conf tenable_was.conf

# Run scan locally (requires Docker)
docker run \
  -v $(pwd):/scanner \
  -e WAS_MODE=cicd \
  -e ACCESS_KEY=your_access_key \
  -e SECRET_KEY=your_secret_key \
  tenable/was-scanner:latest
```

### Method 3: Custom Configuration
Create your own configuration based on the templates:

```bash
# Start with base template
cp config/base-config.conf config/my-custom.conf

# Edit the file to add your authentication
# Then use it in workflows or locally
```

## ✏️ Customizing Configuration Files

### Basic Structure
All configuration files follow this HOCON format:

```hocon
target = "https://your-target-url.com"
vulnerability_threshold = "Medium"
template_id = "web-app-scan"
results_visibility = dashboard

scan {
  assessment { enable = true }
  audit { forms = true headers = true }
  http { request_timeout = 30 }
  scope { page_limit = 100 }
  timeout = "00:30:00"
  
  credentials {
    # Authentication method specific settings
  }
}
```

### Authentication Types

#### Basic Authentication
```hocon
credentials {
  basic_auth {
    username = "your_username"
    password = "your_password"
  }
}
```

#### Form Authentication
```hocon
credentials {
  login_form {
    login_url = "https://example.com/login"
    login_parameters = {
      username = "your_username"
      password = "your_password"
      submit = "Login"
    }
    login_check = "Dashboard"
    login_check_url = "https://example.com/dashboard"
  }
}
```

#### Cookie Authentication
```hocon
credentials {
  cookie_auth {
    cookie = "sessionid=abc123; Path=/; Domain=example.com"
    login_check = "authenticated"
    login_check_url = "https://example.com/profile"
  }
}
```

#### API Key Authentication
```hocon
credentials {
  api_key {
    auth_headers = {
      Authorization = "Bearer your_api_token"
      Content-Type = "application/json"
    }
    login_check = "success"
    login_check_url = "https://api.example.com/user"
  }
}
```

## 🔄 Environment Variables in Configs

You can use environment variables in configuration files:

```hocon
# Use placeholder that gets replaced at runtime
target = "${TARGET_URL}"
vulnerability_threshold = "${VULN_THRESHOLD}"

credentials {
  api_key {
    auth_headers = {
      Authorization = "Bearer ${API_TOKEN}"
    }
  }
}
```

Then in your workflow:
```yaml
- name: Process Config
  run: |
    cp config/api-key.conf tenable_was.conf
    sed -i "s/\${API_TOKEN}/${{ env.API_TOKEN }}/g" tenable_was.conf
```

## 🎛️ Common Configuration Options

### Scan Timeout
```hocon
scan {
  timeout = "01:30:00"  # 1.5 hours
}
```

### Page Limits
```hocon
scan {
  scope {
    page_limit = 500  # Limit pages to scan
  }
}
```

### Request Settings
```hocon
scan {
  http {
    request_timeout = 45        # Seconds
    request_concurrency = 5     # Parallel requests
  }
}
```

### Exclusions
```hocon
scan {
  scope {
    exclude_path_patterns = [
      "logout", "admin", "wp-admin"
    ]
    exclude_file_extensions = [
      js, css, png, jpg, gif
    ]
  }
}
```

## 🛠️ Testing Your Configuration

### Syntax Validation
```bash
# Check if config file has required fields
grep -q "scan {" config/your-config.conf && echo "✅ Valid structure"

# Test with minimal scanner
./scripts/test-config-files.sh
```

### Local Testing
```bash
# Test configuration locally
cp config/your-config.conf tenable_was.conf

# Run with verbose logging
docker run \
  -v $(pwd):/scanner \
  -e WAS_MODE=cicd \
  -e ACCESS_KEY=your_key \
  -e SECRET_KEY=your_secret \
  tenable/was-scanner:latest
```

## 🚨 Troubleshooting

### Common Issues

1. **"missing field `scan`" error**
   - Ensure your config has a `scan { }` block
   - Check HOCON syntax (use `=` not `:`)

2. **"UUID parsing failed" error**
   - Remove `config_id` field or use proper UUID format
   - Let Tenable generate the ID automatically

3. **Authentication failures**
   - Verify credentials in your config file
   - Test authentication manually with curl
   - Check target URL is accessible

4. **Target unreachable**
   - Verify target URL in config file
   - For local apps, use `--network host` in Docker

### Debug Steps
```bash
# 1. Validate config syntax
cat config/your-config.conf

# 2. Test target accessibility
curl -I https://your-target-url.com

# 3. Check scanner logs
tail -50 scanner.log

# 4. Verify environment variables
echo $TENABLE_ACCESS_KEY | cut -c1-10
```

## �� Examples

### Custom E-commerce Site
```hocon
target = "https://shop.example.com"
vulnerability_threshold = "High"

scan {
  timeout = "02:00:00"
  scope {
    page_limit = 1000
    exclude_path_patterns = ["checkout", "payment"]
  }
  
  credentials {
    login_form {
      login_url = "https://shop.example.com/login"
      login_parameters = {
        email = "test@example.com"
        password = "TestPassword123"
        login = "Sign In"
      }
      login_check = "My Account"
      login_check_url = "https://shop.example.com/account"
    }
  }
}
```

### API Testing
```hocon
target = "https://api.example.com/v1/"
vulnerability_threshold = "Medium"

scan {
  scope { page_limit = 200 }
  audit {
    headers = true
    jsons = true
    links = false
  }
  
  credentials {
    api_key {
      auth_headers = {
        Authorization = "Bearer ${API_TOKEN}"
        X-API-Version = "1.0"
        Content-Type = "application/json"
      }
      login_check = "authenticated"
      login_check_url = "https://api.example.com/v1/user/profile"
    }
  }
}
```

## 🎉 Best Practices

1. **Keep credentials separate** - Use environment variables for sensitive data
2. **Start simple** - Begin with minimal-test.conf and add complexity
3. **Test locally first** - Validate configs before using in CI/CD
4. **Use descriptive names** - Name your custom configs clearly
5. **Version control** - Track changes to configuration files
6. **Document custom configs** - Add comments explaining your settings

## 🔗 Related Documentation

- [Setup Guide](SETUP.md) - Initial setup instructions
- [Secrets Guide](SECRETS.md) - Managing sensitive data
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and solutions
EOF

cat > docs/SETUP.md << 'EOF'
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
```

### 3. Run Your First Test

1. Go to Actions tab in your GitHub repository
2. Select "🔐 Basic Auth Test Only"
3. Click "Run workflow"
4. Watch the scan execute and download results

## Available Workflows

| Workflow | Configuration Used | Purpose |
|----------|-------------------|---------|
| `test-all-auth-methods.yml` | Multiple configs | Complete test suite |
| `test-basic-auth.yml` | `config/basic-auth.conf` | Basic auth only |
| `test-form-auth.yml` | `config/dvwa-form-auth.conf` | DVWA form login |
| `test-api-auth.yml` | `config/api-key.conf` | GoRest API testing |
| `test-minimal.yml` | `config/minimal-test.conf` | Quick validation |

## Configuration Files Structure

```
config/
├── base-config.conf          # Template for custom configs
├── basic-auth.conf           # HTTPBin basic authentication
├── digest-auth.conf          # HTTPBin digest authentication  
├── form-auth.conf            # Simple Flask app form login
├── dvwa-form-auth.conf       # DVWA form authentication
├── cookie-auth.conf          # HTTPBin cookie authentication
├── api-key.conf              # GoRest API key authentication
├── bearer-token.conf         # HTTPBin bearer token auth
└── minimal-test.conf         # Minimal test configuration
```

## Local Testing

### Start Test Applications
```bash
cd test-apps
docker-compose up -d
```

This starts:
- **DVWA** on http://localhost:8080 (admin/password)
- **Simple Login App** on http://localhost:5000 (testuser/testpass123)
- **Nginx Basic Auth** on http://localhost:8081 (testuser/testpass123)

### Test Configuration Files
```bash
# Validate all config files
./scripts/test-config-files.sh

# Test specific configuration
cp config/basic-auth.conf tenable_was.conf
docker run \
  -v $(pwd):/scanner \
  -e WAS_MODE=cicd \
  -e ACCESS_KEY=your_key \
  -e SECRET_KEY=your_secret \
  tenable/was-scanner:latest
```

### Validate Endpoints
```bash
./scripts/validate-endpoints.sh
```

## Creating Custom Configurations

### 1. Start with Base Template
```bash
cp config/base-config.conf config/my-custom.conf
```

### 2. Customize for Your Application
Edit the configuration file to match your target application:

```hocon
target = "https://your-app.com"
vulnerability_threshold = "Medium"

scan {
  credentials {
    login_form {
      login_url = "https://your-app.com/login"
      login_parameters = {
        username = "your_username"
        password = "your_password"
      }
      login_check = "Dashboard"
      login_check_url = "https://your-app.com/dashboard"
    }
  }
}
```

### 3. Test Your Configuration
```bash
cp config/my-custom.conf tenable_was.conf
# Run local test or create custom workflow
```

## Troubleshooting

### Common Issues

1. **Config file errors**: Use `./scripts/test-config-files.sh`
2. **Authentication failures**: Check credentials in config files
3. **Target unreachable**: Verify URLs in configuration files
4. **Scan timeouts**: Adjust timeout values in config files

### Debug Steps
```bash
# 1. Test endpoints
./scripts/validate-endpoints.sh

# 2. Check config syntax
grep -q "scan {" config/your-config.conf

# 3. View detailed logs
tail -50 scanner.log
```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.

## Configuration Management

### Best Practices
- Keep sensitive data in GitHub Secrets, not config files
- Use environment variable placeholders in configs
- Test configurations locally before CI/CD deployment
- Version control all configuration changes
- Document custom configurations

### Environment Variables in Configs
```hocon
# In configuration file
target = "${TARGET_URL}"
credentials {
  api_key {
    auth_headers = {
      Authorization = "Bearer ${API_TOKEN}"
    }
  }
}
```

```yaml
# In GitHub workflow
- name: Process Config
  run: |
    cp config/api-key.conf tenable_was.conf
    sed -i "s/\${API_TOKEN}/${{ secrets.API_TOKEN }}/g" tenable_was.conf
```

## Next Steps

1. ✅ Run basic authentication test
2. ✅ Verify results in Tenable.io dashboard  
3. ✅ Test other authentication methods
4. ✅ Create custom configurations for your applications
5. ✅ Set up automated scanning in your CI/CD pipeline

## Additional Resources

- [Configuration Guide](CONFIGURATION-GUIDE.md) - Detailed config documentation
- [Secrets Guide](SECRETS.md) - Managing sensitive data
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and solutions
EOF

cat > docs/SECRETS.md << 'EOF'
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
EOF

cat > docs/TROUBLESHOOTING.md << 'EOF'
# 🔧 Troubleshooting Guide

## Configuration File Issues

### ❌ "missing field `scan`" error

**Problem:** Configuration file doesn't have proper structure
**Solution:**
```bash
# Check if config has scan block
grep -q "scan {" tenable_was.conf && echo "✅ Has scan block" || echo "❌ Missing scan block"

# Use a working config as template
cp config/minimal-test.conf tenable_was.conf
```

### ❌ "UUID parsing failed" error

**Problem:** Invalid config_id format
**Solution:**
Remove config_id from configuration file or use proper UUID:
```bash
# Remove config_id line
sed -i '/config_id/d' tenable_was.conf

# Or generate proper UUID
echo "config_id = \"$(uuidgen)\"" >> tenable_was.conf
```

### ❌ HOCON syntax errors

**Problem:** Invalid configuration syntax
**Solution:**
- Use `=` instead of `:` for assignments
- Ensure proper quote usage
- Check bracket matching

```hocon
# ✅ Correct
target = "https://example.com"
scan {
  timeout = "00:30:00"
}

# ❌ Incorrect  
target: https://example.com
scan {
  timeout: 30 minutes
}
```

## Authentication Issues

### ❌ "Authentication failed" errors

**Problem:** Tenable scanner cannot authenticate
**Solution:**
1. Verify credentials in GitHub Secrets:
   ```bash
   # Check if secrets are set (shows first 10 chars)
   echo "${{ secrets.TENABLE_ACCESS_KEY }}" | cut -c1-10
   ```

2. Test credentials manually:
   ```bash
   curl -X GET "https://cloud.tenable.com/users" \
     -H "X-ApiKeys: accessKey=YOUR_KEY;secretKey=YOUR_SECRET"
   ```

3. Ensure account has WAS license

### ❌ Form authentication failures

**Problem:** Cannot login to web application
**Solution:**
1. Test login manually:
   ```bash
   curl -X POST http://localhost:5000/login \
     -d "username=testuser&password=testpass123"
   ```

2. Check application is running:
   ```bash
   curl http://localhost:5000/health
   ```

3. Verify credentials in config file:
   ```hocon
   login_parameters = {
     username = "testuser"  # Check these match
     password = "testpass123"
   }
   ```

4. Check login success patterns:
   ```hocon
   login_check = "Dashboard"           # Text that appears after login
   login_check_url = "http://localhost:5000/dashboard"
   ```

### ❌ API authentication failures

**Problem:** API endpoints reject authentication
**Solution:**
1. Test API endpoint manually:
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" \
     https://gorest.co.in/public/v2/users
   ```

2. Verify token format in config:
   ```hocon
   auth_headers = {
     Authorization = "Bearer ${GOREST_API_TOKEN}"  # Check format
   }
   ```

3. Check token expiration and regenerate if needed

## Network and Connectivity Issues

### ❌ "Target unreachable" errors

**Problem:** Scanner cannot reach target URL
**Solution:**
1. Test target accessibility:
   ```bash
   curl -I https://httpbin.org/basic-auth/testuser/testpass123
   ```

2. For local applications, use `--network host`:
   ```yaml
   docker run \
     --network host \  # Add this line
     -v $(pwd):/scanner \
     tenable/was-scanner:latest
   ```

3. Check target URL in configuration:
   ```hocon
   target = "http://localhost:5000/"  # Ensure correct URL
   ```

### ❌ "Docker pull failed" errors

**Problem:** Cannot pull Tenable scanner image
**Solution:**
- Usually temporary - retry the workflow
- Check GitHub Actions runner has internet access
- Verify Tenable Docker registry is accessible

### ❌ Local application not starting

**Problem:** Test applications fail to start
**Solution:**
```bash
# Check Docker is running
docker --version

# Check port availability
netstat -tlnp | grep :8080

# Start applications
cd test-apps
docker-compose up -d

# View logs
docker-compose logs dvwa
docker-compose logs simple-login-app

# Restart if needed
docker-compose down && docker-compose up -d
```

## Scan Execution Issues

### ❌ "No vulnerabilities found"

**Problem:** Clean scan results
**Solution:**
- This is expected for test endpoints (they're designed to be accessible, not vulnerable)
- Focus on authentication success rather than vulnerability count
- Check scanner logs for authentication confirmation

### ❌ Scan timeouts

**Problem:** Scan takes too long or times out
**Solution:**
1. Reduce scan scope in configuration:
   ```hocon
   scan {
     scope {
       page_limit = 50        # Reduce from default
     }
     timeout = "00:15:00"     # Shorter timeout
   }
   ```

2. Optimize scan settings:
   ```hocon
   http {
     request_timeout = 15
     request_concurrency = 2  # Reduce parallel requests
   }
   ```

### ❌ Scanner log errors

**Problem:** Scanner reports errors in logs
**Solution:**
1. Download and review scanner.log from artifacts
2. Look for specific error patterns:
   ```bash
   grep -i "error\|fail\|exception" scanner.log
   ```
3. Common log patterns and solutions:
   - `Authentication failed` → Check credentials
   - `Target unreachable` → Check network/URL
   - `Timeout` → Reduce scan scope
   - `Invalid configuration` → Check config syntax

## GitHub Actions Issues

### ❌ Secrets not found

**Problem:** Workflow cannot access secrets
**Solution:**
1. Verify secrets are set in repository (not organization) settings
2. Check secret names match exactly:
   ```yaml
   env:
     TENABLE_ACCESS_KEY: ${{ secrets.TENABLE_ACCESS_KEY }}  # Exact match
   ```
3. Ensure secrets are added to repository, not user profile

### ❌ Workflow permissions

**Problem:** GitHub Actions cannot perform operations
**Solution:**
1. Check repository settings → Actions → General
2. Ensure "Allow GitHub Actions to create and approve pull requests" is enabled
3. Verify workflow has necessary permissions

### ❌ Artifact upload failures

**Problem:** Cannot upload scan results
**Solution:**
1. Check file exists before upload:
   ```yaml
   - name: Upload Results
     if: always()  # Upload even if scan fails
     uses: actions/upload-artifact@v4
   ```
2. Verify file paths are correct
3. Check artifact retention settings

## Environment-Specific Issues

### ❌ Local vs CI/CD differences

**Problem:** Works locally but fails in GitHub Actions
**Solution:**
1. Ensure same configuration files are used
2. Check environment variable substitution
3. Verify network access in CI/CD environment
4. Test with same Docker image locally:
   ```bash
   docker pull tenable/was-scanner:latest
   # Use exact same command as in workflow
   ```

### ❌ Platform-specific issues

**Problem:** Different behavior on different systems
**Solution:**
1. Use consistent line endings (LF not CRLF)
2. Ensure proper file permissions:
   ```bash
   chmod +x scripts/*.sh
   ```
3. Check Docker compatibility

## Debug Tools and Commands

### Configuration Validation
```bash
# Test all config files
./scripts/test-config-files.sh

# Check specific config syntax
grep -q "scan {" config/basic-auth.conf && echo "✅ Valid"

# Validate HOCON syntax
cat config/basic-auth.conf | grep -E "(=|{|})" | head -10
```

### Endpoint Testing
```bash
# Test all endpoints
./scripts/validate-endpoints.sh

# Test specific endpoint
curl -v -u testuser:testpass123 \
  https://httpbin.org/basic-auth/testuser/testpass123
```

### Local Scanner Testing
```bash
# Test scanner with verbose output
docker run \
  -v $(pwd):/scanner \
  -e WAS_MODE=cicd \
  -e ACCESS_KEY=your_key \
  -e SECRET_KEY=your_secret \
  tenable/was-scanner:latest

# Check generated files
ls -la *.html *.log *.conf
```

### Log Analysis
```bash
# Search for errors in scanner log
grep -i "error\|fail\|exception" scanner.log

# Check authentication attempts
grep -i "auth\|login\|credential" scanner.log

# View last 30 lines
tail -30 scanner.log
```

## Getting Help

### 1. Check Common Patterns
- Review this troubleshooting guide
- Test with minimal configuration first
- Verify credentials and endpoints manually

### 2. Collect Debug Information
- Download scanner.log from workflow artifacts
- Note exact error messages
- Test same configuration locally

### 3. Resources
- [Tenable Documentation](https://docs.tenable.com/)
- [Configuration Guide](CONFIGURATION-GUIDE.md)
- [Setup Guide](SETUP.md)
- [Secrets Guide](SECRETS.md)#!/bin/bash

# This script creates the complete Tenable WAS POC directory structure
# with separate configuration files for better maintainability

echo "🚀 Creating Tenable WAS POC Complete Package with Separate Config Files..."

# Create main directory structure
mkdir -p tenable-was-poc/{.github/workflows,config,test-apps/{nginx-basic-auth,simple-login-app/templates},scripts,docs,results}

cd tenable-was-poc

# ==========================================
# 1. SEPARATE CONFIGURATION FILES
# ==========================================

echo "📝 Creating separate configuration files..."

# Base configuration template
cat > config/base-config.conf << 'EOF'
# Tenable WAS Base Configuration Template
# This file contains common settings used across all scan types

target = "${TARGET_URL}"
vulnerability_threshold = "${VULNERABILITY_THRESHOLD}"
template_id = "web-app-scan"
results_visibility = dashboard

scan {
  assessment {
    dictionary = limited
    enable = true
    fingerprinting = false
  }
  
  audit {
    cookies = true
    forms = true
    headers = true
    jsons = true
    links = true
    parameter_names = false
    parameter_values = true
    ui_forms = true
    ui_inputs = true
    xmls = true
  }
  
  browser {
    analysis = false
    ignore_images = true
    job_timeout = 90
    pool_size = 2
    screen_height = 1200
    screen_width = 1600
  }
  
  http {
    request_concurrency = 5
    request_headers {
      Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
      Accept-Language = "en-US,en;q=0.5"
      User-Agent = "TenableWAS-Test/1.0"
    }
    request_timeout = 30
    response_max_size = 2000000
  }
  
  scope {
    exclude_binaries = true
    exclude_file_extensions = [js, css, png, jpg, gif, ico, svg, woff, woff2]
    exclude_path_patterns = [logout, "sign-out", admin]
    page_limit = 1000
  }
  
  timeout = "01:00:00"
}
EOF

# Basic Authentication Configuration
cat > config/basic-auth.conf << 'EOF'
# HTTPBin Basic Authentication Configuration
# Target: https://httpbin.org/basic-auth/testuser/testpass123

target = "https://httpbin.org/basic-auth/testuser/testpass123"
vulnerability_threshold = "Medium"
template_id = "web-app-scan"
results_visibility = dashboard

scan {
  assessment {
    enable = true
    dictionary = limited
  }
  
  audit {
    cookies = true
    forms = true
    headers = true
    links = true
  }
  
  http {
    request_timeout = 30
    request_concurrency = 3
  }
  
  scope {
    exclude_binaries = true
    page_limit = 100
  }
  
  timeout = "00:30:00"
  
  credentials {
    basic_auth {
      username = "testuser"
      password = "testpass123"
    }
  }
}
EOF

# Digest Authentication Configuration
cat > config/digest-auth.conf << 'EOF'
# HTTPBin Digest Authentication Configuration
# Target: https://httpbin.org/digest-auth/auth/testuser/testpass123

target = "https://httpbin.org/digest-auth/auth/testuser/testpass123"
vulnerability_threshold = "Medium"
template_id = "web-app-scan"
results_visibility = dashboard

scan {
  assessment {
    enable = true
    dictionary = limited
  }
  
  audit {
    cookies = true
    forms = true
    headers = true
  }
  
  scope {
    page_limit = 100
  }
  
  timeout = "00:30:00"
  
  credentials {
    digest_auth {
      username = "testuser"
      password = "testpass123"
      realm = "auth"
    }
  }
}
EOF

# Form Authentication Configuration
cat > config/form-auth.conf << 'EOF'
# Form Authentication Configuration for Simple Login App
# Target: http://localhost:5000/

target = "http://localhost:5000/"
vulnerability_threshold = "Medium"
template_id = "web-app-scan"
results_visibility = dashboard

scan {
  assessment {
    enable = true
    dictionary = limited
  }
  
  audit {
    cookies = true
    forms = true
    headers = true
    links = true
  }
  
  http {
    request_timeout = 45
    request_concurrency = 2
  }
  
  scope {
    exclude_binaries = true
    page_limit = 200
    exclude_path_patterns = ["logout"]
  }
  
  timeout = "00:45:00"
  
  credentials {
    login_form {
      login_url = "http://localhost:5000/login"
      login_parameters = {
        username = "testuser"
        password = "testpass123"
      }
      login_check = "Dashboard"
      login_check_pattern = "Welcome.*Dashboard|secure area"
      login_check_url = "http://localhost:5000/dashboard"
      failure_check = "Login failed"
      failure_pattern = "[Ll]ogin.*[Ff]ailed|[Ii]nvalid.*[Cc]redentials"
      auth_headers = {
        Content-Type = "application/x-www-form-urlencoded"
      }
    }
  }
}
EOF

# DVWA Form Authentication Configuration
cat > config/dvwa-form-auth.conf << 'EOF'
# DVWA Form Authentication Configuration
# Target: http://localhost:8080/

target = "http://localhost:8080/"
vulnerability_threshold = "Medium"
template_id = "web-app-scan"
results_visibility = dashboard

scan {
  assessment {
    enable = true
    dictionary = limited
  }
  
  audit {
    cookies = true
    forms = true
    headers = true
    links = true
  }
  
  http {
    request_timeout = 45
    request_concurrency = 2
  }
  
  scope {
    exclude_binaries = true
    page_limit = 200
    exclude_path_patterns = ["logout", "setup.php"]
  }
  
  timeout = "00:45:00"
  
  credentials {
    login_form {
      login_url = "http://localhost:8080/login.php"
      login_parameters = {
        username = "admin"
        password = "password"
        Login = "Login"
      }
      login_check = "Welcome"
      login_check_pattern = "Welcome.*DVWA|Security Level"
      login_check_url = "http://localhost:8080/index.php"
      failure_check = "Login failed"
      failure_pattern = "[Ll]ogin.*[Ff]ailed|[Ii]nvalid.*[Cc]redentials"
      auth_headers = {
        Content-Type = "application/x-www-form-urlencoded"
        User-Agent = "TenableWAS-FormTest/1.0"
      }
    }
  }
}
EOF

# Cookie Authentication Configuration
cat > config/cookie-auth.conf << 'EOF'
# HTTPBin Cookie Authentication Configuration
# Target: https://httpbin.org/cookies

target = "https://httpbin.org/cookies"
vulnerability_threshold = "Medium"
template_id = "web-app-scan"
results_visibility = dashboard

scan {
  assessment {
    enable = true
    dictionary = limited
  }
  
  audit {
    cookies = true
    headers = true
  }
  
  scope {
    page_limit = 50
  }
  
  timeout = "00:30:00"
  
  credentials {
    cookie_auth {
      cookie = "test-session=authenticated-user; Path=/; Domain=httpbin.org"
      login_check = "cookies"
      login_check_pattern = "test-session"
      login_check_url = "https://httpbin.org/cookies"
    }
  }
}
EOF

# API Key Authentication Configuration
cat > config/api-key.conf << 'EOF'
# GoRest API Key Authentication Configuration
# Target: https://gorest.co.in/public/v2/

target = "https://gorest.co.in/public/v2/"
vulnerability_threshold = "Medium"
template_id = "web-app-scan"
results_visibility = dashboard

scan {
  assessment {
    enable = true
    dictionary = limited
  }
  
  audit {
    headers = true
    jsons = true
    links = true
  }
  
  http {
    request_timeout = 30
    request_headers {
      Accept = "application/json"
      Content-Type = "application/json"
    }
  }
  
  scope {
    exclude_binaries = true
    page_limit = 50
  }
  
  timeout = "00:30:00"
  
  credentials {
    api_key {
      auth_headers = {
        Authorization = "Bearer ${GOREST_API_TOKEN}"
        Content-Type = "application/json"
        Accept = "application/json"
      }
      login_check = "users"
      login_check_pattern = "id.*name.*email"
      login_check_url = "https://gorest.co.in/public/v2/users"
    }
  }
}
EOF

# Bearer Token Authentication Configuration
cat > config/bearer-token.conf << 'EOF'
# HTTPBin Bearer Token Authentication Configuration
# Target: https://httpbin.org/bearer

target = "https://httpbin.org/bearer"
vulnerability_threshold = "Medium"
template_id = "web-app-scan"
results_visibility = dashboard

scan {
  assessment {
    enable = true
    dictionary = limited
  }
  
  audit {
    headers = true
    jsons = true
  }
  
  scope {
    page_limit = 50
  }
  
  timeout = "00:30:00"
  
  credentials {
    bearer_auth {
      auth_headers = {
        Authorization = "Bearer test-token-123"
        Content-Type = "application/json"
      }
      login_check = "bearer"
      login_check_pattern = "authenticated|token|bearer"
      login_check_url = "https://httpbin.org/bearer"
    }
  }
}
EOF

# Minimal Test Configuration
cat > config/minimal-test.conf << 'EOF'
# Minimal Test Configuration for Quick Testing
# Target: https://httpbin.org/basic-auth/testuser/testpass123

target = "https://httpbin.org/basic-auth/testuser/testpass123"
vulnerability_threshold = "Medium"

scan {
  timeout = "00:15:00"
  
  credentials {
    basic_auth {
      username = "testuser"
      password = "testpass123"
    }
  }
}
EOF

# ==========================================
# 2. UPDATED GITHUB WORKFLOWS
# ==========================================

echo "⚙️ Creating GitHub workflows that use separate config files..."

# Main comprehensive workflow
cat > .github/workflows/test-all-auth-methods.yml << 'EOF'
name: 🔒 Tenable WAS - Complete Authentication Methods Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      auth_methods:
        description: 'Authentication methods to test'
        required: false
        default: 'basic,digest,form,cookie,api_key,bearer'
        type: string
      vulnerability_threshold:
        description: 'Vulnerability threshold'
        required: false
        default: 'Medium'
        type: choice
        options: [Critical, High, Medium, Low]

env:
  TENABLE_ACCESS_KEY: ${{ secrets.TENABLE_ACCESS_KEY }}
  TENABLE_SECRET_KEY: ${{ secrets.TENABLE_SECRET_KEY }}
  VULNERABILITY_THRESHOLD: ${{ github.event.inputs.vulnerability_threshold || 'Medium' }}
  GOREST_API_TOKEN: ${{ secrets.GOREST_API_TOKEN || 'demo-token' }}

jobs:
  test-basic-authentication:
    name: 🔐 Basic Authentication Test
    runs-on: ubuntu-latest
    if: contains(github.event.inputs.auth_methods || 'basic,digest,form,cookie,api_key,bearer', 'basic')
    
    steps:
    - name: 📥 Checkout
      uses: actions/checkout@v4
      
    - name: 🧪 Test HTTPBin Basic Auth Endpoint
      run: |
        echo "🔍 Testing HTTPBin Basic Auth endpoint..."
        response=$(curl -s -u testuser:testpass123 https://httpbin.org/basic-auth/testuser/testpass123)
        if echo "$response" | jq -r '.authenticated' | grep -q "true"; then
          echo "✅ HTTPBin Basic Auth endpoint working"
        else
          echo "❌ HTTPBin Basic Auth endpoint failed"
          exit 1
        fi
        
    - name: 🔍 Run Basic Auth Scan
      run: |
        echo "🚀 Running Basic Authentication scan using config/basic-auth.conf..."
        
        # Copy the configuration file
        cp config/basic-auth.conf tenable_was.conf
        
        echo "📋 Using configuration:"
        cat tenable_was.conf
        
        # Run the scan
        docker pull tenable/was-scanner:latest
        docker run \
          --name tenable-basic-auth \
          -v $(pwd):/scanner \
          -e WAS_MODE=cicd \
          -e ACCESS_KEY="${{ env.TENABLE_ACCESS_KEY }}" \
          -e SECRET_KEY="${{ env.TENABLE_SECRET_KEY }}" \
          tenable/was-scanner:latest || true
        
        # Organize results
        mkdir -p results/basic-auth
        [[ -f tenable_was_scan.html ]] && cp tenable_was_scan.html results/basic-auth/
        [[ -f scanner.log ]] && cp scanner.log results/basic-auth/
        [[ -f tenable_was.conf ]] && cp tenable_was.conf results/basic-auth/
        
    - name: 📤 Upload Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: basic-auth-results-${{ github.run_number }}
        path: results/basic-auth/
        retention-days: 7

  test-digest-authentication:
    name: 🔐 Digest Authentication Test
    runs-on: ubuntu-latest
    if: contains(github.event.inputs.auth_methods || 'basic,digest,form,cookie,api_key,bearer', 'digest')
    
    steps:
    - name: 📥 Checkout
      uses: actions/checkout@v4
      
    - name: 🧪 Test HTTPBin Digest Auth Endpoint
      run: |
        echo "🔍 Testing HTTPBin Digest Auth endpoint..."
        response=$(curl -s --digest -u testuser:testpass123 https://httpbin.org/digest-auth/auth/testuser/testpass123)
        if echo "$response" | jq -r '.authenticated' | grep -q "true"; then
          echo "✅ HTTPBin Digest Auth endpoint working"
        else
          echo "❌ HTTPBin Digest Auth endpoint failed"
        fi
        
    - name: 🔍 Run Digest Auth Scan
      run: |
        echo "🚀 Running Digest Authentication scan using config/digest-auth.conf..."
        
        # Copy the configuration file
        cp config/digest-auth.conf tenable_was.conf
        
        echo "📋 Using configuration:"
        cat tenable_was.conf
        
        # Run the scan
        docker run \
          --name tenable-digest-auth \
          -v $(pwd):/scanner \
          -e WAS_MODE=cicd \
          -e ACCESS_KEY="${{ env.TENABLE_ACCESS_KEY }}" \
          -e SECRET_KEY="${{ env.TENABLE_SECRET_KEY }}" \
          tenable/was-scanner:latest || true
        
        # Organize results
        mkdir -p results/digest-auth
        [[ -f tenable_was_scan.html ]] && cp tenable_was_scan.html results/digest-auth/
        [[ -f scanner.log ]] && cp scanner.log results/digest-auth/
        [[ -f tenable_was.conf ]] && cp tenable_was.conf results/digest-auth/
        
    - name: 📤 Upload Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: digest-auth-results-${{ github.run_number }}
        path: results/digest-auth/

  test-form-authentication:
    name: 📝 Form Authentication Test
    runs-on: ubuntu-latest
    if: contains(github.event.inputs.auth_methods || 'basic,digest,form,cookie,api_key,bearer', 'form')
    
    steps:
    - name: 📥 Checkout
      uses: actions/checkout@v4
      
    - name: 🐳 Deploy Test Login App
      run: |
        echo "🚀 Deploying simple login application..."
        
        # Create simple Flask login app
        mkdir -p simple-app/templates
        
        cat > simple-app/app.py << 'APP_EOF'
        from flask import Flask, request, render_template, redirect, session
        
        app = Flask(__name__)
        app.secret_key = 'test-secret-key'
        
        @app.route('/')
        def index():
            if 'logged_in' in session:
                return '<h1>Welcome to Dashboard</h1><p>You are authenticated!</p><a href="/logout">Logout</a>'
            return redirect('/login')
        
        @app.route('/login', methods=['GET', 'POST'])
        def login():
            if request.method == 'POST':
                username = request.form.get('username')
                password = request.form.get('password')
                if username == 'testuser' and password == 'testpass123':
                    session['logged_in'] = True
                    return redirect('/dashboard')
                return 'Login failed - Invalid credentials'
            return '''
            <form method="post">
                <label>Username: <input type="text" name="username"></label><br>
                <label>Password: <input type="password" name="password"></label><br>
                <input type="submit" value="Login">
            </form>
            '''
        
        @app.route('/dashboard')
        def dashboard():
            if 'logged_in' not in session:
                return redirect('/login')
            return '<h1>Dashboard</h1><p>Welcome to the secure area!</p><a href="/logout">Logout</a>'
        
        @app.route('/logout')
        def logout():
            session.pop('logged_in', None)
            return redirect('/login')
        
        if __name__ == '__main__':
            app.run(host='0.0.0.0', port=5000)
        APP_EOF
        
        cat > simple-app/requirements.txt << 'REQ_EOF'
        Flask==2.3.3
        REQ_EOF
        
        cat > simple-app/Dockerfile << 'DOCKER_EOF'
        FROM python:3.9-slim
        WORKDIR /app
        COPY requirements.txt .
        RUN pip install -r requirements.txt
        COPY . .
        EXPOSE 5000
        CMD ["python", "app.py"]
        DOCKER_EOF
        
        # Build and run the app
        cd simple-app
        docker build -t simple-login-app .
        docker run -d --name login-app -p 5000:5000 simple-login-app
        
        # Wait for app to start
        sleep 10
        
        # Test the app
        if curl -s http://localhost:5000/login | grep -q "Username"; then
          echo "✅ Login app deployed successfully"
        else
          echo "❌ Login app deployment failed"
        fi
        
    - name: 🔍 Run Form Auth Scan
      run: |
        echo "🚀 Running Form Authentication scan using config/form-auth.conf..."
        
        # Copy the configuration file
        cp config/form-auth.conf tenable_was.conf
        
        echo "📋 Using configuration:"
        cat tenable_was.conf
        
        # Run the scan
        docker run \
          --name tenable-form-auth \
          -v $(pwd):/scanner \
          --network host \
          -e WAS_MODE=cicd \
          -e ACCESS_KEY="${{ env.TENABLE_ACCESS_KEY }}" \
          -e SECRET_KEY="${{ env.TENABLE_SECRET_KEY }}" \
          tenable/was-scanner:latest || true
        
        # Organize results
        mkdir -p results/form-auth
        [[ -f tenable_was_scan.html ]] && cp tenable_was_scan.html results/form-auth/
        [[ -f scanner.log ]] && cp scanner.log results/form-auth/
        [[ -f tenable_was.conf ]] && cp tenable_was.conf results/form-auth/
        
    - name: 📤 Upload Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: form-auth-results-${{ github.run_number }}
        path: results/form-auth/

  test-cookie-authentication:
    name: 🍪 Cookie Authentication Test
    runs-on: ubuntu-latest
    if: contains(github.event.inputs.auth_methods || 'basic,digest,form,cookie,api_key,bearer', 'cookie')
    
    steps:
    - name: 📥 Checkout
      uses: actions/checkout@v4
      
    - name: 🍪 Test Cookie Endpoint
      run: |
        echo "🔍 Testing HTTPBin Cookie endpoint..."
        
        # Set a test cookie
        cookie_jar=$(mktemp)
        curl -s -c "$cookie_jar" https://httpbin.org/cookies/set/test-session/authenticated-user
        
        # Read the cookie back
        response=$(curl -s -b "$cookie_jar" https://httpbin.org/cookies)
        if echo "$response" | grep -q "test-session"; then
          echo "✅ HTTPBin Cookie endpoint working"
        else
          echo "❌ HTTPBin Cookie endpoint failed"
        fi
        
    - name: 🔍 Run Cookie Auth Scan
      run: |
        echo "🚀 Running Cookie Authentication scan using config/cookie-auth.conf..."
        
        # Copy the configuration file
        cp config/cookie-auth.conf tenable_was.conf
        
        echo "📋 Using configuration:"
        cat tenable_was.conf
        
        # Run the scan
        docker run \
          --name tenable-cookie-auth \
          -v $(pwd):/scanner \
          -e WAS_MODE=cicd \
          -e ACCESS_KEY="${{ env.TENABLE_ACCESS_KEY }}" \
          -e SECRET_KEY="${{ env.TENABLE_SECRET_KEY }}" \
          tenable/was-scanner:latest || true
        
        # Organize results
        mkdir -p results/cookie-auth
        [[ -f tenable_was_scan.html ]] && cp tenable_was_scan.html results/cookie-auth/
        [[ -f scanner.log ]] && cp scanner.log results/cookie-auth/
        [[ -f tenable_was.conf ]] && cp tenable_was.conf results/cookie-auth/
        
    - name: 📤 Upload Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: cookie-auth-results-${{ github.run_number }}
        path: results/cookie-auth/

  test-api-authentication:
    name: 🔑 API Authentication Test
    runs-on: ubuntu-latest
    if: contains(github.event.inputs.auth_methods || 'basic,digest,form,cookie,api_key,bearer', 'api_key')
    
    steps:
    - name: �� Checkout
      uses: actions/checkout@v4
      
    - name: 🧪 Test Public API Endpoints
      run: |
        echo "🔍 Testing public API endpoints..."
        
        # Test GoRest public endpoint
        response=$(curl -s https://gorest.co.in/public/v2/users)
        if echo "$response" | jq length > /dev/null; then
          echo "✅ GoRest API endpoint working"
        else
          echo "❌ GoRest API endpoint failed"
        fi
        
    - name: 🔍 Run API Auth Scan
      run: |
        echo "🚀 Running API Authentication scan using config/api-key.conf..."
        
        # Copy and process the configuration file
        cp config/api-key.conf tenable_was.conf
        
        # Replace the GOREST_API_TOKEN placeholder
        sed -i "s/\${GOREST_API_TOKEN}/${{ env.GOREST_API_TOKEN }}/g" tenable_was.conf
        
        echo "📋 Using configuration:"
        cat tenable_was.conf
        
        # Run the scan
        docker run \
          --name tenable-api-auth \
          -v $(pwd):/scanner \
          -e WAS_MODE=cicd \
          -e ACCESS_KEY="${{ env.TENABLE_ACCESS_KEY }}" \
          -e SECRET_KEY="${{ env.TENABLE_SECRET_KEY }}" \
          -e GOREST_API_TOKEN="${{ env.GOREST_API_TOKEN }}" \
          tenable/was-scanner:latest || true
        
        # Organize results
        mkdir -p results/api-auth
        [[ -f tenable_was_scan.html ]] && cp tenable_was_scan.html results/api-auth/
        [[ -f scanner.log ]] && cp scanner.log results/api-auth/
        [[ -f tenable_was.conf ]] && cp tenable_was.conf results/api-auth/
        
    - name: 📤 Upload Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: api-auth-results-${{ github.run_number }}
        path: results/api-auth/

  test-bearer-token-authentication:
    name: 🎫 Bearer Token Test
    runs-on: ubuntu-latest
    if: contains(github.event.inputs.auth_methods || 'basic,digest,form,cookie,api_key,bearer', 'bearer')
    
    steps:
    - name: �� Checkout
      uses: actions/checkout@v4
      
    - name: 🔍 Run Bearer Token Scan
      run: |
        echo "🚀 Running Bearer Token Authentication scan using config/bearer-token.conf..."
        
        # Copy the configuration file
        cp config/bearer-token.conf tenable_was.conf
        
        echo "📋 Using configuration:"
        cat tenable_was.conf
        
        # Run the scan
        docker run \
          --name tenable-bearer-token \
          -v $(pwd):/scanner \
          -e WAS_MODE=cicd \
          -e ACCESS_KEY="${{ env.TENABLE_ACCESS_KEY }}" \
          -e SECRET_KEY="${{ env.TENABLE_SECRET_KEY }}" \
          tenable/was-scanner:latest || true
        
        # Organize results
        mkdir -p results/bearer-token
        [[ -f tenable_was_scan.html ]] && cp tenable_was_scan.html results/bearer-token/
        [[ -f scanner.log ]] && cp scanner.log results/bearer-token/
        [[ -f tenable_was.conf ]] && cp tenable_was.conf results/bearer-token/
        
    - name: 📤 Upload Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: bearer-token-results-${{ github.run_number }}
        path: results/bearer-token/

  summary-report:
    name: 📊 Generate Summary Report
    runs-on: ubuntu-latest
    needs: [test-basic-authentication, test-digest-authentication, test-form-authentication, test-api-authentication, test-bearer-token-authentication, test-cookie-authentication]
    if: always()
    
    steps:
    - name: 📥 Download All Results
      uses: actions/download-artifact@v4
      with:
        path: all-results/
        
    - name: 📊 Generate Summary Report
      run: |
        echo "# 🔒 Tenable WAS Authentication Methods Test Summary" > SUMMARY.md
        echo "" >> SUMMARY.md
        echo "**Test Run:** ${{ github.run_number }}" >> SUMMARY.md
        echo "**Date:** $(date -u)" >> SUMMARY.md
        echo "**Repository:** ${{ github.repository }}" >> SUMMARY.md
        echo "**Configuration Files Used:** Separate .conf files from config/ directory" >> SUMMARY.md
        echo "" >> SUMMARY.md
        
        echo "## 📋 Test Results" >> SUMMARY.md
        echo "" >> SUMMARY.md
        
        for auth_type in basic-auth digest-auth form-auth api-auth bearer-token cookie-auth; do
          if [[ -d "all-results/${auth_type}-results-${{ github.run_number }}" ]]; then
            echo "✅ **${auth_type}**: Completed" >> SUMMARY.md
            
            # Check if HTML report exists
            if [[ -f "all-results/${auth_type}-results-${{ github.run_number }}/tenable_was_scan.html" ]]; then
              echo "   - 📄 HTML Report: Available" >> SUMMARY.md
            fi
            
            # Check if scanner log exists
            if [[ -f "all-results/${auth_type}-results-${{ github.run_number }}/scanner.log" ]]; then
              echo "   - 📋 Scanner Log: Available" >> SUMMARY.md
            fi
            
            # Check if config was used
            if [[ -f "all-results/${auth_type}-results-${{ github.run_number }}/tenable_was.conf" ]]; then
              echo "   - ⚙️ Configuration: Available" >> SUMMARY.md
            fi
          else
            echo "❌ **${auth_type}**: Failed or Skipped" >> SUMMARY.md
          fi
          echo "" >> SUMMARY.md
        done
        
        echo "## 📄 Configuration Files" >> SUMMARY.md
        echo "" >> SUMMARY.md
        echo "All authentication methods use separate configuration files:" >> SUMMARY.md
        echo "- \`config/basic-auth.conf\` - Basic Authentication" >> SUMMARY.md
        echo "- \`config/digest-auth.conf\` - Digest Authentication" >> SUMMARY.md
        echo "- \`config/form-auth.conf\` - Form Authentication" >> SUMMARY.md
        echo "- \`config/cookie-auth.conf\` - Cookie Authentication" >> SUMMARY.md
        echo "- \`config/api-key.conf\` - API Key Authentication" >> SUMMARY.md
        echo "- \`config/bearer-token.conf\` - Bearer Token Authentication" >> SUMMARY.md
        echo "- \`config/dvwa-form-auth.conf\` - DVWA Form Authentication" >> SUMMARY.md
        echo "- \`config/minimal-test.conf\` - Minimal Test Configuration" >> SUMMARY.md
        echo "" >> SUMMARY.md
        echo "## 📄 Reports Available" >> SUMMARY.md
        echo "" >> SUMMARY.md
        echo "All scan reports are available in the GitHub Actions artifacts." >> SUMMARY.md
        echo "Download them from the workflow run page." >> SUMMARY.md
        
        cat SUMMARY.md
        
    - name: 📤 Upload Summary
      uses: actions/upload-artifact@v4
      with:
        name: test-summary-${{ github.run_number }}
        path: SUMMARY.md
        retention-days: 30
EOF

# Simple individual workflows using config files
cat > .github/workflows/test-basic-auth.yml << 'EOF'
name: 🔐 Basic Auth Test Only

on:
  workflow_dispatch:

env:
  TENABLE_ACCESS_KEY: ${{ secrets.TENABLE_ACCESS_KEY }}
  TENABLE_SECRET_KEY: ${{ secrets.TENABLE_SECRET_KEY }}

jobs:
  basic-auth-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: 🧪 Test HTTPBin Basic Auth Endpoint
      run: |
        echo "🔍 Testing HTTPBin Basic Auth endpoint..."
        response=$(curl -s -u testuser:testpass123 https://httpbin.org/basic-auth/testuser/testpass123)
        if echo "$response" | jq -r '.authenticated' | grep -q "true"; then
          echo "✅ HTTPBin Basic Auth endpoint working"
        else
          echo "❌ HTTPBin Basic Auth endpoint failed"
          exit 1
        fi
    
    - name: 🔍 Run Basic Auth Scan
      run: |
        echo "🚀 Running Basic Authentication scan using config/basic-auth.conf..."
        
        # Use the separate configuration file
        cp config/basic-auth.conf tenable_was.conf
        
        echo "📋 Configuration file content:"
        cat tenable_was.conf
        
        # Run the scan
        docker pull tenable/was-scanner:latest
        docker run \
          --name tenable-basic-auth \
          -v $(pwd):/scanner \
          -e WAS_MODE=cicd \
          -e ACCESS_KEY="${{ env.TENABLE_ACCESS_KEY }}" \
          -e SECRET_KEY="${{ env.TENABLE_SECRET_KEY }}" \
          tenable/was-scanner:latest || true
        
        # Show results
        if [[ -f "tenable_was_scan.html" ]]; then
          echo "✅ Scan completed - HTML report generated"
          ls -la tenable_was_scan.html
        fi
        
        if [[ -f "scanner.log" ]]; then
          echo "📋 Scanner log (last 30 lines):"
          tail -30 scanner.log
        fi
          
    - name: 📤 Upload Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: basic-auth-simple-results-${{ github.run_number }}
        path: |
          tenable_was_scan.html
          scanner.log
          tenable_was.conf
EOF

cat > .github/workflows/test-form-auth.yml << 'EOF'
name: 📝 Form Auth Test Only

on:
  workflow_dispatch:

env:
  TENABLE_ACCESS_KEY: ${{ secrets.TENABLE_ACCESS_KEY }}
  TENABLE_SECRET_KEY: ${{ secrets.TENABLE_SECRET_KEY }}

jobs:
  form-auth-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: 🐳 Deploy DVWA
      run: |
        echo "🚀 Deploying DVWA for form authentication testing..."
        docker run -d --name dvwa -p 8080:80 vulnerables/web-dvwa:latest
        
        # Wait for DVWA to start
        sleep 30
        
        # Setup DVWA database
        curl -X POST http://localhost:8080/setup.php -d "create_db=Create / Reset Database" || true
        sleep 10
        
        # Verify DVWA is accessible
        if curl -s http://localhost:8080/login.php | grep -q "login"; then
          echo "✅ DVWA deployed and accessible"
        else
          echo "❌ DVWA deployment failed"
        fi
    
    - name: 🔍 Run Form Auth Scan
      run: |
        echo "🚀 Running Form Authentication scan using config/dvwa-form-auth.conf..."
        
        # Use the DVWA-specific configuration file
        cp config/dvwa-form-auth.conf tenable_was.conf
        
        echo "📋 Configuration file content:"
        cat tenable_was.conf
        
        # Run the scan
        docker run \
          --name tenable-form-auth \
          -v $(pwd):/scanner \
          --network host \
          -e WAS_MODE=cicd \
          -e ACCESS_KEY="${{ env.TENABLE_ACCESS_KEY }}" \
          -e SECRET_KEY="${{ env.TENABLE_SECRET_KEY }}" \
          tenable/was-scanner:latest || true
        
        # Show results
        if [[ -f "scanner.log" ]]; then
          echo "📋 Scanner log (last 30 lines):"
          tail -30 scanner.log
        fi
          
    - name: 📤 Upload Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: form-auth-simple-results-${{ github.run_number }}
        path: |
          tenable_was_scan.html
          scanner.log
          tenable_was.conf
EOF

cat > .github/workflows/test-api-auth.yml << 'EOF'
name: 🔑 API Auth Test Only

on:
  workflow_dispatch:

env:
  TENABLE_ACCESS_KEY: ${{ secrets.TENABLE_ACCESS_KEY }}
  TENABLE_SECRET_KEY: ${{ secrets.TENABLE_SECRET_KEY }}
  GOREST_API_TOKEN: ${{ secrets.GOREST_API_TOKEN || 'demo-token' }}

jobs:
  api-auth-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: 🧪 Test GoRest API Endpoint
      run: |
        echo "🔍 Testing GoRest API endpoint..."
        response=$(curl -s https://gorest.co.in/public/v2/users)
        if echo "$response" | jq length > /dev/null; then
          echo "✅ GoRest API endpoint working"
        else
          echo "❌ GoRest API endpoint failed"
        fi
    
    - name: 🔍 Run API Auth Scan
      run: |
        echo "🚀 Running API Authentication scan using config/api-key.conf..."
        
        # Use the API key configuration file and replace token placeholder
        cp config/api-key.conf tenable_was.conf
        sed -i "s/\${GOREST_API_TOKEN}/${{ env.GOREST_API_TOKEN }}/g" tenable_was.conf
        
        echo "📋 Configuration file content:"
        cat tenable_was.conf
        
        # Run the scan
        docker run \
          --name tenable-api-auth \
          -v $(pwd):/scanner \
          -e WAS_MODE=cicd \
          -e ACCESS_KEY="${{ env.TENABLE_ACCESS_KEY }}" \
          -e SECRET_KEY="${{ env.TENABLE_SECRET_KEY }}" \
          -e GOREST_API_TOKEN="${{ env.GOREST_API_TOKEN }}" \
          tenable/was-scanner:latest || true
        
        # Show results
        if [[ -f "scanner.log" ]]; then
          echo "📋 Scanner log (last 30 lines):"
          tail -30 scanner.log
        fi
          
    - name: �� Upload Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: api-auth-simple-results-${{ github.run_number }}
        path: |
          tenable_was_scan.html
          scanner.log
          tenable_was.conf
EOF

cat > .github/workflows/test-minimal.yml << 'EOF'
name: 🧪 Minimal Test

on:
  workflow_dispatch:

env:
  TENABLE_ACCESS_KEY: ${{ secrets.TENABLE_ACCESS_KEY }}
  TENABLE_SECRET_KEY: ${{ secrets.TENABLE_SECRET_KEY }}

jobs:
  minimal-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: 🔍 Run Minimal Test Scan
      run: |
        echo "🚀 Running minimal test scan using config/minimal-test.conf..."
        
        # Use the minimal configuration file
        cp config/minimal-test.conf tenable_was.conf
        
        echo "📋 Minimal configuration:"
        cat tenable_was.conf
        
        # Run the scan
        docker run \
          --name tenable-minimal-test \
          -v $(pwd):/scanner \
          -e WAS_MODE=cicd \
          -e ACCESS_KEY="${{ env.TENABLE_ACCESS_KEY }}" \
          -e SECRET_KEY="${{ env.TENABLE_SECRET_KEY }}" \
          tenable/was-scanner:latest || true
        
        # Show all generated files
        echo "📁 Generated files:"
        ls -la *.html *.log *.conf 2>/dev/null || echo "No scan files found"
        
        if [[ -f "scanner.log" ]]; then
          echo "📋 Complete scanner log:"
          cat scanner.log
        fi
          
    - name: 📤 Upload Results
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: minimal-test-results-${{ github.run_number }}
        path: |
          tenable_was_scan.html
          scanner.log
          tenable_was.conf
EOF

# ==========================================
# 3. CONTINUE WITH TEST APPLICATIONS
# ==========================================

echo "🐳 Creating test applications..."

# Test applications docker-compose
cat > test-apps/docker-compose.yml << 'EOF'
version: '3.8'

services:
  dvwa:
    image: vulnerables/web-dvwa:latest
    ports:
      - "8080:80"
    environment:
      - MYSQL_DATABASE=dvwa
      - MYSQL_USER=dvwa
      - MYSQL_PASSWORD=p@ssw0rd
    restart: unless-stopped
    
  nginx-basic-auth:
    build: ./nginx-basic-auth
    ports:
      - "8081:80"
    restart: unless-stopped
    
  simple-login-app:
    build: ./simple-login-app
    ports:
      - "5000:5000"
    restart: unless-stopped
EOF

# Nginx Basic Auth
cat > test-apps/nginx-basic-auth/Dockerfile << 'EOF'
FROM nginx:alpine

# Install htpasswd utility
RUN apk add --no-cache apache2-utils

# Copy configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY .htpasswd /etc/nginx/.htpasswd

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

cat > test-apps/nginx-basic-auth/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name localhost;
        
        location / {
            auth_basic "Restricted Area";
            auth_basic_user_file /etc/nginx/.htpasswd;
            
            return 200 '<html><body><h1>Authenticated Access</h1><p>You are logged in!</p></body></html>';
            add_header Content-Type text/html;
        }
        
        location /health {
            return 200 'OK';
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Generate .htpasswd file (testuser:testpass123)
cat > test-apps/nginx-basic-auth/.htpasswd << 'EOF'
testuser:$apr1$rUkMy8Rj$8DyOjTs/8s8GzMkVzG7i/.
EOF

# Simple Login App
cat > test-apps/simple-login-app/Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
EOF

cat > test-apps/simple-login-app/requirements.txt << 'EOF'
Flask==2.3.3
Werkzeug==2.3.7
EOF

cat > test-apps/simple-login-app/app.py << 'EOF'
from flask import Flask, request, render_template, redirect, session, url_for

app = Flask(__name__)
app.secret_key = 'test-secret-key-for-demo'

# Test credentials
VALID_USERS = {
    'testuser': 'testpass123',
    'admin': 'password',
    'demo': 'demo123'
}

@app.route('/')
def index():
    if 'logged_in' in session and session['logged_in']:
        return render_template('dashboard.html', username=session.get('username', 'User'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')
        
        if username in VALID_USERS and VALID_USERS[username] == password:
            session['logged_in'] = True
            session['username'] = username
            return redirect(url_for('dashboard'))
        else:
            error = 'Invalid credentials. Please try again.'
    
    return render_template('login.html', error=error)

@app.route('/dashboard')
def dashboard():
    if 'logged_in' not in session or not session['logged_in']:
        return redirect(url_for('login'))
    return render_template('dashboard.html', username=session.get('username', 'User'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/health')
def health():
    return 'OK', 200

@app.route('/api/status')
def api_status():
    if 'logged_in' in session and session['logged_in']:
        return {'status': 'authenticated', 'user': session.get('username')}
    return {'status': 'unauthenticated'}, 401

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF

cat > test-apps/simple-login-app/templates/login.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Login - Tenable WAS POC</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f4f4f4; margin: 0; padding: 50px; }
        .container { max-width: 400px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h2 { text-align: center; color: #333; margin-bottom: 30px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 5px; color: #555; font-weight: bold; }
        input[type="text"], input[type="password"] { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background: #0056b3; }
        .error { color: #dc3545; margin-top: 10px; text-align: center; }
        .test-credentials { background: #e9ecef; padding: 15px; border-radius: 4px; margin-top: 20px; font-size: 14px; }
        .test-credentials h4 { margin: 0 0 10px 0; color: #495057; }
    </style>
</head>
<body>
    <div class="container">
        <h2>🔒 Test Login Page</h2>
        <form method="post">
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit">Login</button>
        </form>
        
        {% if error %}
        <div class="error">{{ error }}</div>
        {% endif %}
        
        <div class="test-credentials">
            <h4>Test Credentials:</h4>
            <strong>Username:</strong> testuser<br>
            <strong>Password:</strong> testpass123<br><br>
            <strong>Username:</strong> admin<br>
            <strong>Password:</strong> password<br><br>
            <strong>Username:</strong> demo<br>
            <strong>Password:</strong> demo123
        </div>
    </div>
</body>
</html>
EOF

cat > test-apps/simple-login-app/templates/dashboard.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Tenable WAS POC</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f4f4f4; margin: 0; padding: 50px; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #28a745; text-align: center; margin-bottom: 30px; }
        .welcome { background: #d4edda; padding: 20px; border-radius: 4px; margin-bottom: 30px; border-left: 4px solid #28a745; }
        .nav-links { text-align: center; margin-top: 30px; }
        .nav-links a { display: inline-block; margin: 0 10px; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; }
        .nav-links a:hover { background: #0056b3; }
        .nav-links a.logout { background: #dc3545; }
        .nav-links a.logout:hover { background: #c82333; }
        .features { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-top: 30px; }
        .feature { background: #f8f9fa; padding: 20px; border-radius: 4px; border-left: 4px solid #17a2b8; }
        .feature h3 { margin: 0 0 10px 0; color: #495057; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Welcome to the Dashboard</h1>
        
        <div class="welcome">
            <strong>Authentication Successful!</strong><br>
            Hello, <strong>{{ username }}</strong>! You have successfully logged in to the secure area.
        </div>
        
        <div class="features">
            <div class="feature">
                <h3>🔐 Secure Access</h3>
                <p>This page is only accessible to authenticated users. Perfect for testing form-based authentication in Tenable WAS.</p>
            </div>
            <div class="feature">
                <h3>📊 Session Management</h3>
                <p>Your session is being managed securely with server-side session storage.</p>
            </div>
            <div class="feature">
                <h3>🧪 Testing Ready</h3>
                <p>This application is designed specifically for security scanning and penetration testing.</p>
            </div>
            <div class="feature">
                <h3>🔍 Vulnerability Scanning</h3>
                <p>Use this application to test authenticated scans with your security tools.</p>
            </div>
        </div>
        
        <div class="nav-links">
            <a href="/api/status">API Status</a>
            <a href="/health">Health Check</a>
            <a href="/logout" class="logout">Logout</a>
        </div>
    </div>
</body>
</html>
EOF

# ==========================================
# 4. HELPER SCRIPTS
# ==========================================

echo "📜 Creating helper scripts..."

cat > scripts/setup-environment.sh << 'EOF'
#!/bin/bash

echo "🔧 Setting up Tenable WAS POC environment..."

# Check required tools
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "❌ curl is required but not installed."; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "❌ jq is required but not installed."; exit 1; }

echo "✅ All required tools are available"

# Test public endpoints
echo "🧪 Testing public endpoints..."

# Test HTTPBin
if curl -s https://httpbin.org/ip | jq -r '.origin' > /dev/null; then
    echo "✅ HTTPBin.org is accessible"
else
    echo "❌ HTTPBin.org is not accessible"
    exit 1
fi

# Test GoRest API
if curl -s https://gorest.co.in/public/v2/users | jq 'length' > /dev/null; then
    echo "✅ GoRest API is accessible"
else
    echo "❌ GoRest API is not accessible"
fi

# Test Basic Auth endpoint
if curl -s -u testuser:testpass123 https://httpbin.org/basic-auth/testuser/testpass123 | jq -r '.authenticated' | grep -q "true"; then
    echo "✅ HTTPBin Basic Auth endpoint working"
else
    echo "❌ HTTPBin Basic Auth endpoint failed"
fi

# Test Digest Auth endpoint
if curl -s --digest -u testuser:testpass123 https://httpbin.org/digest-auth/auth/testuser/testpass123 | jq -r '.authenticated' | grep -q "true"; then
    echo "✅ HTTPBin Digest Auth endpoint working"
else
    echo "❌ HTTPBin Digest Auth endpoint failed"
fi

echo "🎉 Environment setup complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Set up your GitHub repository secrets:"
echo "   - TENABLE_ACCESS_KEY"
echo "   - TENABLE_SECRET_KEY"
echo "   - GOREST_API_TOKEN (optional)"
echo ""
echo "2. Push this code to your GitHub repository"
echo "3. Go to Actions tab and run the workflows"
echo ""
echo "4. To test locally, run:"
echo "   cd test-apps && docker-compose up -d"
echo ""
echo "5. Available configuration files:"
echo "   - config/basic-auth.conf"
echo "   - config/digest-auth.conf"
echo "   - config/form-auth.conf"
echo "   - config/dvwa-form-auth.conf"
echo "   - config/cookie-auth.conf"
echo "   - config/api-key.conf"
echo "   - config/bearer-token.conf"
echo "   - config/minimal-test.conf"
EOF

cat > scripts/validate-endpoints.sh << 'EOF'
#!/bin/bash

echo "🔍 Validating all test endpoints..."

# HTTPBin endpoints
echo "Testing HTTPBin endpoints..."
curl -s https://httpbin.org/ip && echo "✅ HTTPBin basic endpoint working"
curl -s -u testuser:testpass123 https://httpbin.org/basic-auth/testuser/testpass123 | jq .authenticated && echo "✅ Basic auth working"
curl -s --digest -u testuser:testpass123 https://httpbin.org/digest-auth/auth/testuser/testpass123 | jq .authenticated && echo "✅ Digest auth working"

# GoRest API
echo "Testing GoRest API..."
curl -s https://gorest.co.in/public/v2/users | jq 'length' && echo "✅ GoRest API working"

# Local test apps (if running)
echo "Testing local applications..."
if curl -s http://localhost:5000/health > /dev/null; then
    echo "✅ Simple login app is running on port 5000"
else
    echo "ℹ️ Simple login app not running (run 'docker-compose up' in test-apps directory)"
fi

if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ DVWA is running on port 8080"
else
    echo "ℹ️ DVWA not running (run 'docker-compose up' in test-apps directory)"
fi

if curl -s http://localhost:8081/health > /dev/null; then
    echo "✅ Nginx basic auth is running on port 8081"
else
    echo "ℹ️ Nginx basic auth not running (run 'docker-compose up' in test-apps directory)"
fi

echo "🎉 Endpoint validation complete!"
EOF

cat > scripts/test-config-files.sh << 'EOF'
#!/bin/bash

echo "🧪 Testing all configuration files..."

# Test if all config files exist and are valid
config_dir="config"

if [[ ! -d "$config_dir" ]]; then
    echo "❌ Config directory not found!"
    exit 1
fi

echo "📁 Found configuration files:"
for config_file in "$config_dir"/*.conf; do
    if [[ -f "$config_file" ]]; then
        filename=$(basename "$config_file")
        echo "✅ $filename"
        
        # Basic syntax check
        if grep -q "scan {" "$config_file" && grep -q "target =" "$config_file"; then
            echo "   ✓ Contains required fields"
        else
            echo "   ⚠️ Missing required fields"
        fi
        
        # Check for credentials section
        if grep -q "credentials {" "$config_file"; then
            echo "   ✓ Contains credentials section"
        else
            echo "   ℹ️ No credentials section (may be intentional)"
        fi
        
        echo ""
    fi
done

echo "🎉 Configuration file validation complete!"
echo ""
echo "📋 To use any configuration file:"
echo "1. Copy it to tenable_was.conf: cp config/basic-auth.conf tenable_was.conf"
echo "2. Run the scanner with your Tenable credentials"
echo "3. Or use the GitHub Actions workflows that automatically use these files"
EOF

cat > scripts/generate-cookies.sh << 'EOF'
#!/bin/bash

echo "🍪 Generating test cookies..."

# Generate session cookie for HTTPBin
echo "Creating HTTPBin test cookie..."
cookie_jar=$(mktemp)
curl -s -c "$cookie_jar" https://httpbin.org/cookies/set/test-session/authenticated-user
echo "Generated cookie file: $cookie_jar"
cat "$cookie_jar"

# Test the cookie
echo ""
echo "Testing cookie..."
response=$(curl -s -b "$cookie_jar" https://httpbin.org/cookies)
echo "$response" | jq .

# Generate cookie string for configuration
cookie_string="test-session=authenticated-user; Path=/; Domain=httpbin.org"
echo ""
echo "Cookie string for configuration:"
echo "$cookie_string"

# Clean up
rm -f "$cookie_jar"

echo "✅ Cookie generation complete!"
echo ""
echo "📝 To use this cookie in a config file:"
echo "1. Edit config/cookie-auth.conf"
echo "2. Update the cookie field with your generated cookie"
echo "3. Run the cookie authentication workflow"
EOF

# Make scripts executable
chmod +x scripts/*.sh

# ==========================================
# 5. DOCUMENTATION
# ==========================================

echo "📚 Creating documentation..."

cat > docs/CONFIGURATION-GUIDE.md << 'EOF'
# 🔧 Configuration Files Guide

This guide explains how to use and customize the separate configuration files for Tenable WAS scans.

## 📁 Available Configuration Files

| File | Purpose | Target | Authentication |
|------|---------|--------|----------------|
| `basic-auth.conf` | Basic HTTP Authentication | HTTPBin.org | Username/Password |
| `digest-auth.conf` | Digest HTTP Authentication | HTTPBin.org | Username/Password |
| `form-auth.conf` | Simple Form Login | Local Flask App | Form
