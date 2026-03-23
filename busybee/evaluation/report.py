from __future__ import annotations

import json

from busybee.contracts.models import EvaluationReport
from busybee.foundation.paths import ensure_artifact_dirs


def write_report(report: EvaluationReport, artifact_root_dir: str = "artifacts") -> str:
    dirs = ensure_artifact_dirs(artifact_root_dir)
    path = dirs["reports"] / f"{report.model_name}.metrics.json"
    path.write_text(json.dumps(report.model_dump(), indent=2))
    return str(path)
