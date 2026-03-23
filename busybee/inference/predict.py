from __future__ import annotations

import numpy as np

from busybee.contracts.models import PredictionRecord, PredictionRequest, PredictionResponse
from busybee.foundation.exceptions import PredictionError
from busybee.inference.loader import load_model


def predict(request: PredictionRequest, artifact_root_dir: str = "artifacts") -> PredictionResponse:
    model, contract = load_model(request.model_name, artifact_root_dir=artifact_root_dir)
    matrix = np.asarray(request.records, dtype=float)

    if matrix.ndim != 2:
        raise PredictionError("Prediction records must be a 2D matrix")
    if matrix.shape[1] != len(contract.feature_names):
        raise PredictionError("Prediction width does not match trained feature contract")

    labels = model.predict(matrix)
    if hasattr(model, "predict_proba"):
        probabilities = model.predict_proba(matrix)
        confidences = [float(np.max(row)) for row in probabilities]
    else:
        confidences = [1.0 for _ in range(len(labels))]

    predictions = [
        PredictionRecord(label=int(label), confidence=float(confidence))
        for label, confidence in zip(labels, confidences)
    ]
    return PredictionResponse(model_name=contract.model_name, predictions=predictions)
