# 🔥 SPARQL Playground: Unique RDF Capabilities

> **Hands-on environment demonstrating RDF's distinctive capabilities compared to relational and graph databases**

---

## ⚡ Quick Start

### 🤖 Option A: Automated (recommended)

**Single command setup:**

```bash
./start.sh
```

The script automatically:
- ✅ Starts GraphDB in Docker
- ✅ Creates repository `sparql-playground`
- ✅ Loads all 7 RDF files
- ✅ Verifies data loaded correctly

**Setup completes in ~30 seconds.** 🎉

Open http://localhost:7200 → select SPARQL → begin querying.

---

### 👐 Option B: Manual load via GraphDB Workbench

**For manual repository configuration:**

<details>
<summary>📖 Step-by-step instructions (click to expand)</summary>

#### Step 1: Start GraphDB

```bash
cd infra
docker compose up -d
```

Wait for startup: http://localhost:7200

#### Step 2: Create Repository in GraphDB Workbench

1. Open GraphDB Workbench: http://localhost:7200
2. In the left menu select **Setup** → **Repositories**
3. Click **Create new repository**
4. Fill the form:
   - **Repository ID**: `sparql-playground`
   - **Repository title**: `SPARQL Playground`
   - **Ruleset**: `RDFS-Plus (Optimized)`
5. Click **Create**

#### Step 3: Load dataset via GraphDB Workbench

1. Select repository `sparql-playground` in the dropdown (top right)
2. In the left menu select **Import** → **RDF**
3. Click **Upload RDF files**
4. Upload files from `data/` folder **in this order**:

```
1. data/prefixes.ttl
2. data/adr-core.ttl
3. data/adr-ontology.ttl
4. data/technology-dependencies.ttl
5. data/adr-provenance.trig
6. data/adr-people-reified.trig
7. data/adr-people-rdfstar.trig
```

5. For each file:
   - Click **Import**
   - Wait for "Imported successfully" message

#### Step 4: Verify loading

1. Go to **SPARQL** tab
2. Execute query:

```sparql
PREFIX : <http://example.org/adr#>
SELECT (COUNT(*) as ?count) WHERE { ?s a :ADR }
```

Should return: **count = 8** ✅

</details>

---

**Setup complete.** Execute any query from `examples/` in the SPARQL editor.

---

## 🎯 Overview

An **interactive environment** demonstrating **RDF/SPARQL capabilities** that are impractical or impossible in SQL.

### Dataset

**Synthetic ADR (Architecture Decision Records)** — architectural decisions of a tech company:
- 8 ADRs (decisions)
- 7 technologies with dependencies (Kafka, PostgreSQL, MongoDB, Redis, Kubernetes, Docker, etcd)
- 5 architects with metadata
- 8 named graphs (data sources and metadata)
- Reified statements (metadata about decisions)
- RDF-star statements (quoted triples with metadata)
- Ontology (RDFS/OWL for reasoning)

📖 **[Detailed dataset description →](DATASET.md)**

---

## 📁 Structure

```
sparql-playground/
├── start.sh                    # 🚀 Start (one click!)
├── EXAMPLES.md                 # 📚 Examples catalog
├── QUICKSTART.md               # 📖 Step-by-step guide
├── SPARQL-CHEATSHEET.md        # 📝 SPARQL cheat sheet
│
├── infra/
│   └── docker-compose.yml      # GraphDB Free in Docker
│
├── data/                        # RDF dataset
│   ├── prefixes.ttl            # Prefixes
│   ├── adr-core.ttl            # Core concepts
│   ├── adr-ontology.ttl        # 🔥 RDFS/OWL for reasoning
│   ├── technology-dependencies.ttl  # 🔥 Transitive dependencies
│   ├── adr-provenance.trig     # Named graphs (provenance)
│   ├── adr-people-reified.trig # 🔥 Reification (metadata about facts)
│   └── adr-people-rdfstar.trig # 🔥 RDF-star (quoted triples)
│
├── examples/                    # SPARQL queries
│   ├── 01-basics/              # Basic SELECT
│   ├── 02-filtering/           # Filtering
│   ├── 03-graphs/              # Named graphs
│   ├── 04-analysis/            # Aggregation and analysis
│   │
│   ├── 05-property-paths/      # 🔥 Transitive queries
│   ├── 06-reification/         # 🔥 Metadata about facts
│   ├── 07-reasoning/           # 🔥 RDFS/OWL inference
│   ├── 08-construct/           # 🔥 Graph generation
│   ├── 09-advanced/            # 🔥 Advanced techniques
│   └── 10-rdf-star/            # 🔥 RDF-star
│
└── scripts/
    ├── setup.sh                # Create repository and load data
    ├── health-check.sh         # Check GraphDB health
    ├── test-queries.sh         # 🧪 Test all SPARQL queries
    ├── stop.sh                 # Stop GraphDB
    └── reset.sh                # Full reset
```

---

## 🔥 What makes SPARQL unique?

### 1. **Property Paths** — Graph navigation in one line
SQL requires recursive CTEs (20+ lines). SPARQL: `:Kubernetes :dependsOn+ ?dep` 🚀

**Example**: `examples/05-property-paths/transitive-dependencies.sparql`

### 2. **Reification** — Metadata about facts
SQL requires separate tables with foreign keys. RDF provides native support for metadata about triples.

**Example**: `examples/06-reification/who-decided.sparql` — who made the decision, when and with what confidence

### 3. **RDF-star** — Quoted triples (metadata in one line)
Concise metadata without `rdf:Statement`, using quoted triples in SPARQL*.

**Example**: `examples/10-rdf-star/who-decided-rdf-star.sparql`

**Note**: Requires RDF-star/SPARQL* support in the triplestore.

### 4. **Reasoning** — Automatic inference of new facts
SQL requires triggers and stored procedures. RDF uses declarative rules: `:usesMicroservices rdfs:subPropertyOf :requiresOrchestration` — queries automatically inherit the hierarchy.

**File**: `data/adr-ontology.ttl`

---

## 📊 Comparison with SQL

| Capability | SQL | SPARQL | Advantage |
|------------|-----|--------|-----------|
| **Transitive queries** | Recursive CTE (20+ lines) | `:dependsOn+` (1 line) | **20x shorter** |
| **Metadata about facts** | Separate table + FK | Reification (natural) | **Native support** |
| **Quoted triples** | Separate table + FK | RDF-star (compact) | **Less boilerplate** |
| **Multiple types** | Junction tables | `a :Type1, :Type2` | **No JOINs** |
| **Automatic inference** | Triggers/procedures | RDFS/OWL reasoning | **Declarative** |
| **Graph generation** | CREATE VIEW (limited) | CONSTRUCT | **New structure** |

---

## 📖 Where to start?

### Option 1: Quick Start
```bash
./start.sh
# Open examples/05-property-paths/transitive-dependencies.sparql
```

### Option 2: Full guide
```bash
./start.sh
# Read QUICKSTART.md, execute examples
```

### Option 3: Examples catalog
```bash
./start.sh
# Open EXAMPLES.md — examples catalog
```


---

## 🛠 Requirements

- **Docker** (with docker-compose support)
- **Browser** (Chrome/Firefox for GraphDB UI)
- **8 GB RAM** (minimum 4 GB for GraphDB)

Check:
```bash
docker --version          # Docker 20.10+
docker compose version    # Compose V2 recommended
```

---

## 💡 Commands

```bash
# Start playground
./start.sh

# Check system status
./scripts/health-check.sh

# Test all 35 SPARQL queries
./scripts/test-queries.sh

# Stop GraphDB (data preserved)
./scripts/stop.sh

# Full reset (delete all data and reload)
./scripts/reset.sh
```

---

## 🧪 Testing

The project includes automatic tests for all SPARQL queries:

```bash
./scripts/test-queries.sh
```

The script executes **SPARQL queries** and checks their correctness:
- ✅ SELECT queries — check JSON response
- ✅ CONSTRUCT queries — check RDF/Turtle output
- ✅ Report on passed/failed tests
- ✅ Execution time and result count

**Example output:**
```
═══ 01-basics ═══
[01-basics] Testing: hello-world ... ✓
[01-basics] Testing: list-all-adrs ... ✓

═══ Test Summary ═══
Total tests:   32
Passed:        32
Failed:        0

✓ All queries passed! 🎉
```

---

## 📚 Documentation

| File | Description | Time |
|------|-------------|------|
| [DATASET.md](DATASET.md) | Detailed dataset description
| [EXAMPLES.md](EXAMPLES.md) | Examples catalog
| [QUICKSTART.md](QUICKSTART.md) | Step-by-step guide for beginners
| [SPARQL-CHEATSHEET.md](SPARQL-CHEATSHEET.md) | Syntax cheat sheet

---

## 🎯 Target Audience

- **Enterprise Architects** — architectural knowledge management
- **Data Architects** — evaluating graph technologies
- **CTOs** — strategic knowledge management decisions
- **Tech Leads** — exploring alternatives to relational databases
- **Developers** — understanding RDF's unique capabilities

---

## 🏆 Learning Outcomes

Working through this playground provides understanding of:

✅ **Property paths** — graph navigation without recursion  
✅ **Reification** — metadata about facts (audit trail)  
✅ **Reasoning** — automatic inference of new facts  
✅ **Multi-typing** — natural polymorphism  
✅ **CONSTRUCT** — generating new graphs  
✅ **Schema evolution** — without migrations  
✅ **Named graphs** — built-in provenance  
✅ **Open World Assumption** — difference from closed world SQL  

---

## 📈 Key Takeaway

**Grasp the fundamental differences between RDF, SQL, and other graph databases.**

RDF represents a distinct paradigm: a **knowledge graph** with machine-readable semantics, reasoning capabilities, and seamless external integration.

---

## 🙏 Technologies

- **GraphDB Free** — semantic graph database by Ontotext
- **SPARQL 1.1** — W3C standard for RDF queries
- **RDFS/OWL** — ontologies and reasoning
- **Docker** — containerization

---

---

**Get started** → `./start.sh` 🚀
