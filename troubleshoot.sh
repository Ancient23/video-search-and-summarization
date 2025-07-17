#!/bin/bash

echo "🔧 NVIDIA VSS Blueprint - Troubleshooting Tool"
echo "=============================================="

# Check if we're in deployment directory
if [ ! -f "compose.yaml" ] && [ ! -f "docker-compose.yml" ]; then
    echo "❌ Not in VSS deployment directory. Please run from vss_deployment folder."
    exit 1
fi

echo ""
echo "1. 📊 Checking service status..."
echo "--------------------------------"
docker-compose ps

echo ""
echo "2. 🔗 Checking port availability..."
echo "-----------------------------------"
for port in 7860 7861 7474 7687; do
    if netstat -tln | grep ":$port " > /dev/null; then
        echo "✅ Port $port is in use"
    else
        echo "❌ Port $port is not in use (service may not be running)"
    fi
done

echo ""
echo "3. 🐳 Checking Docker resources..."
echo "-----------------------------------"
docker system df

echo ""
echo "4. 🖥️  Checking GPU status..."
echo "------------------------------"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=index,name,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits
else
    echo "❌ nvidia-smi not available"
fi

echo ""
echo "5. 🌐 Testing service endpoints..."
echo "-----------------------------------"

# Test frontend
if curl -s -f http://localhost:7861 > /dev/null; then
    echo "✅ Frontend (7861) is responding"
else
    echo "❌ Frontend (7861) is not responding"
fi

# Test backend
if curl -s -f http://localhost:7860 > /dev/null; then
    echo "✅ Backend (7860) is responding"
else
    echo "❌ Backend (7860) is not responding"
fi

# Test Neo4j
if curl -s -f http://localhost:7474 > /dev/null; then
    echo "✅ Neo4j (7474) is responding"
else
    echo "❌ Neo4j (7474) is not responding"
fi

echo ""
echo "6. 🔑 Checking environment configuration..."
echo "-------------------------------------------"
if [ -f ".env" ]; then
    echo "✅ .env file exists"
    if grep -q "NVIDIA_API_KEY" .env; then
        echo "✅ NVIDIA_API_KEY is set"
    else
        echo "❌ NVIDIA_API_KEY not found in .env"
    fi
    
    if grep -q "GRAPH_DB_PASSWORD" .env; then
        echo "✅ Database password is set"
    else
        echo "❌ Database password not found in .env"
    fi
else
    echo "❌ .env file not found"
fi

echo ""
echo "7. 📁 Checking storage directories..."
echo "-------------------------------------"
for dir in assets logs data; do
    if [ -d "$dir" ]; then
        size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        echo "✅ Directory $dir exists ($size)"
    else
        echo "❌ Directory $dir missing"
    fi
done

echo ""
echo "8. 🔍 Recent error logs (last 20 lines)..."
echo "--------------------------------------------"
echo "=== VSS Service Logs ==="
docker-compose logs --tail=20 via-server 2>/dev/null | grep -i error || echo "No recent errors found"

echo ""
echo "=== Neo4j Logs ==="
docker-compose logs --tail=20 graph-db 2>/dev/null | grep -i error || echo "No recent errors found"

echo ""
echo "9. 💾 System resources..."
echo "-------------------------"
echo "Memory usage:"
free -h

echo ""
echo "Disk usage:"
df -h . | tail -1

echo ""
echo "🔧 Common Solutions:"
echo "==================="
echo ""
echo "If services aren't responding:"
echo "  docker-compose restart"
echo ""
echo "If containers won't start:"
echo "  docker-compose down"
echo "  docker-compose pull"
echo "  docker-compose up -d"
echo ""
echo "If you get API errors:"
echo "  1. Check your NVIDIA API key at https://build.nvidia.com/"
echo "  2. Test: curl -H 'Authorization: Bearer YOUR_KEY' https://integrate.api.nvidia.com/v1/models"
echo ""
echo "If frontend won't load:"
echo "  1. Wait 2-3 minutes for full startup"
echo "  2. Check: docker-compose logs -f via-server"
echo "  3. Try: docker-compose restart via-server"
echo ""
echo "If you need to start over:"
echo "  docker-compose down -v"
echo "  docker system prune -f"
echo "  ./setup_vss.sh"
echo ""
echo "For live monitoring:"
echo "  watch -n 2 'docker-compose ps && echo && nvidia-smi'"
echo ""
echo "🆘 Still having issues? Check the logs:"
echo "  docker-compose logs -f via-server" 