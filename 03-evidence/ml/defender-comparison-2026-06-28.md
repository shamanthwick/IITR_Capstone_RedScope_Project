# ML Defender Comparison

Date: `2026-06-28`

## Commands

```powershell
python compare_defenders.py
```

## Baseline Defender

Word-token baseline confusion matrix:

```text
[[3 0]
 [1 2]]
```

Baseline evasion observation:

- URL-encoded XSS sample was classified as `normal`
- SQLi-style variants remained classified as `attack`

## Second Defender

Char n-gram defender confusion matrix:

```text
[[2 1]
 [1 2]]
```

Second-defender observation:

- All four evasion samples were classified as `attack`

## Interpretation

The second defender is slightly more robust against the lab's evasion examples, but it also traded off one normal request. This supports the capstone write-up point that a stronger detector can reduce evasion success while still remaining brittle on a tiny toy dataset.
