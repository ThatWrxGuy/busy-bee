import numpy as np
import pytest

from busybee.contracts.models import DatasetContract, TrainingConfig
from busybee.data.ingestion.synthetic import load_synthetic_dataset
from busybee.data.validation.checks import validate_dataset
from busybee.foundation.exceptions import ContractViolationError


def test_validate_dataset_passes():
    bundle = load_synthetic_dataset(TrainingConfig())
    assert validate_dataset(bundle.X, bundle.y, bundle.contract) is True


def test_validate_dataset_rejects_nan():
    bundle = load_synthetic_dataset(TrainingConfig())
    corrupted = bundle.X.copy()
    corrupted[0, 0] = np.nan
    with pytest.raises(ContractViolationError):
        validate_dataset(corrupted, bundle.y, bundle.contract)


def test_validate_dataset_rejects_wrong_width():
    bundle = load_synthetic_dataset(TrainingConfig())
    wrong_contract = DatasetContract(
        name=bundle.contract.name,
        feature_names=bundle.contract.feature_names[:-1],
        target_name=bundle.contract.target_name,
        n_rows=bundle.contract.n_rows,
        n_features=bundle.contract.n_features - 1,
    )
    with pytest.raises(ContractViolationError):
        validate_dataset(bundle.X, bundle.y, wrong_contract)
