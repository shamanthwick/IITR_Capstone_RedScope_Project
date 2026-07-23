# Baseline ML Detector Run

**Date:** 2026-06-27

## Command

```bash
python train_detector.py
```

## Result

Confusion matrix:

```text
[[3 0]
 [1 2]]
```

| Class | Precision | Recall | F1 | Support |
|---|---:|---:|---:|---:|
| Attack | 1.00 | 0.67 | 0.80 | 3 |
| Normal | 0.75 | 1.00 | 0.86 | 3 |

Overall accuracy: **0.83**

## Evasion Sample Predictions

- Attack — URL-encoded SQLi
- Attack — inline-comment SQLi
- Attack — mixed-case SQLi
- Normal — URL-encoded XSS

## Interpretation

The deliberately simple token-based model missed a URL-encoded XSS-style
payload because it learned surface tokens from raw request text instead of
decoding and normalizing inputs before classification.
