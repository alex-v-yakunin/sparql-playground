# 📚 SPARQL Examples Catalog

**Production-ready queries organized by category**

---

## 🚀 How to Use

1. Start playground: `./start.sh`
2. Open GraphDB: http://localhost:7200
3. Select repository: **sparql-playground**
4. Go to **SPARQL** tab
5. Choose an example below
6. Open the file, copy the query
7. Paste into SPARQL editor
8. Click **Execute** (Ctrl+Enter)
9. Study the result and comments

### 🧪 Automated Testing

To check all examples automatically:

```bash
./scripts/test-queries.sh
```

Executes all queries and reports test results.

---

## 📚 Basic Level

### 01-basics/ — SELECT Basics

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **Hello World** | First 10 triples from database | `hello-world.sparql` |
| 2 | **List all ADRs** | All decisions with labels | `list-all-adrs.sparql` |
| 3 | **List technologies** | Catalog of all technologies | `list-technologies.sparql` |
| 4 | **Systems and owners** | Systems with their teams | `systems-and-owners.sparql` |
| 5 | **Count by status** | ADR aggregation by status | `count-by-status.sparql` |

**Key concepts**: Basic SELECT, triple patterns, OPTIONAL, ORDER BY, COUNT

---

### 02-filtering/ — Data Filtering

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **High confidence** | ADRs with confidence > 0.9 | `high-confidence-adrs.sparql` |
| 2 | **Low confidence** | ADRs with confidence < 0.7 | `low-confidence-adrs.sparql` |
| 3 | **Deprecated ADRs** | Outdated decisions | `deprecated-adrs.sparql` |
| 4 | **ADRs for technology** | Decisions for specific technology | `adrs-for-technology.sparql` |

**Key concepts**: FILTER, comparison operators, property filtering

---

### 03-graphs/ — Named Graphs and Provenance

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **ADRs by source** | Grouping by named graph | `adrs-by-source.sparql` |
| 2 | **Multi-source** | ADRs from multiple sources | `multi-source-adrs.sparql` |
| 3 | **Official registry only** | Data from adr-registry | `official-registry-only.sparql` |
| 4 | **Source reliability** | Data quality analysis | `source-reliability.sparql` |

**Key concepts**: Named graphs, GRAPH keyword, data provenance

---

### 04-analysis/ — Analysis and Data Quality

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **Incomplete ADRs** | Decisions without important attributes | `incomplete-adrs.sparql` |
| 2 | **Migration paths** | Technology replacement chains | `migration-paths.sparql` |
| 3 | **Risky decisions** | ADRs with low confidence | `risky-decisions.sparql` |
| 4 | **Technology adoption** | Usage statistics | `technology-adoption.sparql` |

**Key concepts**: Complex filtering, FILTER NOT EXISTS, quality analysis

---

## 🔥 Advanced Level — Unique SPARQL Capabilities

### 05-property-paths/ — Graph Navigation

**💡 SQL requires recursive CTEs for equivalent functionality**

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **🔥 Transitive dependencies** | ALL dependencies of Kubernetes | `transitive-dependencies.sparql` |
| 2 | **🔥 Reverse dependencies** | What depends on Linux? | `reverse-dependencies.sparql` |
| 3 | **Dependency graph** | Dependency map up to 3 levels | `dependency-graph.sparql` |
| 4 | **Circular check** | Circular dependencies | `circular-check.sparql` |
| 5 | **Alternative paths** | Different relationship types | `alternative-paths.sparql` |

**Property path operators**:
- `+` — one or more steps (transitivity)
- `*` — zero or more steps
- `/` — sequence of steps (chain)
- `|` — alternative paths
- `^` — reverse direction

**Note**: Syntax `{n,m}` not supported in GraphDB. Use explicit chains via `/` or `UNION`.

**Recommended starting point**: `transitive-dependencies.sparql`

---

### 06-reification/ — Metadata about Facts

**💡 SQL requires separate metadata tables with foreign keys**

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **🔥 Who decided** | WHO, WHEN, with what confidence | `who-decided.sparql` |
| 2 | **🔥 Decision history** | What was rejected and why | `decision-history.sparql` |
| 3 | **Voting results** | Voting statistics | `voting-results.sparql` |
| 4 | **Evidence trail** | Evidence trail for compliance | `evidence-trail.sparql` |

**Reification enables**:
- Metadata about triples
- Audit trails for compliance
- Decision evolution tracking
- Decision-making context

**Recommended starting point**: `who-decided.sparql`

---

### 07-reasoning/ — RDFS/OWL Automatic Inference

**💡 SQL requires triggers and stored procedures**

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **🔥 Subproperty inference** | usesMicroservices → requiresInfrastructure | `subproperty-inference.sparql` |
| 2 | **🔥 Class hierarchy** | Automatic type inference | `class-hierarchy.sparql` |

**Reasoning enables**:
- One-time rule definitions
- Automatic fact inference
- Simplified queries
- Reduced data duplication

**Rules file**: `data/adr-ontology.ttl`

---

### 08-construct/ — Generating New Graphs

**💡 SQL CREATE VIEW provides limited structural transformation**

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **🔥 Simplified view** | System → uses → Technology | `simplified-view.sparql` |
| 2 | **🔥 Technology graph** | For visualization in Gephi | `technology-graph.sparql` |

**CONSTRUCT enables**:
- New RDF graph creation
- Structural transformation
- Multi-format export
- Visualization-ready views

**Recommended starting point**: `simplified-view.sparql`

---

### 09-advanced/ — Advanced Techniques

**💡 Advanced SPARQL techniques combined**

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **🔥 Federated queries** | Integration with DBpedia | `federation.sparql` |
| 2 | **Complex patterns** | BIND, VALUES, MINUS, EXISTS | `complex-patterns.sparql` |

**Federated queries**:
- Query external SPARQL endpoints
- Without ETL and data import
- Real-time integration

---

### 10-rdf-star/ — RDF-star (Quoted Triples)

**💡 Compact metadata without rdf:Statement**

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **🔥 Who decided (RDF-star)** | WHO, WHEN, with what confidence | `who-decided-rdf-star.sparql` |
| 2 | **Missing evidence** | Decisions without evidenceSource | `missing-evidence-rdf-star.sparql` |
| 3 | **Projection from reification** | RDF-star view built from reified statements | `rdf-star-projection-from-reification.sparql` |

**RDF-star enables**:
- Concise metadata about triples
- Fewer joins and boilerplate
- Quoted triples in SPARQL*

**Recommended starting point**: `who-decided-rdf-star.sparql`

---

## 🎯 Recommended Tracks

### 🚀 Quick Start
Essential queries demonstrating SPARQL's distinctive features:

1. `05-property-paths/transitive-dependencies.sparql` ⚡
2. `06-reification/who-decided.sparql` 🎯
3. `10-rdf-star/who-decided-rdf-star.sparql` ✨
4. `08-construct/simplified-view.sparql` 🌟
5. `09-advanced/federation.sparql` 🔥

### 📖 Comprehensive Study
Progress sequentially from 01-basics through all categories.

### 🎨 Visualization and Dependency Analysis
1. `05-property-paths/dependency-graph.sparql` — Dependency graph
2. `05-property-paths/transitive-dependencies.sparql` — Transitive connections
3. `08-construct/technology-graph.sparql` — Export for visualization

### 🏢 Enterprise Architecture and Governance
1. `06-reification/evidence-trail.sparql` — Audit trail
2. `06-reification/who-decided.sparql` — Decision makers
3. `04-analysis/risky-decisions.sparql` — Risk analysis

---

## 💡 Tips

### Working with Examples
- **Read comments** — they explain the logic
- **Compare with SQL** — see the difference
- **Modify queries** — experiment
- **Look at results** — understand what happens

### Keyboard shortcuts in GraphDB
- `Ctrl+Enter` — execute query
- `Ctrl+/` — comment line
- `Ctrl+Space` — autocomplete

### Result Visualization
GraphDB offers several modes:
- **Table** — tabular view
- **Raw Response** — RDF format
- **Pivot Table** — pivot table (for aggregations)
- **Google Charts** — charts (for COUNT/AVG)

---

## 📚 Other Documents

- **[README.md](README.md)** — project overview and quick start
- **[DATASET.md](DATASET.md)** — dataset description
- **[QUICKSTART.md](QUICKSTART.md)** — step-by-step guide
- **[SPARQL-CHEATSHEET.md](SPARQL-CHEATSHEET.md)** — syntax reference

---

## 🎓 Next Steps

After working with examples:

1. **Study [DATASET.md](DATASET.md)** — detailed data description
2. **Create your own queries** — experiment with the dataset
3. **Share knowledge** — use examples to train your team

---

**Start with category 05-property-paths/** — it shows the real power of SPARQL! 🔥
