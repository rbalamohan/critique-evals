"""Data models for agent pair evaluation results."""

import uuid
from dataclasses import dataclass, field


def _generate_run_id() -> str:
    """Generate a UUIDv7 (time-based, sortable)."""
    return str(uuid.uuid7())


@dataclass
class AgentResponse:
    """Response from a single agent (coder or critic)."""

    role: str  # "coder" or "critic"
    provider: str
    model: str
    tokens_in: int = 0
    tokens_out: int = 0
    output: str = ""
    error: str | None = None
    duration_seconds: float = 0.0
    run_id: str = field(default_factory=_generate_run_id)

    @property
    def total_tokens(self) -> int:
        return self.tokens_in + self.tokens_out

    def success(self) -> bool:
        """Check if agent completed successfully."""
        return self.error is None and len(self.output) > 0


@dataclass
class PairEvalRecord:
    """Complete record of a single agent pair evaluation."""

    testcase: str
    coder_provider: str
    critic_provider: str
    coder_model: str
    critic_model: str
    run_id: str = field(default_factory=_generate_run_id)

    # Responses from each agent
    coder_response: AgentResponse | None = None
    critic_response: AgentResponse | None = None

    # Evaluation results
    wall_time_seconds: float = 0.0
    error: str | None = None
    output_files: list[str] = field(default_factory=list)

    def summary(self) -> str:
        """Get a summary of the run."""
        lines = [
            f"Test: {self.testcase}",
            f"Pair: {self.coder_provider} (coder) + {self.critic_provider} (critic)",
            f"Models: {self.coder_model} / {self.critic_model}",
            f"Time: {self.wall_time_seconds:.1f}s",
        ]

        if self.coder_response:
            status = "✓" if self.coder_response.success() else "✗"
            lines.append(f"Coder [{status}]: {self.coder_response.total_tokens} tokens")

        if self.critic_response:
            status = "✓" if self.critic_response.success() else "✗"
            lines.append(f"Critic [{status}]: {self.critic_response.total_tokens} tokens")

        if self.error:
            lines.append(f"Error: {self.error}")

        return "\n".join(lines)
