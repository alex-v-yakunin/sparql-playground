# 📚 SPARQL Examples Catalog

**32 ready-to-use queries, organized by category**

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

To check all 32 examples automatically:

```bash
./scripts/test-queries.sh
```

The script will execute each query and show test results.

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

**What you learn**: Basic SELECT, triple patterns, OPTIONAL, ORDER BY, COUNT

---

### 02-filtering/ — Data Filtering

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **High confidence** | ADRs with confidence > 0.9 | `high-confidence-adrs.sparql` |
| 2 | **Low confidence** | ADRs with confidence < 0.7 | `low-confidence-adrs.sparql` |
| 3 | **Deprecated ADRs** | Outdated decisions | `deprecated-adrs.sparql` |
| 4 | **ADRs for technology** | Decisions for specific technology | `adrs-for-technology.sparql` |

**What you learn**: FILTER, comparison operators, property filtering

---

### 03-graphs/ — Named Graphs and Provenance

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **ADRs by source** | Grouping by named graph | `adrs-by-source.sparql` |
| 2 | **Multi-source** | ADRs from multiple sources | `multi-source-adrs.sparql` |
| 3 | **Official registry only** | Data from adr-registry | `official-registry-only.sparql` |
| 4 | **Source reliability** | Data quality analysis | `source-reliability.sparql` |

**What you learn**: Named graphs, GRAPH keyword, data provenance

---

### 04-analysis/ — Analysis and Data Quality

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **Incomplete ADRs** | Decisions without important attributes | `incomplete-adrs.sparql` |
| 2 | **Migration paths** | Technology replacement chains | `migration-paths.sparql` |
| 3 | **Risky decisions** | ADRs with low confidence | `risky-decisions.sparql` |
| 4 | **Technology adoption** | Usage statistics | `technology-adoption.sparql` |

**What you learn**: Complex filtering, FILTER NOT EXISTS, quality analysis

---

## 🔥 Advanced Level — Unique SPARQL Capabilities

### 05-property-paths/ — Graph Navigation

**💡 This is impossible in SQL without recursive CTEs!**

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

**Start with**: `transitive-dependencies.sparql` — the most impressive example! 🚀

---

### 06-reification/ — Metadata about Facts

**💡 In SQL you need separate metadata tables with FK!**

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **🔥 Who decided** | WHO, WHEN, with what confidence | `who-decided.sparql` |
| 2 | **🔥 Decision history** | What was rejected and why | `decision-history.sparql` |
| 3 | **Voting results** | Voting statistics | `voting-results.sparql` |
| 4 | **Evidence trail** | Evidence trail for compliance | `evidence-trail.sparql` |

**Reification allows**:
- Store metadata ABOUT FACTS
- Audit trail for compliance
- Track decision evolution
- Decision-making context

**Start with**: `who-decided.sparql` — shows the power of reification!

---

### 07-reasoning/ — RDFS/OWL Automatic Inference

**💡 In SQL you need triggers and stored procedures!**

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **🔥 Subproperty inference** | usesMicroservices → requiresInfrastructure | `subproperty-inference.sparql` |
| 2 | **🔥 Class hierarchy** | Automatic type inference | `class-hierarchy.sparql` |

**Reasoning allows**:
- Define rules once
- Automatically infer new facts
- Simplify queries
- Avoid data duplication

**Rules file**: `data/adr-ontology.ttl`

---

### 08-construct/ — Generating New Graphs

**💡 In SQL: only CREATE VIEW, not structure transformation!**

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **🔥 Simplified view** | System → uses → Technology | `simplified-view.sparql` |
| 2 | **🔥 Technology graph** | For visualization in Gephi | `technology-graph.sparql` |

**CONSTRUCT allows**:
- Create new RDF graphs
- Transform structure
- Export to other formats
- Create views for visualization

**Start with**: `simplified-view.sparql` — you'll see a new graph!

---

### 09-advanced/ — Advanced Techniques

**💡 Combination of powerful SPARQL capabilities**

| # | Query | Description | File |
|---|-------|-------------|------|
| 1 | **🔥 Federated queries** | Integration with DBpedia | `federation.sparql` |
| 2 | **Complex patterns** | BIND, VALUES, MINUS, EXISTS | `complex-patterns.sparql` |

**Federated queries**:
- Query external SPARQL endpoints
- Without ETL and data import
- Real-time integration

---

## 🎯 Recommended Tracks

### 🚀 Quick Start (30 minutes)
For quick understanding of SPARQL uniqueness:

1. `05-property-paths/transitive-dependencies.sparql` ⚡
2. `06-reification/who-decided.sparql` 🎯
3. `08-construct/simplified-view.sparql` 🌟
4. `09-advanced/federation.sparql` 🔥

### 📖 Sequential Study (4 hours)
Start with 01-basics and move in order through all categories.

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
- **[QUICKSTART.md](QUICKSTART.md)** — step-by-step guide (30 minutes)
- **[SPARQL-CHEATSHEET.md](SPARQL-CHEATSHEET.md)** — syntax reference

---

## 🎓 Next Steps

After working with examples:

1. **Study [DATASET.md](DATASET.md)** — detailed data description
2. **Create your own queries** — experiment with the dataset!
3. **Share knowledge** — use examples to train your team

---

**Start with category 05-property-paths/** — it shows the real power of SPARQL! 🔥
