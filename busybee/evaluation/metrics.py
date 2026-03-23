from __future__ import annotations

import numpy as np
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score


def compute_classification_metrics(y_true: np.ndarray, y_pred: np.ndarray) -> dict[str, float]:
    if len(y_true) != len(y_pred):
        raise ValueError("Metric inputs must have the same length")
    return {
        "accuracy": float(accuracy_score(y_true, y_pred)),
        "f1": float(f1_score(y_true, y_pred)),
        "precision": float(precision_score(y_true, y_pred)),
        "recall": float(recall_score(y_true, y_pred)),
    }
