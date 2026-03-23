class BusyBeeError(Exception):
    """Base exception for BusyBee."""


class ContractViolationError(BusyBeeError):
    """Raised when data or message contracts are invalid."""


class ArtifactNotFoundError(BusyBeeError):
    """Raised when an expected artifact is missing."""


class ModelLoadError(BusyBeeError):
    """Raised when a model artifact cannot be loaded safely."""


class PredictionError(BusyBeeError):
    """Raised when a prediction request cannot be fulfilled."""
