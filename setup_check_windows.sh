#!/bin/bash

echo "🚀 NVIDIA VSS Blueprint - Windows/WSL2 Setup Check"
echo "=================================================="

echo "Detected: Windows with WSL2 and Docker Desktop"
echo ""

# Check NVIDIA Driver
echo "1. Checking NVIDIA GPU and drivers..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits
    echo "✅ NVIDIA drivers found"
else
    echo "❌ NVIDIA drivers not found in WSL2"
    echo "   Make sure you have NVIDIA drivers installed on Windows host"
    echo "   Download from: https://www.nvidia.com/drivers"
    exit 1
fi

echo ""

# Check Docker
echo "2. Checking Docker..."
if command -v docker &> /dev/null; then
    docker_version=$(docker --version)
    echo "✅ $docker_version"
else
    echo "❌ Docker not found. Install Docker Desktop for Windows."
    echo "   Download from: https://docs.docker.com/desktop/install/windows-install/"
    exit 1
fi

echo ""

# Check Docker Compose
echo "3. Checking Docker Compose..."
if command -v docker-compose &> /dev/null; then
    compose_version=$(docker-compose --version)
    echo "✅ $compose_version"
elif docker compose version &> /dev/null; then
    compose_version=$(docker compose version)
    echo "✅ $compose_version (using 'docker compose')"
else
    echo "❌ Docker Compose not found"
    exit 1
fi

echo ""

# For Docker Desktop on Windows, we need to check GPU support differently
echo "4. Checking GPU support in Docker Desktop..."

# Check if Docker Desktop has GPU support enabled
if docker run --rm --gpus all ubuntu:22.04 nvidia-smi &> /dev/null; then
    echo "✅ GPU support working in Docker Desktop"
else
    echo "⚠️  GPU support test failed in Docker Desktop"
    echo ""
    echo "🔧 To fix this:"
    echo "1. Open Docker Desktop"
    echo "2. Go to Settings → General"
    echo "3. Make sure 'Use WSL 2 based engine' is checked"
    echo "4. Go to Settings → Resources → WSL Integration"
    echo "5. Enable integration with your Ubuntu distribution"
    echo "6. Restart Docker Desktop"
    echo ""
    echo "If that doesn't work:"
    echo "1. Make sure you have the latest NVIDIA drivers on Windows"
    echo "2. Update Docker Desktop to the latest version"
    echo "3. In PowerShell (as Admin): wsl --update"
    echo ""
    echo "Note: This test may fail even with working GPU access."
    echo "You can proceed with deployment using remote models."
fi

echo ""

# Check available disk space
echo "5. Checking disk space..."
available_space=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$available_space" -ge 20 ]; then
    echo "✅ ${available_space}GB available disk space"
else
    echo "⚠️  Only ${available_space}GB available. Recommend at least 20GB for models and data."
fi

echo ""

# Check WSL2 integration
echo "6. Checking WSL2 Docker integration..."
if docker info | grep -q "WSL"; then
    echo "✅ Docker is using WSL2 backend"
else
    echo "⚠️  Docker may not be using WSL2 backend properly"
    echo "   Check Docker Desktop settings"
fi

echo ""
echo "🎉 Windows/WSL2 prerequisites check complete!"
echo ""
echo "🔑 Next steps:"
echo "1. Get your NVIDIA API key from: https://build.nvidia.com/"
echo "2. Test API key: ./test_nvidia_api.sh YOUR_API_KEY"
echo "3. Run setup: ./setup_vss_windows.sh"
echo ""

# If GPU support is working, show a success message
if docker run --rm --gpus all nvidia/cuda:12.2-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo "🚀 Your system is ready for NVIDIA VSS deployment!"
fi 