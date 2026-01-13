# 📊 Dataset Description

**Synthetic ADR (Architecture Decision Records)** — a demonstration dataset showcasing RDF/SPARQL capabilities.

---

## 🎯 Dataset Contents

Models **architectural knowledge within a technology organization**:

| Data Type | Quantity | Description |
|-----------|----------|-------------|
| **ADRs** | 8 decisions | Architectural decisions about technologies |
| **Technologies** | 7 | Kafka, PostgreSQL, MongoDB, Redis, Kubernetes, Docker, etcd |
| **Systems** | 5 services | OrderService, PaymentService, AnalyticsService, etc. |
| **Architects** | 5 people | With profiles, roles, and expertise |
| **Named Graphs** | 7 sources | Different knowledge sources with provenance and metadata |
| **Dependencies** | 20+ links | Transitive technology dependencies |
| **Reification** | 8 statements | Metadata about WHO made decision and WHEN |

---

## 📁 File Structure

Dataset consists of **6 RDF files** that must be loaded **in strict order**:

### 1. `prefixes.ttl` — Prefixes
Defines common prefixes for all files.

```turtle
@prefix : <http://example.org/adr#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
```

---

### 2. `adr-core.ttl` — Core Concepts
Defines project vocabulary: classes and properties.

**Classes:**
- `:ADR` — Architecture Decision Record
- `:System` — Software system/service
- `:Technology` — Technology (Kafka, PostgreSQL, etc.)
- `:Team` — Development team
- `:Person` — Person (architect)

**Properties:**
- `:decidesTechnology` — ADR decides to use technology
- `:appliesTo` — ADR applies to system
- `:uses` — System uses technology
- `:supersedes` — ADR replaces another ADR
- `:ownedBy` — Owner (team)
- `:hasStatus` — Decision status (Accepted, Deprecated, etc.)
- `:hasConfidence` — Decision confidence (0.0-1.0)

**Example:**
```turtle
:ADR a rdfs:Class ;
    rdfs:label "Architecture Decision Record" .

:decidesTechnology a rdf:Property ;
    rdfs:label "decides on technology" ;
    rdfs:domain :ADR ;
    rdfs:range :Technology .
```

---

### 3. `adr-ontology.ttl` — Ontology (RDFS/OWL)

🔥 **Enables Reasoning** — automatic inference of new facts

Defines:
- **Class hierarchy** (subClassOf)
- **Property hierarchy** (subPropertyOf)
- **Transitive properties**
- **Inverse properties** (inverseOf)

**Example class hierarchy:**
```turtle
:ArchitecturalDecision rdfs:subClassOf :Decision .
:TechnicalDecision rdfs:subClassOf :ArchitecturalDecision .
:DatabaseDecision rdfs:subClassOf :TechnicalDecision .
:InfrastructureDecision rdfs:subClassOf :TechnicalDecision .
```

**Example property hierarchy:**
```turtle
:usesMicroservices rdfs:subPropertyOf :requiresOrchestration .
:requiresOrchestration rdfs:subPropertyOf :requiresInfrastructure .
```

Queries for infrastructure requirements automatically include microservices.

**Technology hierarchy:**
```turtle
:Technology rdfs:subClassOf rdfs:Resource .
:Database rdfs:subClassOf :Technology .
:RelationalDatabase rdfs:subClassOf :Database .
:NoSQLDatabase rdfs:subClassOf :Database .
:MessageBroker rdfs:subClassOf :Technology .
:ContainerOrchestrator rdfs:subClassOf :Technology .
```

---

### 4. `technology-dependencies.ttl` — Technology Dependencies

🔥 **Demonstrates Property Paths** — native graph navigation without recursion

Defines transitive dependencies between technologies.

**Dependency examples:**
```turtle
:Kafka :dependsOn :Java ;
       :dependsOn :Zookeeper .

:Kubernetes :dependsOn :Docker ;
            :dependsOn :etcd .

:Docker :dependsOn :Linux ;
        :dependsOn :ContainerRuntime .

:PostgreSQL :dependsOn :Linux ;
            :dependsOn :FileSystem .
```

**Transitive chain:**
```
Kubernetes → Docker → Linux → Kernel
Kubernetes → etcd → Go
```

With SPARQL you can find **all** dependencies with one query:
```sparql
SELECT ?dep WHERE {
    :Kubernetes :dependsOn+ ?dep
}
```

SQL equivalent requires recursive CTEs (20+ lines).

---

### 5. `adr-provenance.trig` — Named Graphs with Provenance

🔥 **Demonstrates Named Graphs** — native data provenance support

Data is divided by **knowledge sources** (named graphs):

#### Named Graph: `:adr-registry` 
**Official ADR registry** (high quality)

```turtle
:adr-registry {
    :ADR-001 a :ADR ;
        rdfs:label "Use Kafka for Event Streaming in Order Processing" ;
        :decidesTechnology :Kafka ;
        :appliesTo :OrderService ;
        :hasStatus :Accepted ;
        :hasConfidence "0.95"^^xsd:decimal ;
        :ownedBy :TeamCheckout .
}
```

#### Named Graph: `:confluence`
**Confluence documentation** (medium quality)

```turtle
:confluence {
    :ADR-003 a :ADR ;
        rdfs:label "Use Kafka for Real-time Analytics Pipeline" ;
        :decidesTechnology :Kafka ;
        :appliesTo :AnalyticsService ;
        :hasStatus :Accepted ;
        :hasConfidence "0.88"^^xsd:decimal .
}
```

#### Named Graph: `:interview-notes`
**Interview notes** (low quality, incomplete data)

```turtle
:interview-notes {
    :ADR-006 a :ADR ;
        rdfs:label "Consider Redis for Session Storage" ;
        :decidesTechnology :Redis ;
        :hasStatus :Proposed ;
        :hasConfidence "0.60"^^xsd:decimal .
    # Note: no :appliesTo - incomplete information
}
```

**Query by source:**
```sparql
SELECT ?adr ?label WHERE {
    GRAPH :adr-registry {
        ?adr a :ADR ;
             rdfs:label ?label .
    }
}
```

---

### 6. `adr-people-reified.trig` — Reification with Metadata

🔥 **Demonstrates Reification** — metadata about triples

This file contains:
1. **Architect profiles** (in named graph `:people`)
2. **Reified statements** about decisions (WHO decided, WHEN, with what CONFIDENCE)

#### Architect Profiles

```turtle
GRAPH :people {
    :person_IvanPetrov a :Person ;
        rdfs:label "Ivan Petrov" ;
        :fullName "Petrov Ivan Alexandrovich" ;
        :role :LeadArchitect ;
        :team :TeamPlatform ;
        :email "ivan.petrov@company.com" ;
        :expertise ( :Microservices :EventDriven :Kafka :Kubernetes ) ;
        :yearsOfExperience 12 .

    :person_MariaSidorova a :Person ;
        rdfs:label "Maria Sidorova" ;
        :role :DataArchitect ;
        :team :TeamData ;
        :expertise ( :Databases :DataModeling :PostgreSQL :Analytics ) ;
        :yearsOfExperience 10 .
    
    # ... 3 more architects
}
```

#### Reified Statements

Reification allows storing metadata **about a triple**:

```turtle
:statement_001 a rdf:Statement ;
    # Base triple:
    rdf:subject :ADR-001 ;
    rdf:predicate :decidesTechnology ;
    rdf:object :Kafka ;
    
    # Metadata about the triple:
    :statedBy :person_IvanPetrov ;
    :statedOn "2024-12-15"^^xsd:date ;
    :confidence "0.95"^^xsd:decimal ;
    :decisionRationale "Need reliable event streaming for order processing" ;
    :evidenceSource :KafkaBenchmark ;
    :votingResult :Unanimous .
```

**Reification query:**
```sparql
SELECT ?adr ?tech ?person ?date ?confidence WHERE {
    ?stmt a rdf:Statement ;
          rdf:subject ?adr ;
          rdf:predicate :decidesTechnology ;
          rdf:object ?tech ;
          :statedBy ?person ;
          :statedOn ?date ;
          :confidence ?confidence .
    
    ?person rdfs:label ?personName .
}
```

Result: Who made which decision, when, and with what confidence.

SQL requires separate `statement_metadata` tables with multiple JOINs.

---

## 📈 Dataset Statistics

### Triples by File

| File | Approx. Triples | Main Content |
|------|----------------|--------------|
| `prefixes.ttl` | ~5 | Prefix definitions |
| `adr-core.ttl` | ~150 | Vocabulary + 8 ADRs + systems + teams |
| `adr-ontology.ttl` | ~80 | Class and property hierarchy |
| `technology-dependencies.ttl` | ~100 | Technologies + dependencies |
| `adr-provenance.trig` | ~60 | 8 ADRs in 4 named graphs |
| `adr-people-reified.trig` | ~150 | 5 architects + 8 reifications |
| **TOTAL** | **~545** | **Complete dataset** |

### Entities

| Type | Quantity | Examples |
|------|----------|----------|
| **ADRs** | 8 | ADR-001, ADR-002, ..., ADR-008 |
| **Systems** | 5 | OrderService, PaymentService, AnalyticsService, NotificationService, InventoryService |
| **Technologies** | 7 | Kafka, PostgreSQL, MongoDB, Redis, Kubernetes, Docker, etcd |
| **Teams** | 5 | TeamCheckout, TeamPayments, TeamData, TeamPlatform, Security |
| **Architects** | 5 | Ivan Petrov, Maria Sidorova, Alexey Kozlov, Elena Nikitina, Dmitry Volkov |
| **Named Graphs** | 7 | adr-registry, confluence, confluence-metadata, decision-metadata, decision-timeline, interview-notes, people |
| **Reifications** | 8 | statement_001, ..., statement_008 |

### Properties (relationships)

- `:decidesTechnology` — 8 links (ADR → Technology)
- `:appliesTo` — 6 links (ADR → System)
- `:dependsOn` — 20+ links (Technology → Technology)
- `:ownedBy` — 8 links (ADR → Team)
- `:supersedes` — 2 links (ADR → ADR)
- `:statedBy` — 8 links (Statement → Person)

---

## 🎓 Educational Scenarios

The dataset demonstrates:

### 1. Property Paths
```sparql
# Find ALL transitive dependencies of Kubernetes
SELECT ?dep WHERE {
    :Kubernetes :dependsOn+ ?dep
}
```

### 2. Named Graphs (provenance)
```sparql
# Find ADRs only from official registry
SELECT ?adr ?label WHERE {
    GRAPH :adr-registry {
        ?adr a :ADR ;
             rdfs:label ?label .
    }
}
```

### 3. Reification (metadata about facts)
```sparql
# Who decided on Kafka?
SELECT ?person ?date ?confidence WHERE {
    ?stmt rdf:subject :ADR-001 ;
          rdf:predicate :decidesTechnology ;
          rdf:object :Kafka ;
          :statedBy ?person ;
          :statedOn ?date ;
          :confidence ?confidence .
}
```

### 4. Reasoning (automatic inference)
```sparql
# Find ALL infrastructure requirements
# (including microservices through property hierarchy)
SELECT ?adr ?requirement WHERE {
    ?adr :requiresInfrastructure ?requirement .
}
```

### 5. CONSTRUCT (generating new graphs)
```sparql
# Create simplified graph: System → uses → Technology
CONSTRUCT {
    ?system :uses ?tech .
} WHERE {
    ?adr :appliesTo ?system ;
         :decidesTechnology ?tech .
}
```

### 6. Aggregation and Analysis
```sparql
# Technology popularity
SELECT ?tech (COUNT(?adr) as ?count) WHERE {
    ?adr :decidesTechnology ?tech .
}
GROUP BY ?tech
ORDER BY DESC(?count)
```

### 7. Multi-source
```sparql
# Find ADRs that exist in multiple sources
SELECT ?adr (COUNT(DISTINCT ?source) as ?sourceCount) WHERE {
    GRAPH ?source {
        ?adr a :ADR .
    }
}
GROUP BY ?adr
HAVING (?sourceCount > 1)
```

---

## 🔍 Interesting Patterns in Dataset

### Multiple Decisions about One Technology
Kafka is used in **3 different ADRs**:
- ADR-001: Event streaming for orders
- ADR-003: Real-time analytics
- ADR-004: Notification pipeline

### Replacement Chains (supersedes)
```
ADR-008 (Redis) supersedes ADR-004 (Kafka for notifications)
```

### Incomplete Data
ADR-006 and ADR-007 don't have `:appliesTo` — demonstrates Open World Assumption.

### Different Confidence
- High (0.95+): ADR-001, ADR-007
- Medium (0.85-0.92): ADR-002, ADR-003
- Low (0.60-0.75): ADR-006, ADR-008

---

## 💡 Extending the Dataset

Dataset can be easily extended:

1. **Add new ADRs** in `adr-provenance.trig`
2. **Add technologies** in `technology-dependencies.ttl`
3. **Add architects** in `adr-people-reified.trig`
4. **Add new sources** (named graphs)
5. **Enrich ontology** in `adr-ontology.ttl`

---

## 📚 Related Files

- **[README.md](README.md)** — project overview
- **[QUICKSTART.md](QUICKSTART.md)** — quick start
- **[EXAMPLES.md](EXAMPLES.md)** — query examples catalog
- **[examples/](examples/)** — 32 SPARQL queries for working with dataset

---