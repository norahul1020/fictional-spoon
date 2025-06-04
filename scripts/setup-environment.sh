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
