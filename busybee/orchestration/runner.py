from __future__ import annotations

from busybee.contracts.models import EvaluationReport, OutcomeRecord, TrainingConfig, TrainingRequest
from busybee.evaluation.metrics import compute_classification_metrics
from busybee.evaluation.report import write_report
from busybee.feedback.store import record_outcome
from busybee.foundation.config import load_config
from busybee.foundation.context import SystemIdentity
from busybee.foundation.logging_utils import configure_logging
from busybee.training.trainer import train_model


def _system_identity_from_config(config: dict) -> SystemIdentity:
    system = config["system"]
    return SystemIdentity(
        name=system["name"],
        doctrine_version=str(system["doctrine_version"]),
        environment=system["environment"],
    )


def run_training_cycle(config_path: str = "config/base.yaml") -> dict:
    configure_logging()
    raw = load_config(config_path)
    identity = _system_identity_from_config(raw)
    training_request = TrainingRequest(config=TrainingConfig(**raw["training"]))
    train_result, X_test, y_test, pipeline = train_model(
        request=training_request,
        system_identity=identity,
        artifact_root_dir=raw["artifacts"]["root_dir"],
    )
    y_pred = pipeline.predict(X_test)
    metrics = compute_classification_metrics(y_test, y_pred)
    report = EvaluationReport(
        run_id=train_result.run_id,
        model_name=train_result.model_artifact.model_name,
        metrics=metrics,
        metadata={
            "dataset_name": train_result.dataset.name,
            "artifact_manifest": train_result.manifest_path,
        },
    )
    report_path = write_report(report, artifact_root_dir=raw["artifacts"]["root_dir"])
    feedback_path = record_outcome(
        OutcomeRecord(
            run_id=train_result.run_id,
            outcome_type="training_cycle",
            payload={"metrics": metrics, "report_path": report_path},
        ),
        artifact_root_dir=raw["artifacts"]["root_dir"],
    )
    train_result.metrics = metrics
    train_result.report_path = report_path
    return {
        "run_id": train_result.run_id,
        "model_path": train_result.model_path,
        "manifest_path": train_result.manifest_path,
        "report_path": report_path,
        "feedback_path": feedback_path,
        "metrics": metrics,
    }
