from sklearn.pipeline import Pipeline

from busybee.features.transforms import make_scaler
from busybee.models.baseline import build_baseline_model


def build_training_pipeline(max_iter: int = 1000, random_state: int = 42) -> Pipeline:
    return Pipeline(
        [
            ("scaler", make_scaler()),
            ("model", build_baseline_model(max_iter=max_iter, random_state=random_state)),
        ]
    )
