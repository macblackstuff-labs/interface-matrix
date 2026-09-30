# Interface matrix certification

- input: ../../examples/example.md (sha256 d74e7e9eb77f183e25e1e80aef3d6c30eda65e5d01e648d20b67f491155a553b)
- ledger: ../../examples/example-ledger.md
- gate: certified
- report: sha256 1480d1f3872a8d603afa6ceaf17d868d4c225fe7a477dbd250b8312270cf224a
- flags: --sample 20
- blockers: none
- advisories: 1
  - gap Store -> Scorer: event batches (input line 22, missing Format, Trigger): open-parked — format and trigger wait on the storage RFP, due before work packages are cut; gap register G-12
