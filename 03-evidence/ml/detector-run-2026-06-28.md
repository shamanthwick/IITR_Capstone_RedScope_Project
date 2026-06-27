# ML Detector Baseline Run

Date: `2026-06-28`

## Command

```powershell
python train_detector.py
```

## Result

Confusion matrix:

```text
[[3 0]
 [1 2]]
```

## Key Metrics

- Accuracy: `0.83`
- Attack recall: `0.67`
- Normal recall: `1.00`

## Evasion Observation

- A URL-encoded XSS-style payload was classified as `normal`.
- SQLi-style variants with encoding, inline comments, and mixed case were still classified as `attack` in this run.

## Interpretation

The toy classifier is sensitive to the limited training set and does not generalize well to all malformed or encoded attack strings. This is sufficient for the capstone write-up as a demonstration of detector limitations, not as a production control.
