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
    args = parser.parse_args()

    if args.command in {"train", "evaluate"}:
        result = run_training_cycle(config_path=args.config)
        print(json.dumps(result, indent=2))
        return

    if args.command == "predict":
        if not args.input_json:
            raise SystemExit("--input-json is required for predict")
        records = json.loads(Path(args.input_json).read_text())
        model_name = load_config(args.config)["training"]["model_name"]
        response = predict(PredictionRequest(records=records, model_name=model_name))
        print(response.model_dump_json(indent=2))


if __name__ == "__main__":
    main()
