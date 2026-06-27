from pathlib import Path

import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline


ROOT = Path(__file__).resolve().parent
DATASET = ROOT / "sample_requests.csv"


def load_data() -> pd.DataFrame:
    data = pd.read_csv(DATASET)
    if set(data.columns) != {"label", "request"}:
        raise ValueError("Dataset must contain exactly: label, request")
    return data


def build_model() -> Pipeline:
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


def main() -> None:
    data = load_data()
    x_train, x_test, y_train, y_test = train_test_split(
        data["request"],
        data["label"],
        test_size=0.3,
        random_state=7,
        stratify=data["label"],
    )

    model = build_model()
    model.fit(x_train, y_train)

    predictions = model.predict(x_test)
    print("Confusion matrix:")
    print(confusion_matrix(y_test, predictions, labels=["normal", "attack"]))
    print()
    print(classification_report(y_test, predictions))

    evasion_samples = [
        "GET /item?id=1%27%20OR%20%271%27=%271 HTTP/1.1",
        "GET /item?id=1'/**/OR/**/'1'='1 HTTP/1.1",
        "GET /item?id=1' oR '1'='1 HTTP/1.1",
        "GET /search?q=%3Cscript%3Ealert(1)%3C/script%3E HTTP/1.1",
    ]

    print("Evasion sample predictions:")
    for sample, prediction in zip(evasion_samples, model.predict(evasion_samples)):
        print(f"{prediction:>6}  {sample}")


if __name__ == "__main__":
    main()
