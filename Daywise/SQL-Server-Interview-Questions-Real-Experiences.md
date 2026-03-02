# SQL Server Interview Questions - Real Experiences (Beginner to Expert)

Based on real interview experiences from **TCS, Infosys, Wipro, Accenture, Cognizant, Microsoft, Amazon, Google, Meta, Goldman Sachs, Morgan Stanley, and other top companies**.

---

## Table of Contents
0. [Structured Thinking Approach — How to Solve Any SQL Problem](#structured-thinking-approach--how-to-solve-any-sql-problem)
1. [Beginner Level](#beginner-level)
2. [Intermediate Level](#intermediate-level)
3. [Advanced Level](#advanced-level)
4. [Schema Design](#schema-design)
5. [Performance Tuning](#performance-tuning)
6. [Data Migration to Azure](#data-migration-to-azure)
7. [Scenario-Based Questions](#scenario-based-questions)
8. [Classic Must-Know SQL Problems](#classic-must-know-sql-problems)

---

## Structured Thinking Approach — How to Solve Any SQL Problem

> **Mental Model:** Treat every SQL problem like building a house.
> First read the blueprint (understand output), find the materials (identify tables),
> lay the foundation (joins/filters), assemble the floors (aggregation/windowing),
> then inspect for defects (edge cases, NULLs, performance).

---

### The 5-Step Framework

```
┌─────────────────────────────────────────────────────────────────────┐
│               5-STEP SQL PROBLEM SOLVING FRAMEWORK                  │
├──────┬──────────────────────────────────────────────────────────────┤
│ Step │ Action                                                        │
├──────┼──────────────────────────────────────────────────────────────┤
│  1   │ UNDERSTAND  — What is the expected output? (columns, rows)   │
│  2   │ IDENTIFY    — Which tables, columns, relationships needed?    │
│  3   │ DECOMPOSE   — Break complex logic into smaller sub-problems   │
│  4   │ CHOOSE      — Pick the best technique (see decision tree)     │
│  5   │ VALIDATE    — Check NULLs, duplicates, edge cases, perf      │
└──────┴──────────────────────────────────────────────────────────────┘
```

---

### Step 1 — UNDERSTAND: Read the Problem Like a Spec

Ask yourself and the interviewer these questions before writing a single line:

| Question | Why it matters |
|----------|----------------|
| What does one row of output represent? | Determines GROUP BY keys |
| Are duplicates expected or should I deduplicate? | Drives DISTINCT or ROW_NUMBER() |
| Is the result a count, a list, or a comparison? | Determines aggregation vs. filtering |
| What time range or filters apply? | WHERE clause scope |
| Are NULLs meaningful or should they be excluded? | NULL handling strategy |
| Does "top N" mean per group or overall? | Partitioned vs global ranking |

> **Key Insight:** Spending 60 seconds clarifying the problem is worth 10 minutes of re-writing a wrong query. Interviewers reward candidates who ask smart questions.

---

### Step 2 — IDENTIFY: Map Tables and Relationships

Before joining, sketch the data model mentally:

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   Orders     │ N ──1   │  Customers   │  1── N  │   Addresses  │
│  OrderId     │         │  CustomerId  │         │  AddressId   │
│  CustomerId  │◄────────│  Name        │────────►│  CustomerId  │
│  Amount      │         │  Region      │         │  City        │
│  OrderDate   │         └──────────────┘         └──────────────┘
└──────────────┘
        │ N
        │
        ▼ 1
┌──────────────┐
│  Products    │
│  ProductId   │
│  Category    │
└──────────────┘
```

**Checklist:**
- [ ] Which table is the "driver" (the one in FROM)?
- [ ] Which tables bring in lookup/dimension data (JOINs)?
- [ ] Are there bridge/junction tables for M:N relationships?
- [ ] Do I need all rows from a table or just matching ones? (LEFT vs INNER)

---

### Step 3 — DECOMPOSE: Break the Problem Into Layers

Complex problems are always composed of simpler primitives. Identify which layer(s) apply:

```
┌──────────────────────────────────────────────────────────────┐
│                    SQL QUERY LAYERS                          │
│                                                              │
│   Layer 4: FINAL SHAPE  (SELECT, ORDER BY, LIMIT/TOP)        │
│       ▲                                                      │
│   Layer 3: RANK / PIVOT / COMPARE  (Window Functions)        │
│       ▲                                                      │
│   Layer 2: AGGREGATE   (GROUP BY, HAVING, COUNT/SUM/AVG)     │
│       ▲                                                      │
│   Layer 1: FILTER + JOIN  (WHERE, JOINs, subqueries)         │
│       ▲                                                      │
│   Layer 0: RAW DATA    (FROM tables)                         │
└──────────────────────────────────────────────────────────────┘
```

**Rule:** Build from Layer 0 upward. Write (or mentally draft) each layer before writing the full query.

---

### Step 4 — CHOOSE: Decision Tree for SQL Techniques

```
                        SQL TECHNIQUE DECISION TREE

Is the problem about RANKING or COMPARISON within groups?
├── YES ──► Use WINDOW FUNCTIONS (ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD)
└── NO
    │
    Is there a HIERARCHY or RECURSIVE structure (org chart, BOM)?
    ├── YES ──► Use RECURSIVE CTE
    └── NO
        │
        Is the logic REUSED multiple times in the same query?
        ├── YES ──► Use CTE (WITH clause) — readability + reuse
        └── NO
            │
            Is it a ONE-TIME derived result used in FROM?
            ├── YES ──► Use DERIVED TABLE (subquery in FROM)
            └── NO
                │
                Is it a SCALAR value filter (single value comparison)?
                ├── YES ──► Use SUBQUERY in WHERE
                └── NO
                    │
                    Is it a SET membership check (IN / EXISTS)?
                    ├── YES ──► Use EXISTS (correlated) or IN
                    └── NO
                        │
                        Is it a PIVOT / UNPIVOT of rows to columns?
                        ├── YES ──► Use PIVOT operator or conditional aggregation
                        └── NO
                            │
                            Simple JOIN + GROUP BY + HAVING
```

---

### Technique Comparison Table

| Technique | Best For | Readability | Performance | Reusable? |
|-----------|----------|-------------|-------------|-----------|
| Simple JOIN + GROUP BY | Aggregates across tables | High | High | No |
| Subquery (WHERE) | Scalar filters, existence checks | Medium | Varies | No |
| Derived Table (FROM subquery) | One-time intermediate result | Low | Same as CTE | No |
| CTE (`WITH`) | Multi-step logic, reuse, recursion | High | Same as subquery | Yes (in query) |
| Window Function | Ranking, running totals, lag/lead | Medium | High (no extra scan) | No |
| `EXISTS` vs `IN` | Set membership checks | `EXISTS` clearer | `EXISTS` better for large sets | No |
| Temp Table (`#temp`) | Complex multi-step ETL, index needed | High | High (with indexes) | Yes (in session) |
| TVF / Stored Procedure | Parameterized reusable logic | High | High | Yes (cross-query) |

> **Key Insight:** CTEs and derived tables produce the **same execution plan** in SQL Server — CTEs win on readability. Temp tables win when you need an **index on intermediate results**.

---

### Step 5 — VALIDATE: The Edge Case Checklist

Before finalizing any query, run through this checklist mentally (or out loud with the interviewer):

```
┌─────────────────────────────────────────────────────────────┐
│                  EDGE CASE VALIDATION CHECKLIST             │
├─────────────────────────────────────────────────────────────┤
│  □  NULL values  — does NULL in JOIN key drop rows?         │
│  □  Duplicates   — will GROUP BY produce inflated counts?   │
│  □  Zero rows    — what happens if subquery returns empty?  │
│  □  Ties         — RANK() vs DENSE_RANK() vs ROW_NUMBER()?  │
│  □  Date ranges  — is the filter inclusive or exclusive?    │
│  □  Division     — divide by zero guard (NULLIF)?           │
│  □  Data types   — implicit conversion causing index skip?  │
│  □  Performance  — am I scanning a large table without idx? │
└─────────────────────────────────────────────────────────────┘
```

---

### Approach Evolution Box — Example Problem

**Problem:** "Find the top 2 highest-paid employees in each department."

```
┌─────────────────────────────────────────────────────────────────────┐
│  APPROACH EVOLUTION                                                 │
├────────────┬────────────────────────────────────────────────────────┤
│ 🔴 BRUTE   │ Self-join to count how many employees earn more        │
│            │ Complex, slow on large tables, hard to read            │
├────────────┼────────────────────────────────────────────────────────┤
│ 🟡 BETTER  │ Subquery with IN (or correlated subquery)              │
│            │ Works but re-executes for each row                     │
├────────────┼────────────────────────────────────────────────────────┤
│ 🟢 OPTIMAL │ ROW_NUMBER() OVER (PARTITION BY DeptId ORDER BY Salary │
│            │ DESC) — single pass, clean, handles ties explicitly    │
└────────────┴────────────────────────────────────────────────────────┘
```

**Schema:**
```sql
-- Employees(EmployeeId, Name, DepartmentId, Salary)
-- Departments(DepartmentId, DepartmentName)
```

---

#### Option 1 — Brute Force: Self-Join (🔴 Avoid)

```sql
-- Count how many people earn more than me in my dept
-- If fewer than 2 people earn more, I'm in the top 2
SELECT e1.Name, e1.DepartmentId, e1.Salary
FROM Employees e1
WHERE (
    SELECT COUNT(*)
    FROM Employees e2
    WHERE e2.DepartmentId = e1.DepartmentId
      AND e2.Salary > e1.Salary   -- correlated: runs for EVERY row
) < 2
ORDER BY e1.DepartmentId, e1.Salary DESC;

-- WHY THIS IS BAD:
-- Correlated subquery executes once per row (N² problem on large tables)
-- Ties not handled clearly — two employees with same salary both counted
```

---

#### Option 2 — Better: Subquery with RANK (🟡 Acceptable)

```sql
SELECT Name, DepartmentId, Salary
FROM (
    SELECT
        Name,
        DepartmentId,
        Salary,
        -- RANK gives same rank to ties, skips next rank
        RANK() OVER (PARTITION BY DepartmentId ORDER BY Salary DESC) AS rnk
    FROM Employees
) ranked
WHERE rnk <= 2
ORDER BY DepartmentId, Salary DESC;

-- NOTE: If two people share rank 1, both appear.
-- Rank 2 is skipped → you may get 3+ rows if there are ties at #2.
-- Use DENSE_RANK() if you always want exactly 2 distinct salary levels.
```

---

#### Option 3 — Optimal: ROW_NUMBER with CTE (🟢 Best for Interviews)

```sql
WITH RankedEmployees AS (
    SELECT
        e.Name,
        d.DepartmentName,
        e.Salary,
        -- ROW_NUMBER: strictly 1,2,3... — ties broken arbitrarily
        ROW_NUMBER() OVER (
            PARTITION BY e.DepartmentId   -- reset counter per department
            ORDER BY e.Salary DESC         -- highest salary = rank 1
        ) AS rn
    FROM Employees e
    INNER JOIN Departments d ON e.DepartmentId = d.DepartmentId
)
SELECT Name, DepartmentName, Salary
FROM RankedEmployees
WHERE rn <= 2                              -- keep only top 2 per dept
ORDER BY DepartmentName, Salary DESC;

-- WHY THIS IS BEST:
-- Single table scan — window function computed in one pass
-- CTE makes intent clear and easy to extend (change 2 to N)
-- JOIN brings in department name without a second subquery
-- Interviewer can read this without explanation
```

---

#### Option 4 — Alternative: DENSE_RANK for "Top N Salary Levels"

```sql
-- Use when: "top 2 DISTINCT salary amounts" matters more than "top 2 people"
WITH SalaryRanked AS (
    SELECT
        Name, DepartmentId, Salary,
        DENSE_RANK() OVER (PARTITION BY DepartmentId ORDER BY Salary DESC) AS dr
    FROM Employees
)
SELECT Name, DepartmentId, Salary
FROM SalaryRanked
WHERE dr <= 2;

-- DENSE_RANK:  1,1,2,2,3  — no gaps, ties share rank
-- RANK:        1,1,3,4     — gaps after ties
-- ROW_NUMBER:  1,2,3,4     — always unique, tie-breaking is arbitrary
```

---

### Rank Function Quick-Reference

```
Salary: 90k, 90k, 80k, 70k, 70k, 60k

ROW_NUMBER:  1   2   3   4   5   6    ← always unique
RANK:        1   1   3   4   4   6    ← gaps after ties
DENSE_RANK:  1   1   2   3   3   4    ← no gaps
```

| Function | Ties same rank? | Gaps in sequence? | Use when… |
|----------|----------------|-------------------|-----------|
| `ROW_NUMBER()` | No | No | Need exactly N rows, deterministic |
| `RANK()` | Yes | Yes | "Bronze medal" ranking OK |
| `DENSE_RANK()` | Yes | No | Want top N salary *levels* not people |
| `NTILE(N)` | Distributes evenly | N/A | Split into quartiles/deciles |

---

### Common SQL Problem Patterns and Their Go-To Technique

| Problem Statement Pattern | Technique | Key Clause |
|---------------------------|-----------|------------|
| "Top N per group" | Window Function | `ROW_NUMBER() OVER (PARTITION BY…)` |
| "Running total / cumulative sum" | Window Function | `SUM(col) OVER (ORDER BY date ROWS UNBOUNDED PRECEDING)` |
| "Compare current row to previous" | Window Function | `LAG(col) OVER (ORDER BY date)` |
| "Employees with no orders" | LEFT JOIN + IS NULL or NOT EXISTS | `WHERE o.OrderId IS NULL` |
| "Nth highest salary" | Window Function or OFFSET-FETCH | `DENSE_RANK() or ORDER BY OFFSET N-1 ROWS FETCH NEXT 1 ROW ONLY` |
| "Duplicate rows / find duplicates" | GROUP BY + HAVING | `HAVING COUNT(*) > 1` |
| "Delete duplicates, keep one" | CTE + ROW_NUMBER | `DELETE WHERE rn > 1` |
| "Pivot rows to columns" | PIVOT or CASE+SUM | `SUM(CASE WHEN category='X' THEN amount END)` |
| "Hierarchy / org chart" | Recursive CTE | `WITH RCTE AS (anchor UNION ALL recursive)` |
| "Moving average" | Window Function | `AVG(col) OVER (ORDER BY date ROWS 2 PRECEDING)` |
| "Gaps and islands" | Window Function | `ROW_NUMBER() difference trick` |
| "String aggregation" | `STRING_AGG()` | `STRING_AGG(Name, ', ') WITHIN GROUP (ORDER BY Name)` |

---

### SQL Clause Execution Order (Critical for Reasoning)

```
┌───────────────────────────────────────────────────────────┐
│              SQL LOGICAL EXECUTION ORDER                  │
│                                                           │
│   1. FROM         ← which tables? (includes JOINs)       │
│   2. WHERE        ← filter raw rows (no aliases yet!)    │
│   3. GROUP BY     ← group filtered rows                  │
│   4. HAVING       ← filter groups (aggregates available) │
│   5. SELECT       ← compute expressions, aliases defined │
│   6. DISTINCT     ← remove duplicates if specified       │
│   7. ORDER BY     ← sort (aliases from SELECT available) │
│   8. TOP / OFFSET ← slice result                         │
└───────────────────────────────────────────────────────────┘

WHY IT MATTERS:
  - You CANNOT use a SELECT alias in WHERE (alias not defined yet)
  - You CAN use a SELECT alias in ORDER BY (defined before ORDER BY runs)
  - Window functions run AFTER WHERE but can be referenced in outer query
  - HAVING filters on aggregated values; WHERE cannot use aggregate functions
```

---

### Interview Narration Template

Use this structure when solving problems out loud:

```
"Let me think through this step by step.

1. OUTPUT: The question asks for [columns], one row per [entity].

2. TABLES: I'll need [table A] for [data] and [table B] for [data],
   joined on [key]. I'll use [INNER/LEFT] JOIN because [reason].

3. FILTER: I need WHERE [condition] to limit to [scope].

4. AGGREGATION / RANKING: Since we need [top N / sum / count per group],
   I'll use [GROUP BY / window function] because [reason].

5. APPROACH OPTIONS:
   - Option A: [subquery] — works but [trade-off]
   - Option B: [CTE + window function] — cleaner because [reason]
   I'll go with Option B.

6. EDGE CASES: I should check for NULLs in [column], ties in [ranking],
   and whether the result should include [zero-count groups].

[Write the query]

7. VERIFY: Let me trace through with [sample data] to confirm the result."
```

---

### 1. What is the difference between DELETE, TRUNCATE, and DROP?

**Asked at: TCS, Infosys, Wipro, Accenture**

| Feature | DELETE | TRUNCATE | DROP |
|---------|--------|----------|------|
| Type | DML | DDL | DDL |
| WHERE clause | Yes | No | No |
| Rollback | Yes (if in transaction) | Yes (SQL Server) | No |
| Triggers | Fires | Does not fire | Does not fire |
| Identity reset | No | Yes | N/A |
| Space released | No | Yes | Yes |
| Logs | Row-by-row | Minimal (page deallocation) | Minimal |

```sql
-- DELETE - removes specific rows
DELETE FROM Employees WHERE DepartmentId = 5;

-- TRUNCATE - removes all rows, resets identity
TRUNCATE TABLE Employees;

-- DROP - removes entire table structure
DROP TABLE Employees;
```

---

### 2. What are different types of JOINs? Explain with examples.

**Asked at: Almost every company**

**Sample Tables:**

**Employees:**
| EmployeeId | Name    | DepartmentId |
|------------|---------|--------------|
| 1          | Alice   | 10           |
| 2          | Bob     | 20           |
| 3          | Charlie | 10           |
| 4          | David   | NULL         |

**Departments:**
| DepartmentId | DepartmentName |
|--------------|----------------|
| 10           | IT             |
| 20           | HR             |
| 30           | Finance        |

```sql
-- INNER JOIN - Returns matching rows from both tables
SELECT e.Name, d.DepartmentName
FROM Employees e
INNER JOIN Departments d ON e.DepartmentId = d.DepartmentId;
```

**Result:**
| Name    | DepartmentName |
|---------|----------------|
| Alice   | IT             |
| Bob     | HR             |
| Charlie | IT             |

```sql
-- LEFT JOIN - All rows from left + matching from right
SELECT e.Name, d.DepartmentName
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentId = d.DepartmentId;
```

**Result:**
| Name    | DepartmentName |
|---------|----------------|
| Alice   | IT             |
| Bob     | HR             |
| Charlie | IT             |
| David   | NULL           |

```sql
-- RIGHT JOIN - All rows from right + matching from left
SELECT e.Name, d.DepartmentName
FROM Employees e
RIGHT JOIN Departments d ON e.DepartmentId = d.DepartmentId;
```

**Result:**
| Name    | DepartmentName |
|---------|----------------|
| Alice   | IT             |
| Charlie | IT             |
| Bob     | HR             |
| NULL    | Finance        |

```sql
-- FULL OUTER JOIN - All rows from both tables
SELECT e.Name, d.DepartmentName
FROM Employees e
FULL OUTER JOIN Departments d ON e.DepartmentId = d.DepartmentId;
```

**Result:**
| Name    | DepartmentName |
|---------|----------------|
| Alice   | IT             |
| Bob     | HR             |
| Charlie | IT             |
| David   | NULL           |
| NULL    | Finance        |

```sql
-- CROSS JOIN - Cartesian product (4 employees × 3 departments = 12 rows)
SELECT e.Name, d.DepartmentName
FROM Employees e
CROSS JOIN Departments d;
```

**Result (12 rows):**
| Name    | DepartmentName |
|---------|----------------|
| Alice   | IT             |
| Alice   | HR             |
| Alice   | Finance        |
| Bob     | IT             |
| Bob     | HR             |
| Bob     | Finance        |
| ...     | ...            |

```sql
-- SELF JOIN - Join table to itself
SELECT e1.Name AS Employee, e2.Name AS Manager
FROM Employees e1
LEFT JOIN Employees e2 ON e1.ManagerId = e2.EmployeeId;
```

**Sample Data for Self Join:**
| EmployeeId | Name    | ManagerId |
|------------|---------|-----------|
| 1          | Alice   | NULL      |
| 2          | Bob     | 1         |
| 3          | Charlie | 1         |
| 4          | David   | 2         |

**Result:**
| Employee | Manager |
|----------|---------|
| Alice    | NULL    |
| Bob      | Alice   |
| Charlie  | Alice   |
| David    | Bob     |

---

### 3. What is the difference between WHERE and HAVING clause?

**Asked at: Cognizant, HCL, Tech Mahindra**

| WHERE | HAVING |
|-------|--------|
| Filters rows before grouping | Filters groups after aggregation |
| Cannot use aggregate functions | Can use aggregate functions |
| Used with SELECT, UPDATE, DELETE | Used only with SELECT (after GROUP BY) |

**Sample Data - Employees:**
| EmployeeId | Name    | DepartmentId | Salary | Status   |
|------------|---------|--------------|--------|----------|
| 1          | Alice   | 10           | 60000  | Active   |
| 2          | Bob     | 10           | 55000  | Active   |
| 3          | Charlie | 10           | 45000  | Active   |
| 4          | David   | 20           | 70000  | Active   |
| 5          | Eve     | 20           | 65000  | Inactive |
| 6          | Frank   | 20           | 80000  | Active   |

```sql
-- WHERE - filters individual rows BEFORE grouping
SELECT DepartmentId, COUNT(*) as EmpCount
FROM Employees
WHERE Salary > 50000
GROUP BY DepartmentId;
```

**Result:**
| DepartmentId | EmpCount |
|--------------|----------|
| 10           | 2        |
| 20           | 3        |

```sql
-- HAVING - filters grouped results AFTER aggregation
SELECT DepartmentId, COUNT(*) as EmpCount
FROM Employees
GROUP BY DepartmentId
HAVING COUNT(*) > 2;
```

**Result:**
| DepartmentId | EmpCount |
|--------------|----------|
| 10           | 3        |
| 20           | 3        |

```sql
-- Combined usage
SELECT DepartmentId, AVG(Salary) as AvgSalary
FROM Employees
WHERE Status = 'Active'
GROUP BY DepartmentId
HAVING AVG(Salary) > 60000;
```

**Result:**
| DepartmentId | AvgSalary |
|--------------|-----------|
| 20           | 75000.00  |

---

### 4. What are Primary Key and Foreign Key?

**Asked at: Every company (Fundamental question)**

```sql
-- Primary Key: Uniquely identifies each row, cannot be NULL
CREATE TABLE Departments (
    DepartmentId INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);

-- Composite Primary Key
CREATE TABLE OrderDetails (
    OrderId INT,
    ProductId INT,
    Quantity INT,
    PRIMARY KEY (OrderId, ProductId)
);

-- Foreign Key: References Primary Key of another table
CREATE TABLE Employees (
    EmployeeId INT PRIMARY KEY,
    Name VARCHAR(100),
    DepartmentId INT,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(DepartmentId)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

---

### 5. What is the difference between UNION and UNION ALL?

**Asked at: Wipro, Infosys, Capgemini**

**Sample Data:**

**Customers:**
| CustomerId | City      |
|------------|-----------|
| 1          | Mumbai    |
| 2          | Delhi     |
| 3          | Mumbai    |

**Suppliers:**
| SupplierId | City      |
|------------|-----------|
| 1          | Delhi     |
| 2          | Chennai   |

```sql
-- UNION - Removes duplicates (slower, uses DISTINCT internally)
SELECT City FROM Customers
UNION
SELECT City FROM Suppliers;
```

**Result:**
| City    |
|---------|
| Mumbai  |
| Delhi   |
| Chennai |

```sql
-- UNION ALL - Keeps duplicates (faster)
SELECT City FROM Customers
UNION ALL
SELECT City FROM Suppliers;
```

**Result:**
| City    |
|---------|
| Mumbai  |
| Delhi   |
| Mumbai  |
| Delhi   |
| Chennai |

**Key Points:**
- UNION performs implicit DISTINCT
- UNION ALL is faster for large datasets
- Both require same number of columns with compatible data types

---

### 6. What are Aggregate Functions?

**Asked at: TCS, Infosys (Freshers)**

**Sample Data - Employees:**
| EmployeeId | Name    | DepartmentId | Salary |
|------------|---------|--------------|--------|
| 1          | Alice   | 10           | 60000  |
| 2          | Bob     | 10           | 55000  |
| 3          | Charlie | 20           | 70000  |
| 4          | David   | 20           | 80000  |
| 5          | Eve     | 20           | 65000  |

```sql
-- COUNT - Number of rows
SELECT COUNT(*) AS TotalEmployees FROM Employees;
SELECT COUNT(DISTINCT DepartmentId) AS UniqueDepts FROM Employees;
```

**Result:**
| TotalEmployees |
|----------------|
| 5              |

| UniqueDepts |
|-------------|
| 2           |

```sql
-- SUM - Total of numeric column
SELECT SUM(Salary) AS TotalSalary FROM Employees;
```

**Result:**
| TotalSalary |
|-------------|
| 330000      |

```sql
-- AVG - Average value
SELECT AVG(Salary) AS AvgSalary FROM Employees;
```

**Result:**
| AvgSalary |
|-----------|
| 66000.00  |

```sql
-- MIN/MAX - Minimum/Maximum value
SELECT MIN(Salary) AS MinSalary, MAX(Salary) AS MaxSalary FROM Employees;
```

**Result:**
| MinSalary | MaxSalary |
|-----------|-----------|
| 55000     | 80000     |

```sql
-- STRING_AGG (SQL Server 2017+) - Concatenate strings
SELECT DepartmentId, STRING_AGG(Name, ', ') AS Employees
FROM Employees
GROUP BY DepartmentId;
```

**Result:**
| DepartmentId | Employees              |
|--------------|------------------------|
| 10           | Alice, Bob             |
| 20           | Charlie, David, Eve    |

---

### 7. What is NULL in SQL? How to handle it?

**Asked at: Accenture, Cognizant**

```sql
-- NULL is unknown/missing value, not zero or empty string

-- Checking for NULL
SELECT * FROM Employees WHERE ManagerId IS NULL;
SELECT * FROM Employees WHERE ManagerId IS NOT NULL;

-- COALESCE - Returns first non-NULL value
SELECT Name, COALESCE(Phone, Email, 'No Contact') AS ContactInfo
FROM Employees;

-- ISNULL - SQL Server specific (2 parameters only)
SELECT Name, ISNULL(Phone, 'N/A') AS Phone
FROM Employees;

-- NULLIF - Returns NULL if two values are equal
SELECT NULLIF(Salary, 0) AS Salary FROM Employees;

-- NULL in calculations
SELECT Salary + Bonus AS Total -- Returns NULL if Bonus is NULL
FROM Employees;

SELECT Salary + ISNULL(Bonus, 0) AS Total -- Handles NULL
FROM Employees;
```

---

### 8. What is the order of SQL query execution?

**Asked at: Goldman Sachs, Morgan Stanley, Amazon**

```
1. FROM & JOINs
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. DISTINCT
7. ORDER BY
8. TOP/OFFSET-FETCH
```

```sql
-- Example showing execution order
SELECT TOP 10 DepartmentId, COUNT(*) AS EmpCount  -- 5, 8
FROM Employees e                                    -- 1
INNER JOIN Departments d ON e.DeptId = d.DeptId    -- 1
WHERE e.Status = 'Active'                          -- 2
GROUP BY DepartmentId                              -- 3
HAVING COUNT(*) > 5                                -- 4
ORDER BY EmpCount DESC;                            -- 7
```

---

## Intermediate Level

### 9. What are Window Functions? Explain with examples.

**Asked at: Amazon, Microsoft, Goldman Sachs, Flipkart**

**Sample Data - Employees:**
| EmployeeId | Name    | DepartmentId | Salary | HireDate   |
|------------|---------|--------------|--------|------------|
| 1          | Alice   | 10           | 60000  | 2020-01-15 |
| 2          | Bob     | 10           | 55000  | 2020-03-20 |
| 3          | Charlie | 10           | 60000  | 2021-02-10 |
| 4          | David   | 20           | 80000  | 2019-06-01 |
| 5          | Eve     | 20           | 70000  | 2021-08-15 |

```sql
-- ROW_NUMBER - Unique sequential number
SELECT
    Name, Salary, DepartmentId,
    ROW_NUMBER() OVER (PARTITION BY DepartmentId ORDER BY Salary DESC) AS RowNum
FROM Employees;
```

**Result:**
| Name    | Salary | DepartmentId | RowNum |
|---------|--------|--------------|--------|
| Alice   | 60000  | 10           | 1      |
| Charlie | 60000  | 10           | 2      |
| Bob     | 55000  | 10           | 3      |
| David   | 80000  | 20           | 1      |
| Eve     | 70000  | 20           | 2      |

```sql
-- RANK vs DENSE_RANK - Understanding the difference
SELECT
    Name, Salary,
    RANK() OVER (ORDER BY Salary DESC) AS Rank,
    DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRank
FROM Employees;
```

**Result:**
| Name    | Salary | Rank | DenseRank |
|---------|--------|------|-----------|
| David   | 80000  | 1    | 1         |
| Eve     | 70000  | 2    | 2         |
| Alice   | 60000  | 3    | 3         |
| Charlie | 60000  | 3    | 3         |
| Bob     | 55000  | 5    | 4         |

> **Note:** RANK has gap (3,3,5) while DENSE_RANK has no gap (3,3,4)

```sql
-- NTILE - Divides rows into n groups
SELECT Name, Salary,
    NTILE(2) OVER (ORDER BY Salary DESC) AS HalfGroup
FROM Employees;
```

**Result:**
| Name    | Salary | HalfGroup |
|---------|--------|-----------|
| David   | 80000  | 1         |
| Eve     | 70000  | 1         |
| Alice   | 60000  | 1         |
| Charlie | 60000  | 2         |
| Bob     | 55000  | 2         |

```sql
-- LAG/LEAD - Access previous/next row
SELECT Name, Salary, HireDate,
    LAG(Salary, 1, 0) OVER (ORDER BY HireDate) AS PrevSalary,
    LEAD(Salary, 1, 0) OVER (ORDER BY HireDate) AS NextSalary
FROM Employees;
```

**Result:**
| Name    | Salary | HireDate   | PrevSalary | NextSalary |
|---------|--------|------------|------------|------------|
| David   | 80000  | 2019-06-01 | 0          | 60000      |
| Alice   | 60000  | 2020-01-15 | 80000      | 55000      |
| Bob     | 55000  | 2020-03-20 | 60000      | 60000      |
| Charlie | 60000  | 2021-02-10 | 55000      | 70000      |
| Eve     | 70000  | 2021-08-15 | 60000      | 0          |

**Sample Data - Orders:**
| OrderDate  | Amount |
|------------|--------|
| 2024-01-01 | 100    |
| 2024-01-02 | 200    |
| 2024-01-03 | 150    |
| 2024-01-04 | 300    |

```sql
-- Running Total
SELECT OrderDate, Amount,
    SUM(Amount) OVER (ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS RunningTotal
FROM Orders;
```

**Result:**
| OrderDate  | Amount | RunningTotal |
|------------|--------|--------------|
| 2024-01-01 | 100    | 100          |
| 2024-01-02 | 200    | 300          |
| 2024-01-03 | 150    | 450          |
| 2024-01-04 | 300    | 750          |

```sql
-- Moving Average (last 3 rows including current)
SELECT OrderDate, Amount,
    AVG(Amount) OVER (ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg
FROM Orders;
```

**Result:**
| OrderDate  | Amount | MovingAvg |
|------------|--------|-----------|
| 2024-01-01 | 100    | 100.00    |
| 2024-01-02 | 200    | 150.00    |
| 2024-01-03 | 150    | 150.00    |
| 2024-01-04 | 300    | 216.67    |

---

### 10. Find the Nth highest salary (Classic question)

**Asked at: Every product company, Frequently asked**

**Sample Data - Employees:**
| EmployeeId | Name    | Salary |
|------------|---------|--------|
| 1          | Alice   | 80000  |
| 2          | Bob     | 60000  |
| 3          | Charlie | 70000  |
| 4          | David   | 60000  |
| 5          | Eve     | 90000  |
| 6          | Frank   | 50000  |

**Distinct Salaries (Descending):** 90000, 80000, 70000, 60000, 50000

```sql
-- Method 1: Using DENSE_RANK (Handles ties) ✅ Recommended
WITH RankedSalaries AS (
    SELECT Salary,
        DENSE_RANK() OVER (ORDER BY Salary DESC) AS Rank
    FROM Employees
)
SELECT DISTINCT Salary FROM RankedSalaries
WHERE Rank = 3; -- 3rd highest
```

**Result:**
| Salary |
|--------|
| 70000  |

```sql
-- Method 2: Using OFFSET-FETCH (SQL Server 2012+)
SELECT DISTINCT Salary FROM Employees
ORDER BY Salary DESC
OFFSET 2 ROWS FETCH NEXT 1 ROWS ONLY; -- 3rd highest (0-indexed)
```

**Result:**
| Salary |
|--------|
| 70000  |

```sql
-- Method 3: Using Subquery (works on older versions)
SELECT MAX(Salary) AS ThirdHighest
FROM Employees
WHERE Salary < (
    SELECT MAX(Salary) FROM Employees
    WHERE Salary < (SELECT MAX(Salary) FROM Employees)
);
```

**Result:**
| ThirdHighest |
|--------------|
| 70000        |

```sql
-- Method 4: Using TOP with subquery
SELECT TOP 1 Salary FROM (
    SELECT DISTINCT TOP 3 Salary FROM Employees ORDER BY Salary DESC
) AS Top3
ORDER BY Salary ASC;
```

**Result:**
| Salary |
|--------|
| 70000  |

**Finding Nth Highest by Department:**
```sql
WITH RankedSalaries AS (
    SELECT Name, DepartmentId, Salary,
        DENSE_RANK() OVER (PARTITION BY DepartmentId ORDER BY Salary DESC) AS Rank
    FROM Employees
)
SELECT * FROM RankedSalaries WHERE Rank = 2; -- 2nd highest in each dept
```

---

### 11. What are CTEs (Common Table Expressions)?

**Asked at: Microsoft, Google, Meta**

```sql
-- Simple CTE
WITH EmployeeCTE AS (
    SELECT EmployeeId, Name, DepartmentId, Salary
    FROM Employees
    WHERE Salary > 50000
)
SELECT * FROM EmployeeCTE;

-- Multiple CTEs
WITH
DeptSalary AS (
    SELECT DepartmentId, AVG(Salary) AS AvgSalary
    FROM Employees
    GROUP BY DepartmentId
),
HighPayDepts AS (
    SELECT DepartmentId
    FROM DeptSalary
    WHERE AvgSalary > 70000
)
SELECT e.*
FROM Employees e
INNER JOIN HighPayDepts h ON e.DepartmentId = h.DepartmentId;

-- Recursive CTE - Employee Hierarchy
WITH EmployeeHierarchy AS (
    -- Anchor: Top-level employees (no manager)
    SELECT EmployeeId, Name, ManagerId, 0 AS Level
    FROM Employees
    WHERE ManagerId IS NULL

    UNION ALL

    -- Recursive: Get subordinates
    SELECT e.EmployeeId, e.Name, e.ManagerId, eh.Level + 1
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerId = eh.EmployeeId
)
SELECT * FROM EmployeeHierarchy
OPTION (MAXRECURSION 100);
```

---

### 12. What is the difference between Clustered and Non-Clustered Index?

**Asked at: Microsoft, Amazon, Oracle, Every senior role**

| Clustered Index | Non-Clustered Index |
|-----------------|---------------------|
| Determines physical order of data | Separate structure with pointers |
| Only one per table | Up to 999 per table |
| Leaf nodes contain actual data | Leaf nodes contain index + row locator |
| Faster for range queries | Better for point lookups |
| Primary key creates clustered by default | Must be created explicitly |

```sql
-- Clustered Index (usually on Primary Key)
CREATE CLUSTERED INDEX IX_Employees_EmployeeId
ON Employees(EmployeeId);

-- Non-Clustered Index
CREATE NONCLUSTERED INDEX IX_Employees_LastName
ON Employees(LastName);

-- Covering Index (Includes additional columns)
CREATE NONCLUSTERED INDEX IX_Employees_DeptId
ON Employees(DepartmentId)
INCLUDE (Name, Salary);

-- Filtered Index
CREATE NONCLUSTERED INDEX IX_Employees_Active
ON Employees(Status)
WHERE Status = 'Active';

-- Composite Index
CREATE NONCLUSTERED INDEX IX_Employees_Dept_Salary
ON Employees(DepartmentId, Salary DESC);
```

---

### 13. Explain ACID properties with examples.

**Asked at: Goldman Sachs, Morgan Stanley, JP Morgan**

```sql
-- ACID: Atomicity, Consistency, Isolation, Durability

-- ATOMICITY: All or nothing
BEGIN TRANSACTION;
    UPDATE Accounts SET Balance = Balance - 1000 WHERE AccountId = 1;
    UPDATE Accounts SET Balance = Balance + 1000 WHERE AccountId = 2;

    IF @@ERROR <> 0
        ROLLBACK TRANSACTION;
    ELSE
        COMMIT TRANSACTION;

-- Using TRY-CATCH (Better approach)
BEGIN TRY
    BEGIN TRANSACTION;
        UPDATE Accounts SET Balance = Balance - 1000 WHERE AccountId = 1;
        UPDATE Accounts SET Balance = Balance + 1000 WHERE AccountId = 2;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- ISOLATION LEVELS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; -- Dirty reads allowed
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;   -- Default in SQL Server
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;  -- No phantom reads within transaction
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;     -- Highest isolation
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;         -- Row versioning (requires DB setting)
```

---

### 14. What are Stored Procedures vs Functions?

**Asked at: TCS, Infosys, Wipro, Accenture**

| Stored Procedure | Function |
|------------------|----------|
| Can return 0, 1, or multiple values | Must return a value |
| Can have output parameters | Returns single value or table |
| Can use DML (INSERT, UPDATE, DELETE) | Cannot use DML (in most cases) |
| Cannot be used in SELECT statement | Can be used in SELECT |
| Can call functions | Cannot call stored procedures |
| Can use TRY-CATCH | Cannot use TRY-CATCH |

```sql
-- Stored Procedure
CREATE PROCEDURE sp_GetEmployeesByDept
    @DepartmentId INT,
    @TotalCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * FROM Employees WHERE DepartmentId = @DepartmentId;

    SELECT @TotalCount = COUNT(*)
    FROM Employees
    WHERE DepartmentId = @DepartmentId;
END;

-- Execute
DECLARE @Count INT;
EXEC sp_GetEmployeesByDept @DepartmentId = 5, @TotalCount = @Count OUTPUT;
SELECT @Count AS TotalEmployees;

-- Scalar Function
CREATE FUNCTION fn_GetFullName(@FirstName VARCHAR(50), @LastName VARCHAR(50))
RETURNS VARCHAR(101)
AS
BEGIN
    RETURN @FirstName + ' ' + @LastName;
END;

-- Use in query
SELECT dbo.fn_GetFullName(FirstName, LastName) AS FullName FROM Employees;

-- Table-Valued Function (Inline)
CREATE FUNCTION fn_GetEmployeesByDept(@DepartmentId INT)
RETURNS TABLE
AS
RETURN (
    SELECT EmployeeId, Name, Salary
    FROM Employees
    WHERE DepartmentId = @DepartmentId
);

-- Use in query
SELECT * FROM fn_GetEmployeesByDept(5);
```

---

### 15. What are Triggers? Types and use cases?

**Asked at: Oracle, Microsoft, Senior positions**

```sql
-- AFTER Trigger (FOR Trigger) - Executes after the operation
CREATE TRIGGER tr_Employees_Insert
ON Employees
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AuditLog (TableName, Action, RecordId, ActionDate)
    SELECT 'Employees', 'INSERT', EmployeeId, GETDATE()
    FROM INSERTED;
END;

-- INSTEAD OF Trigger - Replaces the operation
CREATE TRIGGER tr_Employees_Delete
ON Employees
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Soft delete instead of hard delete
    UPDATE Employees
    SET IsDeleted = 1, DeletedDate = GETDATE()
    WHERE EmployeeId IN (SELECT EmployeeId FROM DELETED);
END;

-- UPDATE Trigger with column check
CREATE TRIGGER tr_Employees_SalaryUpdate
ON Employees
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Salary)
    BEGIN
        INSERT INTO SalaryHistory (EmployeeId, OldSalary, NewSalary, ChangeDate)
        SELECT d.EmployeeId, d.Salary, i.Salary, GETDATE()
        FROM DELETED d
        INNER JOIN INSERTED i ON d.EmployeeId = i.EmployeeId
        WHERE d.Salary <> i.Salary;
    END
END;

-- DDL Trigger (Database level)
CREATE TRIGGER tr_PreventTableDrop
ON DATABASE
FOR DROP_TABLE
AS
BEGIN
    PRINT 'Table drops are not allowed!';
    ROLLBACK;
END;
```

---

### 16. What is the difference between TEMP tables and Table Variables?

**Asked at: Deloitte, EY, KPMG, PwC**

| Temp Table (#table) | Table Variable (@table) |
|---------------------|-------------------------|
| Created in tempdb | Created in memory (small) / tempdb (large) |
| Can have indexes | Only primary key/unique constraints |
| Statistics created | No statistics |
| Can be used in dynamic SQL | Scope limited to batch |
| Participates in transactions | Not affected by ROLLBACK |
| Better for large datasets | Better for small datasets (<1000 rows) |

```sql
-- Temp Table
CREATE TABLE #TempEmployees (
    EmployeeId INT PRIMARY KEY,
    Name VARCHAR(100),
    Salary DECIMAL(10,2)
);

INSERT INTO #TempEmployees
SELECT EmployeeId, Name, Salary FROM Employees WHERE DepartmentId = 5;

CREATE INDEX IX_TempEmp_Salary ON #TempEmployees(Salary);

SELECT * FROM #TempEmployees;
DROP TABLE #TempEmployees;

-- Global Temp Table (visible to all sessions)
CREATE TABLE ##GlobalTemp (Id INT, Name VARCHAR(100));

-- Table Variable
DECLARE @TempEmployees TABLE (
    EmployeeId INT PRIMARY KEY,
    Name VARCHAR(100),
    Salary DECIMAL(10,2)
);

INSERT INTO @TempEmployees
SELECT EmployeeId, Name, Salary FROM Employees WHERE DepartmentId = 5;

SELECT * FROM @TempEmployees;
-- No need to drop, automatically cleaned up
```

---

### 17. Explain PIVOT and UNPIVOT operations.

**Asked at: Amazon, Microsoft, Data Engineering roles**

**Sample Data - Sales (Before PIVOT):**
| Year | Quarter | Amount |
|------|---------|--------|
| 2023 | Q1      | 1000   |
| 2023 | Q2      | 1500   |
| 2023 | Q3      | 1200   |
| 2023 | Q4      | 1800   |
| 2024 | Q1      | 1100   |
| 2024 | Q2      | 1600   |
| 2024 | Q3      | 1300   |
| 2024 | Q4      | 2000   |

```sql
-- PIVOT - Rows to Columns
SELECT Year, [Q1], [Q2], [Q3], [Q4]
FROM (
    SELECT Year, Quarter, Amount FROM Sales
) AS SourceTable
PIVOT (
    SUM(Amount) FOR Quarter IN ([Q1], [Q2], [Q3], [Q4])
) AS PivotTable;
```

**Result (After PIVOT):**
| Year | Q1   | Q2   | Q3   | Q4   |
|------|------|------|------|------|
| 2023 | 1000 | 1500 | 1200 | 1800 |
| 2024 | 1100 | 1600 | 1300 | 2000 |

```sql
-- Dynamic PIVOT (when column values are unknown)
DECLARE @Columns NVARCHAR(MAX), @SQL NVARCHAR(MAX);

SELECT @Columns = STRING_AGG(QUOTENAME(Quarter), ', ')
FROM (SELECT DISTINCT Quarter FROM Sales) AS Quarters;

SET @SQL = N'
SELECT Year, ' + @Columns + '
FROM (SELECT Year, Quarter, Amount FROM Sales) AS SourceTable
PIVOT (SUM(Amount) FOR Quarter IN (' + @Columns + ')) AS PivotTable';

EXEC sp_executesql @SQL;
```

---

**Sample Data - YearlySales (Before UNPIVOT):**
| Year | Q1   | Q2   | Q3   | Q4   |
|------|------|------|------|------|
| 2023 | 1000 | 1500 | 1200 | 1800 |
| 2024 | 1100 | 1600 | 1300 | 2000 |

```sql
-- UNPIVOT - Columns to Rows
SELECT Year, Quarter, Amount
FROM (
    SELECT Year, Q1, Q2, Q3, Q4 FROM YearlySales
) AS SourceTable
UNPIVOT (
    Amount FOR Quarter IN (Q1, Q2, Q3, Q4)
) AS UnpivotTable;
```

**Result (After UNPIVOT):**
| Year | Quarter | Amount |
|------|---------|--------|
| 2023 | Q1      | 1000   |
| 2023 | Q2      | 1500   |
| 2023 | Q3      | 1200   |
| 2023 | Q4      | 1800   |
| 2024 | Q1      | 1100   |
| 2024 | Q2      | 1600   |
| 2024 | Q3      | 1300   |
| 2024 | Q4      | 2000   |

---

## Advanced Level

### 18. Explain Deadlocks and how to prevent them.

**Asked at: Microsoft, Amazon, Google, Goldman Sachs**

```sql
-- Deadlock occurs when two transactions wait for each other

-- Transaction 1
BEGIN TRANSACTION;
    UPDATE TableA SET Col1 = 'X' WHERE Id = 1;
    WAITFOR DELAY '00:00:05';
    UPDATE TableB SET Col1 = 'X' WHERE Id = 1;
COMMIT;

-- Transaction 2 (running simultaneously)
BEGIN TRANSACTION;
    UPDATE TableB SET Col1 = 'Y' WHERE Id = 1;
    WAITFOR DELAY '00:00:05';
    UPDATE TableA SET Col1 = 'Y' WHERE Id = 1;
COMMIT;

-- PREVENTION STRATEGIES:

-- 1. Access tables in same order
-- Always: TableA -> TableB (never TableB -> TableA)

-- 2. Keep transactions short
-- Move non-essential operations outside transaction

-- 3. Use appropriate isolation level
SET TRANSACTION ISOLATION LEVEL READ COMMITTED SNAPSHOT;

-- 4. Use NOLOCK hint (carefully - dirty reads!)
SELECT * FROM Employees WITH (NOLOCK);

-- 5. Set deadlock priority
SET DEADLOCK_PRIORITY LOW; -- This transaction will be victim

-- 6. Use TRY-CATCH with retry logic
DECLARE @RetryCount INT = 0;
WHILE @RetryCount < 3
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            -- Your operations
        COMMIT;
        BREAK;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        IF ERROR_NUMBER() = 1205 -- Deadlock
            SET @RetryCount += 1;
        ELSE
            THROW;
    END CATCH
END;

-- Monitor deadlocks
-- Enable trace flag 1222 for detailed deadlock info
DBCC TRACEON(1222, -1);

-- Query deadlock info
SELECT * FROM sys.dm_exec_requests WHERE blocking_session_id <> 0;
```

---

### 19. What is Query Execution Plan? How to read and optimize?

**Asked at: Microsoft, Amazon, Google, Performance-focused roles**

```sql
-- View Estimated Execution Plan
SET SHOWPLAN_XML ON;
GO
SELECT * FROM Employees WHERE DepartmentId = 5;
GO
SET SHOWPLAN_XML OFF;

-- View Actual Execution Plan
SET STATISTICS PROFILE ON;
SELECT * FROM Employees WHERE DepartmentId = 5;
SET STATISTICS PROFILE OFF;

-- Display execution statistics
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT * FROM Employees WHERE DepartmentId = 5;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

-- Key operators to watch:
-- 1. Table Scan - Bad (full table scan, needs index)
-- 2. Index Scan - Better (full index scan)
-- 3. Index Seek - Best (direct lookup)
-- 4. Key Lookup - May need covering index
-- 5. Hash Match - Can be expensive for large joins
-- 6. Sort - Check if index can provide order
-- 7. Nested Loops - Good for small datasets
-- 8. Merge Join - Good for sorted, large datasets

-- Find missing indexes
SELECT
    mig.index_handle,
    mid.statement AS TableName,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.user_seeks,
    migs.user_scans,
    migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS ImprovementMeasure
FROM sys.dm_db_missing_index_groups mig
INNER JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY ImprovementMeasure DESC;
```

---

### 20. Explain different types of Locks in SQL Server.

**Asked at: Goldman Sachs, Morgan Stanley, JP Morgan**

```sql
-- Lock Types:
-- S (Shared) - Read locks, compatible with other S locks
-- X (Exclusive) - Write locks, not compatible with any lock
-- U (Update) - Used during update operations
-- IS, IX, SIX - Intent locks (at page/table level)
-- Sch-S, Sch-M - Schema locks

-- View current locks
SELECT
    request_session_id,
    resource_type,
    resource_database_id,
    resource_associated_entity_id,
    request_mode,
    request_status
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID();

-- Lock hints
SELECT * FROM Employees WITH (NOLOCK);      -- No locks (dirty reads)
SELECT * FROM Employees WITH (READPAST);    -- Skip locked rows
SELECT * FROM Employees WITH (UPDLOCK);     -- Update lock
SELECT * FROM Employees WITH (HOLDLOCK);    -- Hold until transaction ends
SELECT * FROM Employees WITH (TABLOCK);     -- Table-level lock
SELECT * FROM Employees WITH (ROWLOCK);     -- Row-level lock
SELECT * FROM Employees WITH (XLOCK);       -- Exclusive lock

-- Lock escalation control
ALTER TABLE Employees SET (LOCK_ESCALATION = DISABLE);
ALTER TABLE Employees SET (LOCK_ESCALATION = TABLE);
ALTER TABLE Employees SET (LOCK_ESCALATION = AUTO);

-- Monitor blocking
SELECT
    blocking.session_id AS BlockingSession,
    blocked.session_id AS BlockedSession,
    blocked.wait_type,
    blocked.wait_time,
    blocking_sql.text AS BlockingQuery,
    blocked_sql.text AS BlockedQuery
FROM sys.dm_exec_requests blocked
INNER JOIN sys.dm_exec_sessions blocking ON blocked.blocking_session_id = blocking.session_id
CROSS APPLY sys.dm_exec_sql_text(blocked.sql_handle) blocked_sql
CROSS APPLY sys.dm_exec_sql_text(blocking.most_recent_sql_handle) blocking_sql
WHERE blocked.blocking_session_id <> 0;
```

---

### 21. What is Partitioning? When and how to use it?

**Asked at: Amazon, Microsoft, Data Engineering roles**

```sql
-- Step 1: Create Partition Function
CREATE PARTITION FUNCTION pf_OrderDate (DATE)
AS RANGE RIGHT FOR VALUES
('2022-01-01', '2023-01-01', '2024-01-01', '2025-01-01');

-- Step 2: Create Partition Scheme
CREATE PARTITION SCHEME ps_OrderDate
AS PARTITION pf_OrderDate
TO (fg_2021, fg_2022, fg_2023, fg_2024, fg_2025);
-- Or use ALL TO ([PRIMARY]) for all partitions on one filegroup

-- Step 3: Create Partitioned Table
CREATE TABLE Orders (
    OrderId INT NOT NULL,
    OrderDate DATE NOT NULL,
    CustomerId INT,
    Amount DECIMAL(10,2),
    CONSTRAINT PK_Orders PRIMARY KEY (OrderId, OrderDate)
) ON ps_OrderDate(OrderDate);

-- Create aligned index
CREATE NONCLUSTERED INDEX IX_Orders_CustomerId
ON Orders(CustomerId)
ON ps_OrderDate(OrderDate);

-- View partition info
SELECT
    p.partition_number,
    p.rows,
    prv.value AS BoundaryValue
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
LEFT JOIN sys.partition_range_values prv ON p.partition_number = prv.boundary_id + 1
WHERE i.object_id = OBJECT_ID('Orders') AND i.index_id <= 1;

-- Switch partition (instant operation for archiving)
ALTER TABLE Orders SWITCH PARTITION 1 TO OrdersArchive PARTITION 1;

-- Split partition (add new boundary)
ALTER PARTITION FUNCTION pf_OrderDate()
SPLIT RANGE ('2026-01-01');

-- Merge partition (remove boundary)
ALTER PARTITION FUNCTION pf_OrderDate()
MERGE RANGE ('2022-01-01');
```

---

### 22. Explain Always Encrypted and TDE (Transparent Data Encryption).

**Asked at: Banking/Finance companies, Security-focused roles**

```sql
-- TDE (Transparent Data Encryption)
-- Encrypts data at rest (database files)

-- Step 1: Create master key
USE master;
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'StrongPassword123!';

-- Step 2: Create certificate
CREATE CERTIFICATE TDE_Cert WITH SUBJECT = 'TDE Certificate';

-- Step 3: Create database encryption key
USE YourDatabase;
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDE_Cert;

-- Step 4: Enable TDE
ALTER DATABASE YourDatabase SET ENCRYPTION ON;

-- Check TDE status
SELECT
    db.name,
    db.is_encrypted,
    dek.encryption_state,
    dek.percent_complete
FROM sys.databases db
LEFT JOIN sys.dm_database_encryption_keys dek ON db.database_id = dek.database_id;

-- ALWAYS ENCRYPTED (Column-level encryption)
-- Data encrypted in client, stays encrypted in database

-- Create Column Master Key (CMK)
CREATE COLUMN MASTER KEY CMK_Auto1
WITH (
    KEY_STORE_PROVIDER_NAME = N'MSSQL_CERTIFICATE_STORE',
    KEY_PATH = N'CurrentUser/My/Certificate_Thumbprint'
);

-- Create Column Encryption Key (CEK)
CREATE COLUMN ENCRYPTION KEY CEK_Auto1
WITH VALUES (
    COLUMN_MASTER_KEY = CMK_Auto1,
    ALGORITHM = 'RSA_OAEP',
    ENCRYPTED_VALUE = 0x01700...
);

-- Create table with encrypted columns
CREATE TABLE Customers (
    CustomerId INT PRIMARY KEY,
    Name VARCHAR(100),
    SSN CHAR(11) COLLATE Latin1_General_BIN2
        ENCRYPTED WITH (
            COLUMN_ENCRYPTION_KEY = CEK_Auto1,
            ENCRYPTION_TYPE = Deterministic,
            ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
        ),
    CreditCard VARCHAR(20)
        ENCRYPTED WITH (
            COLUMN_ENCRYPTION_KEY = CEK_Auto1,
            ENCRYPTION_TYPE = Randomized,
            ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
        )
);
```

---

### 23. What is Change Data Capture (CDC) and Change Tracking?

**Asked at: Data Engineering roles, ETL-focused positions**

```sql
-- CHANGE DATA CAPTURE (CDC)
-- Captures full history of changes with before/after values

-- Enable CDC at database level
EXEC sys.sp_cdc_enable_db;

-- Enable CDC on table
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Employees',
    @role_name = NULL,
    @supports_net_changes = 1;

-- Query changes
DECLARE @from_lsn BINARY(10), @to_lsn BINARY(10);
SET @from_lsn = sys.fn_cdc_get_min_lsn('dbo_Employees');
SET @to_lsn = sys.fn_cdc_get_max_lsn();

-- All changes
SELECT * FROM cdc.fn_cdc_get_all_changes_dbo_Employees(@from_lsn, @to_lsn, 'all');

-- Net changes (final state only)
SELECT * FROM cdc.fn_cdc_get_net_changes_dbo_Employees(@from_lsn, @to_lsn, 'all');

-- CHANGE TRACKING
-- Lightweight, tracks only that a change occurred

-- Enable at database level
ALTER DATABASE YourDatabase SET CHANGE_TRACKING = ON
(CHANGE_RETENTION = 7 DAYS, AUTO_CLEANUP = ON);

-- Enable on table
ALTER TABLE Employees ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = ON);

-- Query changes
DECLARE @last_sync BIGINT = 0;
DECLARE @current_version BIGINT = CHANGE_TRACKING_CURRENT_VERSION();

SELECT
    ct.EmployeeId,
    ct.SYS_CHANGE_OPERATION,  -- I, U, D
    ct.SYS_CHANGE_VERSION,
    e.Name,
    e.Salary
FROM CHANGETABLE(CHANGES Employees, @last_sync) AS ct
LEFT JOIN Employees e ON ct.EmployeeId = e.EmployeeId;
```

---

## Schema Design

### 24. Explain Normalization forms with examples.

**Asked at: Every company, Database design interviews**

```sql
-- UNNORMALIZED DATA (Repeating groups)
-- OrderId | CustomerName | Products
-- 1       | John         | Laptop, Mouse, Keyboard

-- 1NF (First Normal Form)
-- - Atomic values (no repeating groups)
-- - Each column contains single value

CREATE TABLE Orders_1NF (
    OrderId INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    PRIMARY KEY (OrderId, Product)
);

-- 2NF (Second Normal Form)
-- - Must be in 1NF
-- - No partial dependencies (non-key depends on part of composite key)

CREATE TABLE Orders_2NF (
    OrderId INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

CREATE TABLE OrderDetails_2NF (
    OrderId INT,
    ProductId INT,
    Quantity INT,
    PRIMARY KEY (OrderId, ProductId),
    FOREIGN KEY (OrderId) REFERENCES Orders_2NF(OrderId)
);

-- 3NF (Third Normal Form)
-- - Must be in 2NF
-- - No transitive dependencies (non-key depends on another non-key)

-- Bad: CustomerName depends on CustomerId, not OrderId
CREATE TABLE Orders_Bad (
    OrderId INT PRIMARY KEY,
    CustomerId INT,
    CustomerName VARCHAR(100)  -- Transitive dependency!
);

-- Good: 3NF
CREATE TABLE Customers_3NF (
    CustomerId INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

CREATE TABLE Orders_3NF (
    OrderId INT PRIMARY KEY,
    CustomerId INT,
    FOREIGN KEY (CustomerId) REFERENCES Customers_3NF(CustomerId)
);

-- BCNF (Boyce-Codd Normal Form)
-- - Must be in 3NF
-- - Every determinant is a candidate key

-- 4NF - No multi-valued dependencies
-- 5NF - No join dependencies
```

---

### 25. Design a schema for an e-commerce platform.

**Asked at: Amazon, Flipkart, Walmart Labs**

```sql
-- Users
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Email VARCHAR(255) UNIQUE NOT NULL,
    PasswordHash VARBINARY(64) NOT NULL,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Phone VARCHAR(20),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2,
    IsActive BIT DEFAULT 1,
    INDEX IX_Users_Email (Email)
);

-- Addresses
CREATE TABLE Addresses (
    AddressId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    AddressType VARCHAR(20), -- Shipping, Billing
    Street VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100),
    IsDefault BIT DEFAULT 0,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

-- Categories (Self-referencing for hierarchy)
CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    ParentCategoryId INT NULL,
    Name VARCHAR(100) NOT NULL,
    Description VARCHAR(500),
    ImageUrl VARCHAR(500),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (ParentCategoryId) REFERENCES Categories(CategoryId)
);

-- Products
CREATE TABLE Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    SKU VARCHAR(50) UNIQUE NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    CategoryId INT NOT NULL,
    Brand VARCHAR(100),
    BasePrice DECIMAL(10,2) NOT NULL,
    DiscountPercentage DECIMAL(5,2) DEFAULT 0,
    StockQuantity INT DEFAULT 0,
    Weight DECIMAL(8,2),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    INDEX IX_Products_Category (CategoryId),
    INDEX IX_Products_SKU (SKU)
);

-- Product Attributes (EAV pattern for flexibility)
CREATE TABLE ProductAttributes (
    AttributeId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    AttributeName VARCHAR(100) NOT NULL,
    AttributeValue VARCHAR(500),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    INDEX IX_ProductAttr_Product (ProductId)
);

-- Product Images
CREATE TABLE ProductImages (
    ImageId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    ImageUrl VARCHAR(500) NOT NULL,
    IsPrimary BIT DEFAULT 0,
    SortOrder INT DEFAULT 0,
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

-- Shopping Cart
CREATE TABLE ShoppingCarts (
    CartId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

CREATE TABLE CartItems (
    CartItemId INT IDENTITY(1,1) PRIMARY KEY,
    CartId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    AddedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (CartId) REFERENCES ShoppingCarts(CartId),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    UNIQUE (CartId, ProductId)
);

-- Orders
CREATE TABLE Orders (
    OrderId INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber VARCHAR(50) UNIQUE NOT NULL,
    UserId INT NOT NULL,
    OrderStatus VARCHAR(50) NOT NULL, -- Pending, Confirmed, Shipped, Delivered, Cancelled
    PaymentStatus VARCHAR(50) NOT NULL, -- Pending, Paid, Failed, Refunded
    ShippingAddressId INT NOT NULL,
    BillingAddressId INT NOT NULL,
    SubTotal DECIMAL(12,2) NOT NULL,
    ShippingCost DECIMAL(10,2) DEFAULT 0,
    TaxAmount DECIMAL(10,2) DEFAULT 0,
    DiscountAmount DECIMAL(10,2) DEFAULT 0,
    TotalAmount DECIMAL(12,2) NOT NULL,
    Notes NVARCHAR(500),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2,
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (ShippingAddressId) REFERENCES Addresses(AddressId),
    FOREIGN KEY (BillingAddressId) REFERENCES Addresses(AddressId),
    INDEX IX_Orders_User (UserId),
    INDEX IX_Orders_Status (OrderStatus),
    INDEX IX_Orders_CreatedAt (CreatedAt)
);

CREATE TABLE OrderItems (
    OrderItemId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    ProductName VARCHAR(255) NOT NULL, -- Denormalized for history
    SKU VARCHAR(50) NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    DiscountAmount DECIMAL(10,2) DEFAULT 0,
    TotalPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

-- Order Status History
CREATE TABLE OrderStatusHistory (
    HistoryId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    OldStatus VARCHAR(50),
    NewStatus VARCHAR(50) NOT NULL,
    ChangedBy INT,
    ChangedAt DATETIME2 DEFAULT GETDATE(),
    Notes VARCHAR(500),
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    FOREIGN KEY (ChangedBy) REFERENCES Users(UserId)
);

-- Payments
CREATE TABLE Payments (
    PaymentId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL, -- Card, UPI, NetBanking, COD
    TransactionId VARCHAR(100),
    Amount DECIMAL(12,2) NOT NULL,
    Status VARCHAR(50) NOT NULL,
    PaymentDate DATETIME2,
    GatewayResponse NVARCHAR(MAX),
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId)
);

-- Reviews
CREATE TABLE Reviews (
    ReviewId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    UserId INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Title VARCHAR(200),
    Comment NVARCHAR(MAX),
    IsVerifiedPurchase BIT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    INDEX IX_Reviews_Product (ProductId)
);
```

---

### 26. Design patterns: When to denormalize?

**Asked at: Amazon, Google, Meta, Senior roles**

```sql
-- DENORMALIZATION SCENARIOS:

-- 1. Reporting/Analytics tables
CREATE TABLE SalesSummary (
    SummaryId INT IDENTITY(1,1) PRIMARY KEY,
    Date DATE,
    ProductId INT,
    ProductName VARCHAR(255), -- Denormalized
    CategoryName VARCHAR(100), -- Denormalized
    TotalQuantity INT,
    TotalRevenue DECIMAL(15,2),
    INDEX IX_SalesSummary_Date (Date)
);

-- 2. Frequently accessed computed values
ALTER TABLE Products ADD
    AverageRating DECIMAL(3,2),
    ReviewCount INT DEFAULT 0;

-- Update trigger to maintain denormalized data
CREATE TRIGGER tr_Reviews_UpdateProductRating
ON Reviews
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE p SET
        AverageRating = r.AvgRating,
        ReviewCount = r.TotalCount
    FROM Products p
    INNER JOIN (
        SELECT ProductId, AVG(CAST(Rating AS DECIMAL(3,2))) AS AvgRating, COUNT(*) AS TotalCount
        FROM Reviews
        WHERE ProductId IN (SELECT ProductId FROM inserted UNION SELECT ProductId FROM deleted)
        GROUP BY ProductId
    ) r ON p.ProductId = r.ProductId;
END;

-- 3. Historical data preservation
CREATE TABLE OrderItems (
    -- Store product details at time of order
    ProductName VARCHAR(255), -- Even if product is deleted/renamed
    UnitPrice DECIMAL(10,2),  -- Price at time of order
    SKU VARCHAR(50)
);

-- 4. Search optimization
CREATE TABLE ProductSearch (
    ProductId INT PRIMARY KEY,
    SearchText NVARCHAR(MAX), -- Concatenated searchable fields
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

-- Full-text index for search
CREATE FULLTEXT INDEX ON ProductSearch(SearchText)
KEY INDEX PK_ProductSearch;
```

---

## Performance Tuning

### 27. How to identify and fix slow queries?

**Asked at: Amazon, Microsoft, Google, Every senior role**

```sql
-- 1. Find expensive queries using DMVs
SELECT TOP 20
    qs.total_elapsed_time / qs.execution_count AS avg_elapsed_time,
    qs.execution_count,
    qs.total_logical_reads / qs.execution_count AS avg_logical_reads,
    qs.total_worker_time / qs.execution_count AS avg_cpu_time,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1) AS query_text,
    qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY avg_elapsed_time DESC;

-- 2. Find queries with high I/O
SELECT TOP 20
    total_logical_reads + total_logical_writes AS total_io,
    execution_count,
    (total_logical_reads + total_logical_writes) / execution_count AS avg_io,
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(st.text)
        ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1) AS query_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY total_io DESC;

-- 3. Index usage statistics
SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    ius.last_user_seek,
    ius.last_user_scan
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id AND i.index_id = ius.index_id
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY ius.user_seeks + ius.user_scans + ius.user_lookups DESC;

-- 4. Unused indexes (candidates for removal)
SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc,
    ius.user_seeks,
    ius.user_scans,
    ius.user_updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id AND i.index_id = ius.index_id
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
    AND i.type_desc = 'NONCLUSTERED'
    AND (ius.user_seeks + ius.user_scans + ius.user_lookups) < ius.user_updates
ORDER BY ius.user_updates DESC;

-- 5. Wait statistics
SELECT TOP 10
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    max_wait_time_ms,
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE '%SLEEP%'
    AND wait_type NOT LIKE '%IDLE%'
    AND wait_type NOT LIKE '%QUEUE%'
ORDER BY wait_time_ms DESC;

-- 6. Query hints for optimization
-- Force index
SELECT * FROM Employees WITH (INDEX(IX_Employees_DeptId))
WHERE DepartmentId = 5;

-- Force join type
SELECT * FROM Employees e
INNER HASH JOIN Departments d ON e.DepartmentId = d.DepartmentId;

-- Recompile for parameter sniffing issues
SELECT * FROM Employees WHERE DepartmentId = @DeptId
OPTION (RECOMPILE);

-- Optimize for unknown
SELECT * FROM Employees WHERE DepartmentId = @DeptId
OPTION (OPTIMIZE FOR UNKNOWN);
```

---

### 28. Index optimization strategies.

**Asked at: Microsoft, Amazon, Oracle, DBA roles**

```sql
-- 1. Analyze index fragmentation
SELECT
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc,
    ips.avg_fragmentation_in_percent,
    ips.page_count,
    ips.record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- 2. Defragment indexes
-- Reorganize (light, online): 10-30% fragmentation
ALTER INDEX IX_Employees_Name ON Employees REORGANIZE;

-- Rebuild (heavy, can be offline): >30% fragmentation
ALTER INDEX IX_Employees_Name ON Employees REBUILD WITH (ONLINE = ON);

-- Rebuild all indexes on table
ALTER INDEX ALL ON Employees REBUILD;

-- 3. Update statistics
UPDATE STATISTICS Employees;
UPDATE STATISTICS Employees IX_Employees_Name;

-- Update with full scan for accuracy
UPDATE STATISTICS Employees WITH FULLSCAN;

-- 4. Columnstore indexes (for analytics/DW)
CREATE CLUSTERED COLUMNSTORE INDEX CCI_Sales ON SalesHistory;

CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_Orders
ON Orders (OrderDate, CustomerId, TotalAmount)
WHERE OrderDate >= '2024-01-01';

-- 5. Index maintenance script
DECLARE @TableName NVARCHAR(255), @IndexName NVARCHAR(255), @Fragmentation FLOAT;

DECLARE IndexCursor CURSOR FOR
SELECT OBJECT_NAME(ips.object_id), i.name, ips.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10 AND ips.page_count > 1000;

OPEN IndexCursor;
FETCH NEXT FROM IndexCursor INTO @TableName, @IndexName, @Fragmentation;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @Fragmentation BETWEEN 10 AND 30
        EXEC('ALTER INDEX ' + @IndexName + ' ON ' + @TableName + ' REORGANIZE');
    ELSE IF @Fragmentation > 30
        EXEC('ALTER INDEX ' + @IndexName + ' ON ' + @TableName + ' REBUILD WITH (ONLINE = ON)');

    FETCH NEXT FROM IndexCursor INTO @TableName, @IndexName, @Fragmentation;
END;

CLOSE IndexCursor;
DEALLOCATE IndexCursor;
```

---

### 29. Query Store for performance monitoring.

**Asked at: Microsoft, Azure-focused roles**

```sql
-- Enable Query Store
ALTER DATABASE YourDatabase SET QUERY_STORE = ON;

-- Configure Query Store
ALTER DATABASE YourDatabase SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 1024,
    QUERY_CAPTURE_MODE = AUTO,
    SIZE_BASED_CLEANUP_MODE = AUTO
);

-- Find regressed queries
SELECT
    q.query_id,
    qt.query_sql_text,
    rs1.avg_duration AS recent_avg_duration,
    rs2.avg_duration AS historical_avg_duration,
    (rs1.avg_duration - rs2.avg_duration) / rs2.avg_duration * 100 AS regression_percent
FROM sys.query_store_query q
INNER JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
INNER JOIN sys.query_store_plan p ON q.query_id = p.query_id
INNER JOIN sys.query_store_runtime_stats rs1 ON p.plan_id = rs1.plan_id
INNER JOIN sys.query_store_runtime_stats rs2 ON p.plan_id = rs2.plan_id
INNER JOIN sys.query_store_runtime_stats_interval rsi1 ON rs1.runtime_stats_interval_id = rsi1.runtime_stats_interval_id
INNER JOIN sys.query_store_runtime_stats_interval rsi2 ON rs2.runtime_stats_interval_id = rsi2.runtime_stats_interval_id
WHERE rsi1.start_time > DATEADD(day, -1, GETDATE())  -- Recent
    AND rsi2.start_time BETWEEN DATEADD(day, -30, GETDATE()) AND DATEADD(day, -7, GETDATE())  -- Historical
    AND rs2.avg_duration > 0
    AND (rs1.avg_duration - rs2.avg_duration) / rs2.avg_duration > 0.5  -- 50% regression
ORDER BY regression_percent DESC;

-- Force a specific plan
EXEC sp_query_store_force_plan @query_id = 1234, @plan_id = 5678;

-- Unforce plan
EXEC sp_query_store_unforce_plan @query_id = 1234, @plan_id = 5678;

-- Clear Query Store
ALTER DATABASE YourDatabase SET QUERY_STORE CLEAR;
```

---

## Data Migration to Azure

### 30. What are the options for migrating SQL Server to Azure?

**Asked at: Microsoft, Azure-focused companies**

```
Migration Options:

1. Azure SQL Database (PaaS)
   - Fully managed, serverless option available
   - Auto-scaling, built-in HA
   - Best for: New applications, cloud-native apps

2. Azure SQL Managed Instance
   - Near 100% compatibility with on-premises SQL Server
   - Supports SQL Agent, cross-database queries, CLR
   - Best for: Lift-and-shift with minimal changes

3. SQL Server on Azure VMs (IaaS)
   - Full control over SQL Server instance
   - Same as on-premises
   - Best for: Applications requiring OS-level access

Migration Tools:
- Azure Database Migration Service (DMS)
- Data Migration Assistant (DMA)
- Azure Migrate
- BACPAC export/import
- Transactional Replication
- Log Shipping (for VMs)
```

---

### 31. How to use Azure Database Migration Service?

**Asked at: Microsoft, Cloud migration roles**

```sql
-- Pre-migration assessment using DMA
-- 1. Download and run Data Migration Assistant
-- 2. Assess compatibility issues
-- 3. Get SKU recommendations

-- Online migration steps (minimal downtime):

-- Step 1: Create Azure SQL Database/MI target
-- Using Azure Portal or CLI

-- Step 2: Configure DMS
-- Create DMS instance in Azure Portal
-- Create migration project

-- Step 3: Schema migration
-- Use DMA to migrate schema first

-- Step 4: Configure source database for CDC
-- For online migration
ALTER DATABASE YourDatabase SET CHANGE_TRACKING = ON;

-- Or enable CDC
EXEC sys.sp_cdc_enable_db;

-- Step 5: Start data migration
-- DMS handles initial data copy + continuous sync

-- Step 6: Cutover
-- When ready, perform cutover to complete migration

-- Post-migration validation
-- Compare row counts
SELECT
    t.name AS TableName,
    p.rows AS RowCount
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
ORDER BY t.name;

-- Compare checksums for critical tables
SELECT CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM Employees;
```

---

### 32. Explain BACPAC export/import for Azure migration.

**Asked at: Azure migration interviews**

```sql
-- BACPAC = Schema + Data (portable format)

-- Export using SSMS
-- Right-click database -> Tasks -> Export Data-tier Application

-- Export using SqlPackage.exe (command line)
-- SqlPackage.exe /Action:Export /SourceServerName:localhost
--   /SourceDatabaseName:MyDB /TargetFile:MyDB.bacpac

-- Import using SqlPackage.exe
-- SqlPackage.exe /Action:Import /TargetServerName:myserver.database.windows.net
--   /TargetDatabaseName:MyDB /SourceFile:MyDB.bacpac
--   /TargetUser:admin /TargetPassword:password

-- Export using T-SQL (to Azure Blob Storage)
-- Azure SQL Database only
-- Use Azure Portal or PowerShell

-- PowerShell export
/*
$exportRequest = New-AzSqlDatabaseExport -ResourceGroupName "MyRG" `
    -ServerName "myserver" -DatabaseName "MyDB" `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey $storageKey `
    -StorageUri "https://mystorageaccount.blob.core.windows.net/backups/MyDB.bacpac" `
    -AdministratorLogin "admin" `
    -AdministratorLoginPassword $securePassword
*/

-- Best practices for large databases:
-- 1. Use SqlPackage with /p:CommandTimeout=0 for long operations
-- 2. Export during off-peak hours
-- 3. Consider using Azure Data Factory for very large databases
-- 4. Use Premium storage for faster I/O

-- Limitations:
-- - Max size limit (different by tier)
-- - No support for certain features (filestream, etc.)
-- - Single-threaded operation
```

---

### 33. How to set up Geo-Replication in Azure SQL Database?

**Asked at: Azure solution architect roles**

```sql
-- Active Geo-Replication
-- Create secondary in different region

-- Using T-SQL
ALTER DATABASE MyDatabase
ADD SECONDARY ON SERVER myserver-secondary
WITH (ALLOW_CONNECTIONS = ALL);

-- Check replication status
SELECT
    link_guid,
    partner_server,
    partner_database,
    replication_state_desc,
    role_desc,
    secondary_allow_connections_desc
FROM sys.geo_replication_links;

-- Check replication lag
SELECT
    ag.name AS AvailabilityGroupName,
    ar.replica_server_name,
    drs.synchronization_state_desc,
    drs.last_commit_time
FROM sys.dm_hadr_database_replica_states drs
INNER JOIN sys.availability_replicas ar ON drs.replica_id = ar.replica_id
INNER JOIN sys.availability_groups ag ON ar.group_id = ag.group_id;

-- Failover to secondary (planned)
ALTER DATABASE MyDatabase FAILOVER;

-- Failover (forced - data loss possible)
ALTER DATABASE MyDatabase FORCE_FAILOVER_ALLOW_DATA_LOSS;

-- Auto-Failover Groups (recommended)
-- Provides automatic failover with read-write listener

-- Create failover group (Azure CLI/Portal)
/*
az sql failover-group create \
    --name myfailovergroup \
    --partner-server myserver-secondary \
    --resource-group MyRG \
    --server myserver \
    --add-db MyDatabase \
    --failover-policy Automatic \
    --grace-period 1
*/

-- Connection string with failover group
-- Server: myfailovergroup.database.windows.net
-- Automatically routes to current primary
```

---

### 34. Explain Azure SQL Database pricing tiers and performance considerations.

**Asked at: Azure architecture interviews**

```
DTU-based Model:
- Basic: 5 DTUs, 2GB storage
- Standard: S0-S12 (10-3000 DTUs)
- Premium: P1-P15 (125-4000 DTUs)

vCore-based Model:
- General Purpose: Budget-friendly, remote storage
- Business Critical: Local SSD, built-in HA read replica
- Hyperscale: Up to 100TB, rapid scale-out

Serverless:
- Auto-pause after inactivity
- Auto-scale within min/max vCores
- Pay per second of compute used
```

```sql
-- Check current service tier
SELECT
    database_id,
    edition,
    service_objective,
    elastic_pool_name
FROM sys.database_service_objectives;

-- Check resource usage
SELECT
    end_time,
    avg_cpu_percent,
    avg_data_io_percent,
    avg_log_write_percent,
    avg_memory_usage_percent,
    max_worker_percent,
    max_session_percent
FROM sys.dm_db_resource_stats
ORDER BY end_time DESC;

-- Scale up (change service tier)
ALTER DATABASE MyDatabase
MODIFY (SERVICE_OBJECTIVE = 'S3');

-- Move to elastic pool
ALTER DATABASE MyDatabase
MODIFY (SERVICE_OBJECTIVE = ELASTIC_POOL(name = MyElasticPool));

-- Performance recommendations
SELECT * FROM sys.dm_db_tuning_recommendations;

-- Enable automatic tuning
ALTER DATABASE MyDatabase
SET AUTOMATIC_TUNING (CREATE_INDEX = ON, DROP_INDEX = ON, FORCE_LAST_GOOD_PLAN = ON);
```

---

## Scenario-Based Questions

### 35. Find employees earning more than their managers.

**Asked at: Amazon, Google, Facebook, Every product company**

**Sample Data - Employees:**
| EmployeeId | Name    | Salary | ManagerId |
|------------|---------|--------|-----------|
| 1          | Alice   | 100000 | NULL      |
| 2          | Bob     | 80000  | 1         |
| 3          | Charlie | 90000  | 1         |
| 4          | David   | 85000  | 2         |
| 5          | Eve     | 95000  | 2         |

```sql
SELECT
    e.EmployeeId,
    e.Name AS EmployeeName,
    e.Salary AS EmployeeSalary,
    m.Name AS ManagerName,
    m.Salary AS ManagerSalary
FROM Employees e
INNER JOIN Employees m ON e.ManagerId = m.EmployeeId
WHERE e.Salary > m.Salary;
```

**Result:**
| EmployeeId | EmployeeName | EmployeeSalary | ManagerName | ManagerSalary |
|------------|--------------|----------------|-------------|---------------|
| 4          | David        | 85000          | Bob         | 80000         |
| 5          | Eve          | 95000          | Bob         | 80000         |

---

### 36. Find duplicate records in a table.

**Asked at: Every company**

**Sample Data - Employees:**
| EmployeeId | Name    | Email              |
|------------|---------|-------------------|
| 1          | Alice   | alice@email.com   |
| 2          | Bob     | bob@email.com     |
| 3          | Charlie | alice@email.com   |
| 4          | David   | david@email.com   |
| 5          | Eve     | bob@email.com     |
| 6          | Frank   | bob@email.com     |

```sql
-- Find duplicates based on specific columns
SELECT Email, COUNT(*) AS DuplicateCount
FROM Employees
GROUP BY Email
HAVING COUNT(*) > 1;
```

**Result:**
| Email           | DuplicateCount |
|-----------------|----------------|
| alice@email.com | 2              |
| bob@email.com   | 3              |

```sql
-- Get all duplicate rows with details
WITH DuplicateCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY Email ORDER BY EmployeeId) AS RowNum
    FROM Employees
)
SELECT EmployeeId, Name, Email, RowNum FROM DuplicateCTE WHERE RowNum > 1;
```

**Result (Duplicate rows to delete):**
| EmployeeId | Name    | Email           | RowNum |
|------------|---------|-----------------|--------|
| 3          | Charlie | alice@email.com | 2      |
| 5          | Eve     | bob@email.com   | 2      |
| 6          | Frank   | bob@email.com   | 3      |

```sql
-- Delete duplicates keeping first occurrence
WITH DuplicateCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY Email ORDER BY EmployeeId) AS RowNum
    FROM Employees
)
DELETE FROM DuplicateCTE WHERE RowNum > 1;
-- Deletes 3 rows (EmployeeId: 3, 5, 6)
```

---

### 37. Find consecutive login days for users.

**Asked at: Meta, Google, Uber**

**Sample Data - UserLogins:**
| UserId | LoginTime           |
|--------|---------------------|
| 1      | 2024-01-01 10:00:00 |
| 1      | 2024-01-02 11:00:00 |
| 1      | 2024-01-03 09:00:00 |
| 1      | 2024-01-05 14:00:00 |
| 1      | 2024-01-06 10:00:00 |
| 2      | 2024-01-01 08:00:00 |
| 2      | 2024-01-03 12:00:00 |

```sql
-- Find users with 3+ consecutive login days
WITH LoginDates AS (
    SELECT DISTINCT UserId, CAST(LoginTime AS DATE) AS LoginDate
    FROM UserLogins
),
ConsecutiveGroups AS (
    SELECT UserId, LoginDate,
        DATEADD(DAY, -ROW_NUMBER() OVER (PARTITION BY UserId ORDER BY LoginDate), LoginDate) AS GroupDate
    FROM LoginDates
),
ConsecutiveCount AS (
    SELECT UserId, GroupDate,
        COUNT(*) AS ConsecutiveDays,
        MIN(LoginDate) AS StartDate,
        MAX(LoginDate) AS EndDate
    FROM ConsecutiveGroups
    GROUP BY UserId, GroupDate
)
SELECT UserId, ConsecutiveDays, StartDate, EndDate
FROM ConsecutiveCount
WHERE ConsecutiveDays >= 3
ORDER BY UserId, StartDate;
```

**How It Works (Step by Step for UserId = 1):**

| LoginDate  | ROW_NUMBER | GroupDate (LoginDate - RowNum) |
|------------|------------|--------------------------------|
| 2024-01-01 | 1          | 2023-12-31                     |
| 2024-01-02 | 2          | 2023-12-31                     |
| 2024-01-03 | 3          | 2023-12-31                     |
| 2024-01-05 | 4          | 2024-01-01                     |
| 2024-01-06 | 5          | 2024-01-01                     |

> Consecutive dates get the **same GroupDate**!

**Final Result:**
| UserId | ConsecutiveDays | StartDate  | EndDate    |
|--------|-----------------|------------|------------|
| 1      | 3               | 2024-01-01 | 2024-01-03 |

---

### 38. Find gaps in sequential data.

**Asked at: Goldman Sachs, Morgan Stanley**

**Sample Data - Orders:**
| OrderNumber |
|-------------|
| 1001        |
| 1002        |
| 1003        |
| 1006        |
| 1007        |
| 1010        |

```sql
-- Find missing order numbers (gap ranges)
WITH NumberSequence AS (
    SELECT OrderNumber,
        LEAD(OrderNumber) OVER (ORDER BY OrderNumber) AS NextOrderNumber
    FROM Orders
)
SELECT
    OrderNumber + 1 AS GapStart,
    NextOrderNumber - 1 AS GapEnd
FROM NumberSequence
WHERE NextOrderNumber - OrderNumber > 1;
```

**Result:**
| GapStart | GapEnd |
|----------|--------|
| 1004     | 1005   |
| 1008     | 1009   |

```sql
-- Generate all missing numbers
WITH NumberRange AS (
    SELECT MIN(OrderNumber) AS MinNum, MAX(OrderNumber) AS MaxNum FROM Orders
),
AllNumbers AS (
    SELECT MinNum AS Num FROM NumberRange
    UNION ALL
    SELECT Num + 1 FROM AllNumbers, NumberRange WHERE Num < MaxNum
)
SELECT Num AS MissingOrderNumber
FROM AllNumbers
WHERE Num NOT IN (SELECT OrderNumber FROM Orders)
OPTION (MAXRECURSION 10000);
```

**Result:**
| MissingOrderNumber |
|--------------------|
| 1004               |
| 1005               |
| 1008               |
| 1009               |

---

### 39. Calculate running total and moving average.

**Asked at: Finance companies, Data analyst roles**

**Sample Data - Orders:**
| OrderDate  | Category | Amount |
|------------|----------|--------|
| 2024-01-01 | A        | 100    |
| 2024-01-02 | A        | 150    |
| 2024-01-03 | B        | 200    |
| 2024-01-04 | A        | 120    |
| 2024-01-05 | B        | 180    |

```sql
-- Running total
SELECT OrderDate, Amount,
    SUM(Amount) OVER (ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS RunningTotal
FROM Orders;
```

**Result:**
| OrderDate  | Amount | RunningTotal |
|------------|--------|--------------|
| 2024-01-01 | 100    | 100          |
| 2024-01-02 | 150    | 250          |
| 2024-01-03 | 200    | 450          |
| 2024-01-04 | 120    | 570          |
| 2024-01-05 | 180    | 750          |

```sql
-- Running total by category (PARTITION BY)
SELECT Category, OrderDate, Amount,
    SUM(Amount) OVER (PARTITION BY Category ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS RunningTotal
FROM Orders;
```

**Result:**
| Category | OrderDate  | Amount | RunningTotal |
|----------|------------|--------|--------------|
| A        | 2024-01-01 | 100    | 100          |
| A        | 2024-01-02 | 150    | 250          |
| A        | 2024-01-04 | 120    | 370          |
| B        | 2024-01-03 | 200    | 200          |
| B        | 2024-01-05 | 180    | 380          |

```sql
-- Moving average (last 3 rows)
SELECT OrderDate, Amount,
    ROUND(AVG(Amount * 1.0) OVER (ORDER BY OrderDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS MovingAvg3
FROM Orders;
```

**Result:**
| OrderDate  | Amount | MovingAvg3 |
|------------|--------|------------|
| 2024-01-01 | 100    | 100.00     |
| 2024-01-02 | 150    | 125.00     |
| 2024-01-03 | 200    | 150.00     |
| 2024-01-04 | 120    | 156.67     |
| 2024-01-05 | 180    | 166.67     |

```sql
-- YTD (Year-to-Date) calculation
SELECT OrderDate, Amount,
    SUM(Amount) OVER (PARTITION BY YEAR(OrderDate) ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS YTDAmount
FROM Orders;
```

---

### 40. Implement pagination efficiently.

**Asked at: Every company building APIs**

**Sample Data - Products:**
| ProductId | Name       | Price |
|-----------|------------|-------|
| 1         | Apple      | 1.00  |
| 2         | Banana     | 0.50  |
| 3         | Cherry     | 2.00  |
| 4         | Date       | 3.00  |
| 5         | Elderberry | 4.00  |
| 6         | Fig        | 2.50  |
| 7         | Grape      | 1.50  |
| 8         | Honeydew   | 5.00  |

```sql
-- Method 1: OFFSET-FETCH (SQL Server 2012+)
DECLARE @PageSize INT = 3, @PageNumber INT = 2;

SELECT ProductId, Name, Price
FROM Products
ORDER BY ProductId
OFFSET (@PageNumber - 1) * @PageSize ROWS  -- Skip first 3 rows
FETCH NEXT @PageSize ROWS ONLY;            -- Take next 3 rows
```

**Result (Page 2, 3 items per page):**
| ProductId | Name   | Price |
|-----------|--------|-------|
| 4         | Date   | 3.00  |
| 5         | Elderberry | 4.00 |
| 6         | Fig    | 2.50  |

```sql
-- Method 2: Keyset pagination (more efficient for large datasets)
DECLARE @LastProductId INT = 3;  -- Last ID from previous page
DECLARE @PageSize INT = 3;

SELECT TOP (@PageSize) ProductId, Name, Price
FROM Products
WHERE ProductId > @LastProductId
ORDER BY ProductId;
```

**Result:**
| ProductId | Name       | Price |
|-----------|------------|-------|
| 4         | Date       | 3.00  |
| 5         | Elderberry | 4.00  |
| 6         | Fig        | 2.50  |

```sql
-- Method 3: ROW_NUMBER with TotalCount
DECLARE @PageSize INT = 3, @PageNumber INT = 2;

WITH PaginatedProducts AS (
    SELECT ProductId, Name, Price,
        ROW_NUMBER() OVER (ORDER BY ProductId) AS RowNum,
        COUNT(*) OVER () AS TotalCount
    FROM Products
)
SELECT ProductId, Name, Price, TotalCount
FROM PaginatedProducts
WHERE RowNum BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize);
```

**Result:**
| ProductId | Name       | Price | TotalCount |
|-----------|------------|-------|------------|
| 4         | Date       | 3.00  | 8          |
| 5         | Elderberry | 4.00  | 8          |
| 6         | Fig        | 2.50  | 8          |

---

### 41. Write a query to find median salary.

**Asked at: Amazon, Microsoft, Google**

```sql
-- Method 1: Using PERCENTILE_CONT (SQL Server 2012+)
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Salary) OVER () AS MedianSalary
FROM Employees;

-- Method 2: Using ROW_NUMBER
WITH OrderedSalaries AS (
    SELECT
        Salary,
        ROW_NUMBER() OVER (ORDER BY Salary) AS RowNum,
        COUNT(*) OVER () AS TotalCount
    FROM Employees
)
SELECT AVG(Salary) AS MedianSalary
FROM OrderedSalaries
WHERE RowNum IN ((TotalCount + 1) / 2, (TotalCount + 2) / 2);

-- Median by department
SELECT
    DepartmentId,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Salary) OVER (PARTITION BY DepartmentId) AS MedianSalary
FROM Employees;
```

---

### 42. Implement a hierarchical query (org chart).

**Asked at: Oracle, Microsoft, Consulting companies**

```sql
-- Recursive CTE for organization hierarchy
WITH OrgHierarchy AS (
    -- Anchor: CEO/Top-level
    SELECT
        EmployeeId,
        Name,
        ManagerId,
        Title,
        0 AS Level,
        CAST(Name AS VARCHAR(1000)) AS Path
    FROM Employees
    WHERE ManagerId IS NULL

    UNION ALL

    -- Recursive: Get subordinates
    SELECT
        e.EmployeeId,
        e.Name,
        e.ManagerId,
        e.Title,
        oh.Level + 1,
        CAST(oh.Path + ' > ' + e.Name AS VARCHAR(1000))
    FROM Employees e
    INNER JOIN OrgHierarchy oh ON e.ManagerId = oh.EmployeeId
)
SELECT
    REPLICATE('  ', Level) + Name AS EmployeeName,
    Title,
    Level,
    Path
FROM OrgHierarchy
ORDER BY Path
OPTION (MAXRECURSION 100);

-- Find all subordinates of a manager
WITH Subordinates AS (
    SELECT EmployeeId, Name, ManagerId
    FROM Employees
    WHERE ManagerId = 5  -- Manager's ID

    UNION ALL

    SELECT e.EmployeeId, e.Name, e.ManagerId
    FROM Employees e
    INNER JOIN Subordinates s ON e.ManagerId = s.EmployeeId
)
SELECT * FROM Subordinates;

-- Count subordinates at each level
WITH OrgHierarchy AS (
    SELECT EmployeeId, Name, ManagerId, 0 AS Level
    FROM Employees
    WHERE ManagerId IS NULL

    UNION ALL

    SELECT e.EmployeeId, e.Name, e.ManagerId, oh.Level + 1
    FROM Employees e
    INNER JOIN OrgHierarchy oh ON e.ManagerId = oh.EmployeeId
)
SELECT Level, COUNT(*) AS EmployeeCount
FROM OrgHierarchy
GROUP BY Level
ORDER BY Level;
```

---

### 43. Handle slowly changing dimensions (SCD).

**Asked at: Data warehouse roles, ETL interviews**

```sql
-- SCD Type 1: Overwrite (no history)
UPDATE DimCustomer
SET Address = @NewAddress, City = @NewCity
WHERE CustomerKey = @CustomerKey;

-- SCD Type 2: Add new row (full history)
CREATE TABLE DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL,
    Name VARCHAR(100),
    Address VARCHAR(200),
    City VARCHAR(100),
    EffectiveDate DATE NOT NULL,
    ExpiryDate DATE,
    IsCurrent BIT NOT NULL DEFAULT 1
);

-- Process SCD Type 2 change
BEGIN TRANSACTION;
    -- Expire current record
    UPDATE DimCustomer
    SET ExpiryDate = DATEADD(DAY, -1, GETDATE()),
        IsCurrent = 0
    WHERE CustomerId = @CustomerId AND IsCurrent = 1;

    -- Insert new record
    INSERT INTO DimCustomer (CustomerId, Name, Address, City, EffectiveDate, IsCurrent)
    VALUES (@CustomerId, @Name, @NewAddress, @NewCity, GETDATE(), 1);
COMMIT;

-- SCD Type 3: Add column for previous value
CREATE TABLE DimCustomer_Type3 (
    CustomerKey INT PRIMARY KEY,
    CustomerId INT,
    Name VARCHAR(100),
    CurrentAddress VARCHAR(200),
    PreviousAddress VARCHAR(200),
    AddressChangeDate DATE
);

-- Update Type 3
UPDATE DimCustomer_Type3
SET PreviousAddress = CurrentAddress,
    CurrentAddress = @NewAddress,
    AddressChangeDate = GETDATE()
WHERE CustomerId = @CustomerId;

-- SCD Type 4: History table
CREATE TABLE DimCustomer_Current (
    CustomerId INT PRIMARY KEY,
    Name VARCHAR(100),
    Address VARCHAR(200)
);

CREATE TABLE DimCustomer_History (
    HistoryId INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT,
    Name VARCHAR(100),
    Address VARCHAR(200),
    ValidFrom DATE,
    ValidTo DATE
);
```

---

### 44. Write a query to detect fraud patterns.

**Asked at: Banking/Finance companies**

```sql
-- Detect multiple transactions from same user in short time
WITH TransactionPairs AS (
    SELECT
        t1.TransactionId AS Trans1,
        t2.TransactionId AS Trans2,
        t1.UserId,
        t1.Amount AS Amount1,
        t2.Amount AS Amount2,
        t1.TransactionTime AS Time1,
        t2.TransactionTime AS Time2,
        DATEDIFF(SECOND, t1.TransactionTime, t2.TransactionTime) AS SecondsBetween
    FROM Transactions t1
    INNER JOIN Transactions t2 ON t1.UserId = t2.UserId
        AND t1.TransactionId < t2.TransactionId
        AND DATEDIFF(MINUTE, t1.TransactionTime, t2.TransactionTime) <= 5
)
SELECT * FROM TransactionPairs WHERE SecondsBetween < 60;

-- Detect unusual transaction amounts (statistical anomaly)
WITH UserStats AS (
    SELECT
        UserId,
        AVG(Amount) AS AvgAmount,
        STDEV(Amount) AS StdDevAmount
    FROM Transactions
    WHERE TransactionTime >= DATEADD(MONTH, -3, GETDATE())
    GROUP BY UserId
),
SuspiciousTransactions AS (
    SELECT
        t.*,
        us.AvgAmount,
        us.StdDevAmount,
        (t.Amount - us.AvgAmount) / NULLIF(us.StdDevAmount, 0) AS ZScore
    FROM Transactions t
    INNER JOIN UserStats us ON t.UserId = us.UserId
    WHERE t.TransactionTime >= DATEADD(DAY, -1, GETDATE())
)
SELECT * FROM SuspiciousTransactions
WHERE ABS(ZScore) > 3;  -- More than 3 standard deviations

-- Detect transactions from multiple locations
SELECT
    UserId,
    COUNT(DISTINCT City) AS DistinctCities,
    STRING_AGG(City, ', ') AS Cities
FROM Transactions
WHERE TransactionTime >= DATEADD(HOUR, -1, GETDATE())
GROUP BY UserId
HAVING COUNT(DISTINCT City) > 1;
```

---

### 45. Implement rate limiting logic in SQL.

**Asked at: API/Backend roles**

```sql
-- Rate limiting table
CREATE TABLE RateLimits (
    RateLimitId INT IDENTITY(1,1) PRIMARY KEY,
    ApiKey VARCHAR(100) NOT NULL,
    WindowStart DATETIME2 NOT NULL,
    RequestCount INT NOT NULL DEFAULT 1,
    INDEX IX_RateLimits_ApiKey (ApiKey, WindowStart)
);

-- Check and update rate limit (sliding window)
CREATE PROCEDURE sp_CheckRateLimit
    @ApiKey VARCHAR(100),
    @MaxRequests INT = 100,
    @WindowMinutes INT = 1,
    @IsAllowed BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @WindowStart DATETIME2 = DATEADD(MINUTE, -@WindowMinutes, GETDATE());
    DECLARE @CurrentCount INT;

    -- Get current request count in window
    SELECT @CurrentCount = SUM(RequestCount)
    FROM RateLimits
    WHERE ApiKey = @ApiKey AND WindowStart >= @WindowStart;

    IF @CurrentCount IS NULL SET @CurrentCount = 0;

    IF @CurrentCount >= @MaxRequests
    BEGIN
        SET @IsAllowed = 0;
        RETURN;
    END

    -- Record this request
    INSERT INTO RateLimits (ApiKey, WindowStart, RequestCount)
    VALUES (@ApiKey, GETDATE(), 1);

    -- Cleanup old records
    DELETE FROM RateLimits
    WHERE WindowStart < DATEADD(MINUTE, -@WindowMinutes * 2, GETDATE());

    SET @IsAllowed = 1;
END;

-- Token bucket implementation
CREATE TABLE TokenBuckets (
    ApiKey VARCHAR(100) PRIMARY KEY,
    Tokens DECIMAL(10,2) NOT NULL,
    LastRefill DATETIME2 NOT NULL
);

CREATE PROCEDURE sp_ConsumeToken
    @ApiKey VARCHAR(100),
    @MaxTokens DECIMAL(10,2) = 100,
    @RefillRate DECIMAL(10,2) = 10, -- tokens per second
    @IsAllowed BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentTokens DECIMAL(10,2);
    DECLARE @LastRefill DATETIME2;
    DECLARE @Now DATETIME2 = GETDATE();

    -- Get or create bucket
    SELECT @CurrentTokens = Tokens, @LastRefill = LastRefill
    FROM TokenBuckets WHERE ApiKey = @ApiKey;

    IF @CurrentTokens IS NULL
    BEGIN
        INSERT INTO TokenBuckets (ApiKey, Tokens, LastRefill)
        VALUES (@ApiKey, @MaxTokens - 1, @Now);
        SET @IsAllowed = 1;
        RETURN;
    END

    -- Refill tokens based on time elapsed
    DECLARE @ElapsedSeconds DECIMAL(10,2) = DATEDIFF(MILLISECOND, @LastRefill, @Now) / 1000.0;
    DECLARE @NewTokens DECIMAL(10,2) = @CurrentTokens + (@ElapsedSeconds * @RefillRate);

    IF @NewTokens > @MaxTokens SET @NewTokens = @MaxTokens;

    IF @NewTokens >= 1
    BEGIN
        UPDATE TokenBuckets
        SET Tokens = @NewTokens - 1, LastRefill = @Now
        WHERE ApiKey = @ApiKey;
        SET @IsAllowed = 1;
    END
    ELSE
    BEGIN
        SET @IsAllowed = 0;
    END
END;
```

---

## Quick Reference - Common Interview Patterns

### String Functions
```sql
LEN(), DATALENGTH(), LEFT(), RIGHT(), SUBSTRING()
CHARINDEX(), PATINDEX(), REPLACE(), STUFF()
UPPER(), LOWER(), LTRIM(), RTRIM(), TRIM()
CONCAT(), CONCAT_WS(), STRING_AGG(), STRING_SPLIT()
FORMAT(), REPLICATE(), REVERSE()
```

### Date Functions
```sql
GETDATE(), GETUTCDATE(), SYSDATETIME()
DATEADD(), DATEDIFF(), DATEDIFF_BIG()
DATEPART(), DATENAME(), DAY(), MONTH(), YEAR()
EOMONTH(), DATEFROMPARTS(), ISDATE()
FORMAT(date, 'yyyy-MM-dd')
```

### Important System Views
```sql
sys.tables, sys.columns, sys.indexes
sys.dm_exec_requests, sys.dm_exec_sessions
sys.dm_exec_query_stats, sys.dm_exec_sql_text
sys.dm_db_index_usage_stats, sys.dm_db_missing_index_details
sys.dm_tran_locks, sys.dm_os_wait_stats
```

### Transaction Patterns
```sql
BEGIN TRY
    BEGIN TRANSACTION;
    -- Operations
    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW; -- or handle error
END CATCH;
```

---

## Classic Must-Know SQL Problems

> These 8 problems appear in **nearly every SQL interview** across all levels. Each one tests a fundamental pattern. Master these and you cover ~80% of real interview queries.

---

### Schema Used Throughout This Section

```sql
-- Customers(CustomerId, Name, Region, SignupDate)
-- Orders(OrderId, CustomerId, OrderDate, TotalAmount, Status)
-- OrderItems(OrderItemId, OrderId, ProductId, Qty, UnitPrice)
-- Products(ProductId, ProductName, Category, Price)
-- Employees(EmployeeId, Name, DepartmentId, Salary, ManagerId, HireDate)
-- Transactions(TxnId, AccountId, TxnDate, TxnType, Amount)  -- 'CR'=credit 'DR'=debit
-- UserSessions(SessionId, UserId, LoginDate)
```

---

### Problem 1 — Customers Who Never Placed an Order

**Asked at: Amazon, Microsoft, Google, Meta, TCS, Infosys**
**Pattern: Anti-join (find rows in A with no match in B)**

```
┌────────────────────────────────────────────────────────┐
│  APPROACH EVOLUTION                                    │
├─────────────┬──────────────────────────────────────────┤
│ 🔴 BRUTE    │ NOT IN (subquery) — breaks on NULL       │
├─────────────┼──────────────────────────────────────────┤
│ 🟡 BETTER   │ LEFT JOIN + IS NULL — works, widely used │
├─────────────┼──────────────────────────────────────────┤
│ 🟢 OPTIMAL  │ NOT EXISTS — clearest intent, NULL-safe  │
└─────────────┴──────────────────────────────────────────┘
```

#### Option 1 — NOT IN (🔴 Avoid — breaks when subquery has NULLs)

```sql
-- DANGER: If any CustomerId in Orders is NULL, NOT IN returns no rows at all
-- NULL comparison in NOT IN makes the entire predicate UNKNOWN
SELECT CustomerId, Name
FROM Customers
WHERE CustomerId NOT IN (SELECT CustomerId FROM Orders);
-- Fix: SELECT CustomerId FROM Orders WHERE CustomerId IS NOT NULL
```

#### Option 2 — LEFT JOIN + IS NULL (🟡 Acceptable)

```sql
SELECT c.CustomerId, c.Name
FROM Customers c
LEFT JOIN Orders o ON c.CustomerId = o.CustomerId  -- bring in Orders (or NULL if no match)
WHERE o.OrderId IS NULL                             -- NULL means no matching order exists
ORDER BY c.Name;
```

#### Option 3 — NOT EXISTS (🟢 Best)

```sql
-- Reads as plain English: "customers for whom no order exists"
SELECT c.CustomerId, c.Name
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1                              -- value doesn't matter, only existence checked
    FROM Orders o
    WHERE o.CustomerId = c.CustomerId     -- correlated: checks per customer
)
ORDER BY c.Name;

-- WHY NOT EXISTS beats NOT IN:
-- • NULL-safe: EXISTS checks row existence, not value equality
-- • Short-circuits: stops scanning Orders once a match is found
-- • Optimizer can use index on Orders.CustomerId efficiently
```

**Edge cases to mention:**
- What if a customer has cancelled orders only — are they "never ordered"? Clarify with interviewer.
- Add `AND o.Status != 'Cancelled'` inside NOT EXISTS to filter by status if needed.

---

### Problem 2 — Most Recent Order per Customer

**Asked at: Amazon, Flipkart, Infosys, Cognizant**
**Pattern: Latest/first record per group**

```
┌────────────────────────────────────────────────────────┐
│  APPROACH EVOLUTION                                    │
├─────────────┬──────────────────────────────────────────┤
│ 🔴 BRUTE    │ Correlated subquery with MAX — O(N²)     │
├─────────────┼──────────────────────────────────────────┤
│ 🟡 BETTER   │ GROUP BY MAX + re-join — two scans       │
├─────────────┼──────────────────────────────────────────┤
│ 🟢 OPTIMAL  │ ROW_NUMBER() — single scan, most columns │
└─────────────┴──────────────────────────────────────────┘
```

#### Option 1 — Correlated Subquery (🔴 Avoid on large tables)

```sql
SELECT o.OrderId, o.CustomerId, o.OrderDate, o.TotalAmount
FROM Orders o
WHERE o.OrderDate = (
    SELECT MAX(o2.OrderDate)
    FROM Orders o2
    WHERE o2.CustomerId = o.CustomerId  -- runs for every row in Orders
);
-- Problem: ties on same date return multiple rows per customer
```

#### Option 2 — GROUP BY + JOIN (🟡 Acceptable)

```sql
SELECT o.OrderId, o.CustomerId, o.OrderDate, o.TotalAmount
FROM Orders o
INNER JOIN (
    SELECT CustomerId, MAX(OrderDate) AS LatestDate
    FROM Orders
    GROUP BY CustomerId
) latest ON o.CustomerId = latest.CustomerId
          AND o.OrderDate = latest.LatestDate;
-- Problem: still returns multiple rows if two orders share the same max date
```

#### Option 3 — ROW_NUMBER (🟢 Best — handles ties, gets extra columns)

```sql
WITH RankedOrders AS (
    SELECT
        o.OrderId,
        o.CustomerId,
        c.Name,
        o.OrderDate,
        o.TotalAmount,
        ROW_NUMBER() OVER (
            PARTITION BY o.CustomerId          -- reset per customer
            ORDER BY o.OrderDate DESC,         -- most recent first
                     o.OrderId DESC            -- tie-break: higher OrderId wins
        ) AS rn
    FROM Orders o
    INNER JOIN Customers c ON o.CustomerId = c.CustomerId
)
SELECT OrderId, CustomerId, Name, OrderDate, TotalAmount
FROM RankedOrders
WHERE rn = 1;                                  -- keep only the most recent per customer
```

> **Variation:** Replace `rn = 1` with `rn <= 3` to get last 3 orders per customer.
> Replace `ROW_NUMBER` with `FIRST_VALUE(TotalAmount) OVER (PARTITION BY CustomerId ORDER BY OrderDate DESC)` to pull a single column from the latest row without filtering.

---

### Problem 3 — Month-over-Month Revenue Growth

**Asked at: Goldman Sachs, Morgan Stanley, Amazon, Google**
**Pattern: Period comparison using LAG**

```
┌────────────────────────────────────────────────────────┐
│  APPROACH EVOLUTION                                    │
├─────────────┬──────────────────────────────────────────┤
│ 🔴 BRUTE    │ Self-join on month — messy date math     │
├─────────────┼──────────────────────────────────────────┤
│ 🟡 BETTER   │ Subquery per row for prev month          │
├─────────────┼──────────────────────────────────────────┤
│ 🟢 OPTIMAL  │ LAG() window function — single pass      │
└─────────────┴──────────────────────────────────────────┘
```

```sql
WITH MonthlyRevenue AS (
    SELECT
        YEAR(OrderDate)  AS yr,
        MONTH(OrderDate) AS mo,
        SUM(TotalAmount) AS Revenue
    FROM Orders
    WHERE Status != 'Cancelled'
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),
WithGrowth AS (
    SELECT
        yr,
        mo,
        Revenue,
        LAG(Revenue) OVER (ORDER BY yr, mo) AS PrevMonthRevenue  -- previous row's revenue
    FROM MonthlyRevenue
)
SELECT
    yr         AS Year,
    mo         AS Month,
    Revenue,
    PrevMonthRevenue,
    CASE
        WHEN PrevMonthRevenue IS NULL THEN NULL          -- first month has no prior
        WHEN PrevMonthRevenue = 0     THEN NULL          -- avoid division by zero
        ELSE ROUND(
            (Revenue - PrevMonthRevenue) * 100.0 / PrevMonthRevenue,
            2
        )
    END AS GrowthPct
FROM WithGrowth
ORDER BY yr, mo;
```

**Sample Output:**
| Year | Month | Revenue | PrevMonthRevenue | GrowthPct |
|------|-------|---------|-----------------|-----------|
| 2025 | 1 | 50000 | NULL | NULL |
| 2025 | 2 | 62000 | 50000 | 24.00 |
| 2025 | 3 | 58000 | 62000 | -6.45 |

> **Variation:** Use `LAG(Revenue, 12)` to compare to the same month last year (YoY growth).
> Use `LEAD(Revenue)` instead of LAG to show *next* month's revenue alongside current.

---

### Problem 4 — Conditional Aggregation (Pivot Without PIVOT)

**Asked at: TCS, Wipro, Accenture, Microsoft**
**Pattern: CASE inside aggregate function**

**Problem:** Show total sales per product category side by side in one row per month.

```sql
-- Expected output:
-- Month  | Electronics | Clothing | Books
-- 2025-01 | 15000       | 8000     | 3000
-- 2025-02 | 12000       | 9500     | 4200

SELECT
    FORMAT(o.OrderDate, 'yyyy-MM')                          AS Month,

    -- Each column = SUM filtered to one category via CASE
    SUM(CASE WHEN p.Category = 'Electronics' THEN oi.Qty * oi.UnitPrice ELSE 0 END) AS Electronics,
    SUM(CASE WHEN p.Category = 'Clothing'    THEN oi.Qty * oi.UnitPrice ELSE 0 END) AS Clothing,
    SUM(CASE WHEN p.Category = 'Books'       THEN oi.Qty * oi.UnitPrice ELSE 0 END) AS Books,

    -- Grand total for the month
    SUM(oi.Qty * oi.UnitPrice)                              AS Total

FROM Orders o
INNER JOIN OrderItems oi ON o.OrderId = oi.OrderId
INNER JOIN Products   p  ON oi.ProductId = p.ProductId
WHERE o.Status != 'Cancelled'
GROUP BY FORMAT(o.OrderDate, 'yyyy-MM')
ORDER BY Month;
```

**Why this beats PIVOT:**
- No need to hard-code values in `FOR ... IN (...)` clause
- Works with any number of categories visible in SELECT
- Easier to add a "Total" column or percentage column alongside
- Readable without knowing PIVOT syntax

> **Variation:** `COUNT(CASE WHEN Status = 'Shipped' THEN 1 END)` counts rows matching a condition.
> `AVG(CASE WHEN Region = 'North' THEN Salary END)` averages only the filtered subset.

---

### Problem 5 — Users Active in January but NOT February

**Asked at: Meta, Google, Amazon**
**Pattern: Set difference — present in one period, absent in another**

```
┌────────────────────────────────────────────────────────┐
│  APPROACH EVOLUTION                                    │
├─────────────┬──────────────────────────────────────────┤
│ 🔴 BRUTE    │ Two separate subqueries + NOT IN         │
├─────────────┼──────────────────────────────────────────┤
│ 🟡 BETTER   │ LEFT JOIN + IS NULL on month filter      │
├─────────────┼──────────────────────────────────────────┤
│ 🟢 OPTIMAL  │ EXCEPT set operator — self-documenting   │
└─────────────┴──────────────────────────────────────────┘
```

#### Option 1 — LEFT JOIN + IS NULL (🟡 Good)

```sql
SELECT DISTINCT jan.UserId
FROM UserSessions jan
LEFT JOIN UserSessions feb
    ON jan.UserId = feb.UserId
    AND MONTH(feb.LoginDate) = 2
    AND YEAR(feb.LoginDate)  = 2025
WHERE MONTH(jan.LoginDate) = 1
  AND YEAR(jan.LoginDate)  = 2025
  AND feb.UserId IS NULL;         -- no February session found
```

#### Option 2 — EXCEPT (🟢 Clearest intent)

```sql
-- "January users" MINUS "February users"
SELECT DISTINCT UserId
FROM UserSessions
WHERE MONTH(LoginDate) = 1 AND YEAR(LoginDate) = 2025

EXCEPT

SELECT DISTINCT UserId
FROM UserSessions
WHERE MONTH(LoginDate) = 2 AND YEAR(LoginDate) = 2025;

-- EXCEPT removes rows from the first set that appear in the second set
-- Automatically deduplicates (like UNION, not UNION ALL)
```

**INTERSECT / EXCEPT Quick Reference:**

| Operator | Returns | Deduplicates? |
|----------|---------|---------------|
| `UNION` | All rows from A + B | Yes |
| `UNION ALL` | All rows from A + B | No |
| `INTERSECT` | Rows in BOTH A and B | Yes |
| `EXCEPT` | Rows in A but NOT in B | Yes |

> **Variation:** Swap EXCEPT for INTERSECT to find users who logged in **both** months.

---

### Problem 6 — Products Frequently Bought Together

**Asked at: Amazon, Flipkart, e-commerce companies**
**Pattern: Self-join on a bridge/junction table**

**Problem:** Find all pairs of products that appear together in at least 5 orders.

```sql
-- Self-join OrderItems to itself on the same OrderId
-- Each row in the result = one product pair from one order
SELECT
    p1.ProductName                             AS Product1,
    p2.ProductName                             AS Product2,
    COUNT(DISTINCT oi1.OrderId)                AS TimesBoughtTogether
FROM OrderItems oi1
INNER JOIN OrderItems oi2
    ON  oi1.OrderId    = oi2.OrderId           -- same order
    AND oi1.ProductId  < oi2.ProductId         -- avoid (A,B) and (B,A) duplicates
                                               -- < ensures we only get each pair once
INNER JOIN Products p1 ON oi1.ProductId = p1.ProductId
INNER JOIN Products p2 ON oi2.ProductId = p2.ProductId
GROUP BY p1.ProductName, p2.ProductName
HAVING COUNT(DISTINCT oi1.OrderId) >= 5        -- minimum co-occurrence threshold
ORDER BY TimesBoughtTogether DESC;
```

**Sample Output:**
| Product1 | Product2 | TimesBoughtTogether |
|----------|----------|---------------------|
| Phone | Phone Case | 142 |
| Laptop | Mouse | 98 |
| Headphones | Phone | 67 |

> **Key Insight:** The `oi1.ProductId < oi2.ProductId` condition is the trick that eliminates both
> self-pairs (A,A) and reverse duplicates (B,A). Always use `<` not `!=` for undirected pairs.

---

### Problem 7 — Running Bank Account Balance

**Asked at: Goldman Sachs, Morgan Stanley, JP Morgan, Barclays**
**Pattern: Running total with signed values (credits + debits)**

**Problem:** Show the balance after each transaction for account `ACC001`.

```sql
-- Transactions(TxnId, AccountId, TxnDate, TxnType, Amount)
-- TxnType: 'CR' = credit (money in), 'DR' = debit (money out)

SELECT
    TxnId,
    TxnDate,
    TxnType,
    Amount,

    -- Convert to signed amount: CR adds, DR subtracts
    CASE TxnType
        WHEN 'CR' THEN  Amount
        WHEN 'DR' THEN -Amount
    END AS SignedAmount,

    -- Running sum of signed amounts = current balance
    SUM(
        CASE TxnType
            WHEN 'CR' THEN  Amount
            WHEN 'DR' THEN -Amount
        END
    ) OVER (
        PARTITION BY AccountId          -- separate balance per account
        ORDER BY TxnDate, TxnId        -- TxnId breaks ties on same date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  -- cumulative
    ) AS RunningBalance

FROM Transactions
WHERE AccountId = 'ACC001'
ORDER BY TxnDate, TxnId;
```

**Sample Output:**
| TxnId | TxnDate | TxnType | Amount | SignedAmount | RunningBalance |
|-------|---------|---------|--------|-------------|----------------|
| 1 | 2025-01-01 | CR | 10000 | 10000 | 10000 |
| 2 | 2025-01-05 | DR | 2000 | -2000 | 8000 |
| 3 | 2025-01-10 | CR | 5000 | 5000 | 13000 |
| 4 | 2025-01-15 | DR | 3000 | -3000 | 10000 |

> **Variation:** Add `HAVING MIN(RunningBalance) < 0` in an outer query to find accounts that went negative.
> Remove `WHERE AccountId = 'ACC001'` to compute balances for all accounts simultaneously (PARTITION BY handles it).

---

### Problem 8 — Find Employees Who Share the Same Salary

**Asked at: TCS, Cognizant, Wipro, Accenture**
**Pattern: Find duplicates on a specific column**

```
┌────────────────────────────────────────────────────────┐
│  APPROACH EVOLUTION                                    │
├─────────────┬──────────────────────────────────────────┤
│ 🔴 BRUTE    │ Self-join ALL pairs — O(N²), many dupes  │
├─────────────┼──────────────────────────────────────────┤
│ 🟡 BETTER   │ GROUP BY HAVING + subquery re-join       │
├─────────────┼──────────────────────────────────────────┤
│ 🟢 OPTIMAL  │ COUNT() OVER (window) — single scan      │
└─────────────┴──────────────────────────────────────────┘
```

#### Option 1 — GROUP BY + HAVING + JOIN (🟡 Good)

```sql
-- Step 1: find salaries shared by more than one employee
WITH SharedSalaries AS (
    SELECT Salary
    FROM Employees
    GROUP BY Salary
    HAVING COUNT(*) > 1          -- salary appears more than once
)
-- Step 2: get all employees at those salaries
SELECT e.EmployeeId, e.Name, e.Salary, e.DepartmentId
FROM Employees e
WHERE e.Salary IN (SELECT Salary FROM SharedSalaries)
ORDER BY e.Salary, e.Name;
```

#### Option 2 — COUNT OVER Window (🟢 Best — single scan)

```sql
WITH SalaryCount AS (
    SELECT
        EmployeeId,
        Name,
        Salary,
        DepartmentId,
        COUNT(*) OVER (PARTITION BY Salary) AS EmpCountAtSalary  -- how many share this salary
    FROM Employees
)
SELECT EmployeeId, Name, Salary, DepartmentId, EmpCountAtSalary
FROM SalaryCount
WHERE EmpCountAtSalary > 1   -- only employees whose salary is shared
ORDER BY Salary, Name;
```

**Sample Output:**
| EmployeeId | Name | Salary | DepartmentId | EmpCountAtSalary |
|-----------|------|--------|-------------|-----------------|
| 3 | Alice | 75000 | IT | 3 |
| 7 | Bob | 75000 | HR | 3 |
| 11 | Carol | 75000 | IT | 3 |
| 5 | Dave | 90000 | Finance | 2 |
| 9 | Eve | 90000 | IT | 2 |

> **Variation:** Replace `Salary` with any column to find duplicates on that column.
> Add `AND DepartmentId = e2.DepartmentId` to find same-salary pairs *within* a department only.

---

### Quick Problem-to-Pattern Reference

| Problem | Core Pattern | Key SQL |
|---------|-------------|---------|
| Customers with no orders | Anti-join | `NOT EXISTS` / `LEFT JOIN IS NULL` |
| Most recent record per group | Per-group top 1 | `ROW_NUMBER() OVER (PARTITION BY … ORDER BY date DESC)` |
| Month-over-Month growth | Period comparison | `LAG(col) OVER (ORDER BY period)` |
| Pivot: categories as columns | Conditional aggregation | `SUM(CASE WHEN cat='X' THEN val ELSE 0 END)` |
| Active in A but not B | Set difference | `EXCEPT` / `LEFT JOIN IS NULL` |
| Items bought together | Pair generation | Self-join with `p1.id < p2.id` |
| Running balance | Cumulative sum | `SUM() OVER (ORDER BY … ROWS UNBOUNDED PRECEDING)` |
| Employees sharing a salary | Duplicate value detection | `COUNT(*) OVER (PARTITION BY Salary) > 1` |

---

1. **Always clarify requirements** before writing queries
2. **Consider edge cases**: NULL values, empty results, duplicates
3. **Think about performance**: indexes, execution plans
4. **Explain your thought process** while solving
5. **Know trade-offs**: normalization vs denormalization, different join types
6. **Practice writing queries by hand** without IDE assistance
7. **Understand execution order** of SQL clauses
8. **Be ready to optimize** queries you write

---

*Last Updated: 2026*
*Based on real interview experiences from candidates at TCS, Infosys, Wipro, Accenture, Cognizant, Microsoft, Amazon, Google, Meta, Goldman Sachs, Morgan Stanley, and other companies.*
