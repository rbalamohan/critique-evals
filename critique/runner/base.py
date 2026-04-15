"""Base runner for agent pair evaluation."""

import time
from abc import ABC, abstractmethod

from critique.models import AgentResponse


class BaseRunner(ABC):
    """Abstract base runner for LLM agents."""

    @abstractmethod
    def _call(
        self,
        model: str,
        messages: list[dict],
        system_prompt: str | None = None,
        max_tokens: int = 4096,
    ) -> tuple[str, int, int]:
        """Call the LLM. Returns (response_text, tokens_in, tokens_out)."""
        pass

    def generate_code(
        self, model: str, prompt: str, system_context: str = ""
    ) -> AgentResponse:
        """Generate code from a prompt."""
        t0 = time.perf_counter()
        try:
            system_prompt = f"""You are a SQL expert. Generate ONLY valid Snowflake SQL code.
Do NOT include markdown, explanations, or any text outside the SQL query.
Always use dynamic date calculations (DATE_SUB, CURRENT_DATE, etc.) instead of hardcoded dates.
Ensure queries are fully qualified with schema names (db.schema.table).

{system_context}""" if system_context else None

            messages = [{"role": "user", "content": prompt}]
            response, tokens_in, tokens_out = self._call(
                model, messages, system_prompt=system_prompt
            )

            return AgentResponse(
                role="coder",
                provider=self._provider_name(),
                model=model,
                tokens_in=tokens_in,
                tokens_out=tokens_out,
                output=response,
                duration_seconds=time.perf_counter() - t0,
            )
        except Exception as e:
            return AgentResponse(
                role="coder",
                provider=self._provider_name(),
                model=model,
                error=str(e),
                duration_seconds=time.perf_counter() - t0,
            )

    def critique_code(
        self, model: str, code: str, task: str = "", system_context: str = ""
    ) -> AgentResponse:
        """Critique generated code."""
        t0 = time.perf_counter()
        try:
            critique_prompt = f"""Review this code and respond with ONLY:
SATISFACTORY or UNSATISFACTORY
Reason: [one short sentence]

{f"Task: {task}" if task else ""}

Code:
```sql
{code}
```"""

            messages = [{"role": "user", "content": critique_prompt}]
            response, tokens_in, tokens_out = self._call(
                model, messages, system_prompt=system_context if system_context else None
            )

            return AgentResponse(
                role="critic",
                provider=self._provider_name(),
                model=model,
                tokens_in=tokens_in,
                tokens_out=tokens_out,
                output=response,
                duration_seconds=time.perf_counter() - t0,
            )
        except Exception as e:
            return AgentResponse(
                role="critic",
                provider=self._provider_name(),
                model=model,
                error=str(e),
                duration_seconds=time.perf_counter() - t0,
            )

    @abstractmethod
    def _provider_name(self) -> str:
        """Get the provider name."""
        pass
