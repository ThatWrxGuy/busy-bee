from __future__ import annotations

from typing import Any

from pydantic import BaseModel, Field, field_validator


class DatasetContract(BaseModel):
    name: str
    feature_names: list[str]
    target_name: str
    n_rows: int
    n_features: int
    task_type: str = "classification"
    version: str = "1.0"

    @field_validator("n_rows", "n_features")
    @classmethod
    def _positive_counts(cls, value: int) -> int:
        if value <= 0:
            raise ValueError("counts must be positive")
        return value


class ModelArtifactContract(BaseModel):
    model_name: str
    version: str
    task_type: str = "classification"
    algorithm: str
    feature_names: list[str]
    target_name: str
    run_id: str


class TrainingConfig(BaseModel):
    dataset_name: str = "synthetic_classification"
    n_samples: int = 300
    n_features: int = 8
    n_informative: int = 5
    n_redundant: int = 1
    n_classes: int = 2
    test_size: float = 0.2
    random_state: int = 42
    model_name: str = "baseline_logistic"
    model_version: str = "0.2.0"
    max_iter: int = 1000

    @field_validator("test_size")
    @classmethod
    def _valid_test_size(cls, value: float) -> float:
        if not 0 < value < 1:
            raise ValueError("test_size must be between 0 and 1")
        return value


class TrainingRequest(BaseModel):
    config: TrainingConfig


class TrainResult(BaseModel):
    run_id: str
    model_path: str
    manifest_path: str
    report_path: str | None = None
    metrics: dict[str, float]
    dataset: DatasetContract
    model_artifact: ModelArtifactContract


class PredictionRequest(BaseModel):
    records: list[list[float]] = Field(default_factory=list)
    model_name: str = "baseline_logistic"

    @field_validator("records")
    @classmethod
    def _non_empty(cls, value: list[list[float]]) -> list[list[float]]:
        if not value:
            raise ValueError("records cannot be empty")
        return value


class PredictionRecord(BaseModel):
    label: int
    confidence: float


class PredictionResponse(BaseModel):
    model_name: str
    predictions: list[PredictionRecord]


class EvaluationReport(BaseModel):
    run_id: str
    model_name: str
    metrics: dict[str, float]
    metadata: dict[str, Any] = Field(default_factory=dict)


class OutcomeRecord(BaseModel):
    run_id: str
    outcome_type: str
    payload: dict[str, Any]
