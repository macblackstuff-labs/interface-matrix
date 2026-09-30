---
module: interface-matrix
date: 2026-09-30
problem_type: best_practice
component: development_workflow
severity: critical
applies_when:
  - "Building CI gates, review-certification gates, or merge blockers that attest prior work"
  - "A gate anchors its verdict on a persistent record (ledger, manifest, stamp, lockfile)"
  - "Gate logic replays or re-stamps records across multiple runs"
  - "First-run flags or options become the permanent anchor for later replays"
symptoms:
  - "Gate exits GREEN after the attested input was edited post-review"
  - "A tampered or stale ledger record still certifies exit 0"
  - "A passing re-run stamps a fresh record over the old one (laundering)"
  - "An unguarded first run permanently locks a review dimension out of all later runs"
root_cause: "the gate writes its hash-bound anchor record but never re-derives and compares it on subsequent runs, so both the record's integrity and the first run's flag choices are trusted rather than verified"
resolution_type: code_fix
tags: [verification-gate, attestation, silent-pass, anchor-record, first-run, certification]
---

# Attestation gates lie green unless the anchor is re-verified every run and the first run is guarded

## Context

interface-matrix v0.4.0 (merged via PR macblackstuff/interface-matrix#14) added a
review-certification gate: `interface_matrix.py --certify LEDGER` re-derives findings from the
input file and judges a human review ledger of dispositions against them. A pass (exit 0) stamps a
`## Certification record` section into the ledger that binds the input/source files by sha256 and
the flags the review ran under; refusals exit 3 naming every blocker, bad records/flags exit 1.

Adversarial execution-testing — actually running constructed attacks against the shipped gate, not
reading the code — found four P1s that static reading had missed (run 20260930-030735-c0aa86ef),
all demonstrated live, pre-fix:

- A fully-specified input certified; one input row was then edited from `tls|cron|alice` to
  `plaintext-ftp|cron|mallory`; re-certify against the same ledger exited 0 and re-stamped the
  record to bind the edited input. Fully-specified rows carry no per-finding fingerprint, so
  per-finding drift detection had nothing to catch.
- A garbage `- input:` sha in the record still certified and got re-stamped clean — re-stamping
  launders a tampered anchor.
- An input citing source lines, certified first-run without `--source`, pinned
  `- flags: --sample 20` forever; the follow-up run WITH `--source` then exited 1 on flag replay.
  Span review was not skipped once — it was permanently locked out of every future run.

The same silent-green class dominated the skill's earlier engineering (session history): misnamed
Components columns silently ignored, citations in superseded rows skipped, a typo'd blocked-by id
passing — every silent skip had to be converted to a warning or hard failure before the pipeline's
checks could be trusted at all (session history).

## Guidance

Two principles govern any attestation gate (review certification, CI gate, merge blocker):

1. **Verify the anchor on every run.** The record a gate anchors on must be re-derived and
   compared on every run — never written once and then trusted. The anchor here lives in the same
   mutable artifact it attests (the record section is stamped into the ledger it certifies). That
   co-location is necessary — there is nothing else durable to bind to — but it is exactly why the
   binding must be re-checked each run rather than believed: an attacker (or an ordinary edit)
   touches the same file the anchor defends. A mismatch must block (here: a `drifted:` blocker,
   exit 3), and an unparseable or rewritten anchor must be bad input (exit 1), never a clean pass
   that silently re-stamps over it.
2. **Guard the first run.** Whatever state the first passing run pins — flags, identities, config —
   becomes the permanent replay anchor. A gate that replays its recorded invocation exactly
   (good discipline) converts any dimension the first run skipped into a dimension *no* run can
   ever add: strict replay then refuses the corrected invocation. So the first run must refuse to
   pass while a review dimension is reachable but unexamined (an input citing source lines must
   certify with `--source`, or the uncited spans never exist to be reviewed).

Failure shape to watch for: **silent green**. The gate does not crash; it exits 0 and rewrites its
own evidence. Laundering is the signature — each pass re-stamps the anchor to bind whatever is
true *now*, so a tampered or edited state becomes indistinguishable from a reviewed one after one
green run.

Prevention: before shipping a gate, write the failing tests that (a) pass once, edit the attested
artifact, and re-run — expecting refusal, and (b) tamper the anchor itself — expecting refusal, and
(c) run the first pass with a review dimension skipped — expecting exit-before-stamp. Then attack
the gate by execution: construct the attack inputs and run them. All four P1s here were found by
adversarial execution-testing; none by reading. This extends the earlier negative-path-proof
discipline — checks were only trusted after being shown to fail on broken input (session history) —
from "the check rejects bad input" to "the gate cannot be talked into re-attesting after the fact."

## Why This Matters

A certification gate's entire value is that green means "a human reviewed exactly this." A gate
that certifies edited inputs, launders tampered anchors, or permanently amputates a review
dimension is worse than no gate: it produces a signed-looking artifact asserting review that never
happened, and it blocks the fix (flag replay refuses the corrected invocation). Silent-green
failures are invisible in CI logs — every run passes — so they persist until someone attacks the
gate on purpose.

## When to Apply

- Any gate that attests work: review certification, CI/merge gates, policy checks, sign-off bots.
- Whenever the attestation is stored inside an artifact the attested process can still mutate
  (checklist in the PR body, record stamped in the reviewed file, cache in the repo).
- Whenever a gate "replays" or pins its first invocation's configuration — that pin is a lock, and
  the first run chooses what is locked in.
- Whenever a gate writes or updates its own evidence on success — ask what a tampered or stale
  version of that evidence would do to the next run.

## Examples

Fixed behavior in `skills/interface-matrix/scripts/interface_matrix.py` (v0.4.0, PR #14):

- `read_ledger()` (:780) now parses the stamped record section, capturing the `- flags:` line
  (:813) and the `- input:`/`- source:` sha bindings via `record_sha()` (:771); a second record,
  duplicated flag/sha lines, or a disposition row inside the section all exit 1 (:804-:826).
- `certify()` re-derives the current input and source sha256 and compares them to the bound ones
  on **every** run, appending the `drifted: input changed since the last certified run` blocker on
  mismatch (:1098-:1104) — deliberately whole-input, because it also covers rows the ledger never
  fingerprints (:1094-:1097).
- The first-run guard: an input that cites source lines cannot certify without `--source` — `die()`
  (:106, exit 1) fires before anything is stamped (:1035-:1043) — so a pass can never pin a
  span-less review into the flags.
- `check_flags()` (:865-:886) replays the recorded flags exactly: sample mismatch, source
  declared-but-not-invoked, invoked-but-not-declared, and path mismatch each exit 1 — which is only
  safe because the first-run guard keeps the pin complete.
- `certification_record()` (:1146-:1165) is the stamp format (`- input: PATH (sha256 ...)`,
  `- flags: --sample N [--source PATH]`); only a pass re-stamps the ledger (:1220-:1221).

Tests pinning the two principles, in `skills/interface-matrix/scripts/test_interface_matrix.py`:

- `test_post_review_edit_of_a_stated_row_reopens_the_review` (:1699) — pass, edit the input, re-run
  → exit 3 with the `drifted: input changed` blocker; the ledger keeps the last passing stamp while
  the standalone record shows the refusal.
- `test_tampered_record_input_sha_refuses` (:1722) — zeroed `- input:` sha → exit 3 (re-derived
  mismatch); a non-binding `- input:` line → exit 1 (bad record section). Neither launders.
- `test_citing_input_certified_without_source_exits_1` (:1339) — the first-run guard: citing input
  without `--source` exits 1 naming the uncited spans; with `--source` the same input proceeds to a
  normal review refusal (:1351).
