#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GRAPHDB_URL="http://localhost:7200"
REPO_ID="sparql-playground"
MAX_WAIT=60
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   SPARQL Playground Setup Wizard      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Function to check if GraphDB is ready
check_graphdb_ready() {
    local count=0
    echo -e "${YELLOW}⏳ Waiting for GraphDB to be ready...${NC}"
    
    while [ $count -lt $MAX_WAIT ]; do
        if curl -sf "$GRAPHDB_URL/rest/repositories" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ GraphDB is ready!${NC}"
            return 0
        fi
        sleep 2
        count=$((count + 2))
        echo -n "."
    done
    
    echo -e "\n${RED}✗ GraphDB did not start within $MAX_WAIT seconds${NC}"
    return 1
}

# Function to check if repository exists
repository_exists() {
    curl -sf "$GRAPHDB_URL/rest/repositories/$REPO_ID" > /dev/null 2>&1
}

# Function to create repository
create_repository() {
    echo -e "${YELLOW}📦 Creating repository '$REPO_ID'...${NC}"
    
    # Create repository config in Turtle format (GraphDB Free Edition)
    cat > /tmp/repo-config.ttl << 'EOCONFIG'
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
@prefix rep: <http://www.openrdf.org/config/repository#>.
@prefix sr: <http://www.openrdf.org/config/repository/sail#>.
@prefix sail: <http://www.openrdf.org/config/sail#>.
@prefix graphdb: <http://www.ontotext.com/config/graphdb#>.

[] a rep:Repository ;
    rep:repositoryID "REPO_ID_PLACEHOLDER" ;
    rdfs:label "SPARQL Playground" ;
    rep:repositoryImpl [
        rep:repositoryType "graphdb:SailRepository" ;
        sr:sailImpl [
            sail:sailType "graphdb:Sail" ;
            graphdb:base-URL "http://example.org/adr#" ;
            graphdb:defaultNS "" ;
            graphdb:entity-index-size "10000000" ;
            graphdb:entity-id-size "32" ;
            graphdb:imports "" ;
            graphdb:repository-type "file-repository" ;
            graphdb:ruleset "rdfsplus-optimized" ;
            graphdb:storage-folder "REPO_ID_PLACEHOLDER" ;
            graphdb:enable-context-index "true" ;
            graphdb:enablePredicateList "true" ;
            graphdb:in-memory-literal-properties "true" ;
            graphdb:enable-literal-index "true" ;
            graphdb:check-for-inconsistencies "false" ;
            graphdb:disable-sameAs "false" ;
            graphdb:query-timeout "0" ;
            graphdb:query-limit-results "0" ;
            graphdb:throw-QueryEvaluationException-on-timeout "false" ;
            graphdb:read-only "false" ;
        ]
    ].
EOCONFIG
    
    # Replace placeholder with actual repo ID
    sed -i.bak "s/REPO_ID_PLACEHOLDER/$REPO_ID/g" /tmp/repo-config.ttl
    
    local response=$(curl -s -w "\n%{http_code}" -X POST \
        -F "config=@/tmp/repo-config.ttl" \
        "$GRAPHDB_URL/rest/repositories")
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    # Cleanup temp file
    rm -f /tmp/repo-config.ttl /tmp/repo-config.ttl.bak
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Repository created successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to create repository (HTTP $http_code)${NC}"
        if [ -n "$body" ]; then
            echo -e "${RED}Response: $body${NC}"
        fi
        return 1
    fi
}

# Function to load RDF file
load_rdf_file() {
    local file=$1
    local filename=$(basename "$file")
    local context=""
    
    echo -e "${YELLOW}📥 Loading $filename...${NC}"
    
    # Determine content type
    local content_type="text/turtle"
    if [[ $filename == *.trig ]]; then
        content_type="application/x-trig"
    fi
    
    # Upload file
    local response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: $content_type" \
        --data-binary "@$file" \
        "$GRAPHDB_URL/repositories/$REPO_ID/statements")
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "204" ] || [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Loaded $filename${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to load $filename (HTTP $http_code)${NC}"
        if [ -n "$body" ]; then
            echo -e "${RED}Response: $body${NC}"
        fi
        return 1
    fi
}

# Function to verify data
verify_data() {
    echo -e "${YELLOW}🔍 Verifying data...${NC}"
    
    local query="PREFIX : <http://example.org/adr#>
SELECT (COUNT(*) as ?count) WHERE { ?s a :ADR }"
    
    local result=$(curl -s -X POST \
        -H "Accept: application/sparql-results+json" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        --data-urlencode "query=$query" \
        "$GRAPHDB_URL/repositories/$REPO_ID")
    
    # Extract count value from JSON using grep and sed
    local count=$(echo "$result" | grep -o '"value" : "[0-9]*"' | head -1 | sed 's/[^0-9]//g')
    
    if [ -z "$count" ]; then
        echo -e "${RED}✗ Data verification failed (could not parse response)${NC}"
        echo -e "${YELLOW}Response: $result${NC}"
        return 1
    elif [ "$count" = "8" ]; then
        echo -e "${GREEN}✓ Data verification passed (8 ADRs found)${NC}"
        return 0
    else
        echo -e "${RED}✗ Data verification failed (expected 8 ADRs, found $count)${NC}"
        return 1
    fi
}

# Main setup flow
main() {
    echo -e "${BLUE}Step 1/4: Starting GraphDB...${NC}"
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}✗ Docker is not running. Please start Docker Desktop.${NC}"
        exit 1
    fi
    
    # Start GraphDB container
    cd "$PROJECT_ROOT/infra"
    if docker compose ps | grep -q "sparql-playground.*Up"; then
        echo -e "${GREEN}✓ GraphDB is already running${NC}"
    else
        echo -e "${YELLOW}Starting GraphDB container...${NC}"
        docker compose up -d
        if [ $? -ne 0 ]; then
            echo -e "${RED}✗ Failed to start GraphDB${NC}"
            exit 1
        fi
    fi
    
    # Wait for GraphDB
    if ! check_graphdb_ready; then
        exit 1
    fi
    
    echo ""
    echo -e "${BLUE}Step 2/4: Setting up repository...${NC}"
    
    # Check if repository exists
    if repository_exists; then
        echo -e "${YELLOW}⚠ Repository '$REPO_ID' already exists${NC}"
        
        # Check if running in interactive mode
        if [ -t 0 ]; then
            read -p "Delete and recreate? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}Deleting existing repository...${NC}"
                curl -s -X DELETE "$GRAPHDB_URL/rest/repositories/$REPO_ID" > /dev/null
                create_repository
            else
                echo -e "${YELLOW}Using existing repository${NC}"
            fi
        else
            echo -e "${YELLOW}Using existing repository (non-interactive mode)${NC}"
        fi
    else
        create_repository
    fi
    
    echo ""
    echo -e "${BLUE}Step 3/4: Loading data...${NC}"
    
    # Load RDF files
    cd "$PROJECT_ROOT"
    load_rdf_file "data/prefixes.ttl"
    load_rdf_file "data/adr-core.ttl"
    load_rdf_file "data/adr-ontology.ttl"
    load_rdf_file "data/technology-dependencies.ttl"
    load_rdf_file "data/adr-provenance.trig"
    load_rdf_file "data/adr-people-reified.trig"
    
    echo ""
    echo -e "${BLUE}Step 4/4: Verifying installation...${NC}"
    
    verify_data
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       Setup Complete! 🎉               ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}GraphDB UI:${NC}      $GRAPHDB_URL"
    echo -e "${BLUE}SPARQL Endpoint:${NC} $GRAPHDB_URL/repositories/$REPO_ID"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Open $GRAPHDB_URL in your browser"
    echo -e "  2. Go to the SPARQL tab"
    echo -e "  3. Try example queries from examples/ directory"
    echo ""
    echo -e "${BLUE}Quick commands:${NC}"
    echo -e "  ${GREEN}./scripts/health-check.sh${NC}  - Verify data loaded correctly"
    echo -e "  ${GREEN}./scripts/stop.sh${NC}          - Stop GraphDB"
    echo -e "  ${GREEN}./scripts/reset.sh${NC}         - Reset and reload data"
    echo ""
}

# Run main function
main

