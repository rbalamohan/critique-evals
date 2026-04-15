# Critique Evals - Agent Pair Evaluation Framework

Framework for evaluating code generation with critique across different agent pairs. Compare which combinations of coder + critic agents work best.

## Overview

Test all combinations of coding and critique agents:

- **Claude coder + Claude critic**
- **Claude coder + GPT critic**
- **GPT coder + Claude critic**
- **GPT coder + GPT critic**

Measures quality of generated code and effectiveness of critique feedback.

## Supported Providers

- **Claude** (Anthropic)
- **GPT** (OpenAI)

## Installation

Requires Python 3.14+.

```bash
cd critique-evals
uv sync
```

## Usage

```bash
# List available test cases
uv run critique --list

# Run with specific coder/critic pair
uv run critique -t code_generation --coder claude --critic claude

# Run with all pairs for a test
uv run critique -t code_generation --all-pairs

# Run multiple iterations
uv run critique -t code_generation --coder claude --critic gpt -n 5

# Output directory
uv run critique -t code_generation --coder claude --critic claude -o results/
```

## Test Cases

Define tasks with expected outputs that agents will attempt:

| Test Case | Description |
|-----------|-------------|
| `code_generation` | Generate code to solve a problem |
| `algorithm_implementation` | Implement a specific algorithm |
| `refactoring` | Improve existing code |
| `bug_fixing` | Fix bugs in provided code |

## Agent Pair Variations

| Coder | Critic | Notes |
|-------|--------|-------|
| claude | claude | Homogeneous: Both Claude |
| gpt | gpt | Homogeneous: Both GPT |
| claude | gpt | Cross: Claude codes, GPT critiques |
| gpt | claude | Cross: GPT codes, Claude critiques |

## Output Structure

Each run produces:
- `run_record.json` - Metadata (coder, critic, tokens, iterations)
- `trace.jsonl` - Full conversation trace between coder and critic
- `generated_code.py` - The generated code
- `critique.md` - Critique feedback from critic agent
- `metrics.json` - Performance metrics

## CLI Options

```
--testcase, -t      Test case name
--coder             Coder agent provider (claude or gpt)
--critic            Critic agent provider (claude or gpt)
--all-pairs         Test all coder/critic combinations
--iterations, -n    Iterations per pair (default: 1)
--output-root, -o   Output directory (default: output)
--list              List available test cases
--debug             Enable debug output
```
