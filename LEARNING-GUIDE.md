# SPARQL Learning Guide: From Zero to Hero

> A comprehensive tutorial combining RDF/SPARQL theory with hands-on practice using the ADR (Architecture Decision Records) dataset.

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [RDF Fundamentals](#2-rdf-fundamentals)
3. [Getting Started with SPARQL](#3-getting-started-with-sparql)
4. [Basic Queries](#4-basic-queries)
5. [Filtering and Pattern Matching](#5-filtering-and-pattern-matching)
6. [Aggregation and Analysis](#6-aggregation-and-analysis)
7. [Named Graphs and Provenance](#7-named-graphs-and-provenance)
8. [Property Paths](#8-property-paths)
9. [Reification: Metadata About Facts](#9-reification-metadata-about-facts)
10. [RDF-star: Modern Statement Annotation](#10-rdf-star-modern-statement-annotation)
11. [RDFS/OWL Reasoning](#11-rdfsowl-reasoning)
12. [SHACL: Data Validation](#12-shacl-data-validation)
13. [CONSTRUCT: Graph Generation](#13-construct-graph-generation)
14. [Advanced Techniques](#14-advanced-techniques)
15. [SPARQL vs SQL Comparison](#15-sparql-vs-sql-comparison)
16. [Exercises](#16-exercises)
17. [Further Reading](#17-further-reading)

---

## 1. Introduction

### What is This Guide?

This learning guide provides a structured path to mastering SPARQL through the lens of a real-world domain: **Architecture Decision Records (ADRs)**. ADRs document important architectural decisions made during software development, making them an excellent example for learning knowledge graph concepts.

### Prerequisites

- Basic understanding of databases and SQL
- Familiarity with JSON or XML data formats
- Curiosity about graph-based data modeling

### Learning Objectives

By completing this guide, you will be able to:

- Understand the RDF data model and its advantages
- Write SPARQL queries from basic to advanced
- Work with graph patterns, property paths, and named graphs
- Apply reasoning to automatically infer new knowledge
- Validate data using SHACL constraints
- Compare and contrast SPARQL with SQL

### How to Use This Guide

1. **Start the playground**: Run `./start.sh` to set up the environment
2. **Open GraphDB**: Navigate to http://localhost:7200
3. **Select the repository**: Choose `sparql-playground`
4. **Follow along**: Execute queries in the SPARQL tab as you read

---

## 2. RDF Fundamentals

### 2.1 What is RDF?

**RDF (Resource Description Framework)** is a W3C standard for representing information as a graph. Unlike relational databases that use tables with fixed schemas, RDF represents knowledge as a network of connected statements.

### 2.2 The Triple: Building Block of RDF

Every piece of information in RDF is expressed as a **triple** consisting of three parts:

```
Subject → Predicate → Object
```

Think of it as a simple sentence:

| Component | Role | Example |
|-----------|------|---------|
| **Subject** | What we're talking about | `ADR-001` |
| **Predicate** | The relationship/property | `decidesTechnology` |
| **Object** | The value or related thing | `Kafka` |

This creates the statement: *"ADR-001 decides to use Kafka"*

### 2.3 URIs: Universal Identifiers

RDF uses **URIs (Uniform Resource Identifiers)** to uniquely identify resources:

```
http://example.org/adr#ADR-001
http://example.org/adr#decidesTechnology
http://example.org/adr#Kafka
```

**Prefixes** provide shorthand notation:

```turtle
PREFIX : <http://example.org/adr#>

# Full URI:
<http://example.org/adr#ADR-001> <http://example.org/adr#decidesTechnology> <http://example.org/adr#Kafka> .

# With prefix:
:ADR-001 :decidesTechnology :Kafka .
```

### 2.4 Literals: Data Values

Objects can be **literals** (data values) instead of URIs:

```turtle
:ADR-001 rdfs:label "Use Kafka for Event Streaming" .
:ADR-001 :hasConfidence 0.95 .
:ADR-001 :createdOn "2024-12-15"^^xsd:date .
```

Literals can have:
- **Plain text**: `"Hello World"`
- **Language tags**: `"Hello"@en`, `"Hola"@es`
- **Datatypes**: `"0.95"^^xsd:decimal`, `"2024-12-15"^^xsd:date`

### 2.5 Graph Visualization

RDF naturally forms a **graph** where:
- **Nodes** = Subjects and Objects
- **Edges** = Predicates

```
                    ┌──────────────┐
                    │   :Kafka     │
                    └──────────────┘
                           ▲
                           │ :decidesTechnology
                           │
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ :TeamCheckout│◄───│   :ADR-001   │───►│:OrderService │
└──────────────┘    └──────────────┘    └──────────────┘
      :ownedBy             │ :hasStatus
                           ▼
                    ┌──────────────┐
                    │  :Accepted   │
                    └──────────────┘
```

### 2.6 RDF Serialization Formats

RDF can be serialized in multiple formats:

| Format | Extension | Characteristics |
|--------|-----------|-----------------|
| **Turtle** | `.ttl` | Human-readable, concise |
| **N-Triples** | `.nt` | One triple per line, simple |
| **RDF/XML** | `.rdf` | XML-based, verbose |
| **JSON-LD** | `.jsonld` | JSON-compatible |
| **TriG** | `.trig` | Turtle + named graphs |

This playground uses **Turtle** (`.ttl`) and **TriG** (`.trig`) formats.

### 2.7 Key Differences from Relational Databases

| Aspect | Relational (SQL) | RDF/SPARQL |
|--------|------------------|------------|
| **Data model** | Tables with fixed schema | Graph of triples |
| **Schema** | Required before data | Optional, can evolve |
| **Relationships** | Foreign keys + JOINs | Direct edges in graph |
| **Types** | One type per row | Multiple types per resource |
| **Null values** | Explicit NULL | Simply absent (Open World) |
| **Identity** | Primary keys | URIs (globally unique) |

---

## 3. Getting Started with SPARQL

### 3.1 What is SPARQL?

**SPARQL (SPARQL Protocol and RDF Query Language)** is the standard query language for RDF data. Pronounced "sparkle," it's to RDF what SQL is to relational databases.

### 3.2 Setting Up the Environment

1. **Start the playground**:
   ```bash
   ./start.sh
   ```

2. **Open GraphDB Workbench**: http://localhost:7200

3. **Select repository**: Choose `sparql-playground` from the dropdown

4. **Navigate to SPARQL tab**: Click "SPARQL" in the left menu

### 3.3 Your First Query

Let's verify the environment is working. Copy and paste this query:

```sparql
PREFIX : <http://example.org/adr#>

SELECT (COUNT(*) as ?count)
WHERE {
    ?s a :ADR .
}
```

Press **Ctrl+Enter** to execute. You should see a count of ADRs (8).

### 3.4 Query Structure Overview

A SPARQL query has this basic structure:

```sparql
# 1. PREFIX declarations (optional but recommended)
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

# 2. Query form (SELECT, CONSTRUCT, ASK, or DESCRIBE)
SELECT ?variable1 ?variable2

# 3. WHERE clause with graph patterns
WHERE {
    ?subject :predicate ?object .
}

# 4. Solution modifiers (optional)
ORDER BY ?variable1
LIMIT 10
```

### 3.5 Variables

Variables in SPARQL start with `?` or `$`:

```sparql
?adr        # A variable named "adr"
?label      # A variable named "label"
$count      # Same as ?count
```

Variables get **bound** to values when patterns match the data.

---

## 4. Basic Queries

### 4.1 Simple SELECT

**Query all ADRs with their labels:**

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

**Explanation:**
- `?adr a :ADR` — find all resources of type ADR (`a` is shorthand for `rdf:type`)
- `;` — continue with same subject
- `rdfs:label ?label` — get the label property
- `.` — end of pattern

📁 **Try it**: `examples/01-basics/list-all-adrs.sparql`

### 4.2 The Triple Pattern

Triple patterns match data in the graph:

```sparql
# Pattern with all variables (matches everything)
?s ?p ?o .

# Pattern with fixed predicate
?adr :decidesTechnology ?tech .

# Pattern with fixed subject and predicate
:ADR-001 :hasStatus ?status .

# Pattern with all fixed values (checks existence)
:ADR-001 :decidesTechnology :Kafka .
```

### 4.3 Chaining Patterns (Same Subject)

Use `;` to add patterns for the same subject:

```sparql
?adr a :ADR ;
     rdfs:label ?label ;
     :hasStatus ?status ;
     :hasConfidence ?confidence .
```

This is equivalent to:

```sparql
?adr a :ADR .
?adr rdfs:label ?label .
?adr :hasStatus ?status .
?adr :hasConfidence ?confidence .
```

### 4.4 Following Relationships

Chain patterns to navigate the graph:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adrLabel ?techLabel ?systemLabel
WHERE {
    ?adr a :ADR ;
         rdfs:label ?adrLabel ;
         :decidesTechnology ?tech ;
         :appliesTo ?system .
    
    ?tech rdfs:label ?techLabel .
    ?system rdfs:label ?systemLabel .
}
```

📁 **Try it**: `examples/01-basics/systems-and-owners.sparql`

### 4.5 OPTIONAL: Handling Missing Data

RDF follows the **Open World Assumption**: missing data means "unknown," not "false." Use `OPTIONAL` to handle this:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?label ?system
WHERE {
    ?adr a :ADR ;
         rdfs:label ?label .
    
    # Some ADRs don't have :appliesTo
    OPTIONAL {
        ?adr :appliesTo ?sys .
        ?sys rdfs:label ?system .
    }
}
```

Without `OPTIONAL`, ADRs missing `:appliesTo` would be excluded from results.

### 4.6 DISTINCT: Removing Duplicates

```sparql
PREFIX : <http://example.org/adr#>

SELECT DISTINCT ?tech
WHERE {
    ?adr :decidesTechnology ?tech .
}
```

---

## 5. Filtering and Pattern Matching

### 5.1 FILTER Basics

`FILTER` restricts results based on conditions:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?label ?confidence
WHERE {
    ?adr a :ADR ;
         rdfs:label ?label ;
         :hasConfidence ?confidence .
    
    FILTER(?confidence >= 0.90)
}
ORDER BY DESC(?confidence)
```

📁 **Try it**: `examples/02-filtering/high-confidence-adrs.sparql`

### 5.2 Comparison Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | Equal | `FILTER(?status = :Accepted)` |
| `!=` | Not equal | `FILTER(?status != :Deprecated)` |
| `<`, `>` | Less/greater than | `FILTER(?conf > 0.8)` |
| `<=`, `>=` | Less/greater or equal | `FILTER(?conf >= 0.9)` |

### 5.3 Logical Operators

```sparql
# AND
FILTER(?confidence >= 0.80 && ?status = :Accepted)

# OR
FILTER(?status = :Proposed || ?status = :Deprecated)

# NOT
FILTER(!(?confidence < 0.5))
```

### 5.4 String Functions

```sparql
# Contains substring
FILTER(CONTAINS(?label, "Kafka"))

# Regular expression (case-insensitive)
FILTER(REGEX(?label, "event", "i"))

# String starts with
FILTER(STRSTARTS(?label, "Use"))

# String length
FILTER(STRLEN(?label) > 20)
```

📁 **Try it**: `examples/02-filtering/adrs-for-technology.sparql`

### 5.5 FILTER NOT EXISTS: Finding Absence

Find ADRs that are missing a property:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?label
WHERE {
    ?adr a :ADR ;
         rdfs:label ?label .
    
    # Find ADRs without system context
    FILTER NOT EXISTS {
        ?adr :appliesTo ?system .
    }
}
```

📁 **Try it**: `examples/04-analysis/incomplete-adrs.sparql`

### 5.6 BOUND: Checking Variable Binding

```sparql
PREFIX : <http://example.org/adr#>

SELECT ?adr ?system ?hasSystem
WHERE {
    ?adr a :ADR .
    
    OPTIONAL { ?adr :appliesTo ?system }
    
    BIND(BOUND(?system) AS ?hasSystem)
}
```

### 5.7 VALUES: Inline Data

Specify a set of values to match:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?label ?tech
WHERE {
    VALUES ?tech { :Kafka :PostgreSQL :Redis }
    
    ?adr :decidesTechnology ?tech ;
         rdfs:label ?label .
}
```

---

## 6. Aggregation and Analysis

### 6.1 COUNT

```sparql
PREFIX : <http://example.org/adr#>

SELECT (COUNT(?adr) AS ?totalADRs)
WHERE {
    ?adr a :ADR .
}
```

### 6.2 GROUP BY

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?status (COUNT(?adr) AS ?count)
WHERE {
    ?adr a :ADR ;
         :hasStatus ?status .
}
GROUP BY ?status
ORDER BY DESC(?count)
```

📁 **Try it**: `examples/01-basics/count-by-status.sparql`

### 6.3 Aggregation Functions

| Function | Purpose | Example |
|----------|---------|---------|
| `COUNT` | Count items | `COUNT(?adr)` |
| `COUNT(DISTINCT ?x)` | Count unique | `COUNT(DISTINCT ?tech)` |
| `SUM` | Sum values | `SUM(?amount)` |
| `AVG` | Average | `AVG(?confidence)` |
| `MIN` / `MAX` | Minimum/Maximum | `MAX(?confidence)` |
| `GROUP_CONCAT` | Concatenate strings | `GROUP_CONCAT(?label; SEPARATOR=", ")` |

### 6.4 HAVING: Filter After Grouping

```sparql
PREFIX : <http://example.org/adr#>

SELECT ?tech (COUNT(?adr) AS ?usageCount)
WHERE {
    ?adr :decidesTechnology ?tech .
}
GROUP BY ?tech
HAVING (COUNT(?adr) > 1)
ORDER BY DESC(?usageCount)
```

📁 **Try it**: `examples/04-analysis/technology-adoption.sparql`

### 6.5 Complex Analysis Example

Calculate technology adoption score:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?techLabel 
       (COUNT(?adr) AS ?decisions)
       (AVG(?conf) AS ?avgConfidence)
       (COUNT(?adr) * AVG(?conf) AS ?adoptionScore)
WHERE {
    ?adr :decidesTechnology ?tech ;
         :hasConfidence ?conf .
    
    ?tech rdfs:label ?techLabel .
}
GROUP BY ?tech ?techLabel
ORDER BY DESC(?adoptionScore)
```

---

## 7. Named Graphs and Provenance

### 7.1 What are Named Graphs?

RDF can be extended from **triples** to **quads** by adding a fourth component: the **graph name**.

```
Graph → Subject → Predicate → Object
```

Named graphs enable:
- **Data partitioning** — organize data by source or topic
- **Provenance tracking** — know where data came from
- **Access control** — different permissions per graph
- **Temporal versioning** — different snapshots of data

### 7.2 Graphs in Our Dataset

The ADR dataset uses several named graphs:

| Graph | Purpose | Data Quality |
|-------|---------|--------------|
| `:adr-registry` | Official ADR registry | High |
| `:confluence` | Confluence documentation | Medium |
| `:interview-notes` | Interview notes | Low (incomplete) |
| `:people` | Architect profiles | High |
| `:decision-metadata` | Reified statements | High |
| `:decision-metadata-rdfstar` | RDF-star metadata | High |

### 7.3 Query Specific Graph

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?label
WHERE {
    GRAPH :adr-registry {
        ?adr a :ADR ;
             rdfs:label ?label .
    }
}
```

📁 **Try it**: `examples/03-graphs/official-registry-only.sparql`

### 7.4 Query with Graph Variable

Capture the source graph for provenance:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?source ?adr ?label
WHERE {
    GRAPH ?source {
        ?adr a :ADR ;
             rdfs:label ?label .
    }
}
ORDER BY ?source ?adr
```

📁 **Try it**: `examples/03-graphs/adrs-by-source.sparql`

### 7.5 Find Multi-Source ADRs

Find ADRs that appear in multiple sources:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?label (COUNT(DISTINCT ?source) AS ?sourceCount)
WHERE {
    GRAPH ?source {
        ?adr a :ADR ;
             rdfs:label ?label .
    }
}
GROUP BY ?adr ?label
HAVING (COUNT(DISTINCT ?source) > 1)
ORDER BY DESC(?sourceCount)
```

📁 **Try it**: `examples/03-graphs/multi-source-adrs.sparql`

### 7.6 UNION Across Graphs

Query multiple specific graphs:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?label ?source
WHERE {
    {
        GRAPH :adr-registry { 
            ?adr a :ADR ; rdfs:label ?label . 
        }
        BIND("Official" AS ?source)
    }
    UNION
    {
        GRAPH :confluence { 
            ?adr a :ADR ; rdfs:label ?label . 
        }
        BIND("Confluence" AS ?source)
    }
}
```

---

## 8. Property Paths

### 8.1 The Power of Property Paths

Property paths are one of SPARQL's most powerful features, enabling **declarative graph traversal** without explicit recursion.

**SQL equivalent** requires recursive Common Table Expressions (CTEs) — typically 10-15 lines of code.

### 8.2 Property Path Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `/` | Sequence | `:a/:b` (follow a, then b) |
| `\|` | Alternative | `:a\|:b` (follow a or b) |
| `*` | Zero or more | `:a*` (any number of steps) |
| `+` | One or more | `:a+` (at least one step) |
| `?` | Zero or one | `:a?` (optional step) |
| `^` | Inverse | `^:a` (reverse direction) |

### 8.3 Transitive Closure: The `+` Operator

Find all dependencies of Kubernetes (direct and indirect):

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?dependency ?depLabel
WHERE {
    :Kubernetes :dependsOn+ ?dependency .
    
    OPTIONAL { ?dependency rdfs:label ?depLabel }
}
ORDER BY ?depLabel
```

📁 **Try it**: `examples/05-property-paths/transitive-dependencies.sparql`

**Dependency chain:**
```
Kubernetes → Docker → Linux → Kernel
Kubernetes → Docker → ContainerRuntime
Kubernetes → etcd → Go
```

### 8.4 SQL Equivalent (for comparison)

```sql
WITH RECURSIVE deps AS (
  SELECT tech_id, depends_on_id, 1 as level
  FROM dependencies 
  WHERE tech_id = 'kubernetes'
  
  UNION ALL
  
  SELECT d.tech_id, d.depends_on_id, deps.level + 1
  FROM dependencies d 
  JOIN deps ON deps.depends_on_id = d.tech_id
  WHERE deps.level < 10
)
SELECT DISTINCT depends_on_id FROM deps;
```

SPARQL achieves this in **one expression**: `:dependsOn+`

### 8.5 Reverse Dependencies: `^` Operator

What technologies require Linux?

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?tech ?techLabel
WHERE {
    ?tech :dependsOn+ :Linux .
    
    OPTIONAL { ?tech rdfs:label ?techLabel }
}
```

Or using the inverse operator:

```sparql
SELECT ?tech ?techLabel
WHERE {
    :Linux ^:dependsOn+ ?tech .
    
    OPTIONAL { ?tech rdfs:label ?techLabel }
}
```

📁 **Try it**: `examples/05-property-paths/reverse-dependencies.sparql`

### 8.6 Alternative Paths: `|` Operator

Find connections through different relationship types:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?label ?relatedThing
WHERE {
    ?adr a :ADR ;
         rdfs:label ?label ;
         (:decidesTechnology|:appliesTo) ?relatedThing .
}
```

📁 **Try it**: `examples/05-property-paths/alternative-paths.sparql`

### 8.7 Sequence Paths: `/` Operator

Navigate through multiple properties:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

# Find technologies used by systems that have ADRs
SELECT DISTINCT ?tech ?techLabel
WHERE {
    ?adr :appliesTo/:uses ?tech .
    
    ?tech rdfs:label ?techLabel .
}
```

### 8.8 Detecting Circular Dependencies

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?tech ?techLabel
WHERE {
    ?tech :dependsOn+ ?tech .
    
    OPTIONAL { ?tech rdfs:label ?techLabel }
}
```

📁 **Try it**: `examples/05-property-paths/circular-check.sparql`

---

## 9. Reification: Metadata About Facts

### 9.1 The Problem

How do you store metadata about a fact itself?

For example: *"Ivan Petrov stated that ADR-001 decides on Kafka on December 15, 2024, with 95% confidence."*

The fact is: `ADR-001 decides on Kafka`
The metadata is: who, when, and with what confidence

### 9.2 RDF Reification

RDF provides **reification** — the ability to make statements about statements.

```turtle
:statement_001 a rdf:Statement ;
    rdf:subject :ADR-001 ;
    rdf:predicate :decidesTechnology ;
    rdf:object :Kafka ;
    
    # Metadata about the statement
    :statedBy :person_IvanPetrov ;
    :statedOn "2024-12-15"^^xsd:date ;
    :confidence 0.95 .
```

### 9.3 Querying Reified Statements

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?adrLabel ?technology ?decisionMaker ?decisionDate ?confidence
WHERE {
    ?stmt a rdf:Statement ;
          rdf:subject ?adr ;
          rdf:predicate :decidesTechnology ;
          rdf:object ?tech ;
          :statedBy ?person ;
          :statedOn ?decisionDate ;
          :confidence ?confidence .
    
    ?adr rdfs:label ?adrLabel .
    ?tech rdfs:label ?technology .
    ?person rdfs:label ?decisionMaker .
}
ORDER BY ?decisionDate
```

📁 **Try it**: `examples/06-reification/who-decided.sparql`

### 9.4 Use Cases for Reification

| Use Case | Metadata |
|----------|----------|
| **Audit trails** | Who, when, approval status |
| **Confidence levels** | How certain is this fact? |
| **Sources** | Where did this information come from? |
| **Validity periods** | When was this true? |
| **Decision context** | Rationale, alternatives considered |

### 9.5 Evidence Trail for Compliance

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?adrLabel ?technology ?rationale ?evidence ?votingResult
WHERE {
    ?stmt a rdf:Statement ;
          rdf:subject ?adr ;
          rdf:predicate :decidesTechnology ;
          rdf:object ?tech ;
          :decisionRationale ?rationale ;
          :evidenceSource ?evidence ;
          :votingResult ?votingResult .
    
    ?adr rdfs:label ?adrLabel .
    ?tech rdfs:label ?technology .
}
```

📁 **Try it**: `examples/06-reification/evidence-trail.sparql`

### 9.6 SQL Comparison

SQL requires a separate metadata table:

```sql
CREATE TABLE decision_metadata (
    id INT PRIMARY KEY,
    adr_id INT REFERENCES adrs(id),
    technology_id INT REFERENCES technologies(id),
    stated_by INT REFERENCES people(id),
    stated_on DATE,
    confidence DECIMAL(3,2)
);

-- Then JOIN to retrieve:
SELECT a.label, t.name, p.name, dm.stated_on, dm.confidence
FROM decision_metadata dm
JOIN adrs a ON dm.adr_id = a.id
JOIN technologies t ON dm.technology_id = t.id
JOIN people p ON dm.stated_by = p.id;
```

RDF reification provides this capability natively without additional schema.

---

## 10. RDF-star: Modern Statement Annotation

### 10.1 What is RDF-star?

**RDF-star** (RDF 1.2) is a W3C extension that provides a more concise syntax for statement-level metadata using **quoted triples**.

Instead of creating an `rdf:Statement` resource, you directly annotate the triple:

```turtle
<< :ADR-001 :decidesTechnology :Kafka >>
    :statedBy :person_IvanPetrov ;
    :statedOn "2024-12-15"^^xsd:date ;
    :confidence 0.95 .
```

### 10.2 Querying with SPARQL-star

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adrLabel ?technology ?decisionMaker ?decisionDate ?confidence
WHERE {
    GRAPH :decision-metadata-rdfstar {
        << ?adr :decidesTechnology ?tech >>
            :statedBy ?person ;
            :statedOn ?decisionDate ;
            :confidence ?confidence .
    }
    
    ?adr rdfs:label ?adrLabel .
    ?tech rdfs:label ?technology .
    ?person rdfs:label ?decisionMaker .
}
ORDER BY ?decisionDate
```

📁 **Try it**: `examples/10-rdf-star/who-decided-rdf-star.sparql`

### 10.3 RDF-star vs Standard Reification

| Aspect | Standard Reification | RDF-star |
|--------|---------------------|----------|
| **Syntax** | Verbose (4+ triples) | Concise (quoted triple) |
| **Readability** | More complex | More intuitive |
| **Triple count** | Higher | Lower |
| **Support** | All triplestores | Requires RDF-star support |

### 10.4 Finding Missing Evidence

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adrLabel ?technology ?decisionMaker
WHERE {
    GRAPH :decision-metadata-rdfstar {
        << ?adr :decidesTechnology ?tech >>
            :statedBy ?person .
        
        # Find decisions WITHOUT evidence source
        FILTER NOT EXISTS {
            << ?adr :decidesTechnology ?tech >>
                :evidenceSource ?evidence .
        }
    }
    
    ?adr rdfs:label ?adrLabel .
    ?tech rdfs:label ?technology .
    ?person rdfs:label ?decisionMaker .
}
```

📁 **Try it**: `examples/10-rdf-star/missing-evidence-rdf-star.sparql`

---

## 11. RDFS/OWL Reasoning

### 11.1 What is Reasoning?

**Reasoning** (or inference) automatically derives new facts from existing data using schema-level rules.

SQL equivalent requires **triggers** and **stored procedures**.

### 11.2 Class Hierarchy (rdfs:subClassOf)

The ontology defines:

```turtle
:TechnicalDecision rdfs:subClassOf :ArchitecturalDecision .
:DatabaseDecision rdfs:subClassOf :TechnicalDecision .
```

If `ADR-002` is a `:DatabaseDecision`, the reasoner automatically infers:
- `ADR-002` is a `:TechnicalDecision`
- `ADR-002` is an `:ArchitecturalDecision`

### 11.3 Query Using Class Hierarchy

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

# Find ALL architectural decisions (including subtypes)
SELECT ?adr ?label ?type
WHERE {
    ?adr a :ArchitecturalDecision ;
         rdfs:label ?label ;
         a ?type .
    
    ?type rdfs:subClassOf* :ArchitecturalDecision .
}
```

📁 **Try it**: `examples/07-reasoning/class-hierarchy.sparql`

### 11.4 Property Hierarchy (rdfs:subPropertyOf)

```turtle
:usesMicroservices rdfs:subPropertyOf :requiresOrchestration .
:requiresOrchestration rdfs:subPropertyOf :requiresInfrastructure .
```

Query for infrastructure requirements automatically includes microservices:

```sparql
PREFIX : <http://example.org/adr#>

SELECT ?adr ?requirement
WHERE {
    ?adr :requiresInfrastructure ?requirement .
}
```

📁 **Try it**: `examples/07-reasoning/subproperty-inference.sparql`

### 11.5 Inverse Properties (owl:inverseOf)

The ontology defines:

```turtle
:requiredBy owl:inverseOf :dependsOn .
```

The reasoner automatically infers:
- If `Kubernetes :dependsOn Docker`
- Then `Docker :requiredBy Kubernetes`

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?technology ?techLabel ?dependent ?depLabel
WHERE {
    ?technology :requiredBy ?dependent .
    
    OPTIONAL { ?technology rdfs:label ?techLabel }
    OPTIONAL { ?dependent rdfs:label ?depLabel }
}
ORDER BY ?technology
```

📁 **Try it**: `examples/07-reasoning/inverse-properties.sparql`

### 11.6 Transitive Properties (owl:TransitiveProperty)

```turtle
:dependsOn a owl:TransitiveProperty .
```

The reasoner materializes the transitive closure:
- If `A :dependsOn B` and `B :dependsOn C`
- Then `A :dependsOn C` is automatically inferred

This complements SPARQL property paths (`+`) with **materialized inference**.

### 11.7 Symmetric Properties (owl:SymmetricProperty)

```turtle
:conflictsWith a owl:SymmetricProperty .
```

If `A :conflictsWith B`, then `B :conflictsWith A` is automatically inferred.

📁 **Try it**: `examples/07-reasoning/symmetric-properties.sparql`

### 11.8 Functional Properties (owl:FunctionalProperty)

```turtle
:hasStatus a owl:FunctionalProperty .
```

Constrains each ADR to have **at most one** status value.

---

## 12. SHACL: Data Validation

### 12.1 Open World vs Closed World

| Paradigm | Missing Data Interpretation | Typical Use |
|----------|----------------------------|-------------|
| **Open World (OWL)** | Unknown (might exist) | Reasoning, inference |
| **Closed World (SHACL)** | Violation (should exist) | Validation, quality |

### 12.2 What is SHACL?

**SHACL (Shapes Constraint Language)** is a W3C standard for validating RDF data against a set of constraints called **shapes**.

### 12.3 SHACL Shape Structure

```turtle
:ADRShape a sh:NodeShape ;
    sh:targetClass :ADR ;
    
    sh:property [
        sh:path rdfs:label ;
        sh:minCount 1 ;
        sh:maxCount 1 ;
        sh:datatype xsd:string ;
        sh:severity sh:Violation ;
        sh:message "ADR must have exactly one rdfs:label"
    ] ;
    
    sh:property [
        sh:path :hasConfidence ;
        sh:minInclusive 0.0 ;
        sh:maxInclusive 1.0 ;
        sh:severity sh:Warning ;
        sh:message "Confidence must be between 0.0 and 1.0"
    ] .
```

### 12.4 Common SHACL Constraints

| Constraint | Purpose | Example |
|------------|---------|---------|
| `sh:minCount` | Minimum occurrences | `sh:minCount 1` (required) |
| `sh:maxCount` | Maximum occurrences | `sh:maxCount 1` (single value) |
| `sh:datatype` | Value type | `sh:datatype xsd:decimal` |
| `sh:pattern` | Regex pattern | `sh:pattern "^[A-Z]+"` |
| `sh:minInclusive` | Minimum value | `sh:minInclusive 0.0` |
| `sh:maxInclusive` | Maximum value | `sh:maxInclusive 1.0` |
| `sh:class` | Required class | `sh:class :Technology` |

### 12.5 Manual Violation Checking

Query to find potential violations without SHACL validation engine:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?adrLabel ?issue ?severity
WHERE {
    ?adr a :ADR .
    OPTIONAL { ?adr rdfs:label ?adrLabel }
    
    {
        FILTER NOT EXISTS { ?adr rdfs:label ?label }
        BIND("Missing rdfs:label" AS ?issue)
        BIND("Violation" AS ?severity)
    }
    UNION
    {
        FILTER NOT EXISTS { ?adr :hasStatus ?status }
        BIND("Missing :hasStatus" AS ?issue)
        BIND("Violation" AS ?severity)
    }
    UNION
    {
        FILTER NOT EXISTS { ?adr :appliesTo ?system }
        BIND("Missing :appliesTo (no system context)" AS ?issue)
        BIND("Info" AS ?severity)
    }
}
ORDER BY ?severity ?adr
```

📁 **Try it**: `examples/11-shacl/find-violations.sparql`

### 12.6 Exploring SHACL Shapes

```sparql
PREFIX sh: <http://www.w3.org/ns/shacl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?shape ?targetClass ?propertyPath ?minCount ?datatype ?message
WHERE {
    ?shape a sh:NodeShape ;
           sh:targetClass ?targetClass ;
           sh:property ?propShape .
    
    ?propShape sh:path ?propertyPath .
    
    OPTIONAL { ?propShape sh:minCount ?minCount }
    OPTIONAL { ?propShape sh:datatype ?datatype }
    OPTIONAL { ?propShape sh:message ?message }
}
ORDER BY ?shape ?propertyPath
```

📁 **Try it**: `examples/11-shacl/shacl-shapes-overview.sparql`

---

## 13. CONSTRUCT: Graph Generation

### 13.1 What is CONSTRUCT?

`CONSTRUCT` generates a **new RDF graph** rather than a tabular result. It's like `SELECT`, but outputs triples.

### 13.2 Basic CONSTRUCT

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

📁 **Try it**: `examples/08-construct/simplified-view.sparql`

### 13.3 Output Format

Switch GraphDB view to **Raw Response** to see the generated RDF:

```turtle
:OrderService :uses :Kafka .
:OrderService rdfs:label "Order Processing Service" .
:Kafka rdfs:label "Apache Kafka" .
```

### 13.4 Use Cases for CONSTRUCT

| Use Case | Description |
|----------|-------------|
| **Data transformation** | Reshape data for different applications |
| **Schema mapping** | Convert between ontologies |
| **Visualization export** | Generate data for Gephi, D3.js |
| **API responses** | Create JSON-LD for REST APIs |
| **Data integration** | Merge data from multiple sources |

### 13.5 Technology Graph for Visualization

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

CONSTRUCT {
    ?tech1 :relatedTo ?tech2 .
    ?tech1 rdfs:label ?label1 .
    ?tech2 rdfs:label ?label2 .
}
WHERE {
    ?tech1 :dependsOn ?tech2 .
    
    ?tech1 rdfs:label ?label1 .
    ?tech2 rdfs:label ?label2 .
}
```

📁 **Try it**: `examples/08-construct/technology-graph.sparql`

### 13.6 SQL Comparison

SQL `CREATE VIEW` provides limited structural flexibility:

```sql
CREATE VIEW system_technologies AS
SELECT s.name AS system_name, t.name AS technology_name
FROM adrs a
JOIN systems s ON a.system_id = s.id
JOIN technologies t ON a.technology_id = t.id;
```

SPARQL CONSTRUCT can:
- Create arbitrary graph structures
- Generate new properties not in source data
- Transform between schemas
- Output as RDF for further processing

---

## 14. Advanced Techniques

### 14.1 BIND: Creating Computed Values

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?label ?confidence ?riskLevel
WHERE {
    ?adr a :ADR ;
         rdfs:label ?label ;
         :hasConfidence ?confidence .
    
    BIND(
        IF(?confidence >= 0.9, "Low Risk",
        IF(?confidence >= 0.7, "Medium Risk", "High Risk"))
        AS ?riskLevel
    )
}
ORDER BY ?confidence
```

### 14.2 MINUS: Difference

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

# ADRs from registry that are NOT in confluence
SELECT ?adr ?label
WHERE {
    GRAPH :adr-registry {
        ?adr a :ADR ;
             rdfs:label ?label .
    }
    
    MINUS {
        GRAPH :confluence {
            ?adr a :ADR .
        }
    }
}
```

### 14.3 Subqueries

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?tech ?techLabel ?avgConfidence
WHERE {
    {
        SELECT ?tech (AVG(?conf) AS ?avgConfidence)
        WHERE {
            ?adr :decidesTechnology ?tech ;
                 :hasConfidence ?conf .
        }
        GROUP BY ?tech
    }
    
    ?tech rdfs:label ?techLabel .
    
    FILTER(?avgConfidence >= 0.85)
}
ORDER BY DESC(?avgConfidence)
```

### 14.4 Federated Queries (SERVICE)

Query remote SPARQL endpoints:

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dbr: <http://dbpedia.org/resource/>
PREFIX dbo: <http://dbpedia.org/ontology/>

SELECT ?tech ?techLabel ?abstract
WHERE {
    # Local data
    ?adr :decidesTechnology ?tech .
    ?tech rdfs:label ?techLabel .
    
    # Remote query to DBpedia
    SERVICE <http://dbpedia.org/sparql> {
        ?dbpediaTech rdfs:label ?techLabel@en ;
                     dbo:abstract ?abstract .
        FILTER(LANG(?abstract) = "en")
    }
}
LIMIT 5
```

📁 **Try it**: `examples/09-advanced/federation.sparql`

**Note**: Requires network access. May fail if DBpedia is unavailable.

### 14.5 Complex Pattern Example

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?adr ?label ?tech ?status 
       ?hasHighConfidence ?hasSystemContext
WHERE {
    VALUES ?targetStatus { :Accepted :Proposed }
    
    ?adr a :ADR ;
         rdfs:label ?label ;
         :decidesTechnology ?tech ;
         :hasStatus ?targetStatus .
    
    ?targetStatus rdfs:label ?status .
    
    OPTIONAL { ?adr :hasConfidence ?conf }
    OPTIONAL { ?adr :appliesTo ?system }
    
    BIND(COALESCE(?conf >= 0.9, false) AS ?hasHighConfidence)
    BIND(BOUND(?system) AS ?hasSystemContext)
}
ORDER BY ?status DESC(?hasHighConfidence)
```

📁 **Try it**: `examples/09-advanced/complex-patterns.sparql`

---

## 15. SPARQL vs SQL Comparison

### 15.1 Feature Comparison

| Capability | SQL | SPARQL | SPARQL Advantage |
|------------|-----|--------|------------------|
| **Basic queries** | SELECT + WHERE | SELECT + WHERE | Similar |
| **Joins** | Explicit JOIN | Implicit via patterns | Less verbose |
| **Missing data** | NULL + COALESCE | OPTIONAL | More natural |
| **Graph traversal** | Recursive CTE (10+ lines) | Property paths (1 line) | Much simpler |
| **Metadata on facts** | Separate tables | Reification/RDF-star | Native support |
| **Multiple types** | Junction tables | Direct multi-typing | No schema changes |
| **Schema evolution** | ALTER TABLE + migrations | Just add triples | No migrations |
| **Automatic inference** | Triggers/procedures | RDFS/OWL reasoning | Declarative |
| **Data validation** | CHECK + triggers | SHACL | Declarative |
| **Provenance** | Separate audit tables | Named graphs | Built-in |
| **Graph generation** | CREATE VIEW (limited) | CONSTRUCT | Flexible |

### 15.2 Query Comparison: Transitive Closure

**SPARQL (1 line):**
```sparql
SELECT ?dep WHERE { :Kubernetes :dependsOn+ ?dep }
```

**SQL (15+ lines):**
```sql
WITH RECURSIVE deps AS (
  SELECT tech_id, depends_on_id, 1 as level, 
         ARRAY[tech_id] as path
  FROM dependencies 
  WHERE tech_id = 'kubernetes'
  
  UNION ALL
  
  SELECT d.tech_id, d.depends_on_id, deps.level + 1,
         deps.path || d.tech_id
  FROM dependencies d 
  JOIN deps ON deps.depends_on_id = d.tech_id
  WHERE deps.level < 10
    AND NOT (d.tech_id = ANY(deps.path))
)
SELECT DISTINCT depends_on_id 
FROM deps;
```

### 15.3 When to Use RDF/SPARQL

**Best suited for:**
- Knowledge graphs and semantic data
- Data integration from heterogeneous sources
- Flexible, evolving schemas
- Complex relationships and graph navigation
- Reasoning and inference requirements
- Provenance and audit trails
- Metadata-heavy domains

**Consider alternatives when:**
- Fixed schema with high write throughput
- Simple CRUD operations
- Strict ACID requirements
- Team has no RDF experience

---

## 16. Exercises

### Exercise 1: Basic Queries

1. **List all technologies** with their labels
2. **Count ADRs by confidence level** (high: ≥0.9, medium: 0.7-0.9, low: <0.7)
3. **Find all teams** that own ADRs

<details>
<summary>Solution 1.1</summary>

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?tech ?label
WHERE {
    ?tech a :Technology ;
          rdfs:label ?label .
}
ORDER BY ?label
```
</details>

<details>
<summary>Solution 1.2</summary>

```sparql
PREFIX : <http://example.org/adr#>

SELECT ?level (COUNT(?adr) AS ?count)
WHERE {
    ?adr a :ADR ;
         :hasConfidence ?conf .
    
    BIND(
        IF(?conf >= 0.9, "High",
        IF(?conf >= 0.7, "Medium", "Low"))
        AS ?level
    )
}
GROUP BY ?level
ORDER BY ?level
```
</details>

### Exercise 2: Graph Navigation

1. **Find all technologies that PostgreSQL depends on** (direct and indirect)
2. **Find technologies that depend on Linux** (reverse traversal)
3. **Build a dependency chain** showing level depth

<details>
<summary>Solution 2.1</summary>

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?dep ?depLabel
WHERE {
    :PostgreSQL :dependsOn+ ?dep .
    OPTIONAL { ?dep rdfs:label ?depLabel }
}
```
</details>

### Exercise 3: Provenance Analysis

1. **Find ADRs that appear in exactly 2 sources**
2. **Compare confidence levels** between adr-registry and confluence
3. **Identify the most reliable source** (highest average confidence)

<details>
<summary>Solution 3.3</summary>

```sparql
PREFIX : <http://example.org/adr#>

SELECT ?source (AVG(?conf) AS ?avgConfidence) (COUNT(?adr) AS ?adrCount)
WHERE {
    GRAPH ?source {
        ?adr a :ADR ;
             :hasConfidence ?conf .
    }
}
GROUP BY ?source
ORDER BY DESC(?avgConfidence)
```
</details>

### Exercise 4: Reification

1. **Find decisions made by specific architect** (e.g., Ivan Petrov)
2. **List all decisions** with their rationale
3. **Find decisions with unanimous voting**

<details>
<summary>Solution 4.1</summary>

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?adrLabel ?technology ?date ?confidence
WHERE {
    ?stmt a rdf:Statement ;
          rdf:subject ?adr ;
          rdf:predicate :decidesTechnology ;
          rdf:object ?tech ;
          :statedBy :person_IvanPetrov ;
          :statedOn ?date ;
          :confidence ?confidence .
    
    ?adr rdfs:label ?adrLabel .
    ?tech rdfs:label ?technology .
}
ORDER BY ?date
```
</details>

### Exercise 5: CONSTRUCT Challenge

1. **Create a simplified ADR graph** with only label, technology name, and status name
2. **Generate a "risk report" graph** marking ADRs as :HighRisk or :LowRisk based on confidence
3. **Build an architect expertise graph** connecting architects to technologies they've decided on

<details>
<summary>Solution 5.2</summary>

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

CONSTRUCT {
    ?adr :riskLevel ?riskCategory ;
         rdfs:label ?label ;
         :hasConfidence ?conf .
}
WHERE {
    ?adr a :ADR ;
         rdfs:label ?label ;
         :hasConfidence ?conf .
    
    BIND(IF(?conf >= 0.8, :LowRisk, :HighRisk) AS ?riskCategory)
}
```
</details>

---

## 17. Further Reading

### Official Specifications

- [SPARQL 1.1 Query Language](https://www.w3.org/TR/sparql11-query/) — W3C Recommendation
- [RDF 1.1 Concepts](https://www.w3.org/TR/rdf11-concepts/) — W3C Recommendation
- [RDFS 1.1](https://www.w3.org/TR/rdf-schema/) — RDF Schema
- [OWL 2 Overview](https://www.w3.org/TR/owl2-overview/) — Web Ontology Language
- [SHACL](https://www.w3.org/TR/shacl/) — Shapes Constraint Language
- [RDF-star](https://www.w3.org/2021/12/rdf-star.html) — Statement-level metadata

### Books

- *Learning SPARQL* by Bob DuCharme — Excellent introduction
- *Semantic Web for the Working Ontologist* by Allemang & Hendler — Comprehensive coverage
- *Validating RDF Data* by Labra Gayo et al. — SHACL and ShEx

### Online Resources

- [GraphDB Documentation](https://graphdb.ontotext.com/documentation/)
- [SPARQL Tutorial (Apache Jena)](https://jena.apache.org/tutorials/sparql.html)
- [Wikidata Query Service](https://query.wikidata.org/) — Practice with real data
- [DBpedia SPARQL Endpoint](http://dbpedia.org/sparql) — Structured Wikipedia data

### Related Project Files

| File | Description |
|------|-------------|
| [DATASET.md](DATASET.md) | Detailed dataset description |
| [EXAMPLES.md](EXAMPLES.md) | Complete examples catalog |
| [SPARQL-CHEATSHEET.md](SPARQL-CHEATSHEET.md) | Quick reference |
| [QUICKSTART.md](QUICKSTART.md) | Step-by-step tutorial |

---

## Summary

Congratulations! You've completed the SPARQL Learning Guide. Here's what you've mastered:

| Topic | Key Takeaway |
|-------|--------------|
| **RDF Basics** | Data as triples forming a graph |
| **SPARQL Queries** | Pattern matching over graph structures |
| **Filtering** | FILTER, FILTER NOT EXISTS, BOUND |
| **Aggregation** | COUNT, AVG, GROUP BY, HAVING |
| **Named Graphs** | Built-in provenance and data partitioning |
| **Property Paths** | Declarative graph traversal (`+`, `*`, `^`, `/`, `\|`) |
| **Reification** | Metadata about statements |
| **RDF-star** | Modern, concise statement annotation |
| **Reasoning** | Automatic inference via RDFS/OWL |
| **SHACL** | Declarative data validation |
| **CONSTRUCT** | Graph-to-graph transformation |

### Key Insight

RDF/SPARQL represents a **fundamentally different paradigm** from relational databases:

- **Graph-native**: Relationships are first-class citizens
- **Schema-flexible**: Evolve without migrations
- **Inference-capable**: Derive new knowledge automatically
- **Provenance-aware**: Track data sources natively
- **Open World**: Absence of data means unknown, not false

---

**Happy querying!** 🚀

Start exploring: `./start.sh`
