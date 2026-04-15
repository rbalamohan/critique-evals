# Project Structure

## Overview

A framework for evaluating agent pairs (coder + critic) using different LLM providers.

## Architecture

```
critique-evals/
├── critique/
│   ├── __init__.py           # Package initialization
│   ├── __main__.py           # CLI entrypoint
│   ├── cli.py                # Command-line interface
│   ├── config.py             # Configuration dataclasses
│   ├── models.py             # Data models (PairEvalRecord, AgentResponse)
│   ├── testcase.py           # Test case definitions
│   └── runner/
│       ├── __init__.py       # Runner factory
│       ├── base.py           # Abstract base runner
│       ├── claude.py         # Claude/Anthropic implementation
│       └── openai.py         # GPT/OpenAI implementation
├── pyproject.toml            # Project configuration
└── README.md                 # User documentation
```

## Key Components

### Config (`config.py`)
- `PairRunConfig`: Configuration for a single evaluation run
- `Provider`: Type alias for "claude" or "gpt"
- `DEFAULT_MODELS`: Default model per provider
- `ALL_PROVIDER_PAIRS`: All coder/critic combinations to test

### Models (`models.py`)
- `AgentResponse`: Output from a single agent (coder or critic)
- `PairEvalRecord`: Complete record of an agent pair evaluation

### Runners (`runner/`)
- `BaseRunner`: Abstract base class with common methods
  - `generate_code()`: Agent generates code from prompt
  - `critique_code()`: Agent critiques provided code
- `ClaudeRunner`: Anthropic API implementation
- `OpenAIRunner`: OpenAI API implementation

### Test Cases (`testcase.py`)
- `TestCase`: Data class with name, description, and prompt
- Built-in test cases:
  - `code_generation`: Generate function from spec
  - `algorithm_implementation`: Implement an algorithm
  - `refactoring`: Improve code quality
  - `bug_fixing`: Fix bugs in provided code

### CLI (`cli.py`)
- `main()`: Entry point
- `_run_single()`: Run one agent pair evaluation
- `_save_outputs()`: Save results to files

## Provider Pairs

Four combinations are tested:
1. **claude_coder + claude_critic**: Both Claude
2. **claude_coder + gpt_critic**: Claude codes, GPT critiques
3. **gpt_coder + claude_critic**: GPT codes, Claude critiques
4. **gpt_coder + gpt_critic**: Both GPT

## Output Structure

Each run produces:
- `run_record.json`: Metadata and token counts
- `generated_code.py`: Code produced by coder agent
- `critique.md`: Critique from critic agent
- `debug.log`: Debug output (if not in debug mode)
- `summary.json`: Aggregated results across all runs

## Running Evaluations

```bash
# List test cases
uv run critique --list

# Run single pair
uv run critique -t code_generation --coder claude --critic gpt

# Run all pairs
uv run critique -t code_generation --all-pairs

# Run with iterations
uv run critique -t code_generation --all-pairs -n 3
```

## Dependencies

- `anthropic>=0.75` - Claude API client
- `openai>=1.3` - OpenAI API client

Set environment variables:
- `ANTHROPIC_API_KEY` for Claude access
- `OPENAI_API_KEY` for GPT access
