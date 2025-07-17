# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the NVIDIA Video Search and Summarization (VSS) Blueprint - an AI-powered video analysis system that processes video content to provide searchable summaries, enable natural language queries, and deliver contextual responses using Vision-Language Models (VLMs) and Large Language Models (LLMs).

## Key Commands

### Development Setup
```bash
# Prerequisites check
./setup_check.sh

# Test NVIDIA API connectivity
./test_nvidia_api.sh

# One-click local setup (Linux/Mac)
./setup_vss.sh

# One-click local setup (Windows)
./setup_vss_windows.sh

# Start VSS engine
./start_via.sh
```

### Docker Operations
```bash
# Build Docker images
cd src/vss-engine
docker build -t vss-engine:latest -f docker/Dockerfile .

# Run with Docker Compose (various topologies)
cd deploy/docker/local_deployment
docker compose up -d

# Single GPU deployment
cd deploy/docker/local_deployment_single_gpu
docker compose up -d

# Remote LLM deployment
cd deploy/docker/remote_llm_deployment
docker compose up -d
```

### Frontend Development (Video Timeline Component)
```bash
cd src/video_timeline
# Install dependencies
npm install

# Development mode
npm run dev

# Build component
npm run build

# Build Python package
python -m build
```

## Architecture Overview

### Core Components

1. **VIA Server** (`src/vss-engine/src/via_server.py`)
   - FastAPI REST API server
   - Handles all client requests
   - Manages video processing workflows

2. **Processing Pipelines**
   - **VLM Pipeline** (`src/vss-engine/src/vlm_pipeline/`): Vision-Language Model processing
   - **CV Pipeline** (`src/vss-engine/src/cv_pipeline/`): Computer vision for object detection/tracking
   - **Model Integration** (`src/vss-engine/src/models/`): Supports VILA, NVILA, and OpenAI-compatible models

3. **Storage Systems**
   - **Neo4j**: Graph database for entity relationships
   - **Milvus**: Vector database for semantic search
   - **Asset Manager**: Local file storage for processed media

4. **Frontend**
   - Custom Gradio component in `src/video_timeline/`
   - Built with Svelte and TypeScript
   - Provides interactive video timeline visualization

### Configuration Structure

- **Main Config**: `src/vss-engine/config/config.yaml`
  - Summarization settings (model selection, prompts)
  - RAG mode (graph-rag vs vector-rag)
  - Notification settings
  
- **Environment Variables**: `.env` files in deployment directories
  - API keys (NVIDIA_API_KEY, HUGGINGFACE_TOKEN)
  - Service endpoints and ports
  - Model deployment settings

- **Model Configuration**:
  - Local models: Configure paths in environment variables
  - Remote models: Set NIM endpoints in config
  - Supports switching between local and remote deployments

### Key Integration Points

1. **Model Deployment**:
   - Can use NVIDIA NIM microservices or local models
   - Configure via `LLM_USE_NIM` and `VLM_USE_NIM` environment variables
   - Model paths set via `LLM_MODEL_DIRECTORY` and `VLM_MODEL_PATH`

2. **Stream Processing**:
   - Supports RTSP streams and video files
   - Configure via `STREAM_SOURCE` in environment

3. **RAG Configuration**:
   - Switch between graph-rag and vector-rag in config.yaml
   - Embedding model configurable (e.g., NV-Embed-QA)

### Development Workflow

1. **Code Changes**:
   - Core logic: `src/vss-engine/src/`
   - Frontend: `src/video_timeline/frontend/`
   - Configurations: `src/vss-engine/config/`

2. **Testing Changes**:
   - Build custom Docker image
   - Deploy using appropriate Docker Compose configuration
   - Access UI at `http://localhost:8501`

3. **Model Updates**:
   - Update model paths in environment variables
   - Restart services to load new models
   - Verify with health check endpoint

### Important Files and Their Purposes

- `via_server.py`: Main API server entry point
- `vlm_pipeline.py`: Vision-language model processing logic
- `cv_pipeline.py`: Computer vision pipeline implementation
- `asset_manager.py`: Media file and metadata management
- `config.yaml`: Primary configuration file
- `compose.yaml`: Docker Compose orchestration

### Deployment Topologies

The system supports multiple deployment configurations:
- **local_deployment**: Full stack on single machine
- **local_deployment_single_gpu**: Optimized for single GPU
- **remote_llm_deployment**: VLM local, LLM remote
- **remote_vlm_deployment**: VLM remote, LLM local
- **launchables**: Cloud-ready deployment

Each topology has its own Docker Compose file and environment configuration in `deploy/docker/`.