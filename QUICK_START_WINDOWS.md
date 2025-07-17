# NVIDIA VSS Blueprint - Windows/WSL2 Quick Start

Get the NVIDIA Video Search and Summarization Blueprint running on **Windows with WSL2** in under 10 minutes!

## What You Need

- **Windows 10/11** with WSL2 enabled
- **NVIDIA GPU** with 8GB+ VRAM (GTX 1080, RTX 3070, or better)
- **Docker Desktop for Windows** with WSL2 integration
- **Ubuntu** installed in WSL2
- **NVIDIA drivers** installed on Windows (not in WSL2)
- **NVIDIA API key** (free from [build.nvidia.com](https://build.nvidia.com/))

## Pre-Setup: Configure Docker Desktop

1. **Install Docker Desktop for Windows**
   - Download from: https://docs.docker.com/desktop/install/windows-install/
   - During installation, enable "Use WSL 2 based engine"

2. **Configure GPU Support**
   - Open Docker Desktop
   - Go to **Settings → General**
   - Ensure "Use WSL 2 based engine" is ✅ checked
   - Go to **Settings → Resources → WSL Integration**
   - Enable integration with your Ubuntu distribution ✅
   - **Restart Docker Desktop**

3. **Verify Setup**
   - Open PowerShell and run: `wsl --list --verbose`
   - Should show Ubuntu running

## Quick Setup (3 Commands in PowerShell)

```powershell
# 1. Check your system (Windows/WSL2 version)
wsl bash -c "cd /mnt/c/Github/video-search-and-summarization && ./setup_check_windows.sh"

# 2. Set up and deploy VSS
wsl bash -c "cd /mnt/c/Github/video-search-and-summarization && ./setup_vss_windows.sh"

# 3. Open in browser
# Frontend: http://localhost:7861
# Backend API: http://localhost:7860
```

## Alternative: Run from WSL2 Ubuntu

If you prefer working in WSL2 directly:

```bash
# Open Ubuntu terminal and navigate to project
cd /mnt/c/Github/video-search-and-summarization

# 1. Check system
./setup_check_windows.sh

# 2. Deploy VSS
./setup_vss_windows.sh
```

## What This Setup Includes

- **Video Analysis**: Upload videos and get AI-powered summaries
- **Visual Q&A**: Ask questions about video content  
- **Smart Search**: Find specific objects, people, or events in videos
- **Timeline Navigation**: Browse videos with intelligent timestamps
- **Graph Database**: Neo4j for storing video relationships and metadata

## Architecture (Windows/WSL2)

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Your Video    │───▶│  VSS Frontend    │───▶│  NVIDIA APIs    │
│ (Windows Files) │    │ (WSL2 Container) │    │  (Remote AI)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │  VSS Backend     │───▶│  Neo4j Graph    │
                       │ (WSL2 Container) │    │ (WSL2 Container)│
                       └──────────────────┘    └─────────────────┘
```

## First Test

1. **Wait 3-5 minutes** for services to fully start (Windows/WSL2 takes longer)
2. **Open** http://localhost:7861 in your **Windows browser** (Chrome, Edge, etc.)
3. **Upload a test video** (warehouse/surveillance footage works best)
4. **Wait for processing** (2-3 minutes for a short video on Windows)
5. **Try features**:
   - Click "Summarize" to get an AI summary
   - Ask questions like "What safety issues do you see?"
   - Use the timeline to navigate through events

## Monitoring & Troubleshooting

### Check Service Status (in PowerShell or WSL2)
```bash
# From PowerShell
wsl bash -c "cd /mnt/c/Github/video-search-and-summarization/vss_deployment && docker-compose ps"

# From WSL2 Ubuntu
cd /mnt/c/Github/video-search-and-summarization/vss_deployment
docker-compose ps
```

### View Logs
```bash
# From WSL2 Ubuntu terminal
docker-compose logs -f

# Just the main service
docker-compose logs -f via-server

# Neo4j database
docker-compose logs -f graph-db
```

### Check GPU Usage
```bash
# From PowerShell or WSL2
nvidia-smi
watch -n 1 nvidia-smi  # Live monitoring (WSL2 only)
```

### Common Windows/WSL2 Issues

**GPU not detected in Docker:**
```bash
# 1. Check Docker Desktop settings:
#    Settings → Resources → WSL Integration → Enable Ubuntu
# 2. Restart Docker Desktop
# 3. Test GPU: 
wsl bash -c "docker run --rm --gpus all nvidia/cuda:12.2-base-ubuntu22.04 nvidia-smi"
```

**Services start slowly:**
```bash
# Windows/WSL2 takes longer - wait 3-5 minutes
# Check if still starting:
docker-compose logs -f via-server
```

**Port conflicts:**
```bash
# Check what's using ports in PowerShell:
netstat -ano | findstr ":7860"
netstat -ano | findstr ":7861"
```

**WSL2 integration issues:**
```powershell
# In PowerShell as Administrator:
wsl --update
wsl --shutdown
# Then restart Docker Desktop
```

**NVIDIA API errors:**
```bash
# Test your API key (from WSL2):
./test_nvidia_api.sh YOUR_API_KEY
```

## File Locations

### Your Files Are Stored At:
- **WSL2 path**: `/mnt/c/Github/video-search-and-summarization/vss_deployment/`
- **Windows path**: `C:\Github\video-search-and-summarization\vss_deployment\`

### Access From Windows:
- Use Windows Explorer: `\\wsl$\Ubuntu\mnt\c\Github\video-search-and-summarization\vss_deployment`
- Or directly: `C:\Github\video-search-and-summarization\vss_deployment`

## Useful Commands

### From PowerShell:
```powershell
# Start services
wsl bash -c "cd /mnt/c/Github/video-search-and-summarization/vss_deployment && docker-compose up -d"

# Stop services  
wsl bash -c "cd /mnt/c/Github/video-search-and-summarization/vss_deployment && docker-compose down"

# View logs
wsl bash -c "cd /mnt/c/Github/video-search-and-summarization/vss_deployment && docker-compose logs -f"
```

### From WSL2 Ubuntu:
```bash
cd /mnt/c/Github/video-search-and-summarization/vss_deployment

# Start services
docker-compose up -d

# Stop services  
docker-compose down

# Restart a service
docker-compose restart via-server

# Update to latest version
docker-compose pull && docker-compose up -d
```

## Windows Performance Tips

1. **Allocate more resources to WSL2**:
   - Create/edit `%USERPROFILE%\.wslconfig`:
   ```ini
   [wsl2]
   memory=8GB
   processors=4
   ```

2. **Store files on WSL2 filesystem for better performance**:
   - Clone repo to `/home/username/` instead of `/mnt/c/`

3. **Use Windows Terminal** for better WSL2 experience

## Next Steps

Once you have it working:

1. **Try different videos**: Security footage, training videos, meetings
2. **Customize prompts**: Edit `config.yaml` in the deployment directory
3. **Enable audio**: Set `ENABLE_AUDIO=true` for speech transcription
4. **Scale up**: Move to local models if you have powerful hardware
5. **Production**: Use the Kubernetes Helm charts for production deployment

## Getting Help

- **Documentation**: https://docs.nvidia.com/vss/latest/index.html
- **NVIDIA Build**: https://build.nvidia.com/nvidia/video-search-and-summarization
- **Docker Desktop Issues**: https://docs.docker.com/desktop/troubleshoot/topics/
- **WSL2 Issues**: https://docs.microsoft.com/en-us/windows/wsl/troubleshooting

## What's Different on Windows

1. **GPU Access**: Uses Windows NVIDIA drivers through WSL2
2. **File Paths**: Uses Windows filesystem mounted in WSL2 (`/mnt/c/`)
3. **Networking**: Services accessible from both Windows and WSL2
4. **Performance**: Slightly slower than native Linux due to virtualization layer
5. **Startup Time**: Takes 3-5 minutes vs 2-3 minutes on native Linux

The remote deployment still uses NVIDIA's cloud APIs, so the heavy AI processing happens in NVIDIA's infrastructure, not on your local GPU. Your GPU is only used for basic video processing and the web interface.

---

**🎉 You're all set! Start uploading videos and exploring what AI can do with your video content on Windows!**

**💡 Pro tip**: Access the web interface from your Windows browser at http://localhost:7861 for the best experience. 