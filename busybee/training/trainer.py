from __future__ import annotations

import json

import joblib
import numpy as np

from busybee.contracts.models import ModelArtifactContract, TrainResult, TrainingRequest
from busybee.data.ingestion.synthetic import load_synthetic_dataset
from busybee.data.splitting import build_split
from busybee.data.validation.checks import validate_dataset
from busybee.foundation.context import RunContext, SystemIdentity
from busybee.foundation.exceptions import BusyBeeError
from busybee.foundation.logging_utils import get_logger
from busybee.foundation.paths import ensure_artifact_dirs
from busybee.training.pipelines import build_training_pipeline

logger = get_logger(__name__)


def train_model(
    request: TrainingRequest,
    system_identity: SystemIdentity,
    artifact_root_dir: str = "artifacts",
) -> tuple[TrainResult, np.ndarray, np.ndarray, object]:
    dirs = ensure_artifact_dirs(artifact_root_dir)
    context = RunContext.create(dirs["root"])
    dataset = load_synthetic_dataset(request.config)
    validate_dataset(dataset.X, dataset.y, dataset.contract)
    X_train, X_test, y_train, y_test = build_split(
        dataset.X,
        dataset.y,
        test_size=request.config.test_size,
        random_state=request.config.random_state,
    )
    pipeline = build_training_pipeline(
        max_iter=request.config.max_iter,
        random_state=request.config.random_state,
    )
    pipeline.fit(X_train, y_train)

    model_filename = f"{request.config.model_name}.joblib"
    manifest_filename = f"{request.config.model_name}.manifest.json"
    model_path = dirs["models"] / model_filename
    manifest_path = dirs["models"] / manifest_filename

    try:
        joblib.dump(pipeline, model_path)
    except Exception as exc:
        raise BusyBeeError(f"Failed to persist model artifact: {exc}") from exc

    model_contract = ModelArtifactContract(
        model_name=request.config.model_name,
        version=request.config.model_version,
        algorithm="logistic_regression",
        feature_names=dataset.contract.feature_names,
        target_name=dataset.contract.target_name,
        run_id=context.run_id,
    )
    manifest_payload = {
        "system": {
            "name": system_identity.name,
            "doctrine_version": system_identity.doctrine_version,
            "environment": system_identity.environment,
        },
        "dataset": dataset.contract.model_dump(),
        "model_artifact": model_contract.model_dump(),
        "run_context": {
            "run_id": context.run_id,
            "started_at": context.started_at,
        },
    }
    manifest_path.write_text(json.dumps(manifest_payload, indent=2))

    result = TrainResult(
        run_id=context.run_id,
        model_path=str(model_path),
        manifest_path=str(manifest_path),
        metrics={},
        dataset=dataset.contract,
        model_artifact=model_contract,
    )
    logger.info("Training complete for run %s", context.run_id)
    return result, X_test, y_test, pipeline
