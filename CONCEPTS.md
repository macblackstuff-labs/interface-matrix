# Concepts

> Shared domain vocabulary for this project — entities, named processes, and status concepts with project-specific meaning. Seeded with core domain vocabulary, then accretes as ce-compound and ce-compound-refresh process learnings; direct edits are fine. Glossary only, not a spec or catch-all.

## Certification

### Review ledger
A Markdown file kept beside the matrix input, written during review, holding one disposition per finding the report derives — keyed by finding identity, not input line, so unrelated input edits do not disturb it. The ledger is the review's substance: certification judges it, never the report alone.

### Disposition
A reviewer's recorded judgment for one finding: resolved (the input was fixed so the finding no longer exists), open-parked (deliberately not filled now, with a reason), or accepted (kept as-is, with a reason). Open-parked gaps and accepted candidates ride in the certification record as advisories — parked, not ignored — so what ships is always visible.

### Reviewer of record
The person or pinned model named in each ledger row as having made the disposition. Must be distinct from whatever drafted the input — separation of duties. Default is an independent human; a model reviewer is legitimate only through an explicit user pin.

### Certification record
The artifact a completed certification run writes beside the ledger, binding the input, report, and (when used) source files by content hash plus the flags the review ran under, and listing every blocker and advisory. Shipped with the report as the proof of review; a report without its record is a draft. The ledger's stamped copy holds the last passing run; the standalone file reflects the latest completed run.

### Drift
The state where the input no longer matches what was reviewed — a finding changed or vanished since its disposition, or the input as a whole changed since the last certified run. Drift is a blocker, never a pass: it re-opens exactly the touched review, so certification can only attest what was actually examined.

### Certification
The gate that re-derives a report from the input and judges the review ledger against it: every finding of the five ledger kinds dispositioned, none drifted, recorded flags replayed exactly. Its outcome is the machine-checkable answer to "was this reviewed" — green means attested, refusal names every blocker as the review worksheet, and bad records or flag mismatches are input errors, not verdicts.
