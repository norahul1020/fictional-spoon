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
