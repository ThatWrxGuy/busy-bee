from __future__ import annotations

import json

import joblib

from busybee.contracts.models import ModelArtifactContract
from busybee.foundation.exceptions import ArtifactNotFoundError, ModelLoadError
from busybee.foundation.paths import ensure_artifact_dirs


def load_model(model_name: str = "baseline_logistic", artifact_root_dir: str = "artifacts", run_id: str | None = None) -> tuple[object, ModelArtifactContract]:
    """Load model artifact using run-scoped identity per doctrine.
    
    If run_id is provided, loads that specific version. Otherwise loads the most recent.
    """
    dirs = ensure_artifact_dirs(artifact_root_dir)
    model_subdir = dirs["models"] / model_name
    
    if run_id:
        # Load specific run version
        # Find manifest with matching run_id
        for manifest_file in model_subdir.glob("*.manifest.json"):
            if run_id in manifest_file.stem:
                stem = manifest_file.stem
                model_path = model_subdir / f"{stem}.joblib"
                manifest_path = manifest_file
                break
        else:
            raise ArtifactNotFoundError(f"No artifact found for run_id={run_id}")
    else:
        # Find the latest (most recently modified) model version
        model_files = sorted(model_subdir.glob("*.joblib"), key=lambda p: p.stat().st_mtime, reverse=True)
        if not model_files:
            raise ArtifactNotFoundError(f"No model artifacts found in {model_subdir}")
        
        latest_model_path = model_files[0]
        stem = latest_model_path.stem
        manifest_filename = f"{stem}.manifest.json"
        manifest_path = model_subdir / manifest_filename
        model_path = latest_model_path

    if not manifest_path.exists():
        raise ArtifactNotFoundError(f"Missing model manifest: {manifest_path}")

    try:
        model = joblib.load(model_path)
    except Exception as exc:
        raise ModelLoadError(f"Unable to load model artifact: {exc}") from exc

    manifest = json.loads(manifest_path.read_text())
    contract = ModelArtifactContract(**manifest["model_artifact"])
    return model, contract
