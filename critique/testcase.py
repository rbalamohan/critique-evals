"""Test cases for agent pair evaluation."""

from dataclasses import dataclass
from pathlib import Path


@dataclass
class TestCase:
    """A test case for code generation + critique."""

    name: str
    description: str
    prompt: str
    domain_context: str = ""


# Load domain knowledge from SME file
def _load_sme_context() -> str:
    """Load SME context from customers directory."""
    sme_path = Path(__file__).parent.parent.parent / "customers" / "onfleet" / "customer-sme.txt"
    if sme_path.exists():
        with open(sme_path) as f:
            return f.read()
    return ""


_SME_CONTEXT = _load_sme_context()

# Test cases based on logistics domain
SQL_BASIC_QUERY = TestCase(
    name="sql_basic_query",
    description="Generate SQL query for basic logistics data retrieval",
    domain_context=_SME_CONTEXT,
    prompt="""Using the provided logistics data schema, write a Snowflake SQL query to:

Find the total number of tasks completed successfully by executor in the last 30 days,
grouped by executor organization. Use EXECUTOR_ID and COMPLETION_DETAILS_SUCCESS fields.
Use DATE_SUB() or similar to calculate the last 30 days dynamically, not hardcoded dates.

IMPORTANT: Return ONLY the raw SQL query. No markdown, no code blocks, no explanation. Just the SELECT statement.""",
)

SQL_COMPLEX_QUERY = TestCase(
    name="sql_complex_query",
    description="Generate complex SQL with filtering and aggregation",
    domain_context=_SME_CONTEXT,
    prompt="""Using the logistics data schema, write a Snowflake SQL query to:

Calculate the average number of tasks per driver per day for organizations in the US timezone
during Q1 2026. Only include organizations with route optimization enabled.
Filter to tasks that were completed (not pending).

Return the query, explain the joins and filtering logic, and note any data quality considerations.""",
)

SQL_EDGE_CASES = TestCase(
    name="sql_edge_cases",
    description="Handle edge cases and data quality issues",
    domain_context=_SME_CONTEXT,
    prompt="""Using the logistics data schema, write a Snowflake SQL query to:

Identify tasks with missing or NULL failure reasons that were marked as unsuccessful (SUCCESS=FALSE).
Include the organization name, task ID, completion time, and any available notes.
Sort by completion time DESC.

Explain:
1. Why NULL failure reasons are valid data (per schema documentation)
2. How you're handling the EXECUTOR_ID vs ORGANIZATION_ID distinction
3. What the business implications might be""",
)

SQL_OPTIMIZATION = TestCase(
    name="sql_optimization",
    description="Optimize SQL query performance and readability",
    domain_context=_SME_CONTEXT,
    prompt="""Here's a logistics SQL query that works but may not be optimal:

```sql
SELECT o.NAME, COUNT(*) as task_count
FROM PRODUCTION_ANALYTICS.ANALYTICS.ORGANIZATIONS o
WHERE o.ID IN (
  SELECT DISTINCT EXECUTOR_ID FROM PRODUCTION_ANALYTICS.ANALYTICS.TASKS
  WHERE COMPLETION_DETAILS_SUCCESS = TRUE
)
GROUP BY o.ID, o.NAME
ORDER BY task_count DESC;
```

Rewrite this query to be more efficient. Consider:
1. Index usage and join strategy
2. Snowflake-specific optimizations
3. Readability and maintainability

Provide the optimized query and explain what changed and why.""",
)

# Registry
TESTCASES: dict[str, TestCase] = {
    "sql_basic_query": SQL_BASIC_QUERY,
    "sql_complex_query": SQL_COMPLEX_QUERY,
    "sql_edge_cases": SQL_EDGE_CASES,
    "sql_optimization": SQL_OPTIMIZATION,
}


def get_testcase(name: str) -> TestCase:
    """Get a test case by name."""
    if name not in TESTCASES:
        raise ValueError(f"Unknown test case: {name}. Available: {list(TESTCASES.keys())}")
    return TESTCASES[name]


def list_testcases() -> list[str]:
    """List all available test case names."""
    return list(TESTCASES.keys())
