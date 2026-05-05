# adk-a2a-agent-runtime-starter

This repository is a starter kit for Codelab [TODO].

## Prerequisites

- Google Cloud project with billing enabled
- `gcloud` CLI authenticated and configured
- `uv` package manager installed

## Setup

1. Copy `.env.example` to `.env` and update `GOOGLE_CLOUD_PROJECT` with your project ID:

```bash
cp .env.example .env
# Edit .env and set GOOGLE_CLOUD_PROJECT=your-project-id
```

2. Run the full setup pipeline:

```bash
bash scripts/full_setup.sh
```

This will:
- Create a Cloud SQL instance and seed the database (Phase 1)
- Generate agent environment config and start the local Toolbox service (Phase 2)
- Deploy Toolbox and Agent services to Cloud Run (Phase 3)

## Testing Locally

After Phase 2 completes, the Toolbox service runs locally on `http://127.0.0.1:5000`. Start the agent with:

```bash
uv run adk web
```

Open the ADK dev UI, select `restaurant_agent`, and test with queries like:
- "What Italian dishes do you have?"
- "I want something spicy and creamy"

## Testing on Cloud Run

After Phase 3 completes, the deployment script prints the Agent URL. Open it in your browser to access the same ADK dev UI running on Cloud Run.
