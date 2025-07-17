# VSS Blueprint Setup Scripts - Commit Guide

This guide lists the setup scripts and documentation files to commit to your fork for easy reproduction on other systems.

## Files to Commit

### Setup Scripts
```
setup_check.sh              # Linux prerequisites check
setup_vss.sh                 # Linux deployment script
setup_check_windows.sh       # Windows/WSL2 prerequisites check
setup_vss_windows.sh         # Windows/WSL2 deployment script
test_nvidia_api.sh           # NVIDIA API key test utility
troubleshoot.sh              # Diagnostic and troubleshooting tool
```

### Documentation
```
QUICK_START.md               # Linux quick start guide
QUICK_START_WINDOWS.md       # Windows/WSL2 quick start guide
SETUP_COMMIT_GUIDE.md        # This file
.gitignore                   # Updated to exclude deployment artifacts
```

## Git Commands to Commit

```bash
# Add all setup files
git add setup_check.sh setup_vss.sh setup_check_windows.sh setup_vss_windows.sh
git add test_nvidia_api.sh troubleshoot.sh

# Add documentation
git add QUICK_START.md QUICK_START_WINDOWS.md SETUP_COMMIT_GUIDE.md
git add .gitignore

# Commit with descriptive message
git commit -m "Add VSS Blueprint automated setup scripts

- Linux setup: setup_check.sh, setup_vss.sh
- Windows/WSL2 setup: setup_check_windows.sh, setup_vss_windows.sh  
- Utilities: test_nvidia_api.sh, troubleshoot.sh
- Documentation: QUICK_START.md, QUICK_START_WINDOWS.md
- Updated .gitignore to exclude deployment artifacts

Enables one-command deployment of NVIDIA VSS Blueprint on both Linux and Windows systems."

# Push to your fork
git push origin main
```

## What Gets Excluded (.gitignore)

The updated `.gitignore` excludes:
- `vss_deployment/` - Deployment directory created by scripts
- `*.env` - Environment files containing API keys
- `*.log`, `logs/` - Log files and directories
- `assets/`, `data/` - User-uploaded content and data
- Docker overrides and temporary files

## Reproducing Setup on New Systems

### For Linux Users:
```bash
git clone https://github.com/YOUR_USERNAME/video-search-and-summarization.git
cd video-search-and-summarization
./setup_check.sh && ./setup_vss.sh
```

### For Windows/WSL2 Users:
```powershell
git clone https://github.com/YOUR_USERNAME/video-search-and-summarization.git
cd video-search-and-summarization
wsl bash -c "./setup_check_windows.sh && ./setup_vss_windows.sh"
```

### Prerequisites
Users still need:
1. **NVIDIA GPU** with drivers installed
2. **Docker** with GPU support configured
3. **NVIDIA API Key** from https://build.nvidia.com/

## Benefits of This Setup

✅ **One-command deployment** from fresh clone  
✅ **Cross-platform support** (Linux + Windows/WSL2)  
✅ **Automated error checking** and system validation  
✅ **Built-in troubleshooting** tools  
✅ **No manual configuration** required  
✅ **Secure** - API keys not committed to git  

## Script Descriptions

### `setup_check.sh` / `setup_check_windows.sh`
- Validates system prerequisites
- Checks NVIDIA drivers, Docker, GPU access
- Platform-specific checks for Linux vs Windows/WSL2
- Provides fix instructions for common issues

### `setup_vss.sh` / `setup_vss_windows.sh`  
- Prompts for NVIDIA API key
- Creates deployment directory with proper configuration
- Handles Docker Compose deployment
- Monitors service startup and health
- Platform-optimized for performance

### `test_nvidia_api.sh`
- Validates NVIDIA API key connectivity
- Tests access to required models
- Useful for troubleshooting API issues

### `troubleshoot.sh`
- Comprehensive diagnostic tool
- Checks service status, logs, resources
- Provides common solutions
- Helpful for debugging deployment issues

## Maintenance Notes

- Scripts automatically pull latest VSS container images
- API keys remain local (not committed)
- Deployment artifacts excluded from git
- Easy to update scripts and redeploy

---

**Result**: Anyone can clone your fork and have VSS running in under 10 minutes with just basic prerequisites! 