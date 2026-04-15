"""Runner implementations for different LLM providers."""

from critique.runner.base import BaseRunner
from critique.runner.claude import ClaudeRunner
from critique.runner.openai import OpenAIRunner


def create_runner(coder_provider: str, critic_provider: str) -> tuple[BaseRunner, BaseRunner]:
    """Create runners for coder and critic agents."""
    coder_runner: BaseRunner
    critic_runner: BaseRunner

    if coder_provider == "claude":
        coder_runner = ClaudeRunner()
    elif coder_provider == "gpt":
        coder_runner = OpenAIRunner()
    else:
        raise ValueError(f"Unknown provider: {coder_provider}")

    if critic_provider == "claude":
        critic_runner = ClaudeRunner()
    elif critic_provider == "gpt":
        critic_runner = OpenAIRunner()
    else:
        raise ValueError(f"Unknown provider: {critic_provider}")

    return coder_runner, critic_runner
