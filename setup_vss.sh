#!/bin/bash

echo "🚀 NVIDIA VSS Blueprint - Quick Setup"
echo "====================================="

# Check if prerequisites check was run
if [ ! -f "./setup_check.sh" ]; then
    echo "❌ Please run the prerequisites check first: ./setup_check.sh"
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

# Set up deployment directory
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
echo "⚙️  Creating environment configuration..."

# Create .env file
cat > .env << EOF
# NVIDIA API Configuration (VSS expects OPENAI_API_KEY for NVIDIA API)
NVIDIA_API_KEY=$NVIDIA_API_KEY
OPENAI_API_KEY=$NVIDIA_API_KEY

# Service Ports
BACKEND_PORT=7860
FRONTEND_PORT=7861

# Neo4j Database Configuration
GRAPH_DB_USERNAME=neo4j
GRAPH_DB_PASSWORD=vss_secure_password_$(date +%s)
GRAPH_DB_HTTP_PORT=7474
GRAPH_DB_BOLT_PORT=7687

# Storage Directories
ASSET_STORAGE_DIR=$(pwd)/assets
VIA_LOG_DIR=$(pwd)/logs

# Configuration Files
CA_RAG_CONFIG=$(pwd)/config.yaml
GUARDRAILS_CONFIG=$(pwd)/guardrails

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
echo "🐳 Starting Docker deployment..."

# Pull images first
echo "📥 Pulling Docker images..."
docker-compose pull

# Start services
echo "🚀 Starting services..."
docker-compose up -d

# Wait a moment for services to start
echo "⏳ Waiting for services to initialize..."
sleep 10

# Check service status
echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "🔍 Checking service health..."

# Check if frontend is responding
if curl -s http://localhost:7861 > /dev/null; then
    echo "✅ Frontend is running at http://localhost:7861"
else
    echo "⚠️  Frontend not responding yet (this is normal, may take a few minutes)"
fi

# Check if backend is responding  
if curl -s http://localhost:7860 > /dev/null; then
    echo "✅ Backend is running at http://localhost:7860"
else
    echo "⚠️  Backend not responding yet (this is normal, may take a few minutes)"
fi

# Check Neo4j
if curl -s http://localhost:7474 > /dev/null; then
    echo "✅ Neo4j database is running at http://localhost:7474"
else
    echo "⚠️  Neo4j not responding yet"
fi

echo ""
echo "🎉 Deployment complete!"
echo ""
echo "🌐 Access your VSS system:"
echo "   Frontend (Main UI):  http://localhost:7861"
echo "   Backend API:         http://localhost:7860"  
echo "   Neo4j Browser:       http://localhost:7474"
echo ""
echo "📋 Useful commands:"
echo "   View logs:           docker-compose logs -f"
echo "   Stop services:       docker-compose down"
echo "   Restart services:    docker-compose restart"
echo "   Check GPU usage:     nvidia-smi"
echo ""
echo "📖 Next steps:"
echo "1. Wait 2-3 minutes for all services to fully initialize"
echo "2. Open http://localhost:7861 in your browser"
echo "3. Upload a test video to try the system"
echo "4. Check the logs if you encounter issues: docker-compose logs -f via-server"
echo ""

# Show real-time logs for a few seconds
echo "📜 Showing startup logs (press Ctrl+C to stop):"
echo "================================================"
timeout 30s docker-compose logs -f via-server || true

echo ""
echo "🏁 Setup script completed. Your VSS system should be ready!" 