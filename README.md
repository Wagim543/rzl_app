# RZL

**Mobile Event Coordination and Community Engagement Platform for the Province of Rizal**

A Flutter + Supabase mobile application that centralises LGU event announcements so
residents and visitors can find what is happening in their municipality or barangay, and so
organisers can measure engagement.

Capstone project · BSIT · University of Rizal System, Binangonan · SY 2026–2027

---

## Stack

| Layer | Choice |
|---|---|
| Client | Flutter 3.47.5 / Dart 3.13.4 |
| Backend | Supabase — Postgres, Auth, Storage, Realtime, pgvector |
| State | Riverpod |
| Routing | go_router |
| Design | Figma |
| Method | RAD |

## Quick start

```bash
flutter pub get
cp env.example.json env.json      # then fill in the Supabase values
flutter run --dart-define-from-file=env.json
```

Full instructions: [`docs/setup.md`](docs/setup.md)

## Project structure

```
lib/          Flutter application
docs/         Specs, design, QA evidence — the paper's source of truth
.opencode/    Skills that teach the agent this project's conventions
```

## Documentation

| Start here | |
|---|---|
| [Agent rules](AGENTS.md) | Conventions that apply to every change |
| [Setup](docs/setup.md) | Clone to running app |
| [Features](docs/spec/features.md) | 34 functional requirements, `FR-01`…`FR-34` |
| [Roles](docs/spec/roles.md) | Guest, resident, tourist, admin, LGU + permission matrix |
| [Non-goals](docs/spec/non-goals.md) | Documented exclusions |
| [Cost model](docs/spec/cost-model.md) | ₱147,415 initial · ₱37,100 / year |
| [Decisions](docs/spec/decisions.md) | Architecture decision log |
| [Schema](docs/design/schema.md) | Tables and the ERD source |
| [RLS policies](docs/design/rls-policies.md) | Who can read and write what |
| [Test matrix](docs/qa/test-cases.md) | 84 cases, 90% gate |
| [ISO 25010](docs/qa/iso-25010.md) | Expert evaluation instrument |
| [TAM](docs/qa/tam-instrument.md) | Acceptance instrument |
| [UAT](docs/qa/uat-script.md) | LGU acceptance testing |

## Evaluation

| Instrument | Respondents | Target |
|---|---|---|
| QA functionality | development team | ≥ 90% pass rate |
| ISO/IEC 25010:2023 | 5 IT professionals | fully implemented |
| Technology Acceptance Model | 20 residents and tourists | agree or better |
| User Acceptance Testing | 5 LGU personnel | ≥ 90% task completion |

30 participants total, in Binangonan. The design covers all of Rizal.

## Check the 90% gate

```powershell
powershell -File .opencode/skills/rzl-qa/scripts/pass-rate.ps1 -Detailed
```

## Scope in one line

Guests browse events without an account. Residents bookmark, RSVP, like, comment, review,
and export to their calendar. Smart discovery provides semantic search, summaries, and
recommendations. Admins manage events, announcements, and engagement reports.

No ticket scanning. No payments. No attendance verification.
