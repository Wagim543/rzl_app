---
name: RZL Build
description: Load before starting any implementation work, when deciding what to build next, when a feature needs to be added in the right order, or when a milestone is being closed out. Provides the concrete construction backlog, the per-feature build recipe, and the milestone gates for the RZL app.
---

# RZL — Build Order

`rzl-spec` says **what** the system is. This skill says **in what order to build it, and what
"done" means at each step.**

## The per-feature recipe

Every feature is built in this exact sequence. Do not skip steps; do not reorder them. The
order exists because each step depends on the previous one.

| # | Step | Produces |
|---|---|---|
| 1 | **Migration** | `supabase/migrations/<ts>_<name>.sql` — tables, constraints, indexes |
| 2 | **RLS policy** | Same file or the paired `_rls` file. Shape A/B/C/D from `rzl-supabase` |
| 3 | **Seed** (if reference data) | Row in `supabase/seed.sql` |
| 4 | **Domain** | `features/<f>/domain/<entity>.dart` + abstract repository interface |
| 5 | **Data** | `features/<f>/data/<entity>_repository_impl.dart`, `fromJson` mapping |
| 6 | **Provider** | `features/<f>/presentation/providers/*.dart` returning `Future<T>` |
| 7 | **Screen** | `AsyncValue.when` with all four states |
| 8 | **Widgets** | Extracted into `presentation/widgets/` — nothing inline over ~40 lines |
| 9 | **Test** | At least one widget test with a fake repository |
| 10 | **Verify** | `flutter analyze`, `dart format .`, run the `TC-`, update `features.md` status |

Why this order: the schema is the hardest thing to change later, and the screen is the
easiest. Build the expensive decisions first.

## The 7 milestones

Each milestone is one RAD iteration and must end demoable. **Do not start the next milestone
until the current one passes its gate.**

| M | Milestone | Demoable output | Gate |
|---|---|---|---|
| **0** | Foundations | App runs, theme applied, router works | `flutter analyze` clean, both themes render |
| **1** | Guest event browsing | Guest opens app → sees events → filters → opens detail | TC-001, TC-005, TC-012 pass |
| **2** | Auth + engagement | Login → bookmark → RSVP → like → comment → review | TCs 017–043 |
| **3** | Smart discovery | Semantic search, summaries, recommendations | TCs 049–057 |
| **4** | Admin | Create → publish → appears in guest feed; reports | TCs 063–078 |
| **5** | Places and comms | Nearby panel, map handoff, announcements, notifications | TCs 058–062, 073 |
| **6** | Hardening and evaluation | Full regression, all instruments collected | 76/84 TCs, instruments complete |

**Milestone 1 is the one that matters.** Everything before it is setup; everything after it
is repetition of a proven pattern. If the schedule slips, cut Milestone 5 — never 6.

## Rules

1. **One feature at a time, end to end.** Do not build three screens that all depend on a
   schema you have not written.
2. **The app must run after every commit.** A broken `main` for two days costs more than the
   feature gains.
3. **Never start a feature without its `FR-` ID.** If it has no ID, it is not in scope.
4. **Close a milestone by running its gate tests and recording the result.** Not by opinion.
5. **Update `docs/qa/test-cases.md` as you go.** Not at the end.

## Current state

Milestone 1, slice 1: guest event browsing against a real `events` table.

Backlog: `references/backlog.md`. First slice in detail:
`references/vertical-slice.md`.
