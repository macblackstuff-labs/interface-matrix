# Interface matrix certification

- input: examples/example.md (sha256 52ec2692280ee34a4c87124e7fe7117a1dbecb87b63dbf83562664b1daebd1a2)
- ledger: examples/example-ledger.md
- gate: certified
- report: sha256 1480d1f3872a8d603afa6ceaf17d868d4c225fe7a477dbd250b8312270cf224a
- flags: --sample 20
- blockers: none
- advisories: 4
  - candidate ? -> Analyst: weekly digest (input line 23): accepted — the digest is written by the on-call engineer of the week, a person outside the boundary; no component to declare until the reporting pass names the real producer
  - gap Store -> Scorer: event batches (input line 22, missing Format, Trigger): open-parked — format and trigger wait on the storage RFP, due before work packages are cut; gap register G-12
  - boundary Ingest (nothing feeds it): accepted — Ingest is the system's source: it reads the external event broker, which is outside the boundary
  - boundary Scorer (nothing consumes its output): accepted — scored events are read by the Analyst's ad-hoc queries at this stage; the digest interface will name the producer once the reporting pass lands
