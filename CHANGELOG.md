# Changelog

## Unreleased

- Copyright holder in `LICENSE` and the README is now `macblackstuff`.

## 0.2.1 — 2026-09-27

- Moved to [github.com/macblackstuff/interface-matrix](https://github.com/macblackstuff/interface-matrix);
  every link and install command now uses the new owner. The old `macblackstuff-labs` URLs redirect.
- Contributing guide, issue forms and pull request template; README badges; release
  headings dated.

## 0.2.0 — 2026-09-26

- `Kind` now decides external by the same token test `check_plan.py` uses: the Kind's
  first word is `external`, or it carries the token `(external)`. `actor (external)` and
  `External system` are outside the boundary; `externalize` and `(externalish)` are not.
  Previously only the exact word `external` counted.
- A table whose header misspells two or more of a Components, Interfaces or Rules column
  set is still ignored, but now with a stderr warning naming its line. Foreign tables
  (`| Disposition | Reason |`, `| Fruit | Colour |`) stay silent as before.

## 0.1.0 — 2026-09-26

- First release: `interface_matrix.py` builds an N-squared interface matrix (DSM) report
  from a Markdown Components/Interfaces/Rules inventory, with the skill, runbook and
  self-check.
