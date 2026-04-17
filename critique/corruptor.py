"""Inject intentional errors into generated SQL code for testing critic reliability."""

import random


def corrupt_sql(sql: str, corruption_type: str = "random", rng: random.Random | None = None) -> str:
    """
    Introduce intentional bugs into SQL code.

    Args:
        sql: The SQL query to corrupt
        corruption_type: Type of corruption - "random", "join", "group", "date", "filter", "all"
        rng: Random number generator for reproducibility (default: create with seed 42)

    Returns:
        Corrupted SQL query with intentional bugs
    """
    if rng is None:
        rng = random.Random(42)

    if corruption_type == "all":
        sql = _corrupt_join(sql)
        sql = _corrupt_group_by(sql)
        sql = _corrupt_date_function(sql)
        sql = _corrupt_filter(sql)
    elif corruption_type == "join":
        sql = _corrupt_join(sql)
    elif corruption_type == "group":
        sql = _corrupt_group_by(sql)
    elif corruption_type == "date":
        sql = _corrupt_date_function(sql)
    elif corruption_type == "filter":
        sql = _corrupt_filter(sql)
    elif corruption_type == "inner_join":
        sql = _corrupt_inner_join(sql)
    elif corruption_type == "random":
        # Original pool: join (fires ~37%), group (rare), date (rare), inner_join (nullable join).
        # No-op detection in analysis.py excludes runs where corruption didn't apply,
        # so adding non-firing types is safe — they just get filtered out at analysis time.
        corruption_types = ["join", "group", "date", "inner_join"]
        chosen = rng.choice(corruption_types)
        sql = corrupt_sql(sql, chosen, rng)

    return sql


def _corrupt_join(sql: str) -> str:
    """Introduce incorrect join condition."""
    # Change common join conditions
    corruptions = [
        ("EXECUTOR_ID", "CREATOR_ID"),
        ("ON e.ID = t.EXECUTOR_ID", "ON e.ID = t.TASK_ID"),
        ("ORGANIZATION_ID", "USER_ID"),
    ]

    for original, replacement in corruptions:
        if original in sql:
            return sql.replace(original, replacement, 1)

    return sql


def _corrupt_group_by(sql: str) -> str:
    """Remove required column from GROUP BY clause."""
    lines = sql.split("\n")
    for i, line in enumerate(lines):
        if "GROUP BY" in line:
            # Remove one column from GROUP BY
            if "," in line:
                # Has multiple columns, remove one
                parts = line.split(",")
                if len(parts) > 1:
                    # Remove the last column
                    lines[i] = ",".join(parts[:-1])
            return "\n".join(lines)

    return sql


def _corrupt_date_function(sql: str) -> str:
    """Use wrong date function."""
    corruptions = [
        ("DATE_SUB", "DATEADD"),
        ("DATEADD(day, -30", "DATEADD(day, 30"),
        ("DATEDIFF(day", "DATE_DIFF(day"),
    ]

    for original, replacement in corruptions:
        if original in sql:
            return sql.replace(original, replacement, 1)

    return sql


def _corrupt_inner_join(sql: str) -> str:
    """Replace LEFT JOIN with INNER JOIN on the WORKERS table.

    COMPLETING_WORKER_ID is nullable — tasks with no assigned worker have NULL there.
    LEFT JOIN preserves those tasks; INNER JOIN silently drops them, producing wrong
    aggregate counts. The error is invisible syntactically and requires understanding
    NULL semantics + schema nullability to catch. Schema rules don't mention JOIN type,
    so this bypasses the schema-rule lookup that makes filter/join corruptions too easy.
    """
    import re
    # Match LEFT JOIN ... WORKERS (case-insensitive, various spacing)
    pattern = re.compile(r'\bLEFT\s+JOIN\s+(WORKERS\b)', re.IGNORECASE)
    result, count = pattern.subn(r'INNER JOIN \1', sql, count=1)
    if count:
        return result
    # Fallback: any LEFT JOIN if WORKERS not found explicitly
    pattern2 = re.compile(r'\bLEFT\s+JOIN\b', re.IGNORECASE)
    result2, count2 = pattern2.subn('INNER JOIN', sql, count=1)
    return result2 if count2 else sql


def _corrupt_filter(sql: str) -> str:
    """Flip soft-delete filter to include deleted records.

    The schema requires `_FIVETRAN_DELETED = FALSE` everywhere. Flipping to TRUE
    returns only deleted records — a subtle logical error that still runs without
    syntax errors but produces completely wrong results. Catching it requires
    knowing what _FIVETRAN_DELETED means (domain knowledge).
    """
    marker = "_FIVETRAN_DELETED = FALSE"
    if marker in sql:
        return sql.replace(marker, "_FIVETRAN_DELETED = TRUE", 1)
    # Case-insensitive fallback
    lower = sql.lower()
    idx = lower.find("_fivetran_deleted = false")
    if idx != -1:
        return sql[:idx] + "_FIVETRAN_DELETED = TRUE" + sql[idx + len("_fivetran_deleted = false"):]
    return sql
