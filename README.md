# 🔥 SPARQL Playground: Unique RDF Capabilities

> **Interactive playground for exploring how RDF fundamentally differs from relational and graph databases**

---

## ⚡ Quick Start

### 🤖 Option A: Automated (recommended)

**One script does everything:**

```bash
./start.sh
```

The script automatically:
- ✅ Starts GraphDB in Docker
- ✅ Creates repository `sparql-playground`
- ✅ Loads all 6 RDF files
- ✅ Verifies data loaded correctly

**Ready in 30 seconds!** 🎉

Now open http://localhost:7200 → select SPARQL → start experimenting!

---

### 👐 Option B: Manual load via GraphDB Workbench

**For those who want full control:**

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

**Now you're ready!** Open any example from `examples/` and execute in SPARQL editor.

---

## 🎯 What is this?

This is an **interactive playground** for exploring **unique RDF/SPARQL capabilities** that are impossible or very difficult to implement in SQL.

### Dataset

**Synthetic ADR (Architecture Decision Records)** — architectural decisions of a tech company:
- 8 ADRs (decisions)
- 7 technologies with dependencies (Kafka, PostgreSQL, MongoDB, Redis, Kubernetes, Docker, etcd)
- 5 architects with metadata
- 7 named graphs (data sources and metadata)
- Reified statements (metadata about decisions)
- Ontology (RDFS/OWL for reasoning)

📖 **[Detailed dataset description →](DATASET.md)**

---

## 📁 Structure

```
sparql-playground/
├── start.sh                    # 🚀 Start (one click!)
├── EXAMPLES.md                 # 📚 Examples catalog
├── QUICKSTART.md               # 📖 Step-by-step guide (30 minutes)
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
│   └── adr-people-reified.trig # 🔥 Reification (metadata about facts)
│
├── examples/                    # SPARQL queries
│   ├── 01-basics/              # Basic SELECT (5 examples)
│   ├── 02-filtering/           # Filtering (4 examples)
│   ├── 03-graphs/              # Named graphs (4 examples)
│   ├── 04-analysis/            # Aggregation and analysis (4 examples)
│   │
│   ├── 05-property-paths/      # 🔥 Transitive queries (5 examples)
│   ├── 06-reification/         # 🔥 Metadata about facts (4 examples)
│   ├── 07-reasoning/           # 🔥 RDFS/OWL inference (2 examples)
│   ├── 08-construct/           # 🔥 Graph generation (2 examples)
│   └── 09-advanced/            # 🔥 Advanced techniques (2 examples)
│
└── scripts/
    ├── setup.sh                # Create repository and load data
    ├── health-check.sh         # Check GraphDB health
    ├── test-queries.sh         # 🧪 Test all 32 SPARQL queries
    ├── stop.sh                 # Stop GraphDB
    └── reset.sh                # Full reset
```

---

## 🔥 What makes SPARQL unique?

### 1. **Property Paths** — Graph navigation in one line
In SQL you need recursive CTE with 20+ lines. In SPARQL: `:Kubernetes :dependsOn+ ?dep` 🚀

**Example**: `examples/05-property-paths/transitive-dependencies.sparql`

### 2. **Reification** — Metadata about facts
In SQL you need a separate table with foreign keys. In RDF it's a natural concept — metadata ABOUT TRIPLES.

**Example**: `examples/06-reification/who-decided.sparql` — who made the decision, when and with what confidence

### 3. **Reasoning** — Automatic inference of new facts
In SQL you need triggers and stored procedures. In RDF you define a rule once: `:usesMicroservices rdfs:subPropertyOf :requiresOrchestration` — and all queries automatically account for the hierarchy!

**File**: `data/adr-ontology.ttl`

---

## 📊 Comparison with SQL

| Capability | SQL | SPARQL | Advantage |
|------------|-----|--------|-----------|
| **Transitive queries** | Recursive CTE (20+ lines) | `:dependsOn+` (1 line) | **20x shorter** |
| **Metadata about facts** | Separate table + FK | Reification (natural) | **Native support** |
| **Multiple types** | Junction tables | `a :Type1, :Type2` | **No JOINs** |
| **Automatic inference** | Triggers/procedures | RDFS/OWL reasoning | **Declarative** |
| **Graph generation** | CREATE VIEW (limited) | CONSTRUCT | **New structure** |

---

## 📖 Where to start?

### Option 1: Quick Start (5 minutes)
```bash
./start.sh
# Open examples/05-property-paths/transitive-dependencies.sparql
```

### Option 2: Full guide (30 minutes)
```bash
./start.sh
# Read QUICKSTART.md, execute examples
```

### Option 3: Examples catalog
```bash
./start.sh
# Open EXAMPLES.md — catalog of all 32 examples
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

# Test all 32 SPARQL queries
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

The script executes **32 SPARQL queries** and checks their correctness:
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
| [DATASET.md](DATASET.md) | Detailed dataset description | 10 min |
| [EXAMPLES.md](EXAMPLES.md) | Examples catalog (32 queries) | 5 min |
| [QUICKSTART.md](QUICKSTART.md) | Step-by-step guide for beginners | 30 min |
| [SPARQL-CHEATSHEET.md](SPARQL-CHEATSHEET.md) | Syntax cheat sheet | 5 min |

---

## 🎯 Who is this playground for?

- **Enterprise Architects** — architectural knowledge management
- **Data Architects** — evaluating graph technologies
- **CTOs** — strategic knowledge management decisions
- **Tech Leads** — alternatives to relational databases
- **Developers** — who want to understand RDF uniqueness

---

## 🏆 What will you learn?

After working with the playground you'll understand:

✅ **Property paths** — graph navigation without recursion  
✅ **Reification** — metadata about facts (audit trail)  
✅ **Reasoning** — automatic inference of new facts  
✅ **Multi-typing** — natural polymorphism  
✅ **CONSTRUCT** — generating new graphs  
✅ **Schema evolution** — without migrations  
✅ **Named graphs** — built-in provenance  
✅ **Open World Assumption** — difference from closed world SQL  

---

## 📈 Result

**Understanding fundamental differences between RDF and SQL and other graph databases.**

This is not just "another database" — it's a **knowledge graph** with machine-readable semantics, reasoning, and integration with external sources.

---

## 🙏 Technologies

- **GraphDB Free** — semantic graph database by Ontotext
- **SPARQL 1.1** — W3C standard for RDF queries
- **RDFS/OWL** — ontologies and reasoning
- **Docker** — containerization

---

---

**Start right now** → `./start.sh` 🚀
