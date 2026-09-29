# Interface matrix report

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

## 4. Boundary check

External components are exempt.

- nothing feeds (internal): Ingest
- output nothing consumes (internal): Scorer
- isolated (internal): none

## 5. Feedback loops

No feedback loops.

Self-dependencies: none

## 6. Partitioned order

1. Ingest
2. Analyst
3. Store
4. Scorer

## 7. Unstated pairs

showing 10 of 10 (neither an interface nor `none`; external-to-external excluded)

- Ingest -> Scorer
- Ingest -> Analyst
- Store -> Ingest
- Store -> Analyst
- Scorer -> Ingest
- Scorer -> Store
- Scorer -> Analyst
- Analyst -> Ingest
- Analyst -> Store
- Analyst -> Scorer

## 8. Matrix

Row feeds column. Legend: `X` specified, `g` gap, `-` none, blank unstated, `S` self.

```
           1  2  3  4  
  1 Ingest  .     X    
  2 Analyst    .       
  3 Store         .  g 
  4 Scorer           . 
```

below-diagonal check: every below-diagonal mark lies inside a loop block.
