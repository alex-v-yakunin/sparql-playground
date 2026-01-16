# 🚀 Quick Start Guide

**Get hands-on with SPARQL Playground**

---

## Step 1: Launch

### 🤖 Option A: Automated Setup (recommended)

```bash
# Navigate to project directory
cd /path/to/sparql-playground

# Start playground
./start.sh
```

Output:
```
🚀 Starting SPARQL Playground...
✓ GraphDB is running
✓ Repository created
✓ Data loaded
🎉 Playground ready at http://localhost:7200
```

Setup complete. Proceed to **Step 2**.

---

### 👐 Option B: Manual Setup via GraphDB Workbench

<details>
<summary>📖 Manual repository configuration (click to expand)</summary>

#### 1.1 Start Docker container

```bash
cd /path/to/sparql-playground/infra
docker compose up -d
```

Wait for GraphDB to start (30-60 seconds).

#### 1.2 Create Repository in GraphDB Workbench

1. Open GraphDB Workbench: http://localhost:7200
2. Left menu: **Setup** → **Repositories** → **Create new repository**
3. Fill in:
   - Repository ID: `sparql-playground`
   - Repository title: `SPARQL Playground`
   - Ruleset: `RDFS-Plus (Optimized)`
4. Click **Create**

#### 1.3 Load dataset via GraphDB Workbench

1. Select `sparql-playground` in dropdown (top right)
2. Left menu: **Import** → **RDF** → **Upload RDF files**
3. Upload files from `data/` folder **strictly in order**:

```
1. prefixes.ttl
2. adr-core.ttl
3. adr-ontology.ttl
4. technology-dependencies.ttl
5. adr-provenance.trig
6. adr-people-reified.trig
7. adr-people-rdfstar.trig
```

For each file click **Import** and wait for "Imported successfully".

#### 1.4 Verify

Execute on **SPARQL** tab:

```sparql
PREFIX : <http://example.org/adr#>
SELECT (COUNT(*) as ?count) WHERE { ?s a :ADR }
```

Should return: `count = 8` ✅

</details>

---

## Step 2: Open GraphDB

1. Open browser: **http://localhost:7200**
2. Select **SPARQL** in left menu
3. Select repository in dropdown: **sparql-playground**

The SPARQL editor displays three panels:
- **Left** — query
- **Right** — result
- **Bottom** — saved queries

---

## Step 3: Hello World

Copy and execute the first query:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?label
WHERE {
    ?adr a :ADR ;
         rdfs:label ?label .
}
ORDER BY ?adr
```

**Click Execute** (or Ctrl+Enter)

✅ Result: 8 architectural decisions

**Query breakdown:**
- `?adr a :ADR` — find all resources of type ADR
- `rdfs:label ?label` — get their labels
- `ORDER BY ?adr` — sort

---

## Step 4: First Filter

Find decisions with high confidence (> 0.9):

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adrLabel ?confidence
WHERE {
    ?adr a :ADR ;
         rdfs:label ?adrLabel ;
         :hasConfidence ?confidence .
    
    FILTER(?confidence > 0.9)
}
ORDER BY DESC(?confidence)
```

✅ Result: 3-4 ADRs with confidence > 0.9

**New concepts:**
- `FILTER(?confidence > 0.9)` — filtering condition
- `DESC(?confidence)` — sort descending

---

## Step 5: Aggregation

Count ADRs by status:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?statusLabel (COUNT(?adr) AS ?count)
WHERE {
    ?adr a :ADR ;
         :hasStatus ?status .
    ?status rdfs:label ?statusLabel .
}
GROUP BY ?statusLabel
ORDER BY DESC(?count)
```

✅ Result: Statistics by status (Accepted, Deprecated, etc.)

**New concepts:**
- `COUNT(?adr)` — counting
- `GROUP BY` — grouping
- `AS ?count` — variable renaming

---

## 🔥 Step 6: SPARQL Uniqueness — Property Paths

**Demonstrating capabilities that require recursive CTEs in SQL:**

Find ALL transitive dependencies of Kubernetes:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?dependency ?depLabel
WHERE {
    # Operator + means "one or more steps"
    # Automatically finds transitive dependencies
    :Kubernetes :dependsOn+ ?dependency .
    
    OPTIONAL { ?dependency rdfs:label ?depLabel }
}
ORDER BY ?depLabel
```

✅ Result: Docker, Linux, etcd, Go, Kernel, ContainerRuntime...

**🔥 SQL equivalent requires recursive CTEs (20+ lines):**

```sql
-- SQL equivalent (complex!)
WITH RECURSIVE deps AS (
  SELECT tech_id, depends_on_id, 1 as level
  FROM dependencies WHERE tech_id = 'kubernetes'
  UNION ALL
  SELECT d.tech_id, d.depends_on_id, deps.level + 1
  FROM dependencies d JOIN deps ON deps.depends_on_id = d.tech_id
  WHERE deps.level < 10
)
SELECT * FROM deps;
```

**SPARQL achieves this in one line using the `+` operator** 🚀

---

## 🔥 Step 7: Reification — Metadata about Facts

**Unique RDF capability: metadata about triples**

Find out WHO made the decision, WHEN and WITH WHAT CONFIDENCE:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adrLabel ?techLabel ?personName ?date ?confidence
WHERE {
    # Reified statement - statement about decision
    ?stmt a rdf:Statement ;
          rdf:subject ?adr ;
          rdf:predicate :decidesTechnology ;
          rdf:object ?tech ;
          # Metadata about the statement
          :statedBy ?person ;
          :statedOn ?date ;
          :confidence ?confidence .
    
    ?adr rdfs:label ?adrLabel .
    ?tech rdfs:label ?techLabel .
    ?person rdfs:label ?personName .
}
ORDER BY DESC(?date)
```

✅ Result: Who, when and with what confidence made each decision

**🔥 SQL requires separate statement_metadata tables with foreign keys**

RDF provides native support for metadata about triples.

---

## 🔥 Step 8: RDF-star — Quoted Triples

**Same metadata with less boilerplate (SPARQL\*)**

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adrLabel ?techLabel ?personName ?date ?confidence
WHERE {
    GRAPH :decision-metadata-rdfstar {
        << ?adr :decidesTechnology ?tech >>
            :statedBy ?person ;
            :statedOn ?date ;
            :confidence ?confidence .
    }

    ?adr rdfs:label ?adrLabel .
    ?tech rdfs:label ?techLabel .
    ?person rdfs:label ?personName .
}
ORDER BY DESC(?date)
```

✅ Result: Same insight as reification, with shorter syntax

**Note**: Requires RDF-star / SPARQL* support (GraphDB 10.7 supports this).

---

## 🔥 Step 9: CONSTRUCT — Generating New Graph

**Create a new RDF graph from existing data**

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

CONSTRUCT {
    ?system :uses ?tech .
    ?system rdfs:label ?systemLabel .
    ?tech rdfs:label ?techLabel .
}
WHERE {
    ?adr :appliesTo ?system ;
         :decidesTechnology ?tech .
    
    ?system rdfs:label ?systemLabel .
    ?tech rdfs:label ?techLabel .
}
```

✅ Result: **New RDF graph** (not a table!)

**Switch view to "Raw Response"** to see RDF triples:
```turtle
:OrderService :uses :Kafka .
:OrderService rdfs:label "Order Processing Service" .
:Kafka rdfs:label "Apache Kafka" .
```

**🔥 SQL CREATE VIEW provides limited structural transformation**

CONSTRUCT generates entirely new graphs with arbitrary structure.

---

## 🔥 Step 10: Named Graphs — Data Provenance

**Where did the data come from? Named graphs know the answer!**

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?graph ?adr ?label
WHERE {
    # Specify which named graph to query
    GRAPH ?graph {
        ?adr a :ADR ;
             rdfs:label ?label .
    }
}
ORDER BY ?graph ?adr
```

✅ Result: ADRs with source indication (adr-registry, confluence, interview-notes)

**What's new?**
- `GRAPH ?graph { ... }` — query to named graph
- Data provenance built into RDF

---

## 📊 What you learned

| Capability | SQL Complexity | In SPARQL |
|------------|----------------|-----------|
| ✅ Basic SELECT | Simple SELECT | Triple patterns |
| ✅ Filtering | WHERE clause | FILTER |
| ✅ Aggregation | GROUP BY | GROUP BY |
| 🔥 **Transitive queries** | **Recursive CTE (20+ lines)** | **`:dependsOn+` (1 line)** |
| 🔥 **Metadata about facts** | **Separate table + FK** | **Reification (natural)** |
| 🔥 **Quoted triples** | **Separate table + FK** | **RDF-star (compact)** |
| 🔥 **Graph generation** | **CREATE VIEW (limited)** | **CONSTRUCT (new structure)** |
| 🔥 **Provenance** | **Separate tables** | **Named graphs (built-in)** |

---

## 🎯 Next Steps

### Option 1: Quick start with key examples (recommended)
Open **[EXAMPLES.md](EXAMPLES.md)** and choose examples by category:
- 05-property-paths/ — graph navigation
- 06-reification/ — metadata about facts
- 10-rdf-star/ — quoted triples
- 07-reasoning/ — automatic inference
- 08-construct/ — graph generation
- 09-advanced/ — federated queries

### Option 2: Systematic study
Open **[EXAMPLES.md](EXAMPLES.md)** and go through examples sequentially from 01-basics to 10-rdf-star.

### Option 3: Create your own queries
Use examples as templates to experiment with the dataset.

---

## 💡 Useful Tips

### Keyboard shortcuts in GraphDB
- `Ctrl+Enter` — execute query
- `Ctrl+/` — comment line
- `Ctrl+Space` — prefix autocomplete

### Result display modes
- **Table** — tabular view (default)
- **Raw Response** — RDF format (for CONSTRUCT)
- **Pivot Table** — pivot table
- **Google Charts** — charts (for COUNT/AVG)

### Query debugging
1. Start with simple pattern
2. Add conditions gradually
3. Use LIMIT 10 for large results
4. Check intermediate results

### Cheat Sheet
Open **[SPARQL-CHEATSHEET.md](SPARQL-CHEATSHEET.md)** — quick syntax reference.

---

## 🛠 Playground Management

```bash
# Stop GraphDB (data preserved)
./scripts/stop.sh

# Start again
./start.sh

# Full reset (delete all data)
./scripts/reset.sh

# Status check
./scripts/health-check.sh
```

---

## ❓ FAQ

**Q: How to check everything works correctly?**
A: Run `./scripts/health-check.sh` to check system and `./scripts/test-queries.sh` to test all SPARQL queries

**Q: Query returns no results**
A: Check that repository **sparql-playground** is selected in dropdown

**Q: GraphDB doesn't start**
A: Check Docker is running: `docker ps`

**Q: Error "repository not found"**
A: Run `./scripts/setup.sh` to create repository

**Q: Want to start from scratch**
A: Execute `./scripts/reset.sh`, then `./start.sh`

**Q: How to test all examples automatically?**
A: Run `./scripts/test-queries.sh` — script will execute all queries and show results

---

## 🎉 Completion

You completed quick start in SPARQL Playground and saw **unique capabilities** not found in SQL:

✅ Property paths for graph navigation  
✅ Reification for metadata about facts  
✅ CONSTRUCT for generating new graphs  
✅ Named graphs for provenance  

**Continue learning** → [EXAMPLES.md](EXAMPLES.md) 🚀

---

**Need help?** Read comments in examples — they provide detailed explanations.
