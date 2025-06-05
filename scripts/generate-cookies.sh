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
