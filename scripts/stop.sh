#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}Stopping SPARQL Playground...${NC}"

cd "$PROJECT_ROOT/infra"
docker compose down

echo -e "${GREEN}✓ GraphDB stopped${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} Data is preserved. Run ${GREEN}./scripts/setup.sh${NC} to start again."

