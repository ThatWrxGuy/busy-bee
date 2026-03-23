# BusyBee

BusyBee is a doctrine-driven machine learning starter system. It translates the Sacred Systems Doctrine into executable engineering primitives: identity, boundaries, contracts, observability, and feedback.

## What changed in this cohesive refactor

- A real installable Python package under `busybee/`
- Explicit identity, run-context, and artifact manifests
- Versioned contracts for training, inference, evaluation, and feedback
- A single orchestration boundary for train/evaluate/predict
- Cleaner artifact handling with metadata sidecars
- Stronger validation and failure-mode coverage
- Updated doctrine docs, including a doctrine-to-code gap analysis matrix

## Quickstart

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e .

# Train a model - produces run-scoped artifacts
busybee train --config config/base.yaml

# Evaluate an existing artifact (requires --run-id from train output)
busybee evaluate --config config/base.yaml --run-id <run_id_from_train>

# Predict using specific artifact version
busybee predict --config config/base.yaml --input-json data.json --run-id <run_id>

# Run tests
pytest
```

## Repository map

- `busybee/foundation/` — identity, config, logging, paths, exceptions
- `busybee/contracts/` — typed contracts for system exchanges
- `busybee/data/` — dataset generation, validation, and splitting
- `busybee/training/` — model pipeline assembly and persistence
- `busybee/inference/` — model loading and prediction services
- `busybee/evaluation/` — metrics and report writing
- `busybee/orchestration/` — the legal boundary into system execution
- `busybee/feedback/` — persisted outcomes for recursion
- `docs/architecture/` — doctrine, engineering translation, and gap analysis

## Doctrine

See `docs/architecture/sacred_systems_doctrine_v1_1.md`.
