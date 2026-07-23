# Adversarial ML Detector Experiment

## Goal

Build a small classifier that distinguishes normal HTTP requests from
attack-like requests, then show how modified attack inputs can evade it.

## Proposed Models

- Language: Python
- Libraries: scikit-learn, pandas, matplotlib
- Baseline features: word tokens from raw HTTP request text
- Second defender features: character n-grams of length 3–5
- Classifier: Logistic Regression
- Labels: `normal` and `attack`

## Evaluation

- Stratified 70/30 train/test split
- Accuracy
- Attack precision, recall, and F1
- Confusion matrices
- Test-set false positives and false negatives
- Controlled adversarial sample predictions and probabilities
- Explanation of observed evasion behavior

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


The observed false negative from the word-token baseline is the primary evasion
example. The character n-gram comparison demonstrates that a modified feature
representation can reduce evasion success while still creating classification
tradeoffs on a tiny dataset.

All examples must remain inside the lab and should be used only against
intentionally vulnerable or explicitly authorized targets.
