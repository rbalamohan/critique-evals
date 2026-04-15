# Quick Start

## Setup

```bash
# Install dependencies
uv sync

# Set API keys
export ANTHROPIC_API_KEY="your-key"
export OPENAI_API_KEY="your-key"
```

## First Run

```bash
# List available test cases
uv run critique --list

# Run a single pair (Claude coder + GPT critic)
uv run critique -t code_generation --coder claude --critic gpt

# Run all pairs for a test
uv run critique -t code_generation --all-pairs

# Run multiple iterations per pair
uv run critique -t code_generation --all-pairs -n 3 -o results/
```

## Understanding Results

Each pair evaluation produces:

1. **run_record.json** - Token counts and timing
   ```json
   {
     "testcase": "code_generation",
     "coder_provider": "claude",
     "critic_provider": "gpt",
     "wall_time_seconds": 12.34,
     "coder": {
       "tokens_in": 150,
       "tokens_out": 450,
       "error": null
     },
     "critic": {
       "tokens_in": 550,
       "tokens_out": 200,
       "error": null
     }
   }
   ```

2. **generated_code.py** - The code produced by the coder

3. **critique.md** - Feedback from the critic

## Analyzing Results

Check the output directory structure:
```
output/
├── code_generation/
│   ├── claude_coder_claude_critic/
│   │   ├── 20240414_153022/
│   │   │   ├── run_record.json
│   │   │   ├── generated_code.py
│   │   │   └── critique.md
│   │   └── ...
│   ├── claude_coder_gpt_critic/
│   │   └── ...
│   ├── gpt_coder_claude_critic/
│   │   └── ...
│   ├── gpt_coder_gpt_critic/
│   │   └── ...
│   └── summary.json
```

The `summary.json` contains aggregated metrics across all iterations.

## Extending

### Add a new test case

Edit `critique/testcase.py`:
```python
NEW_TEST = TestCase(
    name="my_test",
    description="What this tests",
    prompt="The prompt to send to agents...",
)

TESTCASES["my_test"] = NEW_TEST
```

### Add a new provider

1. Create `critique/runner/newprovider.py` extending `BaseRunner`
2. Implement `_provider_name()` and `_call()` methods
3. Update `critique/runner/__init__.py` factory
4. Update `critique/config.py` with default model
