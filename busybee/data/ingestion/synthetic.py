from __future__ import annotations

from dataclasses import dataclass

import numpy as np
from sklearn.datasets import make_classification

from busybee.contracts.models import DatasetContract, TrainingConfig
from busybee.foundation.logging_utils import get_logger

logger = get_logger(__name__)


@dataclass(frozen=True)
class DatasetBundle:
    X: np.ndarray
    y: np.ndarray
    contract: DatasetContract


def load_synthetic_dataset(config: TrainingConfig) -> DatasetBundle:
    logger.info("Generating synthetic dataset '%s'", config.dataset_name)
    X, y = make_classification(
        n_samples=config.n_samples,
        n_features=config.n_features,
        n_informative=config.n_informative,
        n_redundant=config.n_redundant,
        n_classes=config.n_classes,
        random_state=config.random_state,
    )
    contract = DatasetContract(
        name=config.dataset_name,
        feature_names=[f"feature_{index}" for index in range(config.n_features)],
        target_name="label",
        n_rows=int(X.shape[0]),
        n_features=int(X.shape[1]),
    )
    return DatasetBundle(X=X, y=y, contract=contract)
