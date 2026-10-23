---
name: RZL Defense
description: Load when drafting or revising any chapter of the RZL capstone paper, building the ERD, DFD, or use-case diagrams, mapping work to the RAD methodology, preparing for the panel, or writing Chapter 4 results from QA data. Keeps the paper consistent with the built system.
---

# RZL — Chapters 1-5 and Defense

The paper must **match the built system**. Where they disagree, the panel will find it.

## Rule zero

Never write a claim the repository cannot back. Every number in Chapter 4 traces to a file
in `docs/`. Every scope statement in Chapter 1 traces to an `FR-` or `NG-` ID.

## The five chapters

| Ch | Contents | Source of truth |
|---|---|---|
| 1 | Introduction: background, problem, objectives, significance, scope and limitation | `docs/spec/features.md`, `docs/spec/non-goals.md`, `docs/spec/roles.md` |
| 2 | Review of related literature and systems | citations + competitor table |
| 3 | Methodology: RAD, requirements, system design, ERD/DFD/use case, tech stack | `docs/design/schema.md`, `docs/spec/decisions.md`, `docs/qa/*` |
| 4 | Results and discussion: QA pass rate, ISO 25010, TAM, UAT | `docs/qa/test-cases.md`, `docs/qa/results/` |
| 5 | Conclusion and recommendations | derived from Chapter 4 failures and UAT findings |

## Objectives must be testable

Chapter 1 objectives and Chapter 4 results are read side by side. Write objectives so they
map to measurable outcomes:

| Bad | Good |
|---|---|
| "To develop an event app" | "To develop a Flutter-based mobile application that centralises LGU event announcements for the Province of Rizal" |
| "To test the system" | "To determine the functionality of the system, targeting a 90% passing rate of Quality Assurance Testing" |
| "To evaluate user acceptance" | "To determine the level of acceptance of the system as evaluated by 20 residents and tourists using the Technology Acceptance Model" |

Every objective gets a matching results section. An objective with no Chapter 4 counterpart
is the most common structural defect in capstone papers.

## Diagrams — generate from the schema

- **ERD:** draw from `docs/design/schema.md` §9 only. Entities, PKs, FKs, cardinality.
  Do not draw from memory.
- **DFD:** context diagram (Level 0) then Level 1 with these processes: Account Management,
  Event Management, Event Discovery, Engagement, Announcement, Reporting. Data stores are
  the Supabase tables grouped logically — do not draw 15 stores.
- **Use case:** one actor per role in `docs/spec/roles.md`, and the guest actor must have
  "Browse events" and "View event detail". Omitting the guest actor contradicts FR-01.
- Use one drawing tool for all diagrams (draw.io or Figma). Mixed tools read as rushed.

## RAD mapping

RAD has four phases: Requirements Planning → User Design → Construction → Cutover. The panel
will ask how you actually applied it. The answer is your iteration log, not a paragraph
written at the end. See `references/rad-mapping.md`.

## Chapter 4 discipline

- All four instruments are reported, even if one result is negative.
- Do not compute inferential statistics on n = 20 or n = 5. Descriptive means, SDs, and
  verbal interpretations only.
- Report the exact denominator of the QA matrix.
- A surprisingly perfect 5.00 across every ISO characteristic is a credibility risk;
  report the real numbers.

## The 8 questions you will be asked

Prepare a one-sentence answer each. If any answer starts "we didn't have time to", the scope
should have been smaller.

1. Why did you build this in Flutter?
2. You said RAD — show me the iterations.
3. Why Supabase instead of a custom backend or Firebase?
4. How do you keep the ₱37,100 annual cost from growing?
5. What stops a user from becoming an admin?
6. Show me the app working for a user who has not logged in.
7. How did you achieve 90% functionality? Show the test matrix.
8. What happens when the internet is slow during an event?

Questions 5, 6 and 8 are answered by code (`docs/design/rls-policies.md`, FR-01, FR-33).
Have the app open for the demo, not just the slides.

## Defense-day checklist

- [ ] APK installed on 2+ physical devices, not an emulator
- [ ] Mobile data available as a fallback for venue Wi-Fi
- [ ] Guest-mode demo path rehearsed first
- [ ] One pre-seeded event set, dates in the future at defense time
- [ ] Screenshots of every Chapter 4 table saved locally, in case the laptop fails
- [ ] Test matrix exported to PDF with the run date
- [ ] Every team member can answer the 8 questions, not just the leader

## Writing style

| Do | Don't |
|---|---|
| Past tense for what was built, present for what the system does | Mix tenses within a paragraph |
| Third person, formal academic register | "I built" or "we then tapped the button" |
| Cite every claim from literature | Uncited assertions about social media reach |
| Name the exact version (ISO/IEC 25010:**2023**, Flutter **3.47**) | Vague "latest version" |
| Report ₱ figures and participant counts exactly | Round numbers that contradict each other across chapters |

## Files

- `references/chapter-outline.md` — section-by-section structure with what each needs
- `references/rad-mapping.md` — RAD phases mapped to actual work
