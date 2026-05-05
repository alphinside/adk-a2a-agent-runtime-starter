#!/bin/bash
set -e
source .env

echo "================================================"
echo "Cloud Run Deployment"
echo "================================================"
echo ""

# Step 1: Validate environment
echo "[1/5] Validating environment..."

for VAR in REGION DB_PASSWORD DB_INSTANCE DB_NAME GOOGLE_CLOUD_PROJECT GOOGLE_CLOUD_LOCATION; do
    if [ -z "${!VAR}" ]; then
        echo "ERROR: $VAR is not set in .env"
        exit 1
    fi
done

echo "      ✓ Environment validated"
echo ""

# Step 2: Prepare Toolbox deployment artifacts
echo "[2/5] Preparing Toolbox deployment artifacts..."

cp toolbox tools.yaml deploy-toolbox/

echo "      ✓ Artifacts copied to deploy-toolbox/"
echo ""

# Step 3: Deploy Toolbox service to Cloud Run
echo "[3/5] Deploying Toolbox service to Cloud Run..."

if gcloud run services describe toolbox-service --region="$REGION" --quiet >/dev/null 2>&1; then
    echo "      Service already exists, updating..."
fi

gcloud run deploy toolbox-service \
    --source deploy-toolbox/ \
    --region "$REGION" \
    --set-env-vars "DB_PASSWORD=$DB_PASSWORD,DB_INSTANCE=$DB_INSTANCE,DB_NAME=$DB_NAME,GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT,REGION=$REGION,GOOGLE_CLOUD_LOCATION=$GOOGLE_CLOUD_LOCATION" \
    --allow-unauthenticated \
    --quiet

echo "      ✓ Toolbox service deployed"
echo ""

# Step 4: Verify Toolbox service
echo "[4/5] Verifying Toolbox service..."

TOOLBOX_URL=$(gcloud run services describe toolbox-service \
    --region="$REGION" \
    --format='value(status.url)')

if [ -z "$TOOLBOX_URL" ]; then
    echo "ERROR: Could not retrieve Toolbox service URL"
    exit 1
fi

echo "      Toolbox URL: $TOOLBOX_URL"

curl -sf "$TOOLBOX_URL/api/toolset" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "      WARNING: Toolbox health check failed, service may still be starting"
else
    echo "      ✓ Toolbox service healthy"
fi
echo ""

# Step 5: Deploy Agent service to Cloud Run
echo "[5/5] Deploying Agent service to Cloud Run..."

if gcloud run services describe restaurant-agent --region="$REGION" --quiet >/dev/null 2>&1; then
    echo "      Service already exists, updating..."
fi

gcloud run deploy restaurant-agent \
    --source . \
    --region "$REGION" \
    --set-env-vars "TOOLBOX_URL=$TOOLBOX_URL,GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT,GOOGLE_CLOUD_LOCATION=$GOOGLE_CLOUD_LOCATION,GOOGLE_GENAI_USE_VERTEXAI=TRUE" \
    --allow-unauthenticated \
    --quiet

AGENT_URL=$(gcloud run services describe restaurant-agent \
    --region="$REGION" \
    --format='value(status.url)')

echo "      ✓ Agent service deployed"
echo "      Agent URL: $AGENT_URL"
echo ""

echo "================================================"
echo "Deployment complete!"
echo "================================================"
echo ""
echo "  Toolbox: $TOOLBOX_URL"
echo "  Agent:   $AGENT_URL"
echo ""
