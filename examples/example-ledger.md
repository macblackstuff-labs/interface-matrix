# Example review ledger for interface-matrix

The review ledger for [`example.md`](example.md): one row per finding the report
derives from the input, keyed by identity rather than input line. It was started as
nothing but the header; the first `--certify` run refused with every finding named
`unreviewed:` and its current fingerprint, and the rows below disposition each one —
fingerprints copied from that refusal record, which is the intended move. Run from the
repository root:

    python3 skills/interface-matrix/scripts/interface_matrix.py examples/example.md --certify examples/example-ledger.md

| Kind | Finding | Disposition | Reason | Reviewer | Date | Fingerprint |
|---|---|---|---|---|---|---|
| candidate | ? -> Analyst: weekly digest | accepted | the digest is written by the on-call engineer of the week, a person outside the boundary; no component to declare until the reporting pass names the real producer | J. Merrick | 2026-09-30 | 4e139b0f50474d7629fd7d55b8a86689520d171e5726eba1ff659ea72106ea6c |
| gap | Store -> Scorer: event batches | open-parked | format and trigger wait on the storage RFP, due before work packages are cut; gap register G-12 | J. Merrick | 2026-09-30 | efdae3966ddabbe36042c85f63e7235c49cc231accc8a6638ff20640cdd94a56 |
| boundary | Ingest | accepted | Ingest is the system's source: it reads the external event broker, which is outside the boundary | J. Merrick | 2026-09-30 | 7b2acd46b8fe5961f6e95a9f7a8c2a4d2bb2e847c76fd0b2188585051eafc68c |
| boundary | Scorer | accepted | scored events are read by the Analyst's ad-hoc queries at this stage; the digest interface will name the producer once the reporting pass lands | J. Merrick | 2026-09-30 | b07ad9ad99b47f37ce06a812f6e56d7b2c7cb966d3d130ecb7478c99bcd2418b |
| pair | Ingest -> Scorer | none | Scorer reads event batches from Store, never straight from Ingest | J. Merrick | 2026-09-30 | 6e54deada7063a257816a5093992b19828fd166f36db2f46fffc8bfc36129e10 |
| pair | Ingest -> Analyst | none | raw event rows never reach a human; the Analyst reads digests only | J. Merrick | 2026-09-30 | c37b55540d54122e0418eb7b66ce96402ae435efe482050e68c4a50dddcc0fca |
| pair | Store -> Ingest | none | the event store is write-only for Ingest; no read-back | J. Merrick | 2026-09-30 | 12b6a29a7004ff74da31cac8a1f73f48a4cddd4fbb0c720e72e654a98af04b02 |
| pair | Store -> Analyst | none | the Analyst reads the weekly digest, not the store directly | J. Merrick | 2026-09-30 | 949e4b23e7aa2c743995eb22b42f20691bd7919c57c567d0a2a4c6ebf7e32cae |
| pair | Scorer -> Ingest | none | scoring is downstream of ingest; nothing flows back | J. Merrick | 2026-09-30 | 20e66c9839d4f06130b5a4661c48289ffea19dc00c009b22f6235fc64143564c |
| pair | Scorer -> Store | none | scores are consumed by the Analyst's ad-hoc queries; nothing writes back to the store at this stage | J. Merrick | 2026-09-30 | 848530bc07bfa9cde490f6f6aeba4c506f3b026bea67f8c108829edfe810b686 |
| pair | Scorer -> Analyst | none | the digest is not produced by Scorer; its producer is the unresolved candidate above | J. Merrick | 2026-09-30 | e380fb91cf05a80a6b9d098c719976233f5f57e4d0504c47e9668132bbb8f661 |
| pair | Analyst -> Ingest | none | the Analyst is a read-only consumer; nothing flows into the pipeline | J. Merrick | 2026-09-30 | f1d6bd6de416fb04f3017c8d52d986f397b67d682888a9ee75a7761ca7888688 |
| pair | Analyst -> Store | none | read-only consumer, and external to the boundary | J. Merrick | 2026-09-30 | 0c3cc0de7a486c81adf21e5cf695d515b13be8386e6e75ee4458f4cfff02066f |
| pair | Analyst -> Scorer | none | read-only consumer, and external to the boundary | J. Merrick | 2026-09-30 | 13211bf01419e89a0a02da395a37ab66080baf52eee38caaffa4f127f4ef96fd |

## Certification record

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
