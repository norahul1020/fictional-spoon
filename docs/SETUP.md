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
