# interface-matrix

An Agent Skill for Claude Code, Codex, Cursor and any harness that reads `skills/` from
disk: it builds an N² interface matrix — a design structure matrix (DSM) — from a Markdown
component and interface inventory, and runs the interface-management gap analysis a sparse
interface list hides.

## What it does

The input is one Markdown file with a Components table and an Interfaces table, written by
you or by an agent from a transcript, spec or code read. Each interface row names a
producer, a consumer and four attributes: flows, format, trigger, owner.

The script builds the directed graph of the stated interfaces, partitions it (strongly
connected components, then a topological order of the condensation) and reports four
classes of finding — missing components, interface gaps, boundary problems (unconsumed
outputs and isolated components) and feedback loops — plus every component pair nobody
has stated either way. With `--source FILE` it also reports the lines of the source
document that no cell cites.

The output is one Markdown report on stdout: numbered sections plus the matrix itself, row
feeds column. Nothing is inferred and no gap is filled in for you — a gap stays a gap until
a human resolves it.

An N² matrix (N-squared; a design structure matrix, or DSM) lists every component on both
axes, so each of the N×N cells is a yes/no/unknown about one directed pair — that is what
a flat interface list cannot show.

## Who it is for

Systems engineers, architects and technical leads planning or auditing a system of roughly
eight or more components, at the point where the components are known and the work packages
have not been cut yet. It is also pass 3 of the seven-pass decomposition pipeline shipped by
[`macblackstuff/system-adoption-pipeline`](https://github.com/macblackstuff/system-adoption-pipeline),
and it works on its own.

## Example

A ready-made input lives at [`examples/example.md`](examples/example.md), and the real
report it produces is committed beside it as
[`examples/example-output.md`](examples/example-output.md). To follow along, from
`skills/interface-matrix` write this to `example.md`:

```markdown
## Components

| Component | Kind | Notes |
|---|---|---|
| Ingest |  | pulls raw events |
| Store |  | event store |
| Scorer |  | scores events |
| Analyst | external | reads the digest |

## Interfaces

| Producer | Consumer | Flows | Format | Trigger | Owner | Source | Status |
|---|---|---|---|---|---|---|---|
| Ingest | Store | raw event rows | ndjson file | nightly cron | platform |  |  |
| Store | Scorer | event batches | ? | ? | platform |  |  |
| ? | Analyst | weekly digest | ? | ? | ? |  |  |
```

Then run [`scripts/interface_matrix.py`](skills/interface-matrix/scripts/interface_matrix.py):

```bash
python3 scripts/interface_matrix.py example.md
```

Eight sections come back. The summary, the two finding tables and the matrix:

```
## 1. Summary

- components: 4 (3 internal, 1 external)
- specified interfaces: 1
- interfaces with gaps: 1
- explicit none: 0
- missing-component candidates: 1
- unstated pairs: 10
- feedback loops: 0
- self-dependencies: 0
- superseded rows: 0 (interfaces 0, components 0)

## 2. Missing-component candidates

| line | producer | consumer | flows |
|---|---|---|---|
| line 23 | ? | Analyst | weekly digest |

## 3. Interface gaps

| line | producer | consumer | missing |
|---|---|---|---|
| line 22 | Store | Scorer | Format, Trigger |
```

```
## 8. Matrix

Row feeds column. Legend: `X` specified, `g` gap, `-` none, blank unstated, `S` self.

           1  2  3  4  
  1 Ingest  .     X    
  2 Analyst    .       
  3 Store         .  g 
  4 Scorer           . 
```

Three stated rows, and the report names one unowned digest producer, one interface missing
its format and trigger, a component nothing feeds, an output nothing consumes, and ten
component pairs nobody has ruled in or out.

The example is also certified: [`examples/example-ledger.md`](examples/example-ledger.md)
is the review ledger that dispositions every finding it produces, and
[`examples/example-ledger.cert.md`](examples/example-ledger.cert.md) is the certification
record the passing `--certify` run wrote.

## Install

| Harness | Command | Notes |
|---|---|---|
| [`skills` CLI](https://github.com/vercel-labs/skills) | `npx skills add macblackstuff/interface-matrix` | Pick agents and scope interactively. |
| Claude Code | `npx skills add macblackstuff/interface-matrix --skill interface-matrix -g -a claude-code -y --copy` | Verified in CI. |
| Codex | `npx skills add macblackstuff/interface-matrix --skill interface-matrix -g -a codex -y --copy` | Verified in CI. |
| Cursor | `npx skills add macblackstuff/interface-matrix --skill interface-matrix -g -a cursor -y --copy` | Verified in CI. |
| Gemini CLI | `npx skills add macblackstuff/interface-matrix --skill interface-matrix -g -a gemini-cli -y --copy` | Verified in CI. |
| GitHub Copilot | `npx skills add macblackstuff/interface-matrix --skill interface-matrix -g -a github-copilot -y --copy` | Verified in CI. |
| opencode | `npx skills add macblackstuff/interface-matrix --skill interface-matrix -g -a opencode -y --copy` | Verified in CI. |
| Any harness that reads `skills/` from disk | `cp -R skills/interface-matrix /path/to/your/skills/` | Every path inside the skill is relative to its own folder, so the destination does not matter. |

Verify the install from inside the installed folder with [`scripts/test_interface_matrix.py`](skills/interface-matrix/scripts/test_interface_matrix.py):

```bash
python3 scripts/test_interface_matrix.py    # Ran 125 tests ... OK
```

On Windows the interpreter is `py -3` (`py -3 scripts/interface_matrix.py example.md`);
the script writes UTF-8 whatever the console codepage is, so the report is identical on
every platform.

### Harnesses tested

CI installs the skill with the [`skills` CLI](https://github.com/vercel-labs/skills) on every push
and pull request, once per agent in its own throwaway home, and runs the 125 tests from each
installed copy. Every agent the CLI supports is covered — 79 at the time of writing (`skills`
1.7.0), of which 77 are installed and tested; the list is read from the CLI at run time. Two
agents are excluded with reasons recorded in `.github/scripts/smoke-install.sh`: `eve` and
`promptscript` — the CLI reports that neither supports global skill installation.

A separate CI job runs the same tests on Windows and macOS, so the skill is verified on the
platforms its users actually run, not just Linux.

The skill itself is harness-neutral: it is a `SKILL.md` plus standard-library Python, with no
agent-specific commands.

## Usage

Ask the agent in natural language — the skill's description triggers on planning or auditing
a system of roughly eight or more components, and on any request for an N² diagram, a design
structure matrix, an interface list, or a gap analysis between components.

Directly from a shell, run from the skill's own directory:

```bash
python3 scripts/interface_matrix.py INPUT.md > OUTPUT.md
python3 scripts/interface_matrix.py INPUT.md --sample 0
python3 scripts/interface_matrix.py INPUT.md --source TRANSCRIPT.txt
```

On Windows use `py -3` in place of `python3`.

`--sample N` sets how many unstated pairs are printed (default 20, `0` = all).
`--source FILE` adds the coverage section over the document the inventory was read from.

### Certifying a reviewed matrix

Findings are reviewed into a ledger — one table,
`Kind | Finding | Disposition | Reason | Reviewer | Date | Fingerprint`, one row per
finding, keyed by identity rather than input line. Start it as nothing but the header row
and certify once; every finding comes back an `unreviewed:` blocker carrying its current
fingerprint, so the refusal record doubles as the review worksheet:

```bash
python3 scripts/interface_matrix.py INPUT.md --certify INPUT.ledger.md
```

Disposition each finding in the ledger — the fingerprints to paste are in the record —
and certify again. Exit 0 writes `<ledger>.cert.md` beside the ledger: the certification
record, binding the input, the report and (under `--source`) the source file by sha256,
plus the flags the review ran under, which every later certification must replay exactly.
A citing input must certify with `--source` — the gate refuses it otherwise — and the
record a pass stamps into the ledger anchors the input and source by sha256, so any
post-review edit re-opens the review. The finished deliverable is four files shipped
together: the report, its certification record, the input, and the ledger — five when
the review ran under `--source`, adding the source file. The record's paths are
invocation-relative and must be replayed verbatim. The
ledger format, the review procedure and the optional experimental model pins (a model may
review only when one is explicitly pinned) are in
[`skills/interface-matrix/SKILL.md`](skills/interface-matrix/SKILL.md).

| Exit | Meaning |
|---|---|
| 0 | Report written — or, under `--certify`, certification passed and the record printed. |
| 1 | Bad input row, of the input or of a ledger; a duplicate interface identity; or a `--certify` whose flags do not replay the recorded review. Every error names its line. |
| 2 | The partition invariant tripping while the report renders — and argparse usage errors, which have always shared it and are now documented. |
| 3 | Certification refused: every blocker (a drifted or unreviewed finding) is named in the record. |

## How it works

1. Read the input file: the Components table, the Interfaces table and the optional Rules table; everything else is ignored.
2. Classify each interface row: specified, gap, explicit `none`, missing-component candidate, or superseded.
3. Apply the Rules table, if present, to settle unstated pairs by producer and consumer class.
4. Build the directed graph and partition it into strongly connected components, then a topological order of the condensation.
5. Report the findings: candidates, gaps, boundary checks, feedback loops, partitioned order, unstated pairs, the matrix, the rules audit, and source coverage under `--source`.

The procedure an agent follows, including the mandatory human review and how to resolve
each finding class, is [`skills/interface-matrix/SKILL.md`](skills/interface-matrix/SKILL.md).
Operating it — health checks, every error message and its fix, rollback and escalation —
is [`skills/interface-matrix/references/RUNBOOK.md`](skills/interface-matrix/references/RUNBOOK.md).

## Output format

One Markdown report on stdout.

| Section | Contents |
|---|---|
| 1. Summary | Counts: components, specified interfaces, gaps, explicit none, candidates, unstated pairs, loops, self-dependencies, superseded rows. |
| 2. Missing-component candidates | Rows whose producer or consumer is `?`. |
| 3. Interface gaps | Rows missing flows, format, trigger or owner, and which. |
| 4. Boundary check | Internal components nothing feeds, outputs nothing consumes, isolated components. |
| 5. Feedback loops | Loop blocks and self-dependencies. |
| 6. Partitioned order | Components in dependency order. |
| 7. Unstated pairs | Ordered pairs stated neither way, sampled per `--sample`. |
| 8. Matrix | The N² matrix in partitioned order. |
| 9. Class rules | Per rule: pairs settled and matched, dead rules, unclassed components, residue. Only when a Rules table is present. |
| 10. Source coverage | Uncited spans of the source document. Only under `--source`. |

## Requirements and limits

Python 3.9 or newer. Standard library only — no dependencies, no virtualenv, no install step.
No network access: the script reads the files you name and writes to stdout.

The matrix is N², so the unstated-pair list grows quadratically with the component count;
that is why `--sample` exists. The script never invents a value to close a gap, never breaks
a feedback loop, and does not read your source document unless you pass `--source`. Its
findings are only as good as the inventory you write, which is why SKILL.md makes cell-by-cell
human review mandatory rather than optional.

## Related

- [`macblackstuff/system-adoption-pipeline`](https://github.com/macblackstuff/system-adoption-pipeline) — the seven-pass decomposition pipeline this skill is pass 3 of.
- [Agent Skills specification](https://agentskills.io/specification) — the `SKILL.md` format this repo implements.

## Contributing, security, license

- [`CONTRIBUTING.md`](CONTRIBUTING.md) — how to propose a change.
- [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) — Contributor Covenant 2.1.
- [`SECURITY.md`](SECURITY.md) — supported version and private vulnerability reporting.
- [`LICENSE`](LICENSE) — MIT. Copyright (c) 2026 macblackstuff.
