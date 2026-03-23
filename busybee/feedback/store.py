from __future__ import annotations

import json

from busybee.contracts.models import OutcomeRecord
from busybee.foundation.paths import ensure_artifact_dirs


def record_outcome(outcome: OutcomeRecord, artifact_root_dir: str = "artifacts") -> str:
    dirs = ensure_artifact_dirs(artifact_root_dir)
    path = dirs["feedback"] / "outcomes.json"
    existing: list[dict] = []
    if path.exists():
        try:
            existing = json.loads(path.read_text())
        except json.JSONDecodeError:
            existing = []
    existing.append(outcome.model_dump())
    path.write_text(json.dumps(existing, indent=2))
    return str(path)
