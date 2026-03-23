from __future__ import annotations

import json

from busybee.contracts.models import EvaluationReport, ModelArtifactContract
from busybee.evaluation.metrics import compute_classification_metrics
from busybee.evaluation.report import write_report
from busybee.foundation.exceptions import ArtifactNotFoundError
from busybee.foundation.paths import ensure_artifact_dirs


def evaluate_artifact(
    model_name: str,
    run_id: str,
    artifact_root_dir: str = "artifacts",
    test_X: list[list[float]] | None = None,
    test_y: list[int] | None = None,
) -> EvaluationReport:
    """Evaluate an existing model artifact without retraining.
    
    Loads model and manifest from the run-scoped artifact path,
    optionally evaluates against provided test data, and writes a report.
    """
    dirs = ensure_artifact_dirs(artifact_root_dir)
    model_subdir = dirs["models"] / model_name
    
    # Find the specific run version
    manifest_path = None
    model_path = None
    for manifest_file in model_subdir.glob("*.manifest.json"):
        if run_id in manifest_file.stem:
            manifest_path = manifest_file
            version = manifest_file.stem.replace(f"{run_id}-", "")
            model_path = model_subdir / f"{run_id}-{version}.joblib"
            break
    
    if not manifest_path or not model_path:
        raise ArtifactNotFoundError(f"Missing artifact for run_id={run_id}, model={model_name}")
    
    # Load manifest
    manifest_data = json.loads(manifest_path.read_text())
    contract = ModelArtifactContract(**manifest_data["model_artifact"])
    
    # If test data provided, evaluate with it
    metrics = {}
    if test_X is not None and test_y is not None:
        import numpy as np
        import joblib
        
        model = joblib.load(model_path)
        X = np.asarray(test_X, dtype=float)
        y = np.asarray(test_y, dtype=int)
        y_pred = model.predict(X)
        metrics = compute_classification_metrics(y, y_pred)
    
    report = EvaluationReport(
        run_id=run_id,
        model_name=model_name,
        metrics=metrics,
        metadata={
            "artifact_manifest": str(manifest_path),
            "model_contract": contract.model_dump(),
        },
    )
    
    # Write report to run-scoped location
    report_path = write_report(report, artifact_root_dir=artifact_root_dir)
    report.report_path = report_path  # type: ignore
    
    return report