from __future__ import annotations

from pathlib import Path
from typing import Any

import yaml

from busybee.foundation.paths import project_root


def load_config(path: str | Path = "config/base.yaml") -> dict[str, Any]:
    config_path = Path(path)
    if not config_path.is_absolute():
        config_path = project_root() / config_path
    return yaml.safe_load(config_path.read_text())
