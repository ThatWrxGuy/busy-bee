from busybee.training.pipelines import build_training_pipeline


def test_build_training_pipeline_steps():
    pipeline = build_training_pipeline()
    assert "scaler" in pipeline.named_steps
    assert "model" in pipeline.named_steps
