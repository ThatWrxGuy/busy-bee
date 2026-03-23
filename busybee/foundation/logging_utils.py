from __future__ import annotations

import logging
from typing import Optional

_DEFAULT_FORMAT = "%(asctime)s | %(levelname)s | %(name)s | %(message)s"


def configure_logging(level: int = logging.INFO, fmt: str = _DEFAULT_FORMAT) -> None:
    root = logging.getLogger()
    if not root.handlers:
        logging.basicConfig(level=level, format=fmt)
    else:
        root.setLevel(level)


def get_logger(name: Optional[str] = None) -> logging.Logger:
    return logging.getLogger(name or "busybee")
