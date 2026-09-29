# Example inventory for interface-matrix

The input from the README's Example section, as a real file. Run from
`skills/interface-matrix`:

    python3 scripts/interface_matrix.py ../../examples/example.md

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
| Ingest | Store | raw event rows | ndjson file | nightly cron | platform | S:L42 |  |
| Store | Scorer | event batches | ? | ? | platform | S:L44 |  |
| ? | Analyst | weekly digest | ? | ? | ? |  |  |
