# Runbook — interface-matrix

## Overview

An on-demand command-line report generator, not a service: no daemon, no port, no state. Four files —
`SKILL.md` (the procedure an agent follows), `scripts/interface_matrix.py` (the report generator),
`scripts/test_interface_matrix.py` (its self-check) and this runbook. Python 3.9 or newer, standard library only: no
virtualenv, no install step, no dependency to keep current. All commands below are run from this
skill's own directory.

## Health checks

```bash
python3 scripts/test_interface_matrix.py
```
Expected: `Ran 125 tests ... OK`, exit 0. Also run it under `python3 -O` — the partition
check must survive assertions being stripped.

```bash
grep -E '^(import|from) ' scripts/interface_matrix.py
```
Expected: only `argparse`, `difflib`, `graphlib`, `hashlib`, `json`, `re`, `sys`. Any third-party import is a defect — the skill must stay dependency-free.

## Procedures

1. **Run a matrix.** Write the input file (two Markdown tables — see `SKILL.md` §1), then:
   ```bash
   python3 scripts/interface_matrix.py INPUT.md > OUTPUT.md
   ```
   Exit 0 = report written. Exit 1 = a bad input row; the message names the input line.

2. **Review every unstated pair, not just the sample.** The default prints 20:
   ```bash
   python3 scripts/interface_matrix.py INPUT.md --sample 0
   ```
   `--sample N` prints N; `--sample 0` prints all. A sample is drawn deterministically: round-robin across the producer rows that have unstated pairs, spread evenly along each row so the picks sweep across columns rather than exhausting the first row. On a 50-component system that is ~2,500 lines, which is the point: the sparse form hides false negatives.

3. **Settle unstated pairs at class level.** Give components a `Class` cell and add a Rules table (`Producer class | Consumer class | Disposition | Reason`, disposition `none` or `review`, `*` = any classed component; a component with a blank `Class` matches no rule, and section 9 names every unclassed component). A `none` rule takes every pair of those classes out of section 7; `review` wins where both match; an explicit interface or `none` row always beats a rule. What section 9 then reports per rule — settled pairs, matched pairs, dead rules, contradictions, the residue — is defined in SKILL.md §1; read it there before trusting the audit. Review the rules as carefully as the pairs they replace — one wrong rule silences hundreds of pairs.

4. **Check what the source says and the inventory does not.**
   ```bash
   python3 scripts/interface_matrix.py INPUT.md --source TRANSCRIPT.txt
   ```
   A citation is any `L<n>`, `L<a>-<b>` or `L7,11-12` in a cell of an active Components or Interfaces row. Not citations, but still range-checked: a Rules row's `Reason`, and any citation on a superseded row. Section 10 prints the source lines nothing cites as contiguous spans (blank lines ignored), the first 80 characters of each span, and the line/cited/uncited counts. Read every span: that is where an unmodelled component or interface hides. A reversed range such as `L9-7` exits 1 while parsing, with or without `--source`; a citation past the file's last line and `L0` are only detectable against a source file, so they exit 1 only under `--source`.

5. **Certify a reviewed matrix.** Review writes a ledger beside the input — one table,
   `Kind | Finding | Disposition | Reason | Reviewer | Date | Fingerprint`, started as
   nothing but the header. Certify once — with `--source` when the input cites one (the
   gate refuses a citing input certified without it) and under the `--sample` the review
   used:
   ```bash
   python3 scripts/interface_matrix.py INPUT.md --certify INPUT.ledger.md
   ```
   Exit 3: every finding of the five ledger kinds comes back an `unreviewed:` blocker
   carrying its current fingerprint — the refusal record doubles as the review worksheet.
   Disposition every finding it names, copying the fingerprints from the record's blocker
   lines, then certify again: exit 0, a `certified` record, and the record also stamped
   into the ledger as its `## Certification record` section. A completed run (pass or
   refusal) writes the record beside the ledger; an error (exit 1) writes nothing and
   leaves the previous record in place. The section stamped inside the ledger is the
   last passing run and the replay anchor — flags and input/source sha256 — while the
   standalone record reflects the latest completed run; editing the input or source
   after a pass re-opens the whole review. The finished deliverable is four files —
   report, certification record, input, ledger — five under `--source`, whose paths the
   record names as the run typed them (SKILL.md §3/§5).

6. **Change the script.** Add or change a test in `scripts/test_interface_matrix.py` first and
   watch it fail, then change `scripts/interface_matrix.py`, then rerun the health check. Keep the
   script standard-library only and Python 3.9-compatible. The `system-adoption-pipeline` skill
   vendors a byte-identical copy of this script and pins its sha256, so a change here is not live
   for the pipeline until that copy and its pinned sha256 are updated there too.


## Incident playbooks

| Symptom | Diagnosis | Fix |
|---|---|---|
| `error: unknown producer 'X' at line N` | The interface row names a component the Components table does not declare — usually a typo or an id renamed in only one table. | Fix the name at that input line, or declare the component. The script refuses to invent a node, by design. |
| `error: duplicate component 'X' at line N` | Two **active** rows share the name `X`; the message also gives the first active row's line. Superseded rows are never counted, so a retired name may be re-declared. | Supersede one of the two rows (`Status` = `superseded <date>: <reason>`), or rename one. Only one active row per name. |
| `error: no Components table found (expected columns: component, kind, notes)` | No table header shared two or more names with the Components column set. Tables are a header row plus a `\|---\|` separator, located by their header names, case-insensitively and in any column order. | Add the Components table, or restore its headers. Names, not column positions, are what the parser keys on. |
| `error: no Interfaces table found (expected columns: producer, consumer, flows, format, trigger, owner)` | Same, for the Interfaces table — including a header-only Interfaces table that was deleted. | Add the Interfaces table with those headers. A header-only table (no rows) is valid. |
| `error: table at line N is missing column(s): ...` | A header sharing two or more names with either column set was recognised as that table, but a required column is absent — typically a renamed header (`From` for `Producer`, `Name` for `Component`). The message names every missing column and the header's line. | Rename the columns back on that header row. Order does not matter; a table sharing fewer than two names is ignored instead — with a warning if the names are near-misses (next row). |
| `warning: line N: table header misspells a Components, Interfaces or Rules column set; the whole table was ignored` (exit unchanged) | The header shared fewer than two exact names with any column set, so the table and all of its rows were skipped, but two or more of its cells are near-miss spellings of one set's required names (`Componnt`, `Kindd`). Without this warning the rows would vanish from the report unremarked. The exact-name count decides which of the two diagnostics a misspelling gets, not how bad the misspelling is: `\| Componnt \| Kindd \| Nots \|` shares no exact name, so it warns and exits 0, while `\| COMPONNT \| Kind \| Notes \|` still shares two, so it is the missing-column error above and exits 1. | Fix the spelling of the named line's columns. A genuinely foreign table (`\| Disposition \| Reason \|`, `\| Fruit \| Colour \|`) is skipped silently and needs nothing. If this was the file's only Components or Interfaces table you also get the `no ... table found` error above. |
| `warning: line N: table row outside any table ignored` (exit unchanged) | A line starting with `\|` belongs to no table — usually a blank line left inside a table, which ends it and orphans the rows below. | Delete the blank line so the rows rejoin the table, or delete the orphan rows. The report is produced without them. |
| `error: superseded component 'X' named as producer at line N (retired at line M)` | An interface row that is itself still active names a component whose every row has a `Status` starting `superseded` (no active row of that name; `M` is the last retirement line). Retiring a component does not retire the rows that use it. | Supersede that interface row too (set its `Status`), or repoint it at the replacement component. |
| `error: second Interfaces table at line N (first at line M)` (same for Components) | Two tables of the same kind in one file — usually an addendum appended as a fresh table, whose rows the parser would otherwise merge silently. | Move the new rows into the first table, below its existing rows. One table of each kind per file. |
| `error: rule at line N: unknown disposition 'maybe' (expected none or review)` | A Rules row's `Disposition` is neither `none` nor `review`. Matching is case-insensitive; anything else is rejected rather than guessed. | Write `none` (there is deliberately no interface for those classes) or `review` (still review each pair). |
| `error: rule at line N names producer class 'X' that no component has` | A Rules row names a class no **active** component carries — a typo, or a class removed from the Components table. Classes are compared exactly, so case matters. | Fix the class token in the rule or on the components, or delete the now-meaningless rule. |
| Section 9 says `dead rules (no unstated pair matched): line N` | That rule matched nothing: the classes never co-occur as an unstated pair, or explicit rows already settle every such pair. | Delete the rule, or fix its classes. A dead rule is a claim nobody can check. |
| Section 9 lists a `none` rule under "match an explicit interface" | A rule says those classes never talk, while an Interfaces row says they do. The explicit row wins; the rule is reported so it gets reviewed. | Narrow the rule's classes, or supersede the interface row if the rule is right. |
| Sections 9 and 10 are absent from the report | Section 9 is printed only when the file has a Rules table, section 10 only with `--source`. Reports without either are byte-identical to earlier runs. | Add the Rules table, or pass `--source FILE`. |
| `error: citation L99 at input line N is beyond FILE (283 lines)` (exit 1) | A cell cites a source line past the end of the `--source` file — usually the wrong file, or citations copied from a re-numbered transcript. | Point `--source` at the file the citations were written against, or fix the citation at that input line. |
| `error: citation L0 at input line N: source line numbers start at 1` (exit 1) | A cell cites `L0`; source lines are numbered from 1. Raised under `--source` only. | Fix the citation at that input line. |
| `error: reversed citation range L9-7 at line N` (exit 1) | A cell's range runs backwards, so it would silently cite nothing. Raised while parsing, with or without `--source`. | Write the range low-to-high (`L7-9`) at that input line. |
| A `| Disposition | Reason |` table in the file is ignored | Only a header naming both `Producer class` and `Consumer class` is read as the Rules table; other tables are skipped as someone else's. | If it was meant to be the Rules table, give it the two class columns. |
| `error: argument --sample: must be 0 or more, not -1` (exit 2, argparse) | A negative `--sample`. | Pass `0` for all unstated pairs, or a positive count. |
| Report shows `superseded rows: N` but a retired row still appears in the findings | The `Status` cell does not start with the word `superseded` — a leading date or `retired` is not recognised. | Write `superseded <date>: <reason>`; anything may follow, but the first word must be `superseded`. Matching is case-insensitive. |
| `error: empty component name at line N` | A Components row has a blank name cell — usually a stray `\|` or a half-deleted row. | Name the component or delete the row. |
| `error: below-diagonal mark outside a loop block: partition is wrong` (exit 2) | The partition is wrong: a mark landed below the diagonal outside a feedback-loop block. This is a script defect, not an input defect, and the check runs under `python3 -O` too. | Do not edit the input to silence it. Capture the input file, open an issue, and treat the emitted order as untrusted until the SCC/topological step is fixed. |
| A cell splits into two, or a row is short | A literal pipe inside a cell was not escaped. A backslash escapes the next character and is dropped: `\|` is a literal pipe in the cell value (re-escaped in the report), and `\\` is a literal backslash that leaves the next `\|` a delimiter, so a cell ending in a Windows path needs `C:\\\| next`. Short rows are padded to the header width. | Escape literal pipes as `\|`, and double a trailing backslash. |
| Report looks right but the matrix is mostly empty | Only a handful of pairs were declared; everything else is an unstated pair, not a "no". | This is a finding, not a fault. Declare `none` on the pairs that genuinely have no interface, and add the real interfaces. |
| Everything lands in one giant feedback loop | Legitimate output for a densely coupled system. | Nothing to fix in the tool. A human decides what to assume to break the loop; the script deliberately does not tear. |
| `error: certification refused: N blocker(s) (... unreviewed)` (exit 3) | Findings the report derives from the input that no ledger row covers — a header-only ledger's first run, or a review not finished. | Open `<ledger>.cert.md`: every blocker is named by identity, with the fingerprint to paste. Disposition each finding in the ledger, or fix the input so the finding leaves the report, and rerun. |
| `drifted:` blockers (exit 3) | The input moved under the review: the finding is gone from the input (`no longer matches any ... finding`), or its content changed since disposition (the record names the current fingerprint). | A finding fixed in the input leaves the report, and its ledger row must go too (SKILL.md §3). A finding still present but edited needs its row re-reviewed — new fingerprint, new date; input rows are superseded, never reworded (§5). |
| `drifted: input changed since the last certified run` (exit 3; same shape for `source`) | The ledger's stamped record section binds the sha256 of the input (or source file) of the last passing run, and the current file hashes differently — any edit re-opens the whole review, stated and explicit-`none` rows included, because those rows are never fingerprinted per-finding. | Re-review: the per-finding `drifted:` lines in the same record name what else moved; fix those, delete the stale `## Certification record` section, and certify again — a pass re-stamps a fresh anchor. |
| `error: the input cites N source line(s) ...; certify with --source FILE so the uncited spans are reviewed` (exit 1) | The input cites `L<n>` source lines but `--certify` ran without `--source`: the first run is the only window in which span review can be skipped, and a pass would pin the hole into the record's flags. | Re-run with `--source FILE`, the file the citations were written against. |
| `error: ledger line N: a disposition row cannot live inside a certification record` (exit 1) | A disposition table or row was placed after the `## Certification record` heading, where the record-section scan would silently swallow it. | Move those rows into the ledger's disposition table, above the record section. |
| `error: component name 'A -> B' at line N: component names cannot contain ' -> ' or ': ' under certification` (exit 1) | The ledger's `Finding` identities are parsed out of those delimiters; a component name containing one cannot be pasted into a cell and parsed back — every retry would add false `drifted:` blockers. | Rename the component in the input and re-run. Generation is unaffected; only certification refuses the name. |
| `error: the ledger's certification record declares --sample N but certification was invoked with --sample M` (exit 1; same wording for `--source`) | The record's flags pin the review, and `--certify` must replay them exactly — a run without `--source` cannot silently skip the span checks. | Rerun with the declared flags; the message names the flag and both values. To re-review under other flags, amend the ledger's certification-record section first, as the message says. |
| `error: input rows at lines N and M share one interface identity (P -> C: flows); the review ledger cannot tell them apart` (exit 1, under `--certify`) | Two active interface rows share one `producer -> consumer: flows` — the identity the ledger keys on. | Distinguish the flows, or supersede or merge one of the rows, then certify again. |
| `error: ledger row at line N ...` (exit 1) | A bad ledger row: wrong width, an unknown kind, a missing required cell, a duplicate identity — or a second disposition table in one ledger. | Fix the named row. The format — `Kind \| Finding \| Disposition \| Reason \| Reviewer \| Date \| Fingerprint`, kinds `candidate gap boundary pair span` — is SKILL.md §2. |

## Rollback and recovery

The skill holds no state and writes nothing outside the report you redirect to stdout —
under `--certify`, also the record beside the ledger and the record section stamped into
the ledger itself — so rollback is a
file revert in whatever repository carries the skill folder. A generated report is disposable: rerun the
script against the input file. The input file is the artefact worth keeping, and a reviewed matrix is
amended by a dated addendum rather than rewritten.

## Escalation

1. Bad input (exit 1): the author of the input file fixes it. No escalation. A bad ledger
   row or a duplicate identity is the same class — the ledger's author fixes it.
2. Script defect (exit 2, crash on valid input, wrong partition): open an issue with the input file
   attached, and fix it on a branch with a failing test first.
3. Certification refused (exit 3): not a fault — a review not finished. The reviewer of
   record dispositions or resolves every blocker the record names; the matrix is not done
   until `--certify` exits 0.
4. Method disputes — whether a loop is real, whether an unstated pair is truly `none`, which assumption
   breaks a coupled block — are human decisions and belong to the matrix's reviewer, not to the tool. An
   LLM-generated DSM reproduced only 357/462 entries of a published matrix
   ([arXiv 2312.04134](https://arxiv.org/abs/2312.04134)); review is the control, and it runs
   under separation of duties — the reviewer of record must be someone other than whatever
   drafted the input, with a model in that role only when the user explicitly pinned one
   ("Model pins", SKILL.md).
