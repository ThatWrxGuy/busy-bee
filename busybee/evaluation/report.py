from __future__ import annotations

import json

from busybee.contracts.models import EvaluationReport
from busybee.foundation.paths import ensure_artifact_dirs


def write_report(report: EvaluationReport, artifact_root_dir: str = "artifacts") -> str:
    """Write evaluation report with run-scoped identity per doctrine."""
    dirs = ensure_artifact_dirs(artifact_root_dir)
    # Use run-scoped filename: reports/{model_name}/{run_id}.metrics.json
    report_subdir = dirs["reports"] / report.model_name
    report_subdir.mkdir(exist_ok=True)
    path = report_subdir / f"{report.run_id}.metrics.json"
    path.write_text(json.dumps(report.model_dump(), indent=2))
    return str(path)
