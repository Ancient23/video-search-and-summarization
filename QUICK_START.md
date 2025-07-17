# NVIDIA VSS Blueprint - Quick Start Guide

Get the NVIDIA Video Search and Summarization Blueprint running locally in under 10 minutes!

## What You Need

- **NVIDIA GPU** with 8GB+ VRAM (GTX 1080, RTX 3070, or better)
- **Ubuntu 22.04** (or WSL2 on Windows)
- **Docker** and **Docker Compose**
- **NVIDIA drivers** and **NVIDIA Container Toolkit**
- **NVIDIA API key** (free from [build.nvidia.com](https://build.nvidia.com/))

## Quick Setup (3 Commands)

```bash
# 1. Check your system
chmod +x setup_check.sh && ./setup_check.sh

# 2. Set up and deploy
chmod +x setup_vss.sh && ./setup_vss.sh

# 3. Open in browser
# Frontend: http://localhost:7861
# Backend API: http://localhost:7860
```

## What This Setup Includes

- **Video Analysis**: Upload videos and get AI-powered summaries
- **Visual Q&A**: Ask questions about video content
- **Smart Search**: Find specific objects, people, or events in videos  
- **Timeline Navigation**: Browse videos with intelligent timestamps
- **Graph Database**: Neo4j for storing video relationships and metadata

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Your Video    │───▶│  VSS Frontend    │───▶│  NVIDIA APIs    │
│                 │    │  (Port 7861)     │    │  (Remote AI)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │  VSS Backend     │───▶│  Neo4j Graph    │
                       │  (Port 7860)     │    │  (Port 7474)    │
                       └──────────────────┘    └─────────────────┘
```

## First Test

1. **Wait 2-3 minutes** for services to fully start
2. **Open** http://localhost:7861 in your browser
3. **Upload a test video** (warehouse/surveillance footage works best)
4. **Wait for processing** (1-2 minutes for a short video)
5. **Try features**:
   - Click "Summarize" to get an AI summary
   - Ask questions like "What safety issues do you see?"
   - Use the timeline to navigate through events

## Monitoring & Troubleshooting

### Check Service Status
```bash
cd vss_deployment
docker-compose ps
```

### View Logs
```bash
# All services
docker-compose logs -f

# Just the main service
docker-compose logs -f via-server

# Neo4j database
docker-compose logs -f graph-db
```

### Check GPU Usage
```bash
nvidia-smi
watch -n 1 nvidia-smi  # Live monitoring
```

### Common Issues

**Services won't start:**
```bash
# Check ports aren't in use
netstat -tlnp | grep -E ":(7860|7861|7474|7687)"

# Restart Docker
sudo systemctl restart docker
```

**NVIDIA API errors:**
```bash
# Test your API key
curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://integrate.api.nvidia.com/v1/models
```

**Out of memory:**
```bash
# Check system resources
free -h
df -h

# Reduce batch size in config.yaml
nano config.yaml  # Look for batch_size: 5
```

**Frontend not loading:**
```bash
# Wait longer (services take 2-3 minutes to start)
# Check if containers are running
docker-compose ps

# Try restarting frontend
docker-compose restart via-server
```

## Configuration Files

### Main Config (`config.yaml`)
Controls AI model settings, prompts, and processing parameters.

### Environment (`.env`)
Contains API keys, ports, and directory paths.

### Guardrails (`guardrails/config.yml`)
Safety and content filtering settings.

## Useful Commands

```bash
# Start services
docker-compose up -d

# Stop services  
docker-compose down

# Restart a service
docker-compose restart via-server

# Update to latest version
docker-compose pull && docker-compose up -d

# Clean up everything
docker-compose down -v
docker system prune -f
```

## Next Steps

Once you have it working:

1. **Try different videos**: Security footage, training videos, meetings
2. **Customize prompts**: Edit `config.yaml` to focus on your specific use case
3. **Enable audio**: Set `ENABLE_AUDIO=true` for speech transcription
4. **Scale up**: Move to local models if you have powerful hardware
5. **Production**: Use the Kubernetes Helm charts for production deployment

## Getting Help

- **Documentation**: https://docs.nvidia.com/vss/latest/index.html
- **NVIDIA Build**: https://build.nvidia.com/nvidia/video-search-and-summarization
- **Issues**: Check the logs first, then search GitHub issues

## What's Happening Behind the Scenes

1. **Video Upload**: Your video is chunked into segments
2. **Frame Analysis**: Key frames are sent to NVIDIA's VILA vision model
3. **Caption Generation**: AI generates detailed descriptions of each segment
4. **Vector Storage**: Captions are embedded and stored in Milvus database
5. **Graph Building**: Relationships between objects/events stored in Neo4j
6. **Smart Retrieval**: When you ask questions, relevant segments are found and analyzed

The remote deployment uses NVIDIA's cloud APIs, so the heavy AI processing happens in NVIDIA's infrastructure, not on your local GPU. Your GPU is only used for basic video processing and the web interface.

---

**🎉 You're all set! Start uploading videos and exploring what AI can do with your video content.** 