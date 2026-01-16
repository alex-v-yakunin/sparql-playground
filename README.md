# SPARQL Playground: Unique RDF Capabilities

> Hands-on environment demonstrating RDF's distinctive capabilities compared to relational and graph databases

---

## Quick Start

### Option A: Automated Setup (recommended)

Single command setup:

```bash
./start.sh
```

The script automatically:
- Starts GraphDB in Docker
- Creates repository `sparql-playground`
- Loads all 7 RDF files
- Verifies data loaded correctly

Open http://localhost:7200, select SPARQL, and begin querying.

---

### Option B: Manual Setup via GraphDB Workbench

<details>
<summary>Step-by-step instructions</summary>

#### Step 1: Start GraphDB

```bash
cd infra
docker compose up -d
```

Wait for startup: http://localhost:7200

#### Step 2: Create Repository

1. Open GraphDB Workbench: http://localhost:7200
2. Navigate to **Setup** → **Repositories**
3. Click **Create new repository**
4. Configure:
   - **Repository ID**: `sparql-playground`
   - **Repository title**: `SPARQL Playground`
   - **Ruleset**: `RDFS-Plus (Optimized)`
5. Click **Create**

#### Step 3: Load Dataset

1. Select repository `sparql-playground` in the dropdown
2. Navigate to **Import** → **RDF**
3. Click **Upload RDF files**
4. Upload files from `data/` folder in order:

```
1. data/prefixes.ttl
2. data/adr-core.ttl
3. data/adr-ontology.ttl
4. data/technology-dependencies.ttl
5. data/adr-provenance.trig
6. data/adr-people-reified.trig
7. data/adr-people-rdfstar.trig
```

5. For each file, click **Import** and wait for confirmation.

#### Step 4: Verify

Execute in **SPARQL** tab:

```sparql
PREFIX : <http://example.org/adr#>
SELECT (COUNT(*) as ?count) WHERE { ?s a :ADR }
```

Expected result: `count = 8`

</details>

---

## Overview

An interactive environment demonstrating RDF/SPARQL capabilities that are impractical or impossible to achieve in SQL.

### Dataset

**Synthetic ADR (Architecture Decision Records)** — architectural decisions of a technology organization:
- 8 ADRs (architectural decisions)
- 7 technologies with dependencies (Kafka, PostgreSQL, MongoDB, Redis, Kubernetes, Docker, etcd)
- 5 architects with metadata
- 8 named graphs (data sources and provenance)
- Reified statements (metadata about decisions)
- RDF-star statements (quoted triples with metadata)
- Ontology (RDFS/OWL for reasoning)

See [DATASET.md](DATASET.md) for detailed dataset description.

---

## Project Structure

```
sparql-playground/
├── start.sh                    # Automated startup script
├── EXAMPLES.md                 # Examples catalog
├── QUICKSTART.md               # Step-by-step guide
├── SPARQL-CHEATSHEET.md        # SPARQL syntax reference
│
├── infra/
│   └── docker-compose.yml      # GraphDB Free configuration
│
├── data/                        # RDF dataset
│   ├── prefixes.ttl            # Common prefixes
│   ├── adr-core.ttl            # Core vocabulary
│   ├── adr-ontology.ttl        # RDFS/OWL ontology for reasoning
│   ├── technology-dependencies.ttl  # Transitive dependencies
│   ├── adr-provenance.trig     # Named graphs with provenance
│   ├── adr-people-reified.trig # Reification (metadata about facts)
│   └── adr-people-rdfstar.trig # RDF-star (quoted triples)
│
├── examples/                    # SPARQL query examples
│   ├── 01-basics/              # Basic SELECT queries
│   ├── 02-filtering/           # Filtering techniques
│   ├── 03-graphs/              # Named graphs
│   ├── 04-analysis/            # Aggregation and analysis
│   ├── 05-property-paths/      # Transitive queries
│   ├── 06-reification/         # Metadata about facts
│   ├── 07-reasoning/           # RDFS/OWL inference
│   ├── 08-construct/           # Graph generation
│   ├── 09-advanced/            # Advanced techniques
│   └── 10-rdf-star/            # RDF-star queries
│
└── scripts/
    ├── setup.sh                # Repository creation and data loading
    ├── health-check.sh         # System health verification
    ├── test-queries.sh         # Automated query testing
    ├── stop.sh                 # Stop GraphDB
    └── reset.sh                # Full reset
```

---

## Unique SPARQL Capabilities

### 1. Property Paths — Graph Navigation

SQL requires recursive CTEs (20+ lines). SPARQL achieves the same with: `:Kubernetes :dependsOn+ ?dep`

**Example**: `examples/05-property-paths/transitive-dependencies.sparql`

### 2. Reification — Metadata about Facts

SQL requires separate tables with foreign keys. RDF provides native support for metadata about triples.

**Example**: `examples/06-reification/who-decided.sparql`

### 3. RDF-star — Quoted Triples

Concise metadata without `rdf:Statement`, using quoted triples in SPARQL*.

**Example**: `examples/10-rdf-star/who-decided-rdf-star.sparql`

**Note**: Requires RDF-star/SPARQL* support in the triplestore.

### 4. Reasoning — Automatic Inference

SQL requires triggers and stored procedures. RDF uses declarative rules for automatic inference.

**File**: `data/adr-ontology.ttl`

---

## Comparison with SQL

| Capability | SQL | SPARQL | Advantage |
|------------|-----|--------|-----------|
| Transitive queries | Recursive CTE (20+ lines) | `:dependsOn+` (1 line) | Significantly shorter |
| Metadata about facts | Separate table + FK | Reification | Native support |
| Quoted triples | Separate table + FK | RDF-star | Less boilerplate |
| Multiple types | Junction tables | `a :Type1, :Type2` | No JOINs required |
| Automatic inference | Triggers/procedures | RDFS/OWL reasoning | Declarative |
| Graph generation | CREATE VIEW (limited) | CONSTRUCT | Flexible structure |

---

## Getting Started

### Option 1: Quick Start
```bash
./start.sh
# Open examples/05-property-paths/transitive-dependencies.sparql
```

### Option 2: Comprehensive Guide
```bash
./start.sh
# Follow QUICKSTART.md
```

### Option 3: Examples Catalog
```bash
./start.sh
# Browse EXAMPLES.md
```

---

## Requirements

- **Docker** with docker-compose support
- **Web browser** for GraphDB UI
- **8 GB RAM** (minimum 4 GB for GraphDB)

Verify installation:
```bash
docker --version          # Docker 20.10+
docker compose version    # Compose V2 recommended
```

---

## Commands

```bash
# Start playground
./start.sh

# Check system status
./scripts/health-check.sh

# Test all SPARQL queries
./scripts/test-queries.sh

# Stop GraphDB (data preserved)
./scripts/stop.sh

# Full reset (delete all data and reload)
./scripts/reset.sh
```

---

## Testing

The project includes automated tests for all SPARQL queries:

```bash
./scripts/test-queries.sh
```

The script executes SPARQL queries and validates:
- SELECT queries: JSON response structure
- CONSTRUCT queries: RDF/Turtle output
- Pass/fail reporting with execution metrics

---

## Documentation

| File | Description |
|------|-------------|
| [DATASET.md](DATASET.md) | Detailed dataset description |
| [EXAMPLES.md](EXAMPLES.md) | Examples catalog |
| [QUICKSTART.md](QUICKSTART.md) | Step-by-step guide |
| [SPARQL-CHEATSHEET.md](SPARQL-CHEATSHEET.md) | Syntax reference |

---

## Target Audience

- **Enterprise Architects** — architectural knowledge management
- **Data Architects** — evaluating graph technologies
- **Technical Leaders** — strategic technology decisions
- **Software Engineers** — understanding RDF capabilities

---

## Learning Outcomes

This playground provides understanding of:

- **Property paths** — graph navigation without recursion
- **Reification** — metadata about facts for audit trails
- **Reasoning** — automatic inference of new facts
- **Multi-typing** — natural polymorphism in RDF
- **CONSTRUCT** — generating new graph structures
- **Schema evolution** — flexibility without migrations
- **Named graphs** — built-in provenance tracking
- **Open World Assumption** — semantic difference from SQL

---

## Key Takeaway

RDF represents a distinct paradigm: a knowledge graph with machine-readable semantics, reasoning capabilities, and seamless integration with external data sources.

---

## Technologies

- **GraphDB Free** — semantic graph database by Ontotext
- **SPARQL 1.1** — W3C standard for RDF queries
- **RDFS/OWL** — ontologies and reasoning
- **Docker** — containerization

---

**Get started**: `./start.sh`
