from __future__ import annotations

import numpy as np

from busybee.contracts.models import DatasetContract
from busybee.foundation.exceptions import ContractViolationError


def validate_dataset(X: np.ndarray, y: np.ndarray, contract: DatasetContract) -> bool:
    if X is None or y is None:
        raise ContractViolationError("Dataset cannot be None")
    if not isinstance(X, np.ndarray) or not isinstance(y, np.ndarray):
        raise ContractViolationError("Dataset must be numpy arrays")
    if X.ndim != 2:
        raise ContractViolationError("Features must be a 2D matrix")
    if y.ndim != 1:
        raise ContractViolationError("Labels must be a 1D array")
    if len(X) == 0 or len(y) == 0:
        raise ContractViolationError("Dataset cannot be empty")
    if len(X) != len(y):
        raise ContractViolationError("Feature rows must match label rows")
    if X.shape[1] != contract.n_features:
        raise ContractViolationError("Feature width does not match contract")
    if not np.issubdtype(X.dtype, np.number):
        raise ContractViolationError("Features must be numeric")
    if np.isnan(X).any() or np.isnan(y).any():
        raise ContractViolationError("Dataset cannot contain NaN values")
    if not np.isfinite(X).all() or not np.isfinite(y).all():
        raise ContractViolationError("Dataset cannot contain infinite values")
    unique = np.unique(y)
    if unique.size < 2:
        raise ContractViolationError("Classification dataset requires at least two classes")
    return True
