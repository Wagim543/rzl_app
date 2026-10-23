# RZL — Chapter Outline

Section-by-section structure. Each entry lists what it must contain and where the evidence
lives. Adapt numbering to your adviser's format; keep the substance.

---

## Chapter 1 — The Problem and Its Background

### 1.1 Introduction
The scattered-announcement problem. Events in Rizal's municipalities and barangays are
posted to unrelated Facebook pages, group chats, and physical bulletin boards. A resident
must follow several pages to learn what is happening in their own barangay.

Key paragraph to get right: the **gap** is not "no event app exists" but "no single
authoritative channel exists per LGU, so both residents and organizers lose". That framing
justifies a centralised platform rather than another page to follow.

### 1.2 Statement of the Problem
General problem, then 3–5 specific problems. Each specific problem must map to a feature:

| Specific problem | Answered by |
|---|---|
| Residents cannot find events near them | FR-01 … FR-06 |
| Organizers cannot measure reach | FR-31 |
| Announcements expire with the Facebook feed | FR-08, FR-30 |
| Event details are hard to read on mobile | FR-06, FR-21 |
| Residents cannot express intent to attend | FR-15 |

### 1.3 Objectives
General objective + specific objectives. Use the testable phrasing in the skill
(`rzl-defense/SKILL.md` → "Objectives must be testable"). Each specific objective needs a
Chapter 4 counterpart.

### 1.4 Significance of the Study
Beneficiary → benefit, one paragraph each:
residents and tourists · LGU event organizers · barangay officials · the researchers ·
future researchers.

### 1.5 Scope and Limitations
- **Scope:** guest browsing, engagement features, ML discovery, admin CRUD, reporting.
  Name the test site: **Binangonan**, while the design covers all of Rizal.
- **Limitations:** copy from `docs/spec/non-goals.md` — no ticket scanning, no payments,
  no attendance verification, native calendar export only, listing accuracy depends on
  admin input, testing in Binangonan only.

Do not soften a limitation. Stated limitations are safe; discovered ones are not.

### 1.6 Definition of Terms
Operational definitions only, as used *in this study*: event, barangay, LGU, semantic
search, engagement, RSVP, etc.

---

## Chapter 2 — Review of Related Literature and Systems

### 2.1 Related literature
- Event discovery and community information behaviour
- Digital governance and LGU communication channels
- Semantic search and recommendation systems
- Technology acceptance in public-sector mobile services
- SDG 11 and SDG 16 alignment

### 2.2 Related systems
A comparison table is worth more than prose. Columns: system, platform, event discovery,
guest access, LGU-specific, engagement, reporting.

Candidates: Facebook Events, Google Calendar, Eventbrite, LGU Facebook pages, municipal
websites.

### 2.3 Synthesis
State explicitly what none of them do: no Rizal-specific municipality/barangay taxonomy, no
LGU-operated admin workflow, no engagement reporting for organisers. **This synthesis is
what justifies the project's existence** — without it, Chapter 1's gap is unsupported.

Cite consistently (APA 7th unless your adviser says otherwise). Every claim in 2.1 needs a
citation.

---

## Chapter 3 — Methodology

### 3.1 Research design
Descriptive-developmental, using RAD.

### 3.2 RAD phases
Four phases with what happened in each. See `references/rad-mapping.md`. Include the actual
iteration count.

### 3.3 Requirements analysis
- Functional requirements: the `FR-` table from `docs/spec/features.md`
- Non-functional requirements: performance, security, usability, compatibility — align with
  the ISO 25010 characteristics you evaluate in Chapter 4
- Roles and permissions: `docs/spec/roles.md`

### 3.4 System architecture
Three-tier: Flutter client → Supabase (Auth/PostgREST/Storage/Realtime/Edge Functions) →
Postgres with pgvector. One diagram. Explain why a managed backend suits a 5-person team.

### 3.5 Database design
ERD from `docs/design/schema.md` §9. Then a data dictionary: table, column, type,
constraint, description. Include the `user_role` and `event_status` enums.

### 3.6 Functional design
- Context diagram (DFD Level 0)
- DFD Level 1: Account Management, Event Management, Event Discovery, Engagement,
  Announcement, Reporting
- Use case diagram + at least 5 use case descriptions (one per actor, guest included)
- Screen mockups from Figma

### 3.7 Security design
RLS model from `docs/design/rls-policies.md`. Explain guest read vs. authenticated write vs.
staff write. This section earns credibility with the IT-professional respondents.

### 3.8 Development tools
Flutter 3.47.5 / Dart 3.13.4, Supabase, Figma, VS Code / Android Studio, Git/GitHub.
Versions matter.

### 3.9 Evaluation instruments
- QA test matrix (84 cases, 90% target)
- ISO/IEC 25010:2023, 5 IT professionals
- TAM, 20 residents and tourists
- UAT, 5 LGU personnel
Total 30 participants. State the sampling method (purposive) and the locale (Binangonan).

### 3.10 Data gathering procedure
Step by step: permission letter → LGU coordination → development → QA → expert evaluation →
TAM → UAT → analysis. Mention consent and anonymity.

### 3.11 Statistical treatment
Weighted mean, frequency, percentage, standard deviation. State the interpretation bands
from `docs/qa/iso-25010.md`. **No inferential statistics** — say why (descriptive design,
small n).

---

## Chapter 4 — Results and Discussion

Order: functionality first (it gates everything), then quality, then acceptance.

### 4.1 QA results
Totals table + pass rate + the failure list with resolutions. State the denominator.

### 4.2 ISO/IEC 25010:2023 results
Respondent profile, then one table per characteristic with mean, SD, verbal interpretation.
Then the consolidated table and overall mean.

### 4.3 TAM results
Demographics, then PU / PEOU / ATU / BIU means and interpretations.

### 4.4 UAT results
Task completion table per participant, then the findings log with severities.

### 4.5 Discussion
Tie each result to a design decision. "Security scored 4.6 because RLS enforces role
separation at the database, verified by TC-027/077/078" is a discussion. Restating a mean is
not.

---

## Chapter 5 — Conclusion and Recommendations

### 5.1 Summary of findings
One paragraph per objective from §1.3. Same order, same wording basis. If an objective
produced a weak result, say so.

### 5.2 Conclusion
Did the system meet its objectives? Answer the 90% question explicitly with the number.

### 5.3 Recommendations
From evidence, not imagination:
- Every UAT finding with severity Major or Blocker
- Every QA failure declared as a limitation
- Explicit next steps: ticket scanning, payments, attendance verification (which are
  currently non-goals — naming them as future work is consistent and defensible)
- Provincial-wide rollout plan beyond Binangonan

### 5.4 References
APA 7th, alphabetical, hanging indent. Every in-text citation appears here and vice versa.

### Appendices
- A: Permission letters, consent forms
- B: Instruments (ISO 25010, TAM, UAT)
- C: Test matrix (full 84 rows), exported with the run date
- D: Source code excerpts — RLS policies, the semantic search function
- E: Respondent profile summaries
- F: Full ERD and DFDs at readable size
- G: Cost–benefit analysis from `docs/spec/cost-model.md`

---

## Consistency checks before submission

- [ ] Every specific objective in §1.3 has a §4.x section
- [ ] Every limitation in §1.5 appears in `docs/spec/non-goals.md`
- [ ] Participant counts match across §3.9, §4.2–4.4, and the abstract (30 total: 5 + 20 + 5)
- [ ] The QB pass rate in §4.1 matches the exported matrix
- [ ] The ERD matches `docs/design/schema.md` §9
- [ ] The ISO revision named in §3.9 matches the instrument in Appendix B
- [ ] ₱147,415 and ₱37,100 appear consistently in §1 and Appendix G
- [ ] SDG 11 and SDG 16 named consistently, not swapped
- [ ] Every in-text citation appears in References
