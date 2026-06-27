# Baseline ML Detector Run

Date: 2026-06-27

Command:

```powershell
python train_detector.py
```

Environment:

- Python 3.14.6
- scikit-learn 1.9.0
- pandas 3.0.3

Result:

```text
Confusion matrix:
[[3 0]
 [1 2]]

              precision    recall  f1-score   support

      attack       1.00      0.67      0.80         3
      normal       0.75      1.00      0.86         3

    accuracy                           0.83         6
   macro avg       0.88      0.83      0.83         6
weighted avg       0.88      0.83      0.83         6

Evasion sample predictions:
attack  GET /item?id=1%27%20OR%20%271%27=%271 HTTP/1.1
attack  GET /item?id=1'/**/OR/**/'1'='1 HTTP/1.1
attack  GET /item?id=1' oR '1'='1 HTTP/1.1
normal  GET /search?q=%3Cscript%3Ealert(1)%3C/script%3E HTTP/1.1
```

Interpretation:

The deliberately simple token-based model missed a URL-encoded XSS-style payload because it learned surface tokens from raw request text instead of decoding and normalizing inputs before classification.
