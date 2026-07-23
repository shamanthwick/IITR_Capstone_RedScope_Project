# ML Detector Baseline Run

**Date:** 2026-06-28

## Command

```bash
python train_detector.py
```

## Result

```text
[[3 0]
 [1 2]]
```

## Key Metrics

- Accuracy: **0.83**
- Attack recall: **0.67**
- Normal recall: **1.00**

## Evasion Observation

A URL-encoded XSS-style payload was classified as normal. SQLi-style variants
using URL encoding, inline comments, and mixed case were still classified as
attack in this run.

## Interpretation

The toy classifier is sensitive to its limited training set and does not
generalize to every malformed or encoded attack string. It demonstrates
detector limitations for the capstone; it is not a production security control.
