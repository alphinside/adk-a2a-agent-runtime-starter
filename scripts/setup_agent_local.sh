#!/bin/bash
set -e
source .env

echo "================================================"
echo "Agent Local Environment Setup"
echo "================================================"
echo ""

# Step 1: Validate root .env
echo "[1/4] Validating root .env..."

if [ -z "$GOOGLE_CLOUD_LOCATION" ]; then
    echo "ERROR: GOOGLE_CLOUD_LOCATION is not set in .env"
    exit 1
fi

if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
    echo "ERROR: GOOGLE_CLOUD_PROJECT is not set in .env"
    exit 1
fi

echo "      ✓ Root .env validated"
echo ""

# Step 2: Generate restaurant_agent/.env
echo "[2/4] Generating restaurant_agent/.env..."

cat > restaurant_agent/.env <<EOF
GOOGLE_GENAI_USE_VERTEXAI=1
GOOGLE_CLOUD_LOCATION=${GOOGLE_CLOUD_LOCATION}
GOOGLE_CLOUD_PROJECT=${GOOGLE_CLOUD_PROJECT}
EOF

echo "      ✓ restaurant_agent/.env created"
echo ""

# Step 3: Download MCP Toolbox
echo "[3/4] Preparing MCP Toolbox binary..."

if [ -f "./toolbox" ]; then
    echo "      MCP Toolbox binary already exists, skipping download"
else
    echo "      Downloading MCP Toolbox..."
    curl -O https://storage.googleapis.com/mcp-toolbox-for-databases/v1.1.0/linux/amd64/toolbox > logs/toolbox_dl.log
    chmod +x toolbox
fi

echo "      ✓ MCP Toolbox ready"
echo ""

# Step 4: Start MCP Toolbox service
echo "[4/4] Starting MCP Toolbox service..."

if pgrep -f './toolbox --config tools.yaml' >/dev/null 2>&1; then
    echo "      Stopping existing MCP Toolbox..."
    pkill -f './toolbox --config tools.yaml'
    sleep 1
fi

set -a; source .env; set +a
./toolbox --config tools.yaml --enable-api > logs/mcp_toolbox.log 2>&1 &

echo "      ✓ MCP Toolbox running (PID: $!)"
echo ""

echo "================================================"
echo "Setup complete!"
echo "================================================"
echo ""
