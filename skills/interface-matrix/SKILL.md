---
name: interface-matrix
description: "Builds an N-squared interface matrix (DSM) from a Markdown component and interface inventory: finds missing components, interface gaps, unconsumed outputs, feedback loops and never-stated component pairs. Use when planning or auditing a system of roughly eight or more components, once the components are known and before work packages are cut, or on any request for an N2 diagram, design structure matrix, interface list, or gap analysis between components."
license: MIT
compatibility: Requires Python 3.9 or newer. Standard library only — no dependencies and no install step.
---

# interface-matrix

## Where this fits

Pass 3 of 7 in the systems-engineering decomposition pipeline.

- **Input:** the component inventory from pass 2 — every component named, with its
  purpose, declared inputs/outputs and owner.
- **Output:** the interface list plus four finding classes. Gaps feed the
  SOURCE/RESEARCH/USER/DEFAULT gap register; the partitioned order and the loop
  blocks feed the work packages and their sequencing.

Do not run this before the components are known, and do not cut work packages before
it has run — an interface discovered after packaging re-opens the packaging.

## 1. Write the input file

One Markdown file, two tables. A table is a header row followed by a `|---|` separator;
the Components and Interfaces tables are the ones whose header (case-insensitive) shares
at least two names with their column set, so a misnamed required column is an error, not
a silently skipped table. Everything else — frontmatter, prose, other tables — is ignored.

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

- `Kind` blank = internal. `external` = outside the system boundary (human roles and
  third-party systems), exempt from the boundary check.
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
  explicit interface or `none` row always beats a rule. Section 9 reports, per rule, the
  pairs it settled `none` and the pairs it matched at all (a pair any `review` rule
  reclaimed is matched but not settled; a pair settled by several `none`
  rules is counted under each, so the settled column sums to at least the total), dead rules, `none` rules that match an explicit interface, the unclassed
  components, and the residue left for pair-by-pair review. An unknown `Disposition`, or a
  class no component has, exits 1. A table is read as the Rules table only if its header
  names both `Producer class` and `Consumer class`, so a foreign `| Disposition | Reason |`
  table is left alone.
- `Source` and `Status` are optional; the other six interface columns are required.
  A `Status` starting `superseded` retires the row (see §5).
- One Components table and one Interfaces table per file. A second table of either
  kind exits 1 naming both header lines — addenda go in the first table, below its
  existing rows.
- A backslash escapes the next character and is dropped: `\|` is a literal pipe inside a
  cell, `\\` is a literal backslash and leaves the next `|` a delimiter (`C:\\| csv` is
  `C:\` then `csv`). A `|` line outside any table is ignored with a stderr warning.

## 2. Run it

Run from this skill's own directory; every `scripts/...` path below is relative to it.
Python 3.9 or newer, standard library only.

```bash
python3 scripts/interface_matrix.py INPUT.md > OUTPUT.md
python3 scripts/interface_matrix.py INPUT.md --sample 0
```

```bash
python3 scripts/interface_matrix.py INPUT.md --source TRANSCRIPT.txt
```

`--source FILE` checks coverage of the file the inventory was read from: every `L<n>`,
`L<a>-<b>` and `L7,11-12` in any cell of any active Components or Interfaces row counts
as cited — a Rules row's `Reason` justifies the rule and models nothing, and a superseded
row models nothing any more, so their citations do not cover a line, though they are still
range-checked — and section 10
lists the uncited lines as contiguous spans (blank lines ignored) with counts. Those spans
are where an unmodelled component or interface hides. A citation past the file's last line exits 1, as
does `L0` (source line numbers start at 1); both need `--source` to be caught. A reversed
range such as `L9-7` exits 1 while parsing, with or without `--source`. Every one of these
errors names the input line of the row that carries the citation.

`--sample N` sets how many unstated pairs are printed (default 20, `0` = all). The
sample is drawn deterministically: round-robin across the producer rows that have
unstated pairs, and spread evenly along each row so the picks sweep across columns. An
unknown or duplicate component name exits 1 naming the input line, as does an active
row naming a superseded component; valid input exits 0.
Stdlib only, no install step.

Self-check: `python3 scripts/test_interface_matrix.py`.

Operating it — health checks, every error message and its fix, rollback and escalation:
`references/RUNBOOK.md`.

## 3. Human review is mandatory

Not optional and not delegable to another model pass. An LLM asked to generate a
design structure matrix reproduced **357 of 462 entries — 77.3%** of a published
matrix ([arXiv 2312.04134](https://arxiv.org/abs/2312.04134)): roughly one cell in
four wrong or missing, and **false negatives dominate** — the interface that was never
written down is the one that hurts. The sparse form hides exactly that error.

So review, cell by cell:

1. Every listed row: are the four attributes right, and does the source support them?
   Then, per row: can the named producer actually produce this flow, and can the named
   consumer actually use it? If not, replace that endpoint with `?` and rerun — a named
   but incapable endpoint is how a missing component hides (P7's I14 and I15).
2. The rules (section 9): is each `none` rule true of every pair it matched? A dead rule
   is wrong or premature; a rule that also matches an explicit interface contradicts it.
3. The residue (section 7): for each pair, is "no interface" actually true? Raise
   `--sample` until you have looked at a share you can defend, or `--sample 0` for all.
4. The uncited spans (section 10): read each one. A span nothing cites is either
   irrelevant to the system or a component or interface nobody wrote down.

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

Rerun until there are no missing-component candidates and no unexplained boundary
findings. Gaps and loops may legitimately remain — candidates and silent boundary
findings may not.

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

## Reading the matrix

Row feeds column. `X` specified, `g` gap, `-` explicit none, blank unstated, `S` self.
Rows and columns are in partitioned order (strongly connected components, then a
topological order of the condensation), so every mark below the diagonal lies inside a
feedback-loop block. The script asserts that; if it ever trips, the partition is wrong.
