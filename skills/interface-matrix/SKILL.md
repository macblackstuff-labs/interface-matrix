---
name: interface-matrix
description: "Builds an N-squared interface matrix (DSM) from a Markdown component and interface inventory: finds missing components, interface gaps, unconsumed outputs, feedback loops and never-stated component pairs. Use when planning or auditing a system of eight or more components, before work packages are cut, or on any N2 diagram, design structure matrix or gap-analysis request. Not for source-code dependency graphs, drawing, or discovering components: it needs a hand-written inventory."
license: MIT
compatibility: "Requires Python 3.9 or newer (Windows: py -3). Standard library only — no dependencies and no install step."
metadata:
  author: macblackstuff
  version: 0.4.0
  # Optional model pins — experimental until adapters exist; see "Model pins":
  # decision, thinker, reviewer, judge, each a model-name string, e.g.
  # reviewer: "a review model you independently trust"
---

# interface-matrix

## Where this fits

Pass 3 of 7 in the systems-engineering decomposition pipeline.

- **Input:** the component inventory from pass 2 — every component named, with its
  purpose, declared inputs/outputs and owner.
- **Output:** the interface list plus four finding classes. Gaps feed the
  SOURCE/RESEARCH/USER/DEFAULT gap register; the partitioned order and the loop
  blocks feed the work packages (the units of planned work the packaging pass cuts
  from this output) and their sequencing.

Do not run this before the components are known, and do not cut work packages before
it has run — an interface discovered after packaging re-opens the packaging.

## 1. Write the input file

One Markdown file, two tables. A table is a header row followed by a `|---|` separator;
the Components and Interfaces tables are the ones whose header (case-insensitive) shares
at least two names with their column set, so a misnamed required column is an error, not
a silently skipped table; a header that misspells two or more of a column set is ignored
with a stderr warning naming its line. Everything else — frontmatter, prose, other tables — is ignored.

```markdown
## Components

| Component | Kind | Notes |
|---|---|---|
| Ingest |  | pulls raw events (S:L42) |
| Analyst | external | a human, outside the system boundary |

## Interfaces

| Producer | Consumer | Flows | Format | Trigger | Owner | Source | Status |
|---|---|---|---|---|---|---|---|
| Ingest | Store | raw event rows | ndjson file | nightly cron | platform | S:L42 |  |
| Ingest | Scorer | none |  |  |  |  |  |
| ? | Analyst | weekly digest | ? | ? | ? |  |  |
```

Rules:

- `Kind` blank = internal. Outside the system boundary (human roles and third-party
  systems), exempt from the boundary check, when the Kind's first word is `external` or it
  carries the token `(external)` — `External system` and `actor (external)` both count,
  `externalize` does not.
- **List every ordered pair that exchanges anything.** A pair you leave out is an
  unstated pair, not a "no".
- `Flows` = `none` declares there is deliberately no interface for that ordered pair.
- Any of Flows/Format/Trigger/Owner left blank or `?` makes the row an interface gap
  naming those attributes. Do not invent a value to make the gap go away.
- `?` as Producer or Consumer makes the row a missing-component candidate: kept out of
  the graph and listed for you to resolve.
- Cite the source for every cell you can (`S:Lnn`, doc path, ticket). An uncited cell
  is a claim the reviewer has to re-derive.
- `Class` on Components is optional and free (`ING`, `AGT`), and only feeds the optional
  Rules table:

  ```markdown
  ## Rules

  | Producer class | Consumer class | Disposition | Reason |
  |---|---|---|---|
  | ING | AGT | none | ingest never calls an agent |
  | AGT | * | review | look at every agent output |
  ```

  A `none` rule settles every unstated pair whose producer and consumer classes match
  (`*` = any classed component): not listed, not sampled. A component with a blank `Class`
  matches no rule, not even `*`, so a forgotten Class cell can never drop pairs from
  review — section 9 names every unclassed component. `review` wins where both match. An
  explicit interface or `none` row always beats a rule.
- Section 9 (rules audit, printed only when a Rules table is present) reports, per rule:
  - the pairs it settled `none`;
  - the pairs it matched at all — a pair any `review` rule reclaimed is matched but not
    settled, and a pair settled by several `none` rules is counted under each, so the
    settled column sums to at least the total;
  - dead rules, and `none` rules that match an explicit interface;
  - the unclassed components, and the residue left for pair-by-pair review.
- An unknown `Disposition`, or a class no component has, exits 1. A table is read as the
  Rules table only if its header names both `Producer class` and `Consumer class`, so a
  foreign `| Disposition | Reason |` table is left alone.
- `Source` and `Status` are optional; the other six interface columns are required.
  A `Status` starting `superseded` retires the row (see §5).
- One Components table and one Interfaces table per file. A second table of either
  kind exits 1 naming both header lines — addenda go in the first table, below its
  existing rows.
- A backslash escapes the next character and is dropped: `\|` is a literal pipe inside a
  cell, `\\` is a literal backslash and leaves the next `|` a delimiter (`C:\\| csv` is
  `C:\` then `csv`). A `|` line outside any table is ignored with a stderr warning.

## 2. Run it

Run scripts from the directory containing this SKILL.md — every `scripts/...` path below
is relative to it, wherever the skill is installed and whatever the working directory is.
Python 3.9 or newer, standard library only (`python3`; on Windows `py -3`).

```bash
python3 scripts/interface_matrix.py INPUT.md > OUTPUT.md
python3 scripts/interface_matrix.py INPUT.md --sample 0
```

```bash
python3 scripts/interface_matrix.py INPUT.md --source TRANSCRIPT.txt
```

`--source FILE` checks coverage of the file the inventory was read from:

- Every `L<n>`, `L<a>-<b>` and `L7,11-12` in any cell of any **active** Components or
  Interfaces row counts as cited.
- A Rules row's `Reason` justifies the rule and models nothing, and a superseded row
  models nothing any more, so their citations do not cover a line — though they are
  still range-checked.
- Section 10 lists the uncited lines as contiguous spans (blank lines ignored) with
  counts. Those spans are where an unmodelled component or interface hides.

Errors, each naming the input line of the row that carries the citation: a citation past
the file's last line exits 1, as does `L0` (source line numbers start at 1); both need
`--source` to be caught. A reversed range such as `L9-7` exits 1 while parsing, with or
without `--source`.

`--sample N` sets how many unstated pairs are printed (default 20, `0` = all). The
sample is drawn deterministically: round-robin across the producer rows that have
unstated pairs, and spread evenly along each row so the picks sweep across columns. An
unknown or duplicate component name exits 1 naming the input line, as does an active
row naming a superseded component.

Exit codes: 0 a valid input — report printed, or under `--certify` certification
passed and the record printed; 1 bad input — a bad row of the input or of a ledger, a
duplicate identity, or a `--certify` whose flags do not replay the review the ledger's
record declares — every error naming its line; 2 the partition invariant tripping
while the report renders, and argparse usage errors; 3 certification refused, every
blocker named in the record. Stdlib only, no install step.

`--certify LEDGER` certifies the input against a review ledger instead of printing
the report:

```bash
python3 scripts/interface_matrix.py INPUT.md --certify INPUT.ledger.md
```

The ledger is a Markdown file kept beside the input and written during review (§3):
one disposition table, `Kind | Finding | Disposition | Reason | Reviewer | Date |
Fingerprint`, one row per finding, keyed by identity rather than input line. `Kind` is
one of `candidate`, `gap`, `boundary`, `pair`, `span`; the `Finding` cell carries the
identity — candidates and gaps read `producer -> consumer: flows` (a blank Flows cell
reads `?`, and pastes back as the empty identity), unstated pairs
`A -> B`, boundary findings the component's name, uncited spans `L7-9@<source sha256>`.
`Reviewer` is the reviewer of record (§3) and `Date` when it reviewed; `Fingerprint`
pins the content dispositioned — the record's blocker lines carry current fingerprints
to paste. Every cell but `Reason` is required.

An entry covers the finding whose identity it names when its fingerprint matches; the
disposition text is the reviewer's judgment. Certification exits 0 when every finding
of the five ledger kinds the report derives from the input — candidates, gaps,
boundary findings, unstated pairs and uncited spans — is dispositioned and none has
drifted; feedback loops, self-dependencies and class-rule audit findings are report
findings a human reviews (§4/§9) — the gate does not disposition them. Exit 3 names
every blocker — an entry whose finding is gone from the input or changed since
disposition is `drifted:`, a finding no entry covers is `unreviewed:` — and lists as
advisories, not blockers, every gap dispositioned with a `Disposition` starting `open`
and every candidate or boundary finding dispositioned with one not starting
`resolved`: what ships stays visible in the record. Under `--certify`, two active
input rows sharing one `producer -> consumer: flows` identity also exit 1 (the ledger
cannot tell them apart), as does a component name containing ` -> ` or `: ` (no
Finding cell can express it), an input that cites a source certified without
`--source` (the uncited spans would never enter review), and the ledger's own bad
rows: wrong width, unknown kind, a missing required cell, a duplicate identity, a
second disposition table, a disposition row placed inside the certification-record
section. A completed certification run — pass or refusal — writes a record beside the
ledger, `<ledger>.cert.md`, and prints it instead of the report: the input, report and
(when `--source` ran) source file bound by sha256, the gate result, every blocker and
advisory, and the effective flags, which a later certification must replay exactly.
An error (exit 1) writes nothing and leaves the previous record in place. A pass also
stamps the same record into the ledger as its `## Certification record` section,
replacing the section a previous pass stamped: that section is the last passing run
and the replay anchor — a later run re-derives the input and source sha256 it binds,
and any mismatch is a `drifted:` blocker (`input changed since the last certified
run`), so any post-review edit of the input re-opens the whole review.

Self-check: `python3 scripts/test_interface_matrix.py`.

Operating it — health checks, every error message and its fix, rollback and escalation:
`references/RUNBOOK.md`.

## 3. Independent review is mandatory

Not optional, and not a second pass by whatever drafted the input. An LLM asked to
generate a design structure matrix reproduced **357 of 462 entries — 77.3%** of a
published matrix ([arXiv 2312.04134](https://arxiv.org/abs/2312.04134)): roughly one
cell in four wrong or missing, and **false negatives dominate** — the interface that
was never written down is the one that hurts. The sparse form hides exactly that
error. That is the case for independent review, so review runs under separation of
duties: the reviewer of record — the `Reviewer` the ledger names — must be someone
other than whatever drafted the input. The default is an independent human reviewer;
a model may hold the role only when the user explicitly pinned one ("Model pins"),
and the ledger's `Reviewer` column records what actually reviewed either way.

Review is writing the ledger. Start it as nothing but the header:

```markdown
| Kind | Finding | Disposition | Reason | Reviewer | Date | Fingerprint |
|---|---|---|---|---|---|---|
```

Certify once — with `--source` when the input cites one; the gate refuses a citing
input certified without it, so the uncited spans cannot be skipped — and every finding
of the five ledger kinds comes back an `unreviewed:` blocker, named by identity and
carrying its current fingerprint: the refusal record doubles as the review worksheet.
A passing run's flags become the ones every later certification must replay. Work it
cell by cell:

1. Every listed row: are the four attributes right, and does the source support them?
   Then, per row: can the named producer actually produce this flow, and can the named
   consumer actually use it? If not, replace that endpoint with `?` and rerun — a named
   but incapable endpoint is how a missing component hides (for example, a component
   "Ingest" named as consumer of an agent's reply: it cannot hold that conversation, so
   the real endpoint is a component nobody declared yet).
2. The rules (section 9): is each `none` rule true of every pair it matched? A dead rule
   is wrong or premature; a rule that also matches an explicit interface contradicts it.
3. The residue (section 7): for each pair, is "no interface" actually true?
   Certification needs a ledger row for every pair in the residue, not just the
   sampled ones — raise `--sample` until you have looked at a share you can defend,
   or `--sample 0` for all.
4. The uncited spans (section 10): read each one. A span nothing cites is either
   irrelevant to the system or a component or interface nobody wrote down.

Each blocker ends one of two ways. Resolved: fix the input (§4), the finding leaves
the report — and any ledger row already written for it must go too (a ledger row is
retired by deleting it; the ledger has no Status column — §5's supersede rule governs
input rows), or certification reports it as `drifted:`. Or dispositioned: a ledger row
that leaves the finding in place, covered, with the decision and its reason recorded.
Rerun `--certify` after each pass; it exits 0 only when every finding of the five
ledger kinds is resolved or dispositioned — feedback loops, self-dependencies and
class-rule audit findings stay human-review findings (§4/§9) the gate does not
disposition. Editing the input after a passing run re-opens the whole review: the
ledger's stamped record section anchors the input by sha256.

## 4. Resolve the findings

| Finding | Resolution |
|---|---|
| Missing-component candidate | Add the component to the Components table, name the real endpoint, rerun. |
| Interface gap | Add a row to the gap register, classed SOURCE / RESEARCH / USER / DEFAULT. Leave the gap in the matrix. |
| Nothing feeds an internal component | It has an undeclared input, or it is a source and should say so in Notes. |
| Output nothing consumes | Add the consumer, mark the component `external`, or cut the component. One of the three — never leave it. |
| Isolated internal component | Almost always two missing interfaces, or a component that does not belong. |
| Feedback loop | Keep it. A human decides what to assume to break it; the script does not tear. |
| Self-dependency | Usually a retry or a state carry-over. Confirm it is intended. |

Each candidate and boundary finding ends one of two ways: resolved — fix the input
(§1), the row leaves the report — or dispositioned with its reason; a dispositioned
candidate or boundary finding stays visible in every report and is listed as an
advisory in the certification record until it is resolved, so a shipping candidate is
never silent. Gaps and loops may legitimately remain. A gap you are not filling now
is parked, not ignored: disposition it in the ledger with a `Disposition` starting
`open` — `open-parked` — and a reason it stays open, and certification carries it as
an advisory in the record, never a blocker.

## 5. Record changes

Once a matrix has been reviewed, **never delete or reword a prior row**. To retire one,
set its `Status` to `superseded <date>: <reason>` and add its replacement in a dated
addendum — setting `Status` is the only permitted edit to a prior row, so the review
history stays readable and a later reviewer can see what the first pass missed.

A superseded rule row stops matching; a superseded interface row leaves the graph, gaps, candidates, none-pairs and coverage
entirely, though its citations are still range-checked under `--source`. A superseded component leaves the component set, and any row still naming it
exits 1 — supersede or repoint those rows in the same pass. Section 1 reports the count.
A retired component may be re-declared under the same name in the addendum, and each name
may have at most one active row.

Then certify, and ship everything together:

```bash
python3 scripts/interface_matrix.py INPUT.md --certify INPUT.ledger.md
```

The matrix is not done until `--certify` exits 0 — a done-check that has not seen
exit 0 has not seen a finished matrix. The finished deliverable is four files shipped
together: the report, its certification record (`<ledger>.cert.md`), the input, and
the ledger — five when the review ran under `--source`, adding the source file, whose
sha256 the record binds and whose checks the pinned flags require — enough for any
consumer to re-run certification and check the record's sha256 bindings against the
files they were sent. The record's paths are invocation-relative — the input, ledger
and source paths exactly as the certified run named them — so a replay must use them
verbatim. Generate the report under the flags the record declares, `--sample N` and
`--source` as it names them, so its sha256 is the one the record binds. A report
without its certification record is a draft.

## Model pins (optional, experimental)

Four optional keys may live under `metadata:` in this file's frontmatter —
`decision`, `thinker`, `reviewer`, `judge` — each pinning that role to a model, as a
plain string value (`reviewer: "a review model you independently trust"`). They are
instructions to the agent executing the skill, not configuration: the Python script
reads no pins, only its flags. Experimental until adapters exist. Harness-specific
model settings (an agent's own `model` or `effort` fields) are non-portable and do
not belong here. Pins written into an installed copy are overwritten by a
`skills add` refresh, so persistent pinning means maintaining them in a fork or a
local override. A pin names an intended reviewer, still bound by §3's separation of
duties — distinct from whatever drafted the input; the ledger's `Reviewer` column
records what actually reviewed.

## Reading the matrix

Row feeds column. `X` specified, `g` gap, `-` explicit none, blank unstated, `S` self.
Rows and columns are in partitioned order (strongly connected components, then a
topological order of the condensation), so every mark below the diagonal lies inside a
feedback-loop block. The script asserts that; if it ever trips, the partition is wrong.
