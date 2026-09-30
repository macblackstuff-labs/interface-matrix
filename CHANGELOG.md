# Changelog

## Unreleased

(none)

## 0.4.0 — 2026-09-30

- Certification gate: `--certify LEDGER` judges a review ledger against the findings the
  report derives from the input, instead of printing the report. Exit 0 — every finding
  of the five ledger kinds (candidates, gaps, boundary findings, unstated pairs, uncited
  spans) dispositioned, a certification record printed; exit 3 — refused, every blocker
  named in the record. Feedback loops, self-dependencies and the class-rules audit stay
  human-review findings the gate does not disposition. The ledger format and the gate's
  rules are SKILL.md §2–§3.
- The review ledger is identity-keyed, not line-keyed: one table
  (`Kind | Finding | Disposition | Reason | Reviewer | Date | Fingerprint`), one row per
  finding — candidates and gaps as `producer -> consumer: flows` (a blank Flows cell is
  the placeholder `?`, which pastes back as the empty identity), unstated pairs
  `A -> B`, boundary findings by component name, uncited spans `L7-9@<source sha256>` —
  each pinning the content it dispositioned by fingerprint, so an unrelated edit does not
  re-open a row. The label is emitted by one helper beside the one parser, so the paste
  contract cannot fork.
- A completed certification run (pass or refusal) writes a record beside the ledger
  (`<ledger>.cert.md`) binding the input, the report and (when `--source` ran) the
  source file by sha256, plus the effective flags; an error (exit 1) writes nothing and
  leaves the previous record in place. A passing run also stamps it into the ledger as
  its `## Certification record` section — the last passing run and the replay anchor:
  every later run re-derives the input and source sha256 it binds and refuses on
  mismatch (`drifted: input changed since the last certified run`), so a post-review
  edit of the input re-opens the whole review; a later run whose flags do not replay the
  recorded ones exits 1 naming the flag.
- Drift detection: a ledger entry whose finding is gone from the input, or changed since
  disposition, is a `drifted:` blocker. Dispositions are free text: a candidate or
  boundary finding dispositioned rather than `resolved`, and a gap parked `open`, each
  stay listed as an advisory in the certification record — what ships stays visible.
- An input that cites a source cannot be certified without `--source`: the first run is
  the only window in which span review could be skipped, so the gate refuses it (exit 1)
  rather than let a pass pin the hole into the record's flags.
- Under `--certify`, two active input rows sharing one `producer -> consumer: flows`
  identity exit 1, as does a component name containing ` -> ` or `: ` (no Finding cell
  can express it) and a disposition row placed inside the ledger's certification-record
  section — content the record-section scan must not swallow.
- SKILL.md workflow rewritten: review is writing the ledger (the first refusal record is
  the worksheet), the finished deliverable is four files shipped together — report,
  certification record, input, ledger — five under `--source` (the source file), with
  the record's invocation-relative paths replayed verbatim; review runs under separation
  of duties (the reviewer of record is someone other than whatever drafted the input),
  and a gap not filled now is parked `open` and carried as an advisory, never a blocker.
- Optional, experimental model pins: `decision`, `thinker`, `reviewer` and `judge` keys
  under `metadata:` pin a role to a model. They are instructions to the executing agent,
  not configuration — the script reads no pins, only its flags.
- README and RUNBOOK document the certification flow: the exit codes (3 added; exit 2's
  sharing with argparse usage errors was already true and is now written down), the
  certify procedure, and the drift, anchor, citing-input and flag-mismatch playbooks.
- The worked example is now certified: `examples/example-ledger.md` dispositions every
  finding `examples/example.md` produces, and `examples/example-ledger.cert.md` is the
  record its passing `--certify` run wrote from the repository-root invocation the
  ledger documents. The example input no longer cites `S:L42`/`S:L44` — a citing input
  must certify with `--source`, and no source file ships — so its report is unchanged
  from 0.3.0 (citations do not print in the report).
- The ledger and record writers pin LF newlines, so a Windows re-certification does not
  rewrite the whole ledger as CRLF.
- Standard-library additions: `hashlib` and `json` (fingerprints, record bindings). Still
  no dependencies, no install step; the self-check now runs 125 tests.

## 0.3.0 — 2026-09-29

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
