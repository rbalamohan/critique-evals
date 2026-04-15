"""OpenAI runner using OpenAI SDK."""

import logging

import openai

from critique.runner.base import BaseRunner

logger = logging.getLogger(__name__)


class OpenAIRunner(BaseRunner):
    """Runner for OpenAI models."""

    def __init__(self) -> None:
        self.client = openai.OpenAI()

    def _provider_name(self) -> str:
        return "gpt"

    def _call(
        self,
        model: str,
        messages: list[dict],
        system_prompt: str | None = None,
        max_tokens: int = 4096,
    ) -> tuple[str, int, int]:
        """Call OpenAI API."""
        if system_prompt:
            messages = [{"role": "system", "content": system_prompt}] + messages

        response = self.client.chat.completions.create(
            model=model,
            max_completion_tokens=max_tokens,
            messages=messages,
        )

        response_text = response.choices[0].message.content if response.choices else ""
        tokens_in = response.usage.prompt_tokens
        tokens_out = response.usage.completion_tokens

        return response_text, tokens_in, tokens_out
