# RZL — RAD Mapping

The paper states RAD as the methodology, so the panel will ask for evidence. RAD has four
phases; each iteration runs all four. The **iteration log** is the evidence.

## The four phases

| Phase | Question it answers | RZL activity |
|---|---|---|
| Requirements Planning | What and why? | Stakeholder interviews with 5 LGU personnel, document review, FR prioritisation |
| User Design | How will it work for the user? | Figma prototypes, walkthroughs with LGU staff, revision of screens |
| Construction | Build it | Flutter + Supabase implementation, iterative testing |
| Cutover | Prove it works | QA pass, ISO 25010, TAM, UAT, deployment |

## Planned iterations

Populate the "Actual dates" column as you go. Leaving it blank until the defense is the
single biggest RAD gap in capstone papers.

| Iter | Theme | Requirements | User Design | Construction | Cutover | Actual dates |
|---|---|---|---|---|---|---|
| **1** | Foundation | FR roles, guest browsing, auth | Wireframes: feed, detail, login | Project scaffold, theme, router, Supabase, auth, **event feed + detail (guest)** | Smoke TCs: TC-001, TC-012, TC-023 | |
| **2** | Engagement | FR-13 … FR-20 | Bookmark/RSVP/comment/review flows | Bookmarks, "I'm Going", likes, comments, reviews, calendar export, dark mode | Feature TCs 028–048 | |
| **3** | Smart discovery | FR-21 … FR-23 | Search and recommendation surfaces | Summaries on publish, pgvector semantic search, recommendations with cold start | TCs 049–057 | |
| **4** | Places and comms | FR-08, FR-19, FR-24, FR-25 | Nearby panel, notifications list | Seeded places, radius filter, maps handoff, announcements, notifications | TCs 058–062, 073 | |
| **5** | Administration | FR-26 … FR-32 | Admin dashboard, event editor, reports | CRUD, image upload, announcements, engagement reports, moderation | TCs 063–078 | |
| **6** | Hardening and evaluation | FR-33, FR-34, all instruments | Empty/error states | Offline handling, full regression | All 84 TCs, ISO 25010, TAM, UAT | |

> Iteration 1 is the one to defend hardest. Guest event browsing end-to-end — a guest opens
> the app, sees real events from Supabase, opens one, and reads it without logging in — is
> the minimum demonstrable product. Everything else is additive.

## What each phase actually produced

Fill this table with real artefacts. This is what makes the RAD claim credible.

| Iter | Requirements artefact | Design artefact | Construction artefact | Cutover artefact |
|---|---|---|---|---|
| 1 | Interview notes, FR-01…FR-12 signed off | Figma frames, walkthrough notes | `chore/phase-1-scaffold` branch, commit range | Smoke run 01 |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |
| 6 | | | | |

Artefact suggestions: interview transcripts, Figma link + revision notes, PR links, test run
files in `docs/qa/results/`, deployment screenshot.

## Why RAD is defensible here

| RAD principle | RZL evidence |
|---|---|
| Short iterations | 6 iterations mapped to feature groups |
| User involvement throughout | 5 LGU personnel in interviews, walkthroughs, and UAT |
| Reusable components | Shared `EventCard`, `EmptyState`, `ErrorView`; shared repository pattern |
| Prototyping before building | Figma prototypes reviewed before construction |
| Working software over documentation | Each iteration ends demoable |

Cite the RAD source your adviser expects (Martin, 1991 / Pressman) and keep the citation
consistent between Chapter 2 and Chapter 3.

## Common panel challenge

> "This looks like waterfall with extra steps."

Answer with the iteration log: each iteration ended with a working increment, each had a
user walkthrough that changed the design, and the UAT findings in iteration 6 caused
specific changes. **Show the diff.** A design change traceable to a UAT finding is the
strongest possible RAD evidence.

Have one ready before the defense. Example format:

> In UAT iteration 6, participants P2 and P4 could not distinguish "Bookmark" from "I'm
> Going". We replaced the bookmark icon with a labelled button and added a one-line
> explanation. TC-028 and TC-033 were re-run and passed.

## Timeline reality check

| Iter | Realistic duration (5 devs, part-time) |
|---|---|
| 1 Foundation | 2–3 weeks |
| 2 Engagement | 2–3 weeks |
| 3 Smart discovery | 2–4 weeks |
| 4 Places and comms | 1–2 weeks |
| 5 Administration | 2–3 weeks |
| 6 Hardening and evaluation | 3–4 weeks |

That is roughly 12–19 working weeks. If the remaining calendar is shorter, cut iteration 4
(FR-24/FR-25 are the lowest-value must/should-s) and keep iteration 6 intact. **Never**
shorten iteration 6 — it contains the 90% gate and all three instruments.
