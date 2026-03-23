from __future__ import annotations

from pathlib import Path


def project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def artifact_root(root_dir: str = "artifacts") -> Path:
    return project_root() / root_dir


def ensure_artifact_dirs(root_dir: str = "artifacts") -> dict[str, Path]:
    root = artifact_root(root_dir)
    models = root / "models"
    reports = root / "reports"
    feedback = root / "feedback"
    for path in (root, models, reports, feedback):
        path.mkdir(parents=True, exist_ok=True)
    return {"root": root, "models": models, "reports": reports, "feedback": feedback}
