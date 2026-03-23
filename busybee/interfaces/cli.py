from __future__ import annotations

import argparse
import json
from pathlib import Path

from busybee.contracts.models import PredictionRequest
from busybee.foundation.config import load_config
from busybee.inference.predict import predict
from busybee.orchestration.runner import run_training_cycle


def main() -> None:
    parser = argparse.ArgumentParser(description="BusyBee CLI")
    parser.add_argument("command", choices=["train", "evaluate", "predict"], help="Operation to execute")
    parser.add_argument("--config", default="config/base.yaml", help="Path to config file")
    parser.add_argument(
        "--input-json",
        help="JSON file with records for prediction, shaped as [[...], [...]]",
    )
    parser.add_argument(
        "--run-id",
        help="Run ID for evaluate/predict commands (to load specific artifact version)",
    )
    args = parser.parse_args()

    config = load_config(args.config)
    model_name = config["training"]["model_name"]
    artifact_root_dir = config["artifacts"]["root_dir"]

    if args.command == "train":
        result = run_training_cycle(config_path=args.config)
        print(json.dumps(result.model_dump(), indent=2))
        return

    if args.command == "evaluate":
        if not args.run_id:
            raise SystemExit("--run-id is required for evaluate (to load existing artifact)")
        from busybee.evaluation.artifact import evaluate_artifact
        report = evaluate_artifact(
            model_name=model_name,
            run_id=args.run_id,
            artifact_root_dir=artifact_root_dir,
        )
        print(json.dumps(report.model_dump(), indent=2))
        return

    if args.command == "predict":
        if not args.input_json:
            raise SystemExit("--input-json is required for predict")
        records = json.loads(Path(args.input_json).read_text())
        # Load with run-scoped artifact path if run_id provided
        from busybee.inference.loader import load_model
        model, contract = load_model(
            model_name=model_name,
            artifact_root_dir=artifact_root_dir,
            run_id=args.run_id,
        )
        from busybee.inference.predict import predict
        response = predict(PredictionRequest(records=records, model_name=model_name), artifact_root_dir=artifact_root_dir)
        print(response.model_dump_json(indent=2))


if __name__ == "__main__":
    main()
