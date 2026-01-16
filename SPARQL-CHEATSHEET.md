# SPARQL Quick Reference

Quick lookup for SPARQL syntax and common patterns.

---

## Query Structure

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?variable1 ?variable2
WHERE {
    # Pattern matching here
    ?subject :predicate ?object .
}
ORDER BY ?variable1
LIMIT 10
```

---

## SELECT Clauses

| Clause | Purpose | Example |
|--------|---------|---------|
| `SELECT *` | All variables | `SELECT *` |
| `SELECT ?var` | Specific variable | `SELECT ?adr ?label` |
| `SELECT DISTINCT` | Unique results | `SELECT DISTINCT ?tech` |
| `SELECT (COUNT(*) as ?count)` | Aggregation | Count results |

---

## Triple Patterns

### Basic Pattern
```sparql
?subject :predicate :Object .
```

### Chaining (one subject)
```sparql
?adr a :ADR ;
     :hasStatus :Accepted ;
     rdfs:label ?label .
```

### Multiple Patterns
```sparql
?adr :decidesTechnology ?tech .
?tech rdfs:label ?label .
```

---

## RDF-star (Quoted Triples)

```sparql
<< :ADR-001 :decidesTechnology :Kafka >> :statedBy :person_IvanPetrov .
```

```sparql
GRAPH :decision-metadata-rdfstar {
    << ?adr :decidesTechnology ?tech >> :confidence ?confidence .
}
```

**Use case**: Metadata about a triple without full reification.

---

## OPTIONAL (Handling Missing Data)

```sparql
?adr :decidesTechnology ?tech .

OPTIONAL {
    ?adr :appliesTo ?system .
}
```

**Use case**: Some entities may not have the property.

---

## FILTER

### Comparisons
```sparql
FILTER(?confidence >= 0.90)
FILTER(?status = :Accepted)
FILTER(?status != :Deprecated)
```

### Logical Operators
```sparql
FILTER(?confidence >= 0.80 && ?status = :Accepted)
FILTER(?status = :Proposed || ?status = :Deprecated)
FILTER(!BOUND(?system))  # Check variable is not bound
```

### String Search
```sparql
FILTER(CONTAINS(?label, "Kafka"))
FILTER(REGEX(?label, "^ADR", "i"))  # Case insensitive
```

---

## FILTER NOT EXISTS (Finding Absence)

```sparql
# Find ADRs without system context
?adr a :ADR .

FILTER NOT EXISTS {
    ?adr :appliesTo ?system .
}
```

**Use case**: Find what is NOT in the graph.

---

## Named Graphs

### Query Specific Graph
```sparql
GRAPH :adr-registry {
    ?adr a :ADR .
}
```

### Variable Graph (Capture Source)
```sparql
GRAPH ?source {
    ?adr a :ADR .
}
```

### Multiple Graphs
```sparql
{
    GRAPH :adr-registry { ?adr a :ADR }
}
UNION
{
    GRAPH :confluence { ?adr a :ADR }
}
```

---

## Aggregation

| Function | Purpose | Example |
|----------|---------|---------|
| `COUNT` | Count results | `COUNT(?adr)` |
| `COUNT(DISTINCT ?var)` | Count unique | `COUNT(DISTINCT ?tech)` |
| `AVG` | Average | `AVG(?confidence)` |
| `SUM` | Sum | `SUM(?amount)` |
| `MIN` / `MAX` | Minimum/Maximum | `MAX(?confidence)` |
| `GROUP_CONCAT` | Concatenation | `GROUP_CONCAT(?label; separator=", ")` |

### GROUP BY
```sparql
SELECT ?tech (COUNT(?adr) AS ?count)
WHERE {
    ?adr :decidesTechnology ?tech .
}
GROUP BY ?tech
ORDER BY DESC(?count)
```

### HAVING (Filter After Grouping)
```sparql
SELECT ?adr (COUNT(?source) AS ?sourceCount)
WHERE {
    GRAPH ?source { ?adr a :ADR }
}
GROUP BY ?adr
HAVING (?sourceCount > 1)
```

---

## Sorting and Limits

```sparql
ORDER BY ?variable           # Ascending
ORDER BY DESC(?variable)     # Descending
ORDER BY ?var1 DESC(?var2)   # Multiple fields

LIMIT 10                     # First 10 results
OFFSET 20                    # Skip first 20
```

---

## Common Patterns

### Count All Objects of Type
```sparql
SELECT (COUNT(?adr) AS ?count)
WHERE {
    ?adr a :ADR .
}
```

### Get with Optional Information
```sparql
?adr a :ADR ;
     rdfs:label ?label .

OPTIONAL { ?adr :hasConfidence ?conf }
OPTIONAL { ?adr :appliesTo ?system }
```

### Search by Multiple Criteria
```sparql
?adr :hasStatus :Accepted ;
     :hasConfidence ?conf .

FILTER(?conf >= 0.80)
```

### Rank by Score
```sparql
SELECT ?tech (COUNT(?adr) * AVG(?conf) AS ?score)
WHERE {
    ?adr :decidesTechnology ?tech ;
         :hasConfidence ?conf .
}
GROUP BY ?tech
ORDER BY DESC(?score)
```

### Find What's NOT There
```sparql
?system a :System .

FILTER NOT EXISTS {
    ?adr :appliesTo ?system .
}
```

### Follow Relationships
```sparql
?newADR :supersedes ?oldADR .
?oldADR :decidesTechnology ?oldTech .
?newADR :decidesTechnology ?newTech .
```

---

## Prefixes (Dataset)

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
```

---

## Classes

- `:ADR` — Architecture Decision Record
- `:System` — Software system
- `:Technology` — Technology/tool
- `:Team` — Development team
- `:Status` — ADR status

---

## Properties

| Property | From | To | Meaning |
|----------|------|-----|---------|
| `:decidesTechnology` | ADR | Technology | ADR chooses technology |
| `:appliesTo` | ADR | System | ADR applies to system |
| `:uses` | System | Technology | System uses technology |
| `:supersedes` | ADR | ADR | New ADR replaces old |
| `:ownedBy` | ADR/System | Team | Ownership |
| `:hasStatus` | ADR | Status | Current status |
| `:hasConfidence` | ADR | decimal | Confidence level (0-1) |

---

## Named Graphs

- `:adr-registry` — Official ADR registry (highest quality)
- `:confluence` — Confluence documentation
- `:confluence-metadata` — Metadata from Confluence
- `:decision-metadata` — Decision metadata (reification)
- `:decision-metadata-rdfstar` — Decision metadata (RDF-star)
- `:decision-timeline` — Decision timeline
- `:interview-notes` — Interview notes (lowest quality)
- `:people` — Architect and team profiles

---

## Common Mistakes

### Missing Period
```sparql
# Wrong
?adr a :ADR
?adr rdfs:label ?label

# Correct
?adr a :ADR .
?adr rdfs:label ?label .
```

### Incorrect PREFIX
```sparql
# Wrong - missing colon
PREFIX adr <http://example.org/adr#>

# Correct
PREFIX : <http://example.org/adr#>
```

### FILTER in Wrong Place
```sparql
# Wrong - FILTER before pattern
WHERE {
    FILTER(?conf >= 0.90)
    ?adr :hasConfidence ?conf .
}

# Correct - FILTER after pattern
WHERE {
    ?adr :hasConfidence ?conf .
    FILTER(?conf >= 0.90)
}
```

### Forgot DISTINCT
```sparql
# Returns duplicates
SELECT ?tech WHERE { ?adr :decidesTechnology ?tech }

# Returns unique
SELECT DISTINCT ?tech WHERE { ?adr :decidesTechnology ?tech }
```

---

## SPARQL vs SQL

| SPARQL | SQL | Meaning |
|--------|-----|---------|
| `?variable` | column name | Variable/placeholder |
| Triple pattern | JOIN | Link tables/entities |
| `OPTIONAL` | LEFT JOIN | Optional data |
| `FILTER` | WHERE | Filter results |
| `FILTER NOT EXISTS` | NOT EXISTS subquery | Check absence |
| `GRAPH` | Database/schema | Data partition |
| `.` | End of statement | Pattern separator |

**Key difference**: SPARQL matches patterns in graphs; SQL queries tables with rows.

---

## Best Practices

**Recommended:**
- Start simple: basic pattern first, then add complexity
- Use OPTIONAL for incomplete data (Open World Assumption)
- Check BOUND() to know if optional variables matched
- Place FILTER after pattern (variables must be defined)
- Use DISTINCT for unique results
- Name aggregations: `(COUNT(?x) AS ?count)` not just `COUNT(?x)`

**Avoid:**
- Assuming SQL logic: graphs work differently
- Forgetting prefixes: needed for short notation
- Overcomplicating: simple patterns often work best

---

## Query Template

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

# Description of what the query does

SELECT ?result1 ?result2
WHERE {
    # Required patterns
    ?entity a :Type ;
            :property ?value .
    
    # Optional patterns
    OPTIONAL {
        ?entity :optionalProperty ?optional .
    }
    
    # Filters
    FILTER(?value >= threshold)
}
ORDER BY ?result1
LIMIT 100
```

---

See [EXAMPLES.md](EXAMPLES.md) for working examples.
