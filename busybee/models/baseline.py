from sklearn.linear_model import LogisticRegression


def build_baseline_model(max_iter: int = 1000, random_state: int = 42) -> LogisticRegression:
    return LogisticRegression(max_iter=max_iter, random_state=random_state)
