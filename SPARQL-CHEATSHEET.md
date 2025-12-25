# Краткий справочник по SPARQL

Быстрый поиск синтаксиса SPARQL и распространённых паттернов.

---

## Структура запроса

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?variable1 ?variable2
WHERE {
    # Поиск паттернов здесь
    ?subject :predicate ?object .
}
ORDER BY ?variable1
LIMIT 10
```

---

## SELECT-клаузы

| Клауза | Назначение | Пример |
|--------|------------|--------|
| `SELECT *` | Все переменные | `SELECT *` |
| `SELECT ?var` | Конкретная переменная | `SELECT ?adr ?label` |
| `SELECT DISTINCT` | Уникальные результаты | `SELECT DISTINCT ?tech` |
| `SELECT (COUNT(*) as ?count)` | Агрегация | Подсчёт результатов |

---

## Паттерны триплетов

### Базовый паттерн
```sparql
?subject :predicate :Object .
```

### Связывание (один субъект)
```sparql
?adr a :ADR ;
     :hasStatus :Accepted ;
     rdfs:label ?label .
```

### Множественные паттерны
```sparql
?adr :decidesTechnology ?tech .
?tech rdfs:label ?label .
```

---

## OPTIONAL (Обработка отсутствующих данных)

```sparql
?adr :decidesTechnology ?tech .

OPTIONAL {
    ?adr :appliesTo ?system .
}
```

**Используется когда**: У некоторых сущностей может не быть свойства

---

## FILTER

### Сравнения
```sparql
FILTER(?confidence >= 0.90)
FILTER(?status = :Accepted)
FILTER(?status != :Deprecated)
```

### Логические операторы
```sparql
FILTER(?confidence >= 0.80 && ?status = :Accepted)
FILTER(?status = :Proposed || ?status = :Deprecated)
FILTER(!BOUND(?system))  # Проверка, что переменная не связана
```

### Поиск по строке
```sparql
FILTER(CONTAINS(?label, "Kafka"))
FILTER(REGEX(?label, "^ADR", "i"))  # Регистронезависимый
```

---

## FILTER NOT EXISTS (Поиск отсутствия)

```sparql
# Найти ADR без контекста системы
?adr a :ADR .

FILTER NOT EXISTS {
    ?adr :appliesTo ?system .
}
```

**Используется когда**: Нужно найти то, чего НЕТ в графе

---

## Named Graphs (Именованные графы)

### Запрос к конкретному графу
```sparql
GRAPH :adr-registry {
    ?adr a :ADR .
}
```

### Переменный граф (захват источника)
```sparql
GRAPH ?source {
    ?adr a :ADR .
}
```

### Несколько графов
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

## Агрегация

| Функция | Назначение | Пример |
|---------|------------|--------|
| `COUNT` | Подсчёт результатов | `COUNT(?adr)` |
| `COUNT(DISTINCT ?var)` | Подсчёт уникальных | `COUNT(DISTINCT ?tech)` |
| `AVG` | Среднее | `AVG(?confidence)` |
| `SUM` | Сумма | `SUM(?amount)` |
| `MIN` / `MAX` | Минимум/Максимум | `MAX(?confidence)` |
| `GROUP_CONCAT` | Конкатенация | `GROUP_CONCAT(?label; separator=", ")` |

### GROUP BY
```sparql
SELECT ?tech (COUNT(?adr) AS ?count)
WHERE {
    ?adr :decidesTechnology ?tech .
}
GROUP BY ?tech
ORDER BY DESC(?count)
```

### HAVING (Фильтр после группировки)
```sparql
SELECT ?adr (COUNT(?source) AS ?sourceCount)
WHERE {
    GRAPH ?source { ?adr a :ADR }
}
GROUP BY ?adr
HAVING (?sourceCount > 1)
```

---

## Сортировка и ограничения

```sparql
ORDER BY ?variable           # По возрастанию
ORDER BY DESC(?variable)     # По убыванию
ORDER BY ?var1 DESC(?var2)   # Несколько полей

LIMIT 10                     # Первые 10 результатов
OFFSET 20                    # Пропустить первые 20
```

---

## Распространённые паттерны

### Подсчёт всех объектов типа
```sparql
SELECT (COUNT(?adr) AS ?count)
WHERE {
    ?adr a :ADR .
}
```

### Получение с опциональной информацией
```sparql
?adr a :ADR ;
     rdfs:label ?label .

OPTIONAL { ?adr :hasConfidence ?conf }
OPTIONAL { ?adr :appliesTo ?system }
```

### Поиск по нескольким критериям
```sparql
?adr :hasStatus :Accepted ;
     :hasConfidence ?conf .

FILTER(?conf >= 0.80)
```

### Ранжирование по баллам
```sparql
SELECT ?tech (COUNT(?adr) * AVG(?conf) AS ?score)
WHERE {
    ?adr :decidesTechnology ?tech ;
         :hasConfidence ?conf .
}
GROUP BY ?tech
ORDER BY DESC(?score)
```

### Поиск того, чего НЕТ
```sparql
?system a :System .

FILTER NOT EXISTS {
    ?adr :appliesTo ?system .
}
```

### Следование связям
```sparql
?newADR :supersedes ?oldADR .
?oldADR :decidesTechnology ?oldTech .
?newADR :decidesTechnology ?newTech .
```

---

## Префиксы (Наш датасет)

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
```

---

## Наши классы

- `:ADR` — Architecture Decision Record (запись архитектурного решения)
- `:System` — Программная система
- `:Technology` — Технология/инструмент
- `:Team` — Команда разработки
- `:Status` — Статус ADR

---

## Наши свойства

| Свойство | От | К | Значение |
|----------|-----|-----|----------|
| `:decidesTechnology` | ADR | Technology | ADR выбирает технологию |
| `:appliesTo` | ADR | System | ADR применяется к системе |
| `:uses` | System | Technology | Система использует технологию |
| `:supersedes` | ADR | ADR | Новый ADR заменяет старый |
| `:ownedBy` | ADR/System | Team | Владение |
| `:hasStatus` | ADR | Status | Текущий статус |
| `:hasConfidence` | ADR | decimal | Уровень уверенности (0-1) |

---

## Наши именованные графы

- `:adr-registry` — Официальный реестр ADR (высшее качество)
- `:confluence` — Документация Confluence
- `:confluence-metadata` — Метаданные из Confluence
- `:decision-metadata` — Метаданные о решениях
- `:decision-timeline` — Временная шкала решений
- `:interview-notes` — Заметки интервью (низшее качество)
- `:people` — Профили архитекторов и команд

---

## Частые ошибки

### Отсутствующая точка
```sparql
# Неправильно
?adr a :ADR
?adr rdfs:label ?label

# Правильно
?adr a :ADR .
?adr rdfs:label ?label .
```

### Неправильный PREFIX
```sparql
# Неправильно - отсутствует двоеточие
PREFIX adr <http://example.org/adr#>

# Правильно
PREFIX : <http://example.org/adr#>
```

### FILTER не на месте
```sparql
# Неправильно - FILTER перед паттерном
WHERE {
    FILTER(?conf >= 0.90)
    ?adr :hasConfidence ?conf .
}

# Правильно - FILTER после паттерна
WHERE {
    ?adr :hasConfidence ?conf .
    FILTER(?conf >= 0.90)
}
```

### Забыли DISTINCT
```sparql
# Возвращает дубликаты
SELECT ?tech WHERE { ?adr :decidesTechnology ?tech }

# Возвращает уникальные
SELECT DISTINCT ?tech WHERE { ?adr :decidesTechnology ?tech }
```

---

## SPARQL vs SQL

| SPARQL | SQL | Значение |
|--------|-----|----------|
| `?variable` | имя столбца | Переменная/заполнитель |
| Паттерн триплета | JOIN | Связывание таблиц/сущностей |
| `OPTIONAL` | LEFT JOIN | Опциональные данные |
| `FILTER` | WHERE | Фильтрация результатов |
| `FILTER NOT EXISTS` | NOT EXISTS подзапрос | Проверка отсутствия |
| `GRAPH` | База данных/схема | Раздел данных |
| `.` | Конец выражения | Разделитель паттернов |

**Ключевое отличие**: SPARQL сопоставляет **паттерны в графах**, SQL запрашивает **таблицы со строками**.

---

## Быстрые советы

✅ **Начинайте просто**: Сначала базовый паттерн, затем добавляйте сложность  
✅ **Используйте OPTIONAL**: Для неполных данных (Open World Assumption)  
✅ **Проверяйте BOUND()**: Чтобы узнать, сопоставились ли опциональные переменные  
✅ **FILTER после паттерна**: Определяйте переменные перед фильтрацией  
✅ **Используйте DISTINCT**: Для уникальных результатов  
✅ **Именуйте агрегации**: `(COUNT(?x) AS ?count)` а не просто `COUNT(?x)`  

❌ **Не предполагайте логику SQL**: Графы работают иначе  
❌ **Не забывайте префиксы**: Они нужны для сокращённой записи  
❌ **Не усложняйте**: Простые паттерны часто работают лучше  

---

## Шаблон запроса

```sparql
PREFIX : <http://example.org/adr#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

# Описание того, что делает запрос

SELECT ?result1 ?result2
WHERE {
    # Обязательные паттерны
    ?entity a :Type ;
            :property ?value .
    
    # Опциональные паттерны
    OPTIONAL {
        ?entity :optionalProperty ?optional .
    }
    
    # Фильтры
    FILTER(?value >= threshold)
}
ORDER BY ?result1
LIMIT 100
```

---

**Нужна дополнительная помощь?** Смотрите [EXAMPLES.md](EXAMPLES.md) с рабочими примерами!
