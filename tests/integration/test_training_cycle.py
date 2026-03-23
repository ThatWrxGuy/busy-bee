from pathlib import Path

from busybee.orchestration.runner import run_training_cycle


def test_training_cycle_creates_artifacts(tmp_path):
    config_path = tmp_path / "config.yaml"
    config_path.write_text(
        '''
system:
  name: BusyBee
  doctrine_version: "1.1"
  environment: test
training:
  dataset_name: synthetic_classification
  n_samples: 120
  n_features: 8
  n_informative: 5
  n_redundant: 1
  n_classes: 2
  test_size: 0.25
  random_state: 7
  model_name: baseline_logistic
  model_version: "0.2.0"
  max_iter: 1000
artifacts:
  root_dir: "{artifact_dir}"
'''.format(artifact_dir=(tmp_path / "artifacts").as_posix())
    )
    result = run_training_cycle(str(config_path))
    # Use typed contract attribute access per doctrine
    assert Path(result.model_path).exists()
    assert Path(result.manifest_path).exists()
    assert Path(result.report_path).exists()
    assert Path(result.feedback_path).exists()
    assert "accuracy" in result.metrics
