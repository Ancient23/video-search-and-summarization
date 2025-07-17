#!/bin/bash

echo "🔑 NVIDIA API Key Test"
echo "====================="

if [ -z "$1" ]; then
    echo "Usage: ./test_nvidia_api.sh YOUR_API_KEY"
    echo "Or set NVIDIA_API_KEY environment variable"
    echo ""
    echo "Get your API key from: https://build.nvidia.com/"
    exit 1
fi

API_KEY="$1"
if [ -z "$API_KEY" ] && [ ! -z "$NVIDIA_API_KEY" ]; then
    API_KEY="$NVIDIA_API_KEY"
fi

echo "Testing NVIDIA API connectivity..."
echo ""

# Test API access
response=$(curl -s -w "\n%{http_code}" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Accept: application/json" \
  https://integrate.api.nvidia.com/v1/models)

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    echo "✅ API Key is valid and working!"
    echo ""
    echo "Available models for VSS:"
    echo "$body" | grep -o '"id":"[^"]*"' | grep -E "(llama-3|vila|embedqa|rerankqa)" | head -10
    echo ""
    echo "🎉 Your API key is ready for VSS deployment!"
else
    echo "❌ API Key test failed (HTTP $http_code)"
    echo ""
    echo "Response:"
    echo "$body"
    echo ""
    echo "Common issues:"
    echo "- Invalid API key format"
    echo "- Expired or deactivated key"
    echo "- Network connectivity issues"
    echo ""
    echo "Get a new key from: https://build.nvidia.com/"
fi 