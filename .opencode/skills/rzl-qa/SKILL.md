---
name: RZL QA
description: Load when a feature is implemented and needs verification, when marking work done, when updating the test matrix, or when preparing QA results, ISO/IEC 25010, TAM, or UAT materials for Chapter 4. Enforces the 90 percent functionality gate and evidence collection.
---

# RZL — QA and the 90% Gate

**90% is a hard gate.** It is the number your panel checks, and it is computed from

```
pass rate = passed test cases ÷ total test cases × 100
required passes = ceil(total × 0.90)
```

Current matrix: [`docs/qa/test-cases.md`](../../../docs/qa/test-cases.md) — 84 cases,
so **76 must pass**.

## Instruments

| Instrument | Respondents | File |
|---|---|---|
| QA functionality | the team | `docs/qa/test-cases.md` |
| ISO/IEC 25010:2023 | 5 IT professionals | `docs/qa/iso-25010.md` |
| TAM | 20 residents + tourists | `docs/qa/tam-instrument.md` |
| UAT | 5 LGU personnel | `docs/qa/uat-script.md` |

Total participants across the three human instruments: **30**. Binangonan only. State this
consistently in Chapters 3, 4 and 5.

## When a feature is done

Do not say "done" until all five are true:

1. `flutter analyze` is clean
2. The `FR-` is implemented per its acceptance criteria in `docs/spec/features.md`
3. Every matching `TC-` row in `docs/qa/test-cases.md` has been **executed**, not reasoned about
4. Evidence exists (screenshot, screen recording, or a DB query result)
5. `Status` in `features.md` is updated to `done`

A test case marked ✅ without evidence is a liability. When a panel asks "show me", you
either have it or you do not.

## How to run a test case

For each `TC-`:

1. Set up the **precondition** exactly (role, data state, network state). Half of all false
   passes come from the wrong precondition — e.g. testing as admin and calling it a guest
   test.
2. Perform the steps literally. Do not "know" the result.
3. Compare against the expected result. Binary: pass or fail.
4. Capture evidence. Filename: `docs/qa/evidence/TC-014_im-going.png`.
5. Record `Status` and, on failure, add it to `results/run-NN.md`.

## Required test passes

| Pass | When | Scope |
|---|---|---|
| Smoke | after each merge to `main` | TC-001, TC-012, TC-023, TC-079 |
| Feature | when a feature is implemented | all TCs for that FR |
| Regression | weekly | all High-priority TCs |
| Pre-defense | 2 weeks out | all 84, frozen matrix |
| Re-test | after each fix | previously failed TCs only |

The smoke pass exists because four obvious things break constantly: guest feed, event
detail, logout-to-guest, and offline handling. Run those four after every merge — it takes
three minutes.

## Security-specific tests

These four carry the most weight with IT-professional respondents and they are cheap:

| TC | What it proves |
|---|---|
| TC-027 | A user cannot escalate their own `profiles.role` to admin |
| TC-077 | A `resident` cannot reach admin functions via router or RLS |
| TC-078 | A guest cannot insert an event via the API |
| TC-060 | No runtime Places API calls (budget discipline) |

Run TC-027/077/078 with a **direct REST call**, not through the app UI. The UI is not the
security boundary; RLS is. Use the anon key with `curl` or the Supabase REST endpoint.

## Recording results

Copy `docs/qa/results/run-template.md` to `run-01.md` for each session. Never overwrite a
previous run — the series of runs is itself evidence of iterative testing, which is exactly
what RAD implies.

Compute the rate with:

```powershell
pwsh .opencode/skills/rzl-qa/scripts/pass-rate.ps1
```

## Freezing the matrix

Freeze the total **one week before the defense**. Rationale, in panel terms:

- Adding test cases after collecting results is indefensible — it looks like the denominator
  was managed rather than the quality.
- Deleting hard test cases to raise the percentage is worse; it is visible in git history.
- Freezing early and reporting 76/84 honestly is a strong position. A 100% result invites
  suspicion; 90.5% looks like real testing.

## Honest-failure protocol

When a TC fails and cannot be fixed in time:

1. Set `❌` and record the reason in the run file.
2. Decide: `fix` · `declare as limitation` · `out of scope`.
3. If declared, add a line to Chapter 5's recommendations and to
   `docs/spec/non-goals.md` with a new `NG-` ID.
4. Re-run once after any fix.

Hiding a failure costs more than the failure. Panels test the app themselves.

## Chapter 4 mapping

| Section | Source |
|---|---|
| QA results table | `docs/qa/test-cases.md` totals + `results/run-NN.md` |
| Pass rate discussion | this file |
| ISO 25010 tables | `docs/qa/iso-25010.md` |
| TAM tables | `docs/qa/tam-instrument.md` |
| UAT narrative | `docs/qa/uat-script.md` |
| Screenshots | `docs/qa/evidence/` |

Every number in Chapter 4 must be reproducible from a file in `docs/qa/`. If a panel asks
"where did 4.35 come from", the answer is a response sheet, not memory.
