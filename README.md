# 🔒 Tenable Web App Scanning - Complete POC

A comprehensive Proof of Concept for implementing **Tenable Web App Scanning** with **complete CI/CD integration** and **all authentication methods**.

## 🎯 Features

- ✅ **Zero Console Configuration** - Everything runs via CI/CD
- ✅ **All Authentication Methods** - Basic, Digest, Form, Cookie, API Key, Bearer
- ✅ **Real Test Endpoints** - HTTPBin, GoRest, DVWA, Custom apps
- ✅ **GitHub Actions Ready** - Complete workflows included
- ✅ **Local Testing** - Docker Compose setup for local development
- ✅ **Comprehensive Documentation** - Setup guides and troubleshooting

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone <your-repo>
cd tenable-was-poc
```

### 2. Configure GitHub Secrets
Go to Settings → Secrets and variables → Actions:

**Required:**
- `TENABLE_ACCESS_KEY` - Your Tenable.io access key
- `TENABLE_SECRET_KEY` - Your Tenable.io secret key

**Optional:**
- `GOREST_API_TOKEN` - Free token from gorest.co.in

### 3. Run Your First Scan
1. Go to Actions tab
2. Select "🔐 Basic Auth Test Only"
3. Click "Run workflow"
4. Download results from artifacts

## 📊 Supported Authentication Methods

| Method | Test Endpoint | Status | Notes |
|--------|---------------|--------|-------|
| **Basic Auth** | HTTPBin.org | ✅ Working | Username: testuser, Password: testpass123 |
| **Digest Auth** | HTTPBin.org | ✅ Working | Username: testuser, Password: testpass123 |
| **Form Login** | DVWA/Custom App | ✅ Working | Login form with session management |
| **Cookie Auth** | HTTPBin.org | ✅ Working | Session cookie authentication |
| **API Key** | GoRest API | ✅ Working | Bearer token in headers |
| **Bearer Token** | HTTPBin.org | ✅ Working | Authorization header |

## 🐳 Local Testing

Start all test applications:
```bash
cd test-apps
docker-compose up -d
```

This starts:
- **DVWA** on http://localhost:8080 (admin/password)
- **Simple Login App** on http://localhost:5000 (testuser/testpass123)
- **Nginx Basic Auth** on http://localhost:8081 (testuser/testpass123)

Validate endpoints:
```bash
./scripts/validate-endpoints.sh
```

## 📋 Available Workflows

| Workflow File | Purpose | Triggers |
|---------------|---------|----------|
| `test-all-auth-methods.yml` | Complete test suite | Push, PR, Manual |
| `test-basic-auth.yml` | Basic auth only | Manual |
| `test-form-auth.yml` | Form auth only | Manual |
| `test-api-auth.yml` | API auth only | Manual |

## 🔧 Configuration

All scan configurations are in the `config/` directory:
- `base-config.conf` - Base scan settings
- `basic-auth.conf` - HTTPBin basic authentication
- `digest-auth.conf` - HTTPBin digest authentication
- `form-auth.conf` - DVWA form authentication
- `cookie-auth.conf` - Cookie-based authentication
- `api-key.conf` - GoRest API key authentication
- `bearer-token.conf` - Bearer token authentication

## 📁 Directory Structure

```
tenable-was-poc/
├── .github/workflows/    # GitHub Actions workflows
├── config/              # Tenable WAS configurations
├── test-apps/           # Docker test applications
├── scripts/             # Helper scripts
├── docs/                # Documentation
└── results/             # Scan results (created during runs)
```

## 🔍 Test Endpoints

### Public Endpoints (No setup required)
- **HTTPBin Basic Auth**: https://httpbin.org/basic-auth/testuser/testpass123
- **HTTPBin Digest Auth**: https://httpbin.org/digest-auth/auth/testuser/testpass123
- **HTTPBin Cookies**: https://httpbin.org/cookies
- **HTTPBin Bearer**: https://httpbin.org/bearer
- **GoRest API**: https://gorest.co.in/public/v2/users

### Local Endpoints (Docker required)
- **DVWA**: http://localhost:8080/DVWA/
- **Simple Login App**: http://localhost:5000/
- **Nginx Basic Auth**: http://localhost:8081/

## 📖 Documentation

- [Setup Guide](docs/SETUP.md) - Complete setup instructions
- [Secrets Guide](docs/SECRETS.md) - How to configure secrets
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## 🧪 Example Scan Results

Each workflow generates:
- **HTML Report** (`tenable_was_scan.html`) - Visual vulnerability report
- **Scanner Log** (`scanner.log`) - Detailed execution log
- **Configuration** (`tenable_was.conf`) - Scan parameters used

All results are automatically uploaded as GitHub Actions artifacts.

## 🔐 Security Notes

- Test credentials are intentionally simple for demonstration
- All test endpoints are public or local development only
- Never use these configurations for production applications
- Always rotate Tenable API keys regularly

## 🚀 Getting Started Checklist

- [ ] Fork/clone this repository
- [ ] Set up GitHub repository secrets
- [ ] Run "Basic Auth Test Only" workflow
- [ ] Verify scan completes and results are generated
- [ ] Try other authentication methods
- [ ] Set up local testing environment
- [ ] Customize configurations for your applications

## 📞 Support

- Check [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- Review GitHub Actions logs
- Test endpoints manually with curl
- Verify Tenable.io account has WAS license

## 🎉 Success Criteria

Your POC is successful when:
1. ✅ All GitHub workflows run without errors
2. ✅ Scan reports are generated and downloadable
3. ✅ Results appear in Tenable.io dashboard
4. ✅ Authentication methods work as expected
5. ✅ Local test environment runs properly

## 📚 Additional Resources

- [Tenable WAS Documentation](https://docs.tenable.com/web-app-scanning/)
- [Tenable API Documentation](https://developer.tenable.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

**Ready to secure your applications? Start with the Basic Auth test and expand from there! Hooreeyyyy** 🚀
