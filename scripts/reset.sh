#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GRAPHDB_URL="http://localhost:7200"
REPO_ID="sparql-playground"

echo -e "${YELLOW}╔════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║   Reset SPARQL Playground             ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}This will delete all data and reload from scratch.${NC}"
read -p "Continue? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Reset cancelled${NC}"
    exit 0
fi

# Delete repository if exists
if curl -sf "$GRAPHDB_URL/rest/repositories/$REPO_ID" > /dev/null 2>&1; then
    echo -e "${YELLOW}Deleting repository...${NC}"
    curl -sf -X DELETE "$GRAPHDB_URL/rest/repositories/$REPO_ID" > /dev/null
    echo -e "${GREEN}✓ Repository deleted${NC}"
fi

# Run setup
echo ""
"$SCRIPT_DIR/setup.sh"

