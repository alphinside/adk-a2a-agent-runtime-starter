#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================================"
echo "Full Setup Pipeline"
echo "================================================"
echo ""

# Phase 1: Database Setup
echo "[Phase 1/3] Database Setup"
echo "------------------------------------------------"
bash "$SCRIPT_DIR/setup_database.sh"
echo ""

# Phase 2: Local Agent Setup
echo "[Phase 2/3] Local Agent Setup"
echo "------------------------------------------------"
bash "$SCRIPT_DIR/setup_agent_local.sh"
echo ""

echo "================================================"
echo "Ready for local development"
echo "================================================"
echo ""


# Phase 3: Deployment
echo "[Phase 3/3] Deployment"
echo "------------------------------------------------"
bash "$SCRIPT_DIR/setup_deployment.sh"
echo ""

echo "================================================"
echo "Full setup pipeline complete"
echo "================================================"
