"""Claude runner using Anthropic SDK."""

import logging

import anthropic

from critique.runner.base import BaseRunner

logger = logging.getLogger(__name__)


class ClaudeRunner(BaseRunner):
    """Runner for Claude models via Anthropic API."""

    def __init__(self) -> None:
        self.client = anthropic.Anthropic()

    def _provider_name(self) -> str:
        return "claude"

    def _call(
        self,
        model: str,
        messages: list[dict],
        system_prompt: str | None = None,
        max_tokens: int = 4096,
    ) -> tuple[str, int, int]:
        """Call Claude API."""
        kwargs: dict = {
            "model": model,
            "max_tokens": max_tokens,
            "messages": messages,
        }
        if system_prompt:
            kwargs["system"] = system_prompt

        message = self.client.messages.create(**kwargs)

        response_text = message.content[0].text if message.content else ""
        tokens_in = message.usage.input_tokens
        tokens_out = message.usage.output_tokens

        return response_text, tokens_in, tokens_out
