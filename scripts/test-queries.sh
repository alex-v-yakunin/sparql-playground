#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

GRAPHDB_URL="http://localhost:7200"
REPO_ID="sparql-playground"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

total_tests=0
passed_tests=0
failed_tests=0

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   SPARQL Query Test Suite             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Function to test a SPARQL query
test_query() {
    local query_file=$1
    local category=$(basename "$(dirname "$query_file")")
    local query_name=$(basename "$query_file" .sparql)
    
    total_tests=$((total_tests + 1))
    
    echo -ne "${CYAN}[$category]${NC} Testing: $query_name ... "
    
    # Read query from file
    local query=$(cat "$query_file")
    
    # Determine if this is a CONSTRUCT query
    local accept_header="application/sparql-results+json"
    if echo "$query" | grep -qi "^CONSTRUCT"; then
        accept_header="text/turtle"
    fi
    
    # Execute query
    local response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Accept: $accept_header" \
        -H "Content-Type: application/sparql-query" \
        --data-binary "$query" \
        "$GRAPHDB_URL/repositories/$REPO_ID")
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    # Check if query executed successfully
    if [ "$http_code" = "200" ]; then
        # Check response type
        if [ "$accept_header" = "text/turtle" ]; then
            # CONSTRUCT query - check for valid Turtle
            if echo "$body" | grep -qE '@prefix|<http'; then
                echo -e "${GREEN}✓${NC}"
                passed_tests=$((passed_tests + 1))
                
                # Count triples
                local triple_count=$(echo "$body" | grep -c '\.')
                echo -e "  ${YELLOW}→${NC} Generated RDF graph with ~$triple_count statements"
            else
                echo -e "${RED}✗${NC} (Invalid RDF response)"
                failed_tests=$((failed_tests + 1))
            fi
        else
            # SELECT query - check for valid JSON
            if echo "$body" | grep -q '"head"'; then
                echo -e "${GREEN}✓${NC}"
                passed_tests=$((passed_tests + 1))
                
                # Show result count if available
                if echo "$body" | grep -q '"bindings"'; then
                    local result_count=$(echo "$body" | grep -o '"bindings"' | wc -l)
                    if [ $result_count -gt 0 ]; then
                        local bindings=$(echo "$body" | grep -A1000 '"bindings"' | grep -o '{[^}]*}' | wc -l)
                        echo -e "  ${YELLOW}→${NC} Results: $bindings rows"
                    fi
                fi
            else
                echo -e "${RED}✗${NC} (Invalid JSON response)"
                failed_tests=$((failed_tests + 1))
            fi
        fi
    else
        echo -e "${RED}✗${NC} (HTTP $http_code)"
        failed_tests=$((failed_tests + 1))
        
        # Show error details
        if [ -n "$body" ]; then
            echo -e "  ${RED}Error:${NC} $(echo "$body" | head -1)"
        fi
    fi
}

# Find and test all SPARQL files
echo -e "${YELLOW}Searching for SPARQL queries...${NC}"
echo ""

# Test queries by category
for category_dir in "$PROJECT_ROOT/examples"/*; do
    if [ -d "$category_dir" ]; then
        category_name=$(basename "$category_dir")
        echo -e "${BLUE}═══ $category_name ═══${NC}"
        
        for query_file in "$category_dir"/*.sparql; do
            if [ -f "$query_file" ]; then
                test_query "$query_file"
            fi
        done
        echo ""
    fi
done

# Summary
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Test Summary                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
printf "Total tests:   %d\n" $total_tests
printf "${GREEN}Passed:        %d${NC}\n" $passed_tests
printf "${RED}Failed:        %d${NC}\n" $failed_tests
echo ""

if [ $failed_tests -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   All queries passed! 🎉               ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   Some queries failed!                 ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    exit 1
fi

