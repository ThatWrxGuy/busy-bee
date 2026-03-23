import pytest

from busybee.contracts.models import PredictionRequest, TrainingConfig, TrainingRequest
from busybee.foundation.context import SystemIdentity
from busybee.foundation.exceptions import PredictionError
from busybee.inference.predict import predict
from busybee.training.trainer import train_model


def test_predict_rejects_wrong_feature_width(tmp_path):
    identity = SystemIdentity(name="BusyBee", doctrine_version="1.1", environment="test")
    train_model(
        TrainingRequest(config=TrainingConfig()),
        system_identity=identity,
        artifact_root_dir=str(tmp_path / "artifacts"),
    )
    with pytest.raises(PredictionError):
        predict(
            PredictionRequest(records=[[1.0, 2.0]], model_name="baseline_logistic"),
            artifact_root_dir=str(tmp_path / "artifacts"),
        )
