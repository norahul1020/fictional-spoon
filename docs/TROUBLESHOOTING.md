# 🔧 Troubleshooting Guide

## Common Issues

### 1. "Authentication failed" errors

**Problem:** Tenable scanner cannot authenticate
**Solution:**
- Verify `TENABLE_ACCESS_KEY` and `TENABLE_SECRET_KEY` are correct
- Check secrets are set in GitHub repository (not organization)
- Ensure Tenable.io account has WAS license

### 2. "Docker pull failed" errors

**Problem:** Cannot pull Tenable scanner image
**Solution:**
- This is usually temporary - retry the workflow
- Check GitHub Actions runner has internet access

### 3. "Target unreachable" errors

**Problem:** Scanner cannot reach test endpoints
**Solution:**
- Verify endpoints manually: `curl https://httpbin.org/ip`
- Check if corporate firewall blocks external requests
- Try different test endpoints

### 4. Form authentication failures

**Problem:** DVWA login not working
**Solution:**
- DVWA needs database setup - this is done automatically
- Wait longer for DVWA to initialize (increase sleep time)
- Check DVWA logs: `docker logs dvwa-container`

### 5. "No vulnerabilities found"

**Problem:** Clean scan results
**Solution:**
- This is expected for test endpoints
- Test endpoints are designed to be accessible, not vulnerable
- Focus on authentication success rather than vulnerability count

### 6. Local testing issues

**Problem:** Local apps not starting
**Solution:**
```bash
# Check Docker is running
docker --version

# Check ports are available
netstat -tlnp | grep :8080

# View logs
docker-compose logs

# Restart services
docker-compose down && docker-compose up -d
```

### 7. API rate limiting

**Problem:** Too many requests to public APIs
**Solution:**
- Reduce scan scope in configuration
- Add delays between requests
- Use different test endpoints

## Debugging Steps

### 1. Check endpoint accessibility
```bash
curl -v https://httpbin.org/basic-auth/testuser/testpass123 \
  -u testuser:testpass123
```

### 2. Validate configuration
- Check HOCON syntax in configuration files
- Verify target URLs are accessible
- Test authentication manually

### 3. Review scan logs
- Download scanner.log from workflow artifacts
- Look for authentication errors
- Check for network connectivity issues

### 4. Test locally
```bash
# Run scanner locally
docker run \
  -v $(pwd):/scanner \
  -e WAS_MODE=cicd \
  -e ACCESS_KEY=your_key \
  -e SECRET_KEY=your_secret \
  tenable/was-scanner:latest
```

## Getting Help

1. Check Tenable documentation: https://docs.tenable.com/
2. Review GitHub Actions logs for detailed error messages
3. Test authentication endpoints manually
4. Verify all secrets are correctly configured

## Useful Commands

```bash
# Test HTTPBin endpoints
curl -u testuser:testpass123 https://httpbin.org/basic-auth/testuser/testpass123

# Test GoRest API
curl https://gorest.co.in/public/v2/users

# Check local services
docker ps
docker-compose ps

# View logs
docker logs container_name
docker-compose logs service_name
```
