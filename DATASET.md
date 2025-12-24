# 📊 Описание Dataset

**Synthetic ADR (Architecture Decision Records)** — синтетический датасет, созданный для демонстрации уникальных возможностей RDF/SPARQL.

---

## 🎯 Что внутри?

Датасет моделирует **архитектурное знание технологической компании**:

| Тип данных | Количество | Описание |
|------------|------------|----------|
| **ADR** | 8 решений | Архитектурные решения о технологиях |
| **Технологии** | 15+ | Kafka, PostgreSQL, Kubernetes, Docker и др. |
| **Системы** | 5 сервисов | OrderService, PaymentService, AnalyticsService и др. |
| **Архитекторы** | 5 человек | С профилями, ролями и экспертизой |
| **Named Graphs** | 4 источника | Разные источники знаний с провенансом |
| **Зависимости** | 20+ связей | Транзитивные зависимости технологий |
| **Реификация** | 8 утверждений | Метаданные о том, КТО принял решение и КОГДА |

---

## 📁 Структура файлов

Dataset состоит из **6 RDF файлов**, которые должны загружаться **в строгом порядке**:

### 1. `prefixes.ttl` — Префиксы
Определяет общие префиксы для всех файлов.

```turtle
@prefix : <http://example.org/adr#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
```

---

### 2. `adr-core.ttl` — Базовые концепции
Определяет словарь (vocabulary) проекта: классы и свойства.

**Классы:**
- `:ADR` — Architecture Decision Record
- `:System` — Программная система/сервис
- `:Technology` — Технология (Kafka, PostgreSQL, etc.)
- `:Team` — Команда разработки
- `:Person` — Человек (архитектор)

**Свойства:**
- `:decidesTechnology` — ADR решает использовать технологию
- `:appliesTo` — ADR применяется к системе
- `:uses` — Система использует технологию
- `:supersedes` — ADR заменяет другой ADR
- `:ownedBy` — Владелец (команда)
- `:hasStatus` — Статус решения (Accepted, Deprecated, etc.)
- `:hasConfidence` — Уверенность в решении (0.0-1.0)

**Пример:**
```turtle
:ADR a rdfs:Class ;
    rdfs:label "Architecture Decision Record" .

:decidesTechnology a rdf:Property ;
    rdfs:label "decides on technology" ;
    rdfs:domain :ADR ;
    rdfs:range :Technology .
```

---

### 3. `adr-ontology.ttl` — Онтология (RDFS/OWL)

🔥 **Демонстрирует Reasoning** — автоматический вывод новых фактов!

Определяет:
- **Иерархию классов** (subClassOf)
- **Иерархию свойств** (subPropertyOf)
- **Транзитивные свойства**
- **Обратные свойства** (inverseOf)

**Пример иерархии классов:**
```turtle
:ArchitecturalDecision rdfs:subClassOf :Decision .
:TechnicalDecision rdfs:subClassOf :ArchitecturalDecision .
:DatabaseDecision rdfs:subClassOf :TechnicalDecision .
:InfrastructureDecision rdfs:subClassOf :TechnicalDecision .
```

**Пример иерархии свойств:**
```turtle
:usesMicroservices rdfs:subPropertyOf :requiresOrchestration .
:requiresOrchestration rdfs:subPropertyOf :requiresInfrastructure .
```

Теперь запрос "покажи инфраструктурные требования" **автоматически** включает микросервисы!

**Иерархия технологий:**
```turtle
:Technology rdfs:subClassOf rdfs:Resource .
:Database rdfs:subClassOf :Technology .
:RelationalDatabase rdfs:subClassOf :Database .
:NoSQLDatabase rdfs:subClassOf :Database .
:MessageBroker rdfs:subClassOf :Technology .
:ContainerOrchestrator rdfs:subClassOf :Technology .
```

---

### 4. `technology-dependencies.ttl` — Зависимости технологий

🔥 **Демонстрирует Property Paths** — навигация по графу без рекурсии!

Определяет транзитивные зависимости между технологиями.

**Примеры зависимостей:**
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

**Транзитивная цепочка:**
```
Kubernetes → Docker → Linux → Kernel
Kubernetes → etcd → Go
```

С помощью SPARQL можно найти **все** зависимости одним запросом:
```sparql
SELECT ?dep WHERE {
    :Kubernetes :dependsOn+ ?dep
}
```

В SQL это потребовало бы рекурсивный CTE на 20+ строк!

---

### 5. `adr-provenance.trig` — Named Graphs с провенансом

🔥 **Демонстрирует Named Graphs** — встроенный провенанс данных!

Данные разделены по **источникам знаний** (named graphs):

#### Named Graph: `:adr-registry` 
**Официальный реестр ADR** (высокое качество)

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
**Confluence документация** (среднее качество)

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
**Заметки с интервью** (низкое качество, неполные данные)

```turtle
:interview-notes {
    :ADR-006 a :ADR ;
        rdfs:label "Consider Redis for Session Storage" ;
        :decidesTechnology :Redis ;
        :hasStatus :Proposed ;
        :hasConfidence "0.60"^^xsd:decimal .
    # Обратите внимание: нет :appliesTo - неполная информация!
}
```

**Запрос по источнику:**
```sparql
SELECT ?adr ?label WHERE {
    GRAPH :adr-registry {
        ?adr a :ADR ;
             rdfs:label ?label .
    }
}
```

---

### 6. `adr-people-reified.trig` — Реификация с метаданными

🔥 **Демонстрирует Reification** — метаданные О ФАКТАХ!

Этот файл содержит:
1. **Профили архитекторов** (в named graph `:people`)
2. **Реифицированные утверждения** о решениях (КТО принял, КОГДА, с какой УВЕРЕННОСТЬЮ)

#### Профили архитекторов

```turtle
GRAPH :people {
    :person_IvanPetrov a :Person ;
        rdfs:label "Иван Петров" ;
        :fullName "Петров Иван Александрович" ;
        :role :LeadArchitect ;
        :team :TeamPlatform ;
        :email "ivan.petrov@company.com" ;
        :expertise ( :Microservices :EventDriven :Kafka :Kubernetes ) ;
        :yearsOfExperience 12 .

    :person_MariaSidorova a :Person ;
        rdfs:label "Мария Сидорова" ;
        :role :DataArchitect ;
        :team :TeamData ;
        :expertise ( :Databases :DataModeling :PostgreSQL :Analytics ) ;
        :yearsOfExperience 10 .
    
    # ... ещё 3 архитектора
}
```

#### Реифицированные утверждения

Reification позволяет хранить метаданные **о триплете**:

```turtle
:statement_001 a rdf:Statement ;
    # Базовый триплет:
    rdf:subject :ADR-001 ;
    rdf:predicate :decidesTechnology ;
    rdf:object :Kafka ;
    
    # Метаданные О ТРИПЛЕТЕ:
    :statedBy :person_IvanPetrov ;
    :statedOn "2024-12-15"^^xsd:date ;
    :confidence "0.95"^^xsd:decimal ;
    :decisionRationale "Необходима надёжная потоковая обработка событий заказов" ;
    :evidenceSource :KafkaBenchmark ;
    :votingResult :Unanimous .
```

**Запрос реификации:**
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

Результат: КТО принял КАКОЕ решение, КОГДА и С КАКОЙ УВЕРЕННОСТЬЮ!

В SQL для этого нужна отдельная таблица `statement_metadata` с множественными JOIN'ами.

---

## 📈 Статистика датасета

### Триплеты по файлам

| Файл | Приблизительно триплетов | Основное содержание |
|------|---------------------------|---------------------|
| `prefixes.ttl` | ~5 | Определения префиксов |
| `adr-core.ttl` | ~150 | Vocabulary + 8 ADR + системы + команды |
| `adr-ontology.ttl` | ~80 | Иерархия классов и свойств |
| `technology-dependencies.ttl` | ~100 | Технологии + зависимости |
| `adr-provenance.trig` | ~60 | 8 ADR в 4 named graphs |
| `adr-people-reified.trig` | ~150 | 5 архитекторов + 8 реификаций |
| **ИТОГО** | **~545** | **Полный датасет** |

### Сущности

| Тип | Количество | Примеры |
|-----|------------|---------|
| **ADR** | 8 | ADR-001, ADR-002, ..., ADR-008 |
| **Системы** | 5 | OrderService, PaymentService, AnalyticsService, NotificationService, InventoryService |
| **Технологии** | 15+ | Kafka, PostgreSQL, MongoDB, Redis, Kubernetes, Docker, Linux, Java, Go, etcd, Zookeeper, Nginx, FileSystem, ContainerRuntime, Kernel |
| **Команды** | 5 | TeamCheckout, TeamPayments, TeamData, TeamPlatform, Security |
| **Архитекторы** | 5 | Иван Петров, Мария Сидорова, Алексей Козлов, Елена Никитина, Дмитрий Волков |
| **Named Graphs** | 4 | adr-registry, confluence, interview-notes, people |
| **Реификации** | 8 | statement_001, ..., statement_008 |

### Свойства (relationships)

- `:decidesTechnology` — 8 связей (ADR → Technology)
- `:appliesTo` — 6 связей (ADR → System)
- `:dependsOn` — 20+ связей (Technology → Technology)
- `:ownedBy` — 8 связей (ADR → Team)
- `:supersedes` — 2 связи (ADR → ADR)
- `:statedBy` — 8 связей (Statement → Person)

---

## 🎓 Учебные сценарии

Датасет позволяет продемонстрировать:

### 1. Property Paths
```sparql
# Найти ВСЕ транзитивные зависимости Kubernetes
SELECT ?dep WHERE {
    :Kubernetes :dependsOn+ ?dep
}
```

### 2. Named Graphs (провенанс)
```sparql
# Найти ADR только из официального реестра
SELECT ?adr ?label WHERE {
    GRAPH :adr-registry {
        ?adr a :ADR ;
             rdfs:label ?label .
    }
}
```

### 3. Reification (метаданные о фактах)
```sparql
# Кто принял решение о Kafka?
SELECT ?person ?date ?confidence WHERE {
    ?stmt rdf:subject :ADR-001 ;
          rdf:predicate :decidesTechnology ;
          rdf:object :Kafka ;
          :statedBy ?person ;
          :statedOn ?date ;
          :confidence ?confidence .
}
```

### 4. Reasoning (автоматический вывод)
```sparql
# Найти ВСЕ инфраструктурные требования
# (включая микросервисы через иерархию свойств)
SELECT ?adr ?requirement WHERE {
    ?adr :requiresInfrastructure ?requirement .
}
```

### 5. CONSTRUCT (генерация новых графов)
```sparql
# Создать упрощённый граф: System → uses → Technology
CONSTRUCT {
    ?system :uses ?tech .
} WHERE {
    ?adr :appliesTo ?system ;
         :decidesTechnology ?tech .
}
```

### 6. Агрегация и анализ
```sparql
# Популярность технологий
SELECT ?tech (COUNT(?adr) as ?count) WHERE {
    ?adr :decidesTechnology ?tech .
}
GROUP BY ?tech
ORDER BY DESC(?count)
```

### 7. Многоисточниковость
```sparql
# Найти ADR, которые есть в нескольких источниках
SELECT ?adr (COUNT(DISTINCT ?source) as ?sourceCount) WHERE {
    GRAPH ?source {
        ?adr a :ADR .
    }
}
GROUP BY ?adr
HAVING (?sourceCount > 1)
```

---

## 🔍 Интересные паттерны в датасете

### Множественные решения об одной технологии
Kafka используется в **3 разных ADR**:
- ADR-001: Event streaming для заказов
- ADR-003: Real-time analytics
- ADR-004: Notification pipeline

### Цепочки замен (supersedes)
```
ADR-008 (Redis) supersedes ADR-004 (Kafka для нотификаций)
```

### Неполные данные
ADR-006 и ADR-007 не имеют `:appliesTo` — демонстрирует Open World Assumption.

### Разная уверенность
- Высокая (0.95+): ADR-001, ADR-007
- Средняя (0.85-0.92): ADR-002, ADR-003
- Низкая (0.60-0.75): ADR-006, ADR-008

---

## 💡 Расширение датасета

Датасет можно легко расширить:

1. **Добавить новые ADR** в `adr-provenance.trig`
2. **Добавить технологии** в `technology-dependencies.ttl`
3. **Добавить архитекторов** в `adr-people-reified.trig`
4. **Добавить новые источники** (named graphs)
5. **Обогатить онтологию** в `adr-ontology.ttl`

---

## 📚 Связанные файлы

- **[README.md](README.md)** — обзор проекта
- **[QUICKSTART.md](QUICKSTART.md)** — быстрый старт
- **[EXAMPLES.md](EXAMPLES.md)** — каталог примеров запросов
- **[examples/](examples/)** — 32 SPARQL запроса для работы с датасетом

