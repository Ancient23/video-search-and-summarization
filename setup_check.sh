#!/bin/bash

echo "🚀 NVIDIA VSS Blueprint - System Prerequisites Check"
echo "=================================================="

# Check if running on Windows (Git Bash/WSL)
if [[ "$OS" == "Windows_NT" ]] || [[ $(uname -r) == *microsoft* ]]; then
    echo "⚠️  Windows detected. This setup is optimized for Linux."
    echo "   Consider using WSL2 with Docker Desktop for Windows."
    echo ""
fi

# Check NVIDIA Driver
echo "1. Checking NVIDIA GPU and drivers..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits
    echo "✅ NVIDIA drivers found"
else
    echo "❌ NVIDIA drivers not found. Please install NVIDIA drivers first."
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
    echo "❌ Docker not found. Please install Docker first."
    echo "   Install from: https://docs.docker.com/get-docker/"
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
    echo "❌ Docker Compose not found. Please install Docker Compose."
    exit 1
fi

echo ""

# Check NVIDIA Container Toolkit
echo "4. Checking NVIDIA Container Toolkit..."
if docker run --rm --gpus all nvidia/cuda:12.2-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo "✅ NVIDIA Container Toolkit working"
else
    echo "❌ NVIDIA Container Toolkit not working properly."
    echo "   Install with:"
    echo "   curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
    echo "   curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list"
    echo "   sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit"
    echo "   sudo systemctl restart docker"
    exit 1
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
echo "🎉 Prerequisites check complete!"
echo ""
echo "Next steps:"
echo "1. Get your NVIDIA API key from: https://build.nvidia.com/"
echo "2. Run the setup script: ./setup_vss.sh" 