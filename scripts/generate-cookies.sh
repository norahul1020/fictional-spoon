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
