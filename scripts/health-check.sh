#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

GRAPHDB_URL="http://localhost:7200"
REPO_ID="sparql-playground"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   SPARQL Playground Health Check      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check Docker
echo -e "${YELLOW}Checking Docker...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}✗ Docker is not running${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is running${NC}"

# Check GraphDB container
echo -e "${YELLOW}Checking GraphDB container...${NC}"
if ! docker compose ps | grep -q "sparql-playground.*Up"; then
    echo -e "${RED}✗ GraphDB container is not running${NC}"
    echo -e "${YELLOW}Run: ./scripts/setup.sh${NC}"
    exit 1
fi
echo -e "${GREEN}✓ GraphDB container is running${NC}"

# Check GraphDB HTTP endpoint
echo -e "${YELLOW}Checking GraphDB HTTP endpoint...${NC}"
if ! curl -sf "$GRAPHDB_URL/rest/repositories" > /dev/null 2>&1; then
    echo -e "${RED}✗ GraphDB is not responding${NC}"
    exit 1
fi
echo -e "${GREEN}✓ GraphDB is responding${NC}"

# Check repository exists
echo -e "${YELLOW}Checking repository...${NC}"
if ! curl -sf "$GRAPHDB_URL/rest/repositories/$REPO_ID" > /dev/null 2>&1; then
    echo -e "${RED}✗ Repository '$REPO_ID' does not exist${NC}"
    echo -e "${YELLOW}Run: ./scripts/setup.sh${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Repository exists${NC}"

# Run health check query
echo ""
echo -e "${BLUE}Data Verification:${NC}"
echo ""

query="PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT 
  (COUNT(DISTINCT ?adr) as ?adrCount)
  (COUNT(DISTINCT ?system) as ?systemCount)
  (COUNT(DISTINCT ?tech) as ?techCount)
  (COUNT(DISTINCT ?team) as ?teamCount)
  (COUNT(DISTINCT ?graph) as ?graphCount)
WHERE {
  { ?adr a :ADR }
  UNION { ?system a :System }
  UNION { ?tech a :Technology }
  UNION { ?team a :Team }
  UNION { GRAPH ?graph { ?s ?p ?o } }
}"

result=$(curl -sf -X POST \
    -H "Accept: application/sparql-results+json" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "query=$query" \
    "$GRAPHDB_URL/repositories/$REPO_ID")

# Parse results
adr_count=$(echo "$result" | grep -o '"adrCount"[^}]*"value":"[0-9]*"' | grep -o '[0-9]*$')
system_count=$(echo "$result" | grep -o '"systemCount"[^}]*"value":"[0-9]*"' | grep -o '[0-9]*$')
tech_count=$(echo "$result" | grep -o '"techCount"[^}]*"value":"[0-9]*"' | grep -o '[0-9]*$')
team_count=$(echo "$result" | grep -o '"teamCount"[^}]*"value":"[0-9]*"' | grep -o '[0-9]*$')
graph_count=$(echo "$result" | grep -o '"graphCount"[^}]*"value":"[0-9]*"' | grep -o '[0-9]*$')

# Expected values
expected_adrs=8
expected_systems=5
expected_techs=6
expected_teams=5
expected_graphs=3

# Print results
printf "%-20s %-10s %-10s %-10s\n" "Entity Type" "Expected" "Actual" "Status"
echo "────────────────────────────────────────────────────"

print_check() {
    local name=$1
    local expected=$2
    local actual=$3
    
    if [ "$actual" = "$expected" ]; then
        printf "%-20s %-10s %-10s ${GREEN}%-10s${NC}\n" "$name" "$expected" "$actual" "✓"
    else
        printf "%-20s %-10s %-10s ${RED}%-10s${NC}\n" "$name" "$expected" "$actual" "✗"
    fi
}

print_check "ADRs" $expected_adrs $adr_count
print_check "Systems" $expected_systems $system_count
print_check "Technologies" $expected_techs $tech_count
print_check "Teams" $expected_teams $team_count
print_check "Named Graphs" $expected_graphs $graph_count

echo ""

# Overall status
if [ "$adr_count" = "$expected_adrs" ] && \
   [ "$system_count" = "$expected_systems" ] && \
   [ "$tech_count" = "$expected_techs" ] && \
   [ "$team_count" = "$expected_teams" ] && \
   [ "$graph_count" = "$expected_graphs" ]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   All checks passed! ✓                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Ready to query!${NC}"
    echo -e "Open: $GRAPHDB_URL"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   Health check failed! ✗               ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Try running: ./scripts/setup.sh${NC}"
    exit 1
fi

