---
name: RZL Spec
description: Load when planning any feature, deciding scope, resolving a conflicting requirement, writing Chapters 1-3, or when a request may fall outside the documented scope. Holds the canonical requirements, roles, non-goals, cost model, and architecture decisions for the RZL capstone.
---

# RZL — Product Spec

The source of truth for **what RZL is**. Read this before building anything, and check it
before agreeing to build something new.

## Canonical files

| File | Contents |
|---|---|
| `docs/spec/features.md` | 34 functional requirements, `FR-01` … `FR-34`, with acceptance criteria |
| `docs/spec/roles.md` | 5 roles + the permission matrix |
| `docs/spec/non-goals.md` | 10 hard non-goals, 5 soft, 3 budget-driven |
| `docs/spec/cost-model.md` | ₱147,415 initial / ₱37,100yr recurring, itemised |
| `docs/spec/decisions.md` | Architecture decision log, `AD-01` … `AD-12` |

## Project in one paragraph

RZL is a mobile event coordination and community engagement platform for the Province of
Rizal. Events are currently announced across scattered Facebook pages and barangay
bulletins, so residents cannot find them and organizers cannot promote them. RZL
centralises event discovery. Guests browse without an account; logged-in residents
bookmark, RSVP ("I'm Going"), like, comment, review, export to their device calendar, and
receive notifications. An ML layer provides event summaries, semantic search, and
personalised recommendations. Admins CRUD events, publish announcements, and read
engagement reports. Capstone of 5 BSIT students, URS Binangonan, SY 2026–2027, RAD model,
evaluated via QA testing (90% target), ISO/IEC 25010:2023, and TAM.

## The five roles

`guest` · `resident` · `tourist` · `admin` · `lgu`

Detailed matrix in `docs/spec/roles.md`. Three facts drive most design decisions:

1. **Guests browse without an account.** Never gate the event feed behind auth.
2. **`resident` and `tourist` are one permission tier**, differing only in recommendation
   weighting. Do not build two auth paths.
3. **`admin` and `lgu` are one permission tier**, distinguished only for reporting.

## Workflow when a feature is requested

1. **Is it in `docs/spec/features.md`?** Use the existing `FR-` ID. Do not invent a
   duplicate.
2. **Is it in `docs/spec/non-goals.md`?** Stop. Name the `NG-` ID and the reason. Ask
   whether this is a formal scope change. Do not implement silently.
3. **Is it a new feature?** It needs, in this order:
   - a new `FR-nn` row (never renumber existing ones)
   - a row in the permission matrix if it touches data
   - at least one `TC-` in `docs/qa/test-cases.md`
   - a cost note if it calls a paid API
   - a Chapter 1/3 sentence, because scope and implementation must match the paper
4. **Does it contradict an `AD-` decision?** Raise it. Do not quietly reverse an
   architecture decision; supersede it with a new row.

## Hard constraints to keep in mind

- **90% functionality passing rate** is a gate. A feature with no test case contributes
  nothing to that number and is effectively unbuilt.
- **Budget is ₱37,100/year.** No Google Places at runtime, no per-read LLM calls, no maps
  SDK. See `docs/spec/cost-model.md`.
- **Testing is Binangonan only**, though the design covers all of Rizal. Do not add
  features that only make sense province-wide.
- **No ticket scanning, payments, or attendance verification.** These are stated
  limitations in the paper. Implementing them contradicts Chapter 1.

## Traceability

`FR-` → `TC-` → Chapter 4 result. Every FR you build must be traceable forward to a passing
test case and backward to a stated requirement. When you finish a feature, update
`Status` in `docs/spec/features.md` and the corresponding rows in
`docs/qa/test-cases.md`.

## Anti-patterns

| Don't | Why |
|---|---|
| Add a feature because it is easy | Scope creep is the #1 capstone failure mode |
| Invent a new FR number for an existing requirement | Breaks Chapter 4 traceability |
| Implement a non-goal "just in case" | Contradicts the stated limitations |
| Renumber or delete FR IDs | Chapter 3 and 4 references break |
| Promise a feature without a test case | It cannot count toward the 90% gate |
