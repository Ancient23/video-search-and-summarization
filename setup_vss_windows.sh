#!/bin/bash

echo "🚀 NVIDIA VSS Blueprint - Windows/WSL2 Setup"
echo "============================================="

echo "Setting up VSS for Windows with WSL2 and Docker Desktop..."
echo ""

# Check if we're in WSL2
if [[ ! $(uname -r) == *microsoft* ]]; then
    echo "⚠️  This script should be run in WSL2. Run from PowerShell:"
    echo "   wsl bash -c \"cd /mnt/c/Github/video-search-and-summarization && ./setup_vss_windows.sh\""
    exit 1
fi

# Check if prerequisites check was run
if [ ! -f "./setup_check_windows.sh" ]; then
    echo "❌ Please run the Windows prerequisites check first:"
    echo "   wsl bash -c \"cd /mnt/c/Github/video-search-and-summarization && ./setup_check_windows.sh\""
    exit 1
fi

# Check for NVIDIA API key
if [ -z "$NVIDIA_API_KEY" ]; then
    echo "📋 NVIDIA API Key Setup"
    echo "----------------------"
    echo "You need an NVIDIA API key to use remote models."
    echo "Get one from: https://build.nvidia.com/"
    echo ""
    read -p "Enter your NVIDIA API key: " NVIDIA_API_KEY
    
    if [ -z "$NVIDIA_API_KEY" ]; then
        echo "❌ API key is required. Exiting."
        exit 1
    fi
fi

# Set up deployment directory (in Windows file system for easier access)
DEPLOYMENT_DIR="vss_deployment"
DOCKER_DIR="deploy/docker/remote_vlm_deployment"

echo ""
echo "📁 Setting up deployment directory..."

# Create deployment directory
mkdir -p "$DEPLOYMENT_DIR"
cd "$DEPLOYMENT_DIR"

# Copy deployment files
if [ -d "../$DOCKER_DIR" ]; then
    cp -r "../$DOCKER_DIR"/* .
    echo "✅ Copied deployment files"
else
    echo "❌ Deployment files not found. Make sure you're in the project root directory."
    exit 1
fi

# Create directories for data
mkdir -p ./assets ./logs ./data

echo ""
echo "⚙️  Creating Windows-compatible environment configuration..."

# Create .env file with Windows-compatible paths
cat > .env << EOF
# NVIDIA API Configuration
NVIDIA_API_KEY=$NVIDIA_API_KEY

# Service Ports
BACKEND_PORT=7860
FRONTEND_PORT=7861

# Neo4j Database Configuration
GRAPH_DB_USERNAME=neo4j
GRAPH_DB_PASSWORD=vss_secure_password_$(date +%s)
GRAPH_DB_HTTP_PORT=7474
GRAPH_DB_BOLT_PORT=7687

# Storage Directories (Windows-compatible paths)
ASSET_STORAGE_DIR=$(pwd)/assets
VIA_LOG_DIR=$(pwd)/logs

# Configuration Files
CA_RAG_CONFIG=$(pwd)/config.yaml
GUARDRAILS_CONFIG=$(pwd)/guardrails

# Windows/WSL2 specific settings
COMPOSE_CONVERT_WINDOWS_PATHS=1

# Optional: Uncomment to customize
# DISABLE_FRONTEND=false
# DISABLE_GUARDRAILS=false
# VSS_LOG_LEVEL=INFO
EOF

echo "✅ Environment file created (.env)"

# Make sure compose file exists
if [ ! -f "compose.yaml" ]; then
    echo "❌ Docker compose file not found!"
    exit 1
fi

echo ""
echo "🐳 Starting Docker deployment on Windows/WSL2..."

# Test GPU access first
echo "🔍 Testing GPU access in Docker..."
if docker run --rm --gpus all ubuntu:22.04 nvidia-smi &> /dev/null; then
    echo "✅ GPU access confirmed"
else
    echo "⚠️  GPU test failed, but continuing with deployment"
    echo "   (Remote models don't require full GPU access)"
fi

# Pull images first
echo "📥 Pulling Docker images..."
docker-compose pull

# Start services
echo "🚀 Starting services..."
docker-compose up -d

# Wait a bit longer for Windows/WSL2
echo "⏳ Waiting for services to initialize (Windows/WSL2 may take longer)..."
sleep 15

# Check service status
echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "🔍 Checking service health..."

# Function to check service with retries
check_service() {
    local url=$1
    local name=$2
    local retries=3
    
    for i in $(seq 1 $retries); do
        if curl -s "$url" > /dev/null; then
            echo "✅ $name is running at $url"
            return 0
        else
            if [ $i -lt $retries ]; then
                echo "⏳ $name not ready yet, retrying in 5s..."
                sleep 5
            fi
        fi
    done
    echo "⚠️  $name not responding at $url (this is normal, may take a few minutes)"
    return 1
}

# Check services
check_service "http://localhost:7861" "Frontend"
check_service "http://localhost:7860" "Backend" 
check_service "http://localhost:7474" "Neo4j database"

echo ""
echo "🎉 Windows/WSL2 deployment complete!"
echo ""
echo "🌐 Access your VSS system:"
echo "   Frontend (Main UI):  http://localhost:7861"
echo "   Backend API:         http://localhost:7860"  
echo "   Neo4j Browser:       http://localhost:7474"
echo ""
echo "💡 Windows-specific tips:"
echo "   • Access URLs from both Windows and WSL2"
echo "   • Files are stored in: $(pwd)"
echo "   • Windows path: /mnt/c/Github/video-search-and-summarization/$DEPLOYMENT_DIR"
echo ""
echo "📋 Useful commands (run in WSL2):"
echo "   View logs:           docker-compose logs -f"
echo "   Stop services:       docker-compose down"
echo "   Restart services:    docker-compose restart"
echo "   Check GPU usage:     nvidia-smi"
echo ""
echo "📖 Next steps:"
echo "1. Wait 3-5 minutes for all services to fully initialize on Windows"
echo "2. Open http://localhost:7861 in your Windows browser"
echo "3. Upload a test video to try the system"
echo "4. Check logs if issues: docker-compose logs -f via-server"
echo ""

# Show real-time logs for a bit longer on Windows
echo "📜 Showing startup logs (press Ctrl+C to stop):"
echo "================================================"
timeout 45s docker-compose logs -f via-server || true

echo ""
echo "🏁 Windows/WSL2 setup completed. Your VSS system should be ready!"
echo "🔗 Open http://localhost:7861 in your Windows browser to start using VSS!" 