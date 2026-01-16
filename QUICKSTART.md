# Quick Start Guide

This guide provides a hands-on introduction to SPARQL Playground.

---

## Step 1: Launch

### Option A: Automated Setup (recommended)

```bash
cd /path/to/sparql-playground
./start.sh
```

Expected output:
```
Starting SPARQL Playground...
GraphDB is running
Repository created
Data loaded
Playground ready at http://localhost:7200
```

Proceed to Step 2.

---

### Option B: Manual Setup via GraphDB Workbench

<details>
<summary>Manual repository configuration</summary>

#### 1.1 Start Docker Container

```bash
cd /path/to/sparql-playground/infra
docker compose up -d
```

Wait for GraphDB to start (30-60 seconds).

#### 1.2 Create Repository

1. Open GraphDB Workbench: http://localhost:7200
2. Navigate to **Setup** → **Repositories** → **Create new repository**
3. Configure:
   - Repository ID: `sparql-playground`
   - Repository title: `SPARQL Playground`
   - Ruleset: `RDFS-Plus (Optimized)`
4. Click **Create**

#### 1.3 Load Dataset

1. Select `sparql-playground` in dropdown
2. Navigate to **Import** → **RDF** → **Upload RDF files**
3. Upload files from `data/` folder in order:

```
1. prefixes.ttl
2. adr-core.ttl
3. adr-ontology.ttl
4. technology-dependencies.ttl
5. adr-provenance.trig
6. adr-people-reified.trig
7. adr-people-rdfstar.trig
```

For each file, click **Import** and wait for confirmation.

#### 1.4 Verify

Execute in **SPARQL** tab:

```sparql
PREFIX : <http://example.org/adr#>
SELECT (COUNT(*) as ?count) WHERE { ?s a :ADR }
```

Expected result: `count = 8`

</details>

---

## Step 2: Open GraphDB

1. Open browser: http://localhost:7200
2. Select **SPARQL** in left menu
3. Select repository: **sparql-playground**

The SPARQL editor displays three panels:
- **Left**: Query editor
- **Right**: Results
- **Bottom**: Saved queries

---

## Step 3: Hello World

Execute the following query:

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

Press **Ctrl+Enter** to execute.

Expected result: 8 architectural decisions

**Query breakdown:**
- `?adr a :ADR` — find all resources of type ADR
- `rdfs:label ?label` — retrieve their labels
- `ORDER BY ?adr` — sort results

---

## Step 4: Filtering

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

Expected result: 3-4 ADRs with confidence > 0.9

**Key concepts:**
- `FILTER(?confidence > 0.9)` — filtering condition
- `DESC(?confidence)` — descending sort

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

Expected result: Statistics by status (Accepted, Deprecated, etc.)

**Key concepts:**
- `COUNT(?adr)` — aggregation function
- `GROUP BY` — grouping clause
- `AS ?count` — variable aliasing

---

## Step 6: Property Paths

**This capability requires recursive CTEs in SQL.**

Find all transitive dependencies of Kubernetes:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?dependency ?depLabel
WHERE {
    # Operator + means "one or more steps"
    :Kubernetes :dependsOn+ ?dependency .
    
    OPTIONAL { ?dependency rdfs:label ?depLabel }
}
ORDER BY ?depLabel
```

Expected result: Docker, Linux, etcd, Go, Kernel, ContainerRuntime...

**SQL equivalent requires recursive CTEs (20+ lines):**

```sql
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

SPARQL achieves this in one line using the `+` operator.

---

## Step 7: Reification — Metadata about Facts

Find out who made each decision, when, and with what confidence:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adrLabel ?techLabel ?personName ?date ?confidence
WHERE {
    ?stmt a rdf:Statement ;
          rdf:subject ?adr ;
          rdf:predicate :decidesTechnology ;
          rdf:object ?tech ;
          :statedBy ?person ;
          :statedOn ?date ;
          :confidence ?confidence .
    
    ?adr rdfs:label ?adrLabel .
    ?tech rdfs:label ?techLabel .
    ?person rdfs:label ?personName .
}
ORDER BY DESC(?date)
```

Expected result: Decision metadata including author, date, and confidence level.

SQL requires separate metadata tables with foreign keys. RDF provides native support for metadata about triples.

---

## Step 8: RDF-star — Quoted Triples

Same metadata with less boilerplate using SPARQL*:

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

Expected result: Same insight as reification, with shorter syntax.

**Note**: Requires RDF-star/SPARQL* support (GraphDB 10.7+).

---

## Step 9: CONSTRUCT — Generating New Graphs

Create a new RDF graph from existing data:

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

Expected result: New RDF graph (not a table).

Switch view to **Raw Response** to see RDF triples:
```turtle
:OrderService :uses :Kafka .
:OrderService rdfs:label "Order Processing Service" .
:Kafka rdfs:label "Apache Kafka" .
```

CONSTRUCT generates new graphs with arbitrary structure, unlike SQL's limited CREATE VIEW.

---

## Step 10: Named Graphs — Data Provenance

Query data with source tracking:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?graph ?adr ?label
WHERE {
    GRAPH ?graph {
        ?adr a :ADR ;
             rdfs:label ?label .
    }
}
ORDER BY ?graph ?adr
```

Expected result: ADRs with source indication (adr-registry, confluence, interview-notes)

**Key concept:**
- `GRAPH ?graph { ... }` — query named graph with variable binding
- Data provenance is built into RDF

---

## Summary

| Capability | SQL Complexity | SPARQL |
|------------|----------------|--------|
| Basic SELECT | Simple SELECT | Triple patterns |
| Filtering | WHERE clause | FILTER |
| Aggregation | GROUP BY | GROUP BY |
| **Transitive queries** | Recursive CTE (20+ lines) | `:dependsOn+` (1 line) |
| **Metadata about facts** | Separate table + FK | Reification |
| **Quoted triples** | Separate table + FK | RDF-star |
| **Graph generation** | CREATE VIEW (limited) | CONSTRUCT |
| **Provenance** | Separate tables | Named graphs |

---

## Next Steps

### Option 1: Key Examples
Open [EXAMPLES.md](EXAMPLES.md) and explore:
- 05-property-paths/ — graph navigation
- 06-reification/ — metadata about facts
- 10-rdf-star/ — quoted triples
- 07-reasoning/ — automatic inference
- 08-construct/ — graph generation
- 09-advanced/ — federated queries

### Option 2: Systematic Study
Progress through [EXAMPLES.md](EXAMPLES.md) sequentially from 01-basics to 10-rdf-star.

### Option 3: Experimentation
Use examples as templates to create custom queries.

---

## Tips

### Keyboard Shortcuts
- `Ctrl+Enter` — execute query
- `Ctrl+/` — comment line
- `Ctrl+Space` — prefix autocomplete

### Result Display Modes
- **Table** — tabular view (default)
- **Raw Response** — RDF format (for CONSTRUCT)
- **Pivot Table** — pivot table
- **Google Charts** — charts (for COUNT/AVG)

### Query Debugging
1. Start with simple pattern
2. Add conditions gradually
3. Use LIMIT 10 for large results
4. Check intermediate results

### Reference
See [SPARQL-CHEATSHEET.md](SPARQL-CHEATSHEET.md) for syntax reference.

---

## Environment Management

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

## FAQ

**Q: How to verify correct operation?**
A: Run `./scripts/health-check.sh` for system check and `./scripts/test-queries.sh` for query testing.

**Q: Query returns no results**
A: Verify repository **sparql-playground** is selected in dropdown.

**Q: GraphDB fails to start**
A: Check Docker is running: `docker ps`

**Q: Error "repository not found"**
A: Run `./scripts/setup.sh` to create repository.

**Q: Need to start from scratch**
A: Execute `./scripts/reset.sh`, then `./start.sh`

**Q: How to test all examples automatically?**
A: Run `./scripts/test-queries.sh`

---

## Conclusion

This guide demonstrated unique SPARQL capabilities not available in SQL:

- Property paths for graph navigation
- Reification for metadata about facts
- CONSTRUCT for generating new graphs
- Named graphs for provenance

Continue learning: [EXAMPLES.md](EXAMPLES.md)
