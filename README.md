# Critique Evals - Agent Pair Evaluation Framework

Framework for evaluating code generation with critique across different LLM provider pairs. Measures **critic agreement and disagreement** to understand which agent pairs produce consistent, high-quality feedback.

## Overview

Tests all combinations of coder and critic agents on logistics SQL generation tasks:

- **Claude coder + Claude critic** - Both Claude Sonnet 4.6
- **Claude coder + GPT critic** - Claude codes, GPT critiques
- **GPT coder + Claude critic** - GPT codes, Claude critiques
- **GPT coder + GPT critic** - Both GPT 5.4

**Key insight**: By running coders first and then having all critics evaluate the same generated code, we isolate **critic quality** from coder quality and can measure whether critics agree or disagree on the same outputs.

## Models

- **Claude**: `claude-sonnet-4-6`
- **GPT**: `gpt-5.4`

## Installation

Requires Python 3.14+ and API keys.

```bash
cd critique-evals
uv sync

# Set API keys
export ANTHROPIC_API_KEY="your-key"
export OPENAI_API_KEY="your-key"
```

## Usage

```bash
# List available test cases
uv run critique --list

# Run all pairs (default) - Phase 1: coders, Phase 2: critics on same code
uv run critique -t sql_basic_query

# Run with custom output directory
uv run critique -t sql_optimization -o results/

# Run multiple iterations (new coder outputs each time)
uv run critique -t sql_complex_query -n 3

# Run specific pair only
uv run critique -t sql_basic_query --coder claude --critic gpt
```

## Test Cases

All test cases use logistics domain knowledge (Snowflake SQL):

| Test Case | Description |
|-----------|-------------|
| `sql_basic_query` | Basic task retrieval with dynamic date calculations |
| `sql_complex_query` | Complex filtering, aggregation, and joins |
| `sql_edge_cases` | Handle NULL values and data quality issues |
| `sql_optimization` | Optimize a subquery-based approach with joins |

## Evaluation Format

Critics evaluate code with **SATISFACTORY** or **UNSATISFACTORY** verdicts:

```
SATISFACTORY
Reason: The query correctly counts successful tasks in the last 30 days grouped by executor.
```

This simplified format enables quick comparison of critic verdicts across providers.

## Output Structure

Organized by test case → coder+critic pair → timestamp:

```
output/sql_basic_query/
├── claude_coder_claude_critic/
│   └── 20260414_225000/
│       ├── generated_code.py      # SQL from coder
│       ├── critique.md             # Verdict + reason from critic
│       └── run_record.json         # Tokens, timing, metadata
├── claude_coder_gpt_critic/
├── gpt_coder_claude_critic/
├── gpt_coder_gpt_critic/
└── summary.json                    # Aggregated results
```

**summary.json** includes:
- `coder_tokens` / `critic_tokens` - Token usage per agent
- `coder_time_seconds` / `critic_time_seconds` - Separate timing
- `wall_time_seconds` - Total run time

## CLI Options

```
--testcase, -t      Test case name (required)
--coder             Coder provider (claude or gpt) - optional, runs all pairs by default
--critic            Critic provider (claude or gpt) - optional, runs all pairs by default
--iterations, -n    Iterations (repeat coder and critic runs, default: 1)
--corrupt           Inject SQL errors before critique (random, join, group, date, all)
--output-root, -o   Output directory (default: output)
--list              List available test cases
--debug             Enable debug logging
```

**Default behavior**: Runs all 4 coder/critic pairs unless `--coder` and `--critic` are both specified.

## Inconsistency Analysis

Use `--iterations` to measure model inconsistency:

```bash
# Phase 1: Run coder 3 times (different outputs for same prompt)
# Phase 2: Run critic 3 times on each coder output
uv run critique -t sql_basic_query -n 3
```

The reports will show:
- **Coder Inconsistency**: Code similarity % between runs, overall inconsistency rate
- **Critic Inconsistency**: Sentiment flip rate (positive→negative or vice versa), consistency %

## Testing Critic Reliability

Use `--corrupt` to inject intentional SQL errors and measure if critics catch them:

```bash
# Test if critics catch join condition errors
uv run critique -t sql_basic_query --corrupt join

# Test if critics catch GROUP BY issues
uv run critique -t sql_optimization --corrupt group

# Test multiple error types
uv run critique -t sql_basic_query --corrupt all

# Combine with iterations to test consistency
uv run critique -t sql_complex_query --corrupt random -n 3
```

**Corruption types:**
- `join`: Changes join conditions (EXECUTOR_ID → CREATOR_ID)
- `group`: Removes required columns from GROUP BY
- `date`: Uses wrong date function (DATE_SUB → DATEADD)
- `random`: Picks a random error type
- `all`: Applies all three error types

Each run saves both the corrupted code and original code for comparison.

## Analyzing Results

### Finding Disagreement

When the same code gets different verdicts from different critics:

```bash
# sql_optimization example:
# GPT coder → Claude critic: UNSATISFACTORY (bad reasoning)
# GPT coder → GPT critic:    SATISFACTORY (good optimization)
# → Disagreement between critics on same code
```

This reveals how critic evaluation styles differ across providers.

### Comparing Critic Performance

Use `summary.json` to analyze:
- Which critics are most/least strict
- Whether critics agree or disagree frequently
- Token efficiency (cheaper vs expensive critics)
- Speed (fast vs slow critics)
