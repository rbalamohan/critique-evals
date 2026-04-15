"""Configuration for agent pair evaluation runs."""

from dataclasses import dataclass
from typing import Literal

Provider = Literal["claude", "gpt"]

# Default models per provider
DEFAULT_MODELS: dict[str, str] = {
    "claude": "claude-sonnet-4-6",
    "gpt": "gpt-5.4",
}


@dataclass(frozen=True)
class PairRunConfig:
    """Configuration for an agent pair evaluation run."""

    testcase: str
    coder_provider: Provider
    critic_provider: Provider
    coder_model: str = ""
    critic_model: str = ""
    iterations: int = 1
    output_root: str = "output"
    debug: bool = False

    def coder_model_resolved(self) -> str:
        """Get the coder model, using default if not specified."""
        return self.coder_model or DEFAULT_MODELS.get(self.coder_provider, "")

    def critic_model_resolved(self) -> str:
        """Get the critic model, using default if not specified."""
        return self.critic_model or DEFAULT_MODELS.get(self.critic_provider, "")


# All provider pair combinations
ALL_PROVIDER_PAIRS: list[tuple[Provider, Provider]] = [
    ("claude", "claude"),
    ("claude", "gpt"),
    ("gpt", "claude"),
    ("gpt", "gpt"),
]
