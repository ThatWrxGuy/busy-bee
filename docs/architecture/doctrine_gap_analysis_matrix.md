# Doctrine-to-Code Gap Analysis Matrix

| Doctrine principle | Current interpretation in original repo | Gap | Refactor response |
|---|---|---|---|
| Identity First | Folder naming implied identity | No explicit run, artifact, or system identity | Added `SystemIdentity`, `RunContext`, model manifests |
| Boundaries Are Explicit | Scripts imported internals directly | Execution depended on implicit import paths | Added installable package and CLI boundary |
| All Interaction Is Contract-Based | Some Pydantic models existed | Core flows still used tuples and dict conventions | Added request/response contracts across train, inference, evaluation, feedback |
| Stability Requires Structure | IPO shape existed informally | Failure modes and validation were shallow | Added strict dataset validation and explicit artifact/report contracts |
| Domains Are Finite | Package layout was promising | Dependency directions were soft | Consolidated legal entrypoint through orchestration layer |
| Data Is Ground Truth | Synthetic data and a validator existed | Schema fidelity and metadata persistence were thin | Added dataset contracts and feature metadata |
| System Must Behave as One Field | Local runner coordinated modules | No shared run context or manifest | Added orchestration around identity, reports, and feedback |
| Core Nodes Are Protected | No special handling | Loading and persistence were optimistic | Added dedicated exceptions and manifest checks |
| All Relationships Are Defined | Dependencies existed but were implicit | No first-class artifact relationship record | Added manifest sidecars and report metadata |
| Completion Requires Integrity | Light tests only | Missing negative tests and observability discipline | Added negative-path tests and logging bootstrap |
| Output Must Influence Future Behavior | Feedback directory existed | Feedback not part of default lifecycle | Training cycle now records outcomes automatically |
| Architecture Must Recurse | Intent visible in structure | Not encoded as hard interfaces | Added reusable contracts and service boundaries that can repeat per module |
