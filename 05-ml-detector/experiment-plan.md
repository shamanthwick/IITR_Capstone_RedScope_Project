# Adversarial ML Detector Experiment

## Goal

Build a small classifier that distinguishes normal HTTP requests from attack-like requests, then show how modified attack inputs can evade it.

## Proposed Model

- Language: Python
- Libraries: scikit-learn, pandas
- Features: character n-grams or token counts from HTTP request paths/body
- Labels: `normal` and `attack`

## Evaluation

- Train/test split accuracy
- Confusion matrix
- Examples of false negatives
- Explanation of why evasion worked

## First Baseline Result

The initial executable baseline is stored at `../03-evidence/ml/baseline-run.md`.
The refreshed run on `2026-06-28` is stored at `../03-evidence/ml/detector-run-2026-06-28.md`.
The team stretch-goal comparison is stored at `../03-evidence/ml/defender-comparison-2026-06-28.md`.

The simple token-based model classified one URL-encoded XSS-style payload as `normal`, which gives the adversarial ML section a concrete evasion example to explain.
On the refreshed run, SQLi-style variants were still detected, but the classifier continued to miss the URL-encoded XSS-style sample.

## Evasion Ideas

- Case variation
- Inline comments
- URL encoding
- Whitespace changes
- Equivalent SQL syntax

For the final write-up, use the observed false negative as the primary evasion example and note that token-based models are not robust to all encodings or payload formats.

The optional team stretch goal is now covered by a second defender based on character n-grams. It reduces the observed evasion success, but it also introduces a false positive on the small sample set.

All examples must remain inside the lab and should be used only against intentionally vulnerable targets.
