from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from uuid import uuid4


@dataclass(frozen=True)
class SystemIdentity:
    name: str
    doctrine_version: str
    environment: str


@dataclass(frozen=True)
class RunContext:
    run_id: str
    started_at: str
    root_dir: Path

    @classmethod
    def create(cls, root_dir: Path) -> "RunContext":
        return cls(
            run_id=f"run-{uuid4().hex[:12]}",
            started_at=datetime.now(UTC).isoformat(),
            root_dir=root_dir,
        )
