# RedScope ML Detector

A lab-only adversarial machine-learning demonstration for classifying normal
and attack-like HTTP requests.

## Recommended Script

`ml_detector_report.py` is the polished combined experiment. It:

- validates the dataset;
- compares the word-token baseline with a character n-gram defender;
- shows accuracy, attack precision, attack recall, and attack F1;
- tests four controlled evasion samples;
- identifies test-set false positives and false negatives;
- generates Markdown, JSON, and PNG evidence.

The original `train_detector.py` and `compare_defenders.py` scripts are retained
for comparison.

## Setup

### Windows

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
py -m pip install -r requirements.txt
py ml_detector_report.py
```

### Linux / macOS

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python ml_detector_report.py
```

Generated evidence is saved in `results/`:

- `detector_report.md`
- `detector_results.json`
- `confusion_matrices.png`

Useful options:

```bash
python ml_detector_report.py --help
python ml_detector_report.py --no-color
python ml_detector_report.py --dataset path/to/requests.csv
python ml_detector_report.py --output-dir path/to/results
python ml_detector_report.py --timezone Asia/Kolkata
```

## Dataset Format

The CSV must contain exactly two columns:

```csv
label,request
normal,GET /products HTTP/1.1
attack,GET /item?id=1' OR '1'='1 HTTP/1.1
```

Supported labels are `normal` and `attack`.

## Important Limitation

The included dataset has only 20 examples. It is suitable for demonstrating
classification, evasion, and defensive tradeoffs, but it is not evidence of
production readiness. A real detector needs representative traffic, robust
normalization, broader attack coverage, environment-specific threshold tuning,
drift monitoring, and continuous validation.

Use only in a controlled lab or against systems you are explicitly authorized
to assess.
