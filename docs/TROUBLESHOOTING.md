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
