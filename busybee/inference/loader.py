from __future__ import annotations

import json

import joblib

from busybee.contracts.models import ModelArtifactContract
from busybee.foundation.exceptions import ArtifactNotFoundError, ModelLoadError
from busybee.foundation.paths import ensure_artifact_dirs


def load_model(model_name: str = "baseline_logistic", artifact_root_dir: str = "artifacts") -> tuple[object, ModelArtifactContract]:
    dirs = ensure_artifact_dirs(artifact_root_dir)
    model_path = dirs["models"] / f"{model_name}.joblib"
    manifest_path = dirs["models"] / f"{model_name}.manifest.json"

    if not model_path.exists():
        raise ArtifactNotFoundError(f"Missing model artifact: {model_path}")
    if not manifest_path.exists():
        raise ArtifactNotFoundError(f"Missing model manifest: {manifest_path}")

    try:
        model = joblib.load(model_path)
    except Exception as exc:
        raise ModelLoadError(f"Unable to load model artifact: {exc}") from exc

    manifest = json.loads(manifest_path.read_text())
    contract = ModelArtifactContract(**manifest["model_artifact"])
    return model, contract
