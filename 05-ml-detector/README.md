# ML Detector Scaffold

This folder contains a small baseline classifier for the capstone's adversarial ML section.

The team version now also includes a second, slightly stronger defender comparison to show how the observed evasion degrades against a character n-gram model.

## Files

- `sample_requests.csv`: toy labeled HTTP request examples
- `train_detector.py`: trains and evaluates a character n-gram classifier
- `compare_defenders.py`: compares the baseline model against a second defender
- `requirements.txt`: Python dependencies

## Run

```powershell
python -m pip install -r requirements.txt
python train_detector.py
```

## Important Limitation

The sample dataset is intentionally small. It is useful for demonstrating the concept, but the final report should clearly state that a real detector needs broader data, better labels, environment-specific validation, and continuous tuning.
