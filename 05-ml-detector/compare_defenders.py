"""Original two-model comparison retained for reference."""

from pathlib import Path

import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline


ROOT = Path(__file__).resolve().parent
DATASET = ROOT / "sample_requests.csv"


def load_data() -> pd.DataFrame:
    data = pd.read_csv(DATASET)
    if set(data.columns) != {"label", "request"}:
        raise ValueError("Dataset must contain exactly: label, request")
    return data


def build_word_model() -> Pipeline:
    return Pipeline(
        steps=[
            (
                "vectorizer",
                TfidfVectorizer(
                    analyzer="word",
                    token_pattern=r"[A-Za-z0-9_]{2,}",
                    lowercase=True,
                ),
            ),
            ("classifier", LogisticRegression(max_iter=1000)),
        ]
    )


def build_char_model() -> Pipeline:
    return Pipeline(
        steps=[
            (
                "vectorizer",
                TfidfVectorizer(
                    analyzer="char",
                    ngram_range=(3, 5),
                    lowercase=True,
                ),
            ),
            ("classifier", LogisticRegression(max_iter=1000)),
        ]
    )


def run_model(
    name: str,
    model: Pipeline,
    x_train,
    x_test,
    y_train,
    y_test,
    samples,
) -> None:
    model.fit(x_train, y_train)
    predictions = model.predict(x_test)
    print(f"{name} confusion matrix:")
    print(confusion_matrix(y_test, predictions, labels=["normal", "attack"]))
    print()
    print(f"{name} evasion sample predictions:")
    for sample, prediction in zip(samples, model.predict(samples)):
        print(f"{prediction:>6}  {sample}")
    print()


def main() -> None:
    data = load_data()
    x_train, x_test, y_train, y_test = train_test_split(
        data["request"],
        data["label"],
        test_size=0.3,
        random_state=7,
        stratify=data["label"],
    )

    evasion_samples = [
        "GET /item?id=1%27%20OR%20%271%27=%271 HTTP/1.1",
        "GET /item?id=1'/**/OR/**/'1'='1 HTTP/1.1",
        "GET /item?id=1' oR '1'='1 HTTP/1.1",
        "GET /search?q=%3Cscript%3Ealert(1)%3C/script%3E HTTP/1.1",
    ]

    run_model(
        "Word-token baseline",
        build_word_model(),
        x_train,
        x_test,
        y_train,
        y_test,
        evasion_samples,
    )
    run_model(
        "Char n-gram defender",
        build_char_model(),
        x_train,
        x_test,
        y_train,
        y_test,
        evasion_samples,
    )


if __name__ == "__main__":
    main()
