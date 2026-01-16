# SPARQL Playground: RDF/RDFS/OWL/SHACL Capabilities

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
- Loads all RDF files from `data/` directory
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
data/prefixes.ttl
data/adr-core.ttl
data/adr-ontology.ttl
data/adr-shapes.ttl
data/technology-dependencies.ttl
data/adr-provenance.trig
data/adr-people-reified.trig
data/adr-people-rdfstar.trig
```

5. For each file, click **Import** and wait for confirmation.

#### Step 4: Verify

Execute in **SPARQL** tab:

```sparql
PREFIX : <http://example.org/adr#>
SELECT (COUNT(*) as ?count) WHERE { ?s a :ADR }
```

Expected result: ADR count matching loaded data

</details>

---

## Overview

An interactive environment demonstrating RDF/SPARQL capabilities that are impractical or impossible to achieve in SQL.

### Dataset

**Synthetic ADR (Architecture Decision Records)** — architectural decisions of a technology organization:
- ADRs (architectural decisions)
- Technologies with dependencies (Kafka, PostgreSQL, MongoDB, Redis, Kubernetes, Docker, etcd)
- Architects with metadata
- Named graphs (data sources and provenance)
- Reified statements (metadata about decisions)
- RDF-star statements (quoted triples with metadata)
- Ontology (RDFS/OWL for reasoning)
- SHACL shapes (data validation constraints)

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
│   ├── adr-shapes.ttl          # SHACL shapes for validation
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
│   ├── 05-property-paths/      # Transitive queries (SPARQL 1.1)
│   ├── 06-reification/         # Metadata about facts
│   ├── 07-reasoning/           # RDFS/OWL inference
│   ├── 08-construct/           # Graph generation
│   ├── 09-advanced/            # Advanced techniques
│   ├── 10-rdf-star/            # RDF-star queries
│   └── 11-shacl/               # SHACL validation
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

SQL requires recursive CTEs (typically 10-15 lines). SPARQL achieves the same in a single expression: `:Kubernetes :dependsOn+ ?dep`

**Example**: `examples/05-property-paths/transitive-dependencies.sparql`

### 2. Reification — Metadata about Facts

SQL requires separate tables with foreign keys. RDF provides native support for metadata about triples.

**Example**: `examples/06-reification/who-decided.sparql`

### 3. RDF-star — Quoted Triples

Concise metadata without `rdf:Statement`, using quoted triples in SPARQL*.

**Example**: `examples/10-rdf-star/who-decided-rdf-star.sparql`

**Note**: Requires RDF-star/SPARQL* support in the triplestore.

### 4. Reasoning — Automatic Inference (RDFS/OWL)

SQL requires triggers and stored procedures. RDF uses declarative rules for automatic inference.

**Examples**: `examples/07-reasoning/` (subproperty inference, inverse properties, transitive reasoning)

**Ontology**: `data/adr-ontology.ttl`

### 5. SHACL — Data Validation

SQL uses CHECK constraints and triggers. SHACL provides declarative constraint definitions with Closed World semantics.

**Shapes**: `data/adr-shapes.ttl`

**Examples**: `examples/11-shacl/`

---

## Comparison with SQL

| Capability | SQL | SPARQL | Advantage |
|------------|-----|--------|-----------|
| Transitive queries | Recursive CTE (10-15 lines) | `:dependsOn+` (1 expression) | Significantly more concise |
| Metadata about facts | Separate table + FK | Reification | Native support |
| Quoted triples | Separate table + FK | RDF-star | Less boilerplate |
| Multiple types | Junction tables | `a :Type1, :Type2` | No JOINs required |
| Automatic inference | Triggers/procedures | RDFS/OWL reasoning | Declarative |
| Data validation | CHECK + triggers | SHACL shapes | Declarative constraints |
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

- **Property paths** — declarative graph traversal without explicit recursion
- **Reification** — first-class metadata about statements for audit trails
- **RDFS reasoning** — class/property hierarchy inference (subClassOf, subPropertyOf)
- **OWL reasoning** — advanced inference (inverseOf, TransitiveProperty, SymmetricProperty)
- **SHACL validation** — declarative data quality constraints with Closed World semantics
- **Multi-typing** — native support for multiple class membership
- **CONSTRUCT** — declarative generation of derived graph structures
- **Schema evolution** — additive schema changes without migrations
- **Named graphs** — native provenance and context management
- **Open World Assumption** — fundamental semantic distinction from Closed World (SQL)

---

## Key Takeaway

RDF represents a distinct data modeling paradigm: a knowledge graph with formal semantics, automated reasoning capabilities, and native support for data integration across heterogeneous sources.

---

## Technologies and Standards

- **GraphDB Free** — semantic graph database by Ontotext
- **SPARQL 1.1** — W3C Recommendation for RDF query language ([W3C SPARQL 1.1](https://www.w3.org/TR/sparql11-query/))
- **RDF 1.1** — W3C Recommendation for graph data model ([W3C RDF 1.1](https://www.w3.org/TR/rdf11-concepts/))
- **RDFS/OWL** — W3C standards for ontology definition and reasoning ([RDFS](https://www.w3.org/TR/rdf-schema/), [OWL 2](https://www.w3.org/TR/owl2-overview/))
- **RDF-star** — W3C Community Group extension for statement-level metadata ([RDF-star](https://www.w3.org/2021/12/rdf-star.html))
- **SHACL** — W3C Recommendation for RDF validation ([SHACL](https://www.w3.org/TR/shacl/))
- **Docker** — container runtime environment

---

**Get started**: `./start.sh`
