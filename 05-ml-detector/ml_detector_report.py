#!/usr/bin/env python3
"""Generate a polished adversarial ML detector comparison report.

This lab-only script trains:
1. A word-token TF-IDF + Logistic Regression baseline.
2. A character n-gram TF-IDF + Logistic Regression defender.

It prints an easy-to-read console dashboard and writes reproducible evidence
files (Markdown, JSON, and PNG) to the selected output directory.
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import sys
from dataclasses import asdict, dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, Iterable
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

import pandas as pd
import sklearn
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    precision_recall_fscore_support,
)
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline


ROOT = Path(__file__).resolve().parent
DEFAULT_DATASET = ROOT / "sample_requests.csv"
DEFAULT_OUTPUT_DIR = ROOT / "results"
DEFAULT_TIMEZONE = os.getenv("REDSCOPE_TIMEZONE", "Asia/Kolkata")
LABELS = ["normal", "attack"]
RANDOM_STATE = 7
TEST_SIZE = 0.30


@dataclass(frozen=True)
class EvasionSample:
    sample_id: str
    technique: str
    request: str


@dataclass
class ModelResult:
    name: str
    description: str
    confusion_matrix: list[list[int]]
    accuracy: float
    attack_precision: float
    attack_recall: float
    attack_f1: float
    classification_report: dict[str, Any]
    false_negatives: list[str]
    false_positives: list[str]
    evasion_results: list[dict[str, Any]]


EVASION_SAMPLES = [
    EvasionSample(
        "EV-01",
        "URL-encoded SQL injection",
        "GET /item?id=1%27%20OR%20%271%27=%271 HTTP/1.1",
    ),
    EvasionSample(
        "EV-02",
        "Inline-comment SQL injection",
        "GET /item?id=1'/**/OR/**/'1'='1 HTTP/1.1",
    ),
    EvasionSample(
        "EV-03",
        "Mixed-case SQL injection",
        "GET /item?id=1' oR '1'='1 HTTP/1.1",
    ),
    EvasionSample(
        "EV-04",
        "URL-encoded XSS",
        "GET /search?q=%3Cscript%3Ealert(1)%3C/script%3E HTTP/1.1",
    ),
]


class Style:
    """Small ANSI styling helper with automatic plain-text fallback."""

    def __init__(self, enabled: bool) -> None:
        self.enabled = enabled

    def wrap(self, text: str, code: str) -> str:
        return f"\033[{code}m{text}\033[0m" if self.enabled else text

    def bold(self, text: str) -> str:
        return self.wrap(text, "1")

    def blue(self, text: str) -> str:
        return self.wrap(text, "94")

    def cyan(self, text: str) -> str:
        return self.wrap(text, "96")

    def green(self, text: str) -> str:
        return self.wrap(text, "92")

    def yellow(self, text: str) -> str:
        return self.wrap(text, "93")

    def red(self, text: str) -> str:
        return self.wrap(text, "91")

    def dim(self, text: str) -> str:
        return self.wrap(text, "2")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Train and compare two toy HTTP request detectors.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--dataset",
        type=Path,
        default=DEFAULT_DATASET,
        help="CSV file containing label and request columns.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT_DIR,
        help="Directory for generated evidence files.",
    )
    parser.add_argument(
        "--no-color",
        action="store_true",
        help="Disable ANSI colors in terminal output.",
    )
    parser.add_argument(
        "--timezone",
        default=DEFAULT_TIMEZONE,
        help="IANA timezone used in generated evidence timestamps.",
    )
    return parser.parse_args()


def load_data(dataset: Path) -> pd.DataFrame:
    if not dataset.is_file():
        raise FileNotFoundError(f"Dataset not found: {dataset}")

    data = pd.read_csv(dataset)
    if set(data.columns) != {"label", "request"}:
        raise ValueError("Dataset must contain exactly these columns: label, request")
    if data.empty:
        raise ValueError("Dataset must contain at least one row")
    if data[["label", "request"]].isnull().any().any():
        raise ValueError("Dataset contains missing labels or requests")

    invalid_labels = sorted(set(data["label"]) - set(LABELS))
    if invalid_labels:
        raise ValueError(
            "Unsupported label(s): "
            f"{', '.join(invalid_labels)}. Expected only: {', '.join(LABELS)}"
        )

    label_counts = data["label"].value_counts()
    if any(label_counts.get(label, 0) < 2 for label in LABELS):
        raise ValueError("Each label needs at least two rows for a stratified split")

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
            (
                "classifier",
                LogisticRegression(max_iter=1000, random_state=RANDOM_STATE),
            ),
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
            (
                "classifier",
                LogisticRegression(max_iter=1000, random_state=RANDOM_STATE),
            ),
        ]
    )


def evaluate_model(
    name: str,
    description: str,
    model: Pipeline,
    x_train: pd.Series,
    x_test: pd.Series,
    y_train: pd.Series,
    y_test: pd.Series,
) -> ModelResult:
    model.fit(x_train, y_train)
    predictions = model.predict(x_test)
    probabilities = model.predict_proba([sample.request for sample in EVASION_SAMPLES])
    predicted_evasions = model.predict([sample.request for sample in EVASION_SAMPLES])
    attack_index = list(model.classes_).index("attack")

    matrix = confusion_matrix(y_test, predictions, labels=LABELS)
    report = classification_report(
        y_test,
        predictions,
        labels=LABELS,
        output_dict=True,
        zero_division=0,
    )
    attack_precision, attack_recall, attack_f1, _ = (
        precision_recall_fscore_support(
            y_test,
            predictions,
            labels=["attack"],
            average=None,
            zero_division=0,
        )
    )

    false_negatives = [
        request
        for request, actual, predicted in zip(x_test, y_test, predictions)
        if actual == "attack" and predicted == "normal"
    ]
    false_positives = [
        request
        for request, actual, predicted in zip(x_test, y_test, predictions)
        if actual == "normal" and predicted == "attack"
    ]

    evasion_results = []
    for sample, prediction, probability_row in zip(
        EVASION_SAMPLES, predicted_evasions, probabilities
    ):
        evasion_results.append(
            {
                **asdict(sample),
                "prediction": str(prediction),
                "attack_probability": float(probability_row[attack_index]),
                "outcome": "detected" if prediction == "attack" else "evaded",
            }
        )

    return ModelResult(
        name=name,
        description=description,
        confusion_matrix=matrix.astype(int).tolist(),
        accuracy=float(accuracy_score(y_test, predictions)),
        attack_precision=float(attack_precision[0]),
        attack_recall=float(attack_recall[0]),
        attack_f1=float(attack_f1[0]),
        classification_report=report,
        false_negatives=false_negatives,
        false_positives=false_positives,
        evasion_results=evasion_results,
    )


def line(char: str = "─", width: int = 78) -> str:
    return char * width


def print_banner(style: Style) -> None:
    print(style.blue("╔" + "═" * 76 + "╗"))
    print(
        style.blue("║")
        + style.bold(" REDSCOPE · ADVERSARIAL ML DETECTOR REPORT ".center(76))
        + style.blue("║")
    )
    print(
        style.blue("║")
        + style.dim(" Lab-only HTTP request classification experiment ".center(76))
        + style.blue("║")
    )
    print(style.blue("╚" + "═" * 76 + "╝"))


def print_dataset_summary(data: pd.DataFrame, style: Style) -> None:
    counts = data["label"].value_counts()
    print()
    print(style.bold(style.cyan("DATASET SUMMARY")))
    print(line())
    print(
        f"  Total samples : {len(data):>3}      "
        f"Training : {int(len(data) * (1 - TEST_SIZE)):>3}      "
        f"Testing : {int(len(data) * TEST_SIZE):>3}"
    )
    print(
        f"  Normal        : {int(counts.get('normal', 0)):>3}      "
        f"Attack   : {int(counts.get('attack', 0)):>3}      "
        f"Split   : stratified"
    )


def print_metric_table(results: list[ModelResult], style: Style) -> None:
    print()
    print(style.bold(style.cyan("MODEL PERFORMANCE")))
    print(line())
    header = (
        f"{'Model':<25} {'Accuracy':>10} {'Atk Precision':>14} "
        f"{'Atk Recall':>11} {'Atk F1':>9}"
    )
    print(style.bold(header))
    print(line())
    for result in results:
        print(
            f"{result.name:<25} {result.accuracy:>9.2%} "
            f"{result.attack_precision:>13.2%} {result.attack_recall:>10.2%} "
            f"{result.attack_f1:>8.2%}"
        )


def print_confusion_matrices(results: list[ModelResult], style: Style) -> None:
    print()
    print(style.bold(style.cyan("CONFUSION MATRICES")))
    print(line())
    for result in results:
        matrix = result.confusion_matrix
        print(style.bold(result.name))
        print("                         Predicted")
        print("                     Normal   Attack")
        print(f"  Actual Normal      {matrix[0][0]:>6}   {matrix[0][1]:>6}")
        print(f"  Actual Attack      {matrix[1][0]:>6}   {matrix[1][1]:>6}")
        print()


def print_evasion_table(results: list[ModelResult], style: Style) -> None:
    print(style.bold(style.cyan("EVASION TEST RESULTS")))
    print(line())
    print(
        style.bold(
            f"{'ID':<7} {'Technique':<34} "
            f"{'Word baseline':<17} {'Char defender':<17}"
        )
    )
    print(line())

    result_maps = [
        {item["sample_id"]: item for item in result.evasion_results}
        for result in results
    ]
    for sample in EVASION_SAMPLES:
        cells = []
        for mapping in result_maps:
            item = mapping[sample.sample_id]
            label = f"{item['prediction']} ({item['attack_probability']:.0%})"
            cells.append(
                style.green(label)
                if item["prediction"] == "attack"
                else style.red(label)
            )
        print(
            f"{sample.sample_id:<7} {sample.technique:<34} "
            f"{cells[0]:<17} {cells[1]:<17}"
        )

    print()
    print(
        "  Legend: "
        + style.green("attack = detected")
        + "  |  "
        + style.red("normal = evasion succeeded")
    )


def print_findings(results: list[ModelResult], style: Style) -> None:
    baseline, defender = results
    baseline_evasions = sum(
        item["outcome"] == "evaded" for item in baseline.evasion_results
    )
    defender_evasions = sum(
        item["outcome"] == "evaded" for item in defender.evasion_results
    )

    print()
    print(style.bold(style.cyan("KEY FINDINGS")))
    print(line())
    print(
        "  "
        + (
            style.red("●")
            if baseline_evasions
            else style.green("●")
        )
        + f" Word-token baseline: {baseline_evasions}/{len(EVASION_SAMPLES)} "
        "evasion samples bypassed detection."
    )
    print(
        "  "
        + (
            style.red("●")
            if defender_evasions
            else style.green("●")
        )
        + f" Character n-gram defender: {defender_evasions}/{len(EVASION_SAMPLES)} "
        "evasion samples bypassed detection."
    )
    print(
        "  "
        + style.yellow("●")
        + " This 20-row toy dataset demonstrates detector behavior; it does not "
        "establish production readiness."
    )


def save_confusion_chart(results: list[ModelResult], output_path: Path) -> None:
    # Defer the import so console-only failures still produce useful diagnostics.
    os.environ.setdefault("MPLCONFIGDIR", str(output_path.parent / ".mpl-cache"))
    import matplotlib  # noqa: PLC0415

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt  # noqa: PLC0415
    import numpy as np  # noqa: PLC0415

    fig, axes = plt.subplots(1, len(results), figsize=(11, 4.8))
    fig.patch.set_facecolor("#07111f")
    if len(results) == 1:
        axes = [axes]

    palette = matplotlib.colors.LinearSegmentedColormap.from_list(
        "redscope", ["#13253d", "#00b8d9", "#a7f3d0"]
    )

    for axis, result in zip(axes, results):
        matrix = np.asarray(result.confusion_matrix)
        axis.set_facecolor("#0b172a")
        axis.imshow(matrix, cmap=palette, vmin=0, vmax=max(1, int(matrix.max())))
        axis.set_title(result.name, color="#f8fafc", fontsize=12, weight="bold", pad=12)
        axis.set_xticks([0, 1], LABELS)
        axis.set_yticks([0, 1], LABELS)
        axis.set_xlabel("Predicted label", color="#cbd5e1")
        axis.set_ylabel("Actual label", color="#cbd5e1")
        axis.tick_params(colors="#cbd5e1")

        threshold = matrix.max() / 2
        for row in range(2):
            for column in range(2):
                value = int(matrix[row, column])
                axis.text(
                    column,
                    row,
                    str(value),
                    ha="center",
                    va="center",
                    color="#07111f" if value > threshold else "#f8fafc",
                    fontsize=20,
                    weight="bold",
                )
        for spine in axis.spines.values():
            spine.set_color("#334155")

    fig.suptitle(
        "RedScope · HTTP Request Detector Comparison",
        color="#67e8f9",
        fontsize=16,
        weight="bold",
        y=1.02,
    )
    fig.tight_layout()
    fig.savefig(output_path, dpi=220, bbox_inches="tight", facecolor=fig.get_facecolor())
    plt.close(fig)


def markdown_matrix(matrix: list[list[int]]) -> str:
    return "\n".join(
        [
            "| Actual \\ Predicted | Normal | Attack |",
            "|---|---:|---:|",
            f"| Normal | {matrix[0][0]} | {matrix[0][1]} |",
            f"| Attack | {matrix[1][0]} | {matrix[1][1]} |",
        ]
    )


def make_markdown_report(
    dataset: Path,
    data: pd.DataFrame,
    results: list[ModelResult],
    generated_at: str,
    timezone_name: str,
) -> str:
    baseline, defender = results
    lines = [
        "# RedScope Adversarial ML Detector Report",
        "",
        f"**Generated:** {generated_at}  ",
        f"**Timezone:** `{timezone_name}`  ",
        f"**Dataset:** `{dataset.name}`  ",
        "**Scope:** Lab-only demonstration",
        "",
        "## Executive Summary",
        "",
        (
            "The word-token baseline and character n-gram defender were trained "
            "on the same stratified split. The character model detected more of "
            "the deliberately modified attack inputs, while its test-set behavior "
            "shows that stronger evasion resistance can still introduce tradeoffs."
        ),
        "",
        "## Dataset and Method",
        "",
        f"- Samples: **{len(data)}**",
        f"- Normal requests: **{int((data['label'] == 'normal').sum())}**",
        f"- Attack requests: **{int((data['label'] == 'attack').sum())}**",
        f"- Train/test split: **{int((1 - TEST_SIZE) * 100)}/{int(TEST_SIZE * 100)}**",
        f"- Random state: **{RANDOM_STATE}**",
        "- Classifier: **Logistic Regression**",
        "",
        "## Performance Summary",
        "",
        "| Model | Accuracy | Attack precision | Attack recall | Attack F1 |",
        "|---|---:|---:|---:|---:|",
    ]
    for result in results:
        lines.append(
            f"| {result.name} | {result.accuracy:.2%} | "
            f"{result.attack_precision:.2%} | {result.attack_recall:.2%} | "
            f"{result.attack_f1:.2%} |"
        )

    lines.extend(["", "## Confusion Matrices", ""])
    for result in results:
        lines.extend([f"### {result.name}", "", markdown_matrix(result.confusion_matrix), ""])

    lines.extend(
        [
            "![Confusion matrix comparison](confusion_matrices.png)",
            "",
            "## Evasion Results",
            "",
            "| ID | Technique | Word baseline | Char defender |",
            "|---|---|---|---|",
        ]
    )
    for index, sample in enumerate(EVASION_SAMPLES):
        word_result = baseline.evasion_results[index]
        char_result = defender.evasion_results[index]
        lines.append(
            f"| {sample.sample_id} | {sample.technique} | "
            f"{word_result['prediction']} "
            f"({word_result['attack_probability']:.1%} attack probability) | "
            f"{char_result['prediction']} "
            f"({char_result['attack_probability']:.1%} attack probability) |"
        )

    lines.extend(["", "## Observed Errors", ""])
    for result in results:
        lines.append(f"### {result.name}")
        lines.append("")
        if result.false_negatives:
            lines.append("**False negatives**")
            lines.append("")
            lines.extend(f"- `{item}`" for item in result.false_negatives)
        else:
            lines.append("- False negatives: none")
        lines.append("")
        if result.false_positives:
            lines.append("**False positives**")
            lines.append("")
            lines.extend(f"- `{item}`" for item in result.false_positives)
        else:
            lines.append("- False positives: none")
        lines.append("")

    baseline_evasions = [
        item for item in baseline.evasion_results if item["outcome"] == "evaded"
    ]
    defender_evasions = [
        item for item in defender.evasion_results if item["outcome"] == "evaded"
    ]
    lines.extend(
        [
            "## Interpretation",
            "",
            (
                f"- The word-token baseline missed **{len(baseline_evasions)} of "
                f"{len(EVASION_SAMPLES)}** adversarial samples."
            ),
            (
                f"- The character n-gram defender missed **{len(defender_evasions)} "
                f"of {len(EVASION_SAMPLES)}** adversarial samples."
            ),
            (
                "- Character n-grams retain punctuation and local character "
                "patterns that the baseline token pattern discards, which can "
                "improve detection of encoded or reformatted payloads."
            ),
            (
                "- Results are highly sensitive to the tiny dataset. Accuracy and "
                "evasion resistance here should be treated as demonstration "
                "evidence, not production performance."
            ),
            "",
            "## Recommended Production Improvements",
            "",
            "1. Decode and canonicalize URL/body data before feature extraction.",
            "2. Train on more representative normal and malicious traffic.",
            "3. Test multiple encodings and nested/double-encoding cases.",
            "4. Tune thresholds using environment-specific false-positive costs.",
            "5. Combine ML output with deterministic WAF/rule-based detections.",
            "6. Monitor drift and revalidate after model or application changes.",
            "",
            "## Reproducibility",
            "",
            f"- Python: `{platform.python_version()}`",
            f"- pandas: `{pd.__version__}`",
            f"- scikit-learn: `{sklearn.__version__}`",
            "",
            "> Authorized lab use only. Do not test payloads against systems you "
            "do not own or have explicit permission to assess.",
            "",
        ]
    )
    return "\n".join(lines)


def save_json_report(
    dataset: Path,
    data: pd.DataFrame,
    results: list[ModelResult],
    generated_at: str,
    timezone_name: str,
    output_path: Path,
) -> None:
    payload = {
        "experiment": "RedScope Adversarial ML Detector Comparison",
        "scope": "lab-only",
        "generated_at": generated_at,
        "timezone": timezone_name,
        "environment": {
            "python": platform.python_version(),
            "pandas": pd.__version__,
            "scikit_learn": sklearn.__version__,
        },
        "dataset": {
            "file": dataset.name,
            "samples": len(data),
            "normal": int((data["label"] == "normal").sum()),
            "attack": int((data["label"] == "attack").sum()),
        },
        "split": {
            "test_size": TEST_SIZE,
            "random_state": RANDOM_STATE,
            "stratified": True,
        },
        "models": [asdict(result) for result in results],
    }
    output_path.write_text(
        json.dumps(payload, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def print_output_files(output_dir: Path, files: Iterable[Path], style: Style) -> None:
    print()
    print(style.bold(style.cyan("GENERATED EVIDENCE")))
    print(line())
    for path in files:
        display_path = path.relative_to(output_dir.parent)
        print("  " + style.green("✓") + f" {display_path}")
    print()
    print(style.bold(style.green("Experiment completed successfully.")))
    print(style.dim("Authorized lab use only."))


def main() -> int:
    args = parse_args()
    style = Style(enabled=sys.stdout.isatty() and not args.no_color)
    output_dir = args.output_dir.resolve()
    dataset = args.dataset.resolve()

    try:
        data = load_data(dataset)
        x_train, x_test, y_train, y_test = train_test_split(
            data["request"],
            data["label"],
            test_size=TEST_SIZE,
            random_state=RANDOM_STATE,
            stratify=data["label"],
        )

        results = [
            evaluate_model(
                "Word-token baseline",
                "Word-token TF-IDF features with Logistic Regression",
                build_word_model(),
                x_train,
                x_test,
                y_train,
                y_test,
            ),
            evaluate_model(
                "Char n-gram defender",
                "Character 3–5 gram TF-IDF features with Logistic Regression",
                build_char_model(),
                x_train,
                x_test,
                y_train,
                y_test,
            ),
        ]

        output_dir.mkdir(parents=True, exist_ok=True)
        try:
            timezone = ZoneInfo(args.timezone)
        except ZoneInfoNotFoundError as exc:
            raise ValueError(f"Unknown IANA timezone: {args.timezone}") from exc
        generated_at = datetime.now(timezone).isoformat(timespec="seconds")
        markdown_path = output_dir / "detector_report.md"
        json_path = output_dir / "detector_results.json"
        chart_path = output_dir / "confusion_matrices.png"

        markdown_path.write_text(
            make_markdown_report(
                dataset,
                data,
                results,
                generated_at,
                args.timezone,
            ),
            encoding="utf-8",
        )
        save_json_report(
            dataset,
            data,
            results,
            generated_at,
            args.timezone,
            json_path,
        )
        save_confusion_chart(results, chart_path)

        print_banner(style)
        print_dataset_summary(data, style)
        print_metric_table(results, style)
        print_confusion_matrices(results, style)
        print_evasion_table(results, style)
        print_findings(results, style)
        print_output_files(
            output_dir,
            [markdown_path, json_path, chart_path],
            style,
        )
        return 0
    except (FileNotFoundError, ValueError, OSError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    except Exception as exc:  # Defensive final boundary for a CLI tool.
        print(f"UNEXPECTED ERROR: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
