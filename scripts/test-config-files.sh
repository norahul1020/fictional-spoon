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
