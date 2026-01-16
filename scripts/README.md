# Automation Scripts

Set of bash scripts for managing SPARQL Playground.

---

## 📋 Script List

### 🚀 setup.sh

**Purpose**: Complete GraphDB setup and data loading.

**Usage**:
```bash
./scripts/setup.sh
```

**What it does**:
1. Starts GraphDB container in Docker
2. Waits for GraphDB ready (up to 60 seconds)
3. Creates repository `sparql-playground`
4. Loads 7 RDF files from `data/`
5. Verifies loading correctness (8 ADRs)

**Modes**:
- Interactive: asks for confirmation if repository exists
- Non-interactive: automatically uses existing repository

**Exit codes**:
- `0` — successful setup
- `1` — error (Docker not running, GraphDB unavailable, etc.)

---

### ✅ health-check.sh

**Purpose**: Check system and data status.

**Usage**:
```bash
./scripts/health-check.sh
```

**What it checks**:
1. Docker daemon running
2. GraphDB container running
3. GraphDB HTTP endpoint accessible
4. Repository exists
5. Data loaded correctly:
   - 8 ADRs
   - 5 Systems
   - 7 Technologies
   - 5 Teams
  - 8 Named Graphs

**Exit codes**:
- `0` — all checks passed
- `1` — one or more checks failed

**Example output**:
```
Entity Type          Expected   Actual     Status    
────────────────────────────────────────────────────
ADRs                 8          8          ✓       
Systems              5          5          ✓       
Technologies         7          7          ✓       
Teams                5          5          ✓       
Named Graphs         8          8          ✓       

✓ All checks passed!
```

---

### 🧪 test-queries.sh

**Purpose**: Automated testing of all SPARQL queries.

**Usage**:
```bash
./scripts/test-queries.sh
```

**What it does**:
1. Finds all `.sparql` files in `examples/`
2. Executes each query via HTTP API
3. Checks response correctness:
   - SELECT: valid JSON with `"head"` and `"bindings"`
   - CONSTRUCT: valid RDF/Turtle
4. Counts results
5. Shows summary: passed/failed

**Supported query types**:
- SELECT — Accept: `application/sparql-results+json`
- CONSTRUCT — Accept: `text/turtle`

**Exit codes**:
- `0` — all tests passed
- `1` — one or more tests failed

**Example output**:
```
═══ 01-basics ═══
[01-basics] Testing: hello-world ... ✓
  → Results: 10 rows
[01-basics] Testing: list-all-adrs ... ✓
  → Results: 8 rows

═══ Test Summary ═══
Total tests:   N
Passed:        N
Failed:        0

✓ All queries passed! 🎉
```

**Using in CI/CD**:
```bash
#!/bin/bash
./start.sh
./scripts/health-check.sh || exit 1
./scripts/test-queries.sh || exit 1
./scripts/stop.sh
```

---

### ⏹️ stop.sh

**Purpose**: Stop GraphDB container.

**Usage**:
```bash
./scripts/stop.sh
```

**What it does**:
- Stops and removes container
- Removes Docker network
- **Preserves data** in Docker volume

**Note**: Data is not deleted! For full reset use `reset.sh`.

**Exit codes**:
- `0` — successful stop

---

### 🔄 reset.sh

**Purpose**: Full reset and data reload.

**Usage**:
```bash
./scripts/reset.sh
```

**What it does**:
1. Asks for user confirmation
2. Deletes repository `sparql-playground`
3. Runs `setup.sh` for full reload

**Warning**: Deletes ALL data! Operation is irreversible.

**Exit codes**:
- `0` — successful reset and reload
- `1` — error during reset

---

## 🔧 Configuration

All scripts use common variables:

```bash
GRAPHDB_URL="http://localhost:7200"
REPO_ID="sparql-playground"
```

To change port or repository ID, edit the respective scripts.

---

## 🚨 Troubleshooting

### Docker not running

**Error**: `Docker is not running`

**Solution**: Start Docker Desktop or docker daemon

### GraphDB unavailable

**Error**: `GraphDB is not responding`

**Solution**:
```bash
# Check container status
docker ps

# View logs
cd infra && docker compose logs

# Restart
./scripts/stop.sh
./start.sh
```

### Repository already exists

**Error**: `Repository 'sparql-playground' already exists`

**Solution**:
- In interactive mode: answer `y` to recreate
- In non-interactive: script automatically uses existing
- Or execute: `./scripts/reset.sh`

### Tests failed

**Error**: `Some queries failed!`

**Solution**:
1. Check all data loaded: `./scripts/health-check.sh`
2. View error details in `test-queries.sh` output
3. Try reloading data: `./scripts/reset.sh`

---

## 📝 Development

### Adding New Script

1. Create file in `scripts/`
2. Make executable: `chmod +x scripts/new-script.sh`
3. Use common variables and colored output
4. Add documentation to this README

### Script Structure

```bash
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
GRAPHDB_URL="http://localhost:7200"
REPO_ID="sparql-playground"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Your logic here
```

---

## 🧪 Testing Scripts

To check all scripts:

```bash
# Full cycle
./start.sh
./scripts/health-check.sh
./scripts/test-queries.sh
./scripts/stop.sh

# Check reset
./scripts/reset.sh  # Confirm 'y'
./scripts/health-check.sh
```

---

**All scripts tested and ready to use!** ✅
