# Changelog

## Unreleased

- Windows is a supported platform: the script reconfigures stdout to UTF-8, so the report
  is byte-identical on legacy Windows console codepages (cp437/cp1252) instead of crashing
  with `UnicodeEncodeError` mid-report. Regression-tested; a CI `portability` job runs the
  full self-check on `windows-latest` and `macos-latest` in addition to Linux.
- SKILL.md: description cut to 483 characters — released OpenAI Codex builds reject
  descriptions over 500; paths now say "run scripts from the directory containing this
  SKILL.md" so a symlinked install works; `py -3` documented for Windows; the §2
  `--source` paragraph and the §1 rules-audit sentence broken into readable form; the
  unexplained "(P7's I14 and I15)" replaced with a concrete example.
- README: worked example now ships as committed files (`examples/example.md`,
  `examples/example-output.md`, byte-reproducible); the four finding classes counted
  correctly; N²/DSM glossed in plain English; Windows commands documented; tests count 84.
- RUNBOOK: section-9 detail now points at SKILL.md §1 instead of restating it; the
  `--source` citation rule split into three sentences.
- Security policy "Supported version" now names the supported version (the latest
  release) without stale first-release trivia.
- Issue-form version placeholder is no longer a hardcoded release tag.
- CI installs and self-tests the skill for every agent the `skills` CLI supports, with the
  agent list read from the CLI at run time.
- Copyright holder in `LICENSE` and the README is now `macblackstuff`.
- Code of conduct (Contributor Covenant 2.1); reports go to `conduct@macblackstuff.com`.
- README rewritten: what it does, who it is for, a worked example, the
  components and interfaces it reads, install with the harnesses tested,
  usage, how it works, the output format section by section, requirements
  and limits, related projects, and contributing, security and license. The
  badges added in 0.2.1 are gone.
- The skill description carries an explicit Not-for clause.
- CI workflow vendored into the repository.

## 0.2.2 — 2026-09-28

- Shipped the conduct and licence changes below: `CODE_OF_CONDUCT.md` names
  `conduct@macblackstuff.com`, a live mailbox, so the published policy needed a release.
- Nothing else changed in this release; v0.2.1 remains the functional baseline.

## 0.2.1 — 2026-09-26

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
