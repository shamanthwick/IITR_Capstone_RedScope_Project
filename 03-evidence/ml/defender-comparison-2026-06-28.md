# ML Defender Comparison

**Date:** 2026-06-28

## Command

```bash
python compare_defenders.py
```

## Word-Token Baseline

```text
[[3 0]
 [1 2]]
```

- The URL-encoded XSS sample was classified as normal.
- SQLi-style variants remained classified as attack.

## Character N-Gram Defender

```text
[[2 1]
 [1 2]]
```

- All four evasion samples were classified as attack.
- One normal test request was classified as attack.

## Interpretation

The character n-gram defender is more robust against the lab's four evasion
examples, but it also introduces a false positive on the small sample set. This
supports the capstone conclusion that stronger evasion resistance may create
operational tradeoffs and remains brittle when trained on very limited data.
