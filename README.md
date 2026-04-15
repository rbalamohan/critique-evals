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
--iterations, -n    Iterations per pair (default: 1)
--repeat-coder      Repeat coder runs to measure inconsistency (default: 1)
--repeat-critic     Repeat critic runs to measure inconsistency (default: 1)
--output-root, -o   Output directory (default: output)
--list              List available test cases
--debug             Enable debug logging
```

**Default behavior**: Runs all 4 coder/critic pairs unless `--coder` and `--critic` are both specified.

## Inconsistency Analysis

Use `--repeat-coder` and `--repeat-critic` to measure model inconsistency:

```bash
# Measure coder inconsistency: how often does the same prompt produce different code?
uv run critique -t sql_basic_query --repeat-coder 3

# Measure critic inconsistency: how often does the same code get different assessments?
uv run critique -t sql_basic_query --repeat-critic 3

# Measure both
uv run critique -t sql_basic_query --repeat-coder 3 --repeat-critic 3
```

The reports will show:
- **Coder Inconsistency**: Code similarity % between runs, overall inconsistency rate
- **Critic Inconsistency**: Sentiment flip rate (positive→negative or vice versa), consistency %

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
