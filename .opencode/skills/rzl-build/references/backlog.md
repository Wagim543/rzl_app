# RZL — Construction Backlog

Ordered, dependency-aware. Each task names the `FR-` it satisfies and the `TC-` that proves
it. Work top to bottom; do not pull a task forward past an unmet dependency.

Legend: `✅` done · `🔄` in progress · `☐` not started

---

## Milestone 0 — Foundations

| # | Task | Depends on | FR | TC | Status |
|---|---|---|---|---|---|
| 0.1 | Environment config via `--dart-define` (`env.dart`, `env.example.json`) | — | — | — | ☐ |
| 0.2 | Supabase bootstrap (`initSupabase()`) | 0.1 | — | — | ☐ |
| 0.3 | Theme: light + dark from one seed colour | — | FR-20 | TC-046 | ☐ |
| 0.4 | Router: feed + detail, auth-guard scaffold | 0.3 | — | — | ☐ |
| 0.5 | Error types + mapper (`Failure`, `PostgrestException` → `Failure`) | 0.2 | FR-34 | TC-082 | ☐ |
| 0.6 | Shared widgets: `EmptyState`, `ErrorView`, `LoadingSkeleton` | 0.3 | FR-34 | TC-081 | ☐ |
| 0.7 | `main.dart` reduced to bootstrap only | 0.2, 0.4 | — | — | ☐ |

**Gate:** app runs with both themes, a broken network shows `ErrorView` not a crash.

## Milestone 1 — Guest event browsing

| # | Task | Depends on | FR | TC | Status |
|---|---|---|---|---|---|
| 1.1 | Migration: `municipalities`, `barangays`, `categories` | 0.2 | — | — | ☐ |
| 1.2 | Migration: `profiles` + signup trigger | 1.1 | — | — | ☐ |
| 1.3 | Migration: `events` + indexes | 1.2 | — | — | ☐ |
| 1.4 | RLS: public read for reference tables, published events; staff write | 1.3 | FR-01 | TC-001, TC-078 | ☐ |
| 1.5 | Seed: 14 Rizal municipalities, Binangonan barangays, 10 categories | 1.1 | — | — | ☐ |
| 1.6 | Seed: 6 realistic Binangonan events | 1.3, 1.5 | — | — | ☐ |
| 1.7 | `Event` entity + `EventFilter` | 1.3 | FR-06 | — | ☐ |
| 1.8 | `EventRepository` interface + Supabase implementation | 1.4, 1.7 | FR-01 | TC-001 | ☐ |
| 1.9 | `eventFeedProvider`, `eventDetailProvider`, `municipalitiesProvider` | 1.8 | FR-01 | TC-001 | ☐ |
| 1.10 | `EventCard` + `EventFeedScreen` with four states | 1.9 | FR-01 | TC-001, TC-002 | ☐ |
| 1.11 | `EventDetailScreen` | 1.9 | FR-06 | TC-012, TC-013 | ☐ |
| 1.12 | Municipality filter chip bar | 1.9 | FR-02 | TC-005, TC-006 | ☐ |
| 1.13 | Category filter | 1.9 | FR-04 | TC-009 | ☐ |
| 1.14 | Schedule presets (Today / Week / Month) | 1.9 | FR-05 | TC-010, TC-011 | ☐ |
| 1.15 | Keyword search bar, debounced 300 ms | 1.9 | FR-07 | TC-014, TC-015 | ☐ |
| 1.16 | Widget tests: feed data / empty / error states | 1.10 | FR-34 | TC-081, TC-082 | ☐ |

**Gate:** TC-001, TC-005, TC-012, TC-023 pass on a physical device as a logged-out user.

## Milestone 2 — Auth and engagement

| # | Task | Depends on | FR | TC | Status |
|---|---|---|---|---|---|
| 2.1 | `AuthRepository` + `authStateProvider` | 1.2 | FR-10 | TC-021, TC-022 | ☐ |
| 2.2 | Register screen + validation | 2.1 | FR-09 | TC-017 … TC-020 | ☐ |
| 2.3 | Login screen + error handling | 2.1 | FR-10 | TC-021, TC-024 | ☐ |
| 2.4 | Logout returning to guest mode | 2.1 | FR-10 | TC-023 | ☐ |
| 2.5 | Onboarding: resident vs tourist, municipality | 2.1 | FR-11 | TC-025 | ☐ |
| 2.6 | Profile screen + edit | 2.1 | FR-12 | TC-026, TC-027 | ☐ |
| 2.7 | Migration: `bookmarks`, `attendance`, `likes` + RLS Shape B | 2.1 | — | — | ☐ |
| 2.8 | Migration: `comments`, `reviews` + RLS Shape C | 2.1 | — | — | ☐ |
| 2.9 | Bookmark toggle + Saved tab | 2.7 | FR-13 | TC-028 … TC-030 | ☐ |
| 2.10 | "I'm Going" toggle + count | 2.7 | FR-15 | TC-033 … TC-035 | ☐ |
| 2.11 | Like toggle + count | 2.7 | FR-16 | TC-036, TC-037 | ☐ |
| 2.12 | Comment list + composer | 2.8 | FR-17 | TC-038 … TC-040 | ☐ |
| 2.13 | Review form + average rating | 2.8 | FR-18 | TC-041 … TC-043 | ☐ |
| 2.14 | Calendar export | 2.1 | FR-14 | TC-031, TC-032 | ☐ |
| 2.15 | Dark mode toggle persisted on `profiles.dark_mode` | 2.6 | FR-20 | TC-046 … TC-048 | ☐ |

**Gate:** a full engagement loop on a physical device; logout still leaves a working feed.

## Milestone 3 — Smart discovery

| # | Task | Depends on | FR | TC | Status |
|---|---|---|---|---|---|
| 3.1 | Enable `pgvector`, add `events.embedding` + HNSW index | 1.3 | — | — | ☐ |
| 3.2 | Edge Function: `generate-event-content` (summary + embedding) | 3.1 | FR-21 | TC-049, TC-050 | ☐ |
| 3.3 | Trigger summary generation on publish; cache in `events.summary` | 3.2 | FR-21 | TC-051 | ☐ |
| 3.4 | `match_events` SQL function | 3.1 | FR-22 | TC-052, TC-054 | ☐ |
| 3.5 | Edge Function: `search-events` | 3.4 | FR-22 | TC-052 | ☐ |
| 3.6 | Semantic search UI + keyword fallback notice | 3.5 | FR-22 | TC-053 | ☐ |
| 3.7 | `user_taste_vector` function + recommendation scoring | 3.4 | FR-23 | TC-056 | ☐ |
| 3.8 | Recommendations screen + cold-start path | 3.7 | FR-23 | TC-055, TC-057 | ☐ |

**Gate:** semantic search returns meaning-matches; removing the API key degrades to keyword
search instead of breaking.

## Milestone 4 — Administration

| # | Task | Depends on | FR | TC | Status |
|---|---|---|---|---|---|
| 4.1 | Admin route guard + role check | 2.1 | — | TC-077 | ☐ |
| 4.2 | Admin dashboard shell | 4.1 | — | — | ☐ |
| 4.3 | Event editor: create with validation | 4.2 | FR-26 | TC-063 … TC-066 | ☐ |
| 4.4 | Event editor: update | 4.3 | FR-27 | TC-067, TC-068 | ☐ |
| 4.5 | Archive / unpublish | 4.3 | FR-28 | TC-069 | ☐ |
| 4.6 | Storage bucket + image upload with size/mime validation | 4.3 | FR-29 | TC-070 … TC-072 | ☐ |
| 4.7 | Announcements: create + publish | 4.2 | FR-30 | TC-073 | ☐ |
| 4.8 | Engagement report queries + screen | 4.2 | FR-31 | TC-074, TC-075 | ☐ |
| 4.9 | Comment / review moderation | 4.2 | FR-32 | TC-076 | ☐ |

**Gate:** an admin creates an event on a phone and it appears in the guest feed on another.

## Milestone 5 — Places and communications

| # | Task | Depends on | FR | TC | Status |
|---|---|---|---|---|---|
| 5.1 | Migration: `places` + seed Binangonan establishments | 1.1 | — | — | ☐ |
| 5.2 | Haversine + radius filter | 5.1 | FR-24 | TC-058, TC-059 | ☐ |
| 5.3 | Nearby places section on event detail | 5.2 | FR-24 | TC-058, TC-060 | ☐ |
| 5.4 | Directions handoff via `url_launcher` | 5.3 | FR-25 | TC-061, TC-062 | ☐ |
| 5.5 | Migration: `notifications` | 2.1 | — | — | ☐ |
| 5.6 | Notification generation + list + unread badge | 5.5 | FR-19 | TC-044, TC-045 | ☐ |
| 5.7 | Announcements list for guests | 4.7 | FR-08 | TC-016 | ☐ |

**Gate:** zero runtime Places API calls; directions open the device maps app.

## Milestone 6 — Hardening and evaluation

| # | Task | Depends on | FR | TC | Status |
|---|---|---|---|---|---|
| 6.1 | Offline handling: retry everywhere, cached fallback | all | FR-33 | TC-079, TC-080 | ☐ |
| 6.2 | Empty/error state audit on every list | all | FR-34 | TC-081 | ☐ |
| 6.3 | Full regression, matrix frozen | 6.2 | — | all 84 | ☐ |
| 6.4 | Signed APK + install on 2 physical devices | 6.3 | — | TC-083 | ☐ |
| 6.5 | ISO 25010 with 5 IT professionals | 6.3 | — | — | ☐ |
| 6.6 | TAM with 20 residents and tourists | 6.3 | — | — | ☐ |
| 6.7 | UAT with 5 LGU personnel | 6.3 | — | — | ☐ |
| 6.8 | Chapter 4 tables, Chapter 5 conclusions | 6.5–6.7 | — | — | ☐ |

**Gate:** 76/84 TCs, three instruments collected, verified APK tagged `v1.0.0-defense`.

---

## Dependency rules worth remembering

- `profiles` must exist before `events` (FK on `created_by`)
- `municipalities` before `barangays` before `events`
- `categories` before `events`
- RLS **in the same commit** as the table — never "we'll add policies later"
- Auth before any engagement feature (every engagement row has `user_id`)
- `pgvector` before any semantic search work
- Admin role before any admin screen

## If you are behind schedule

Cut in this order:

1. Milestone 5 entirely — FR-24, FR-25, FR-19 are the lowest-value `Should`s
2. Category and schedule filters (FR-04, FR-05) — keep municipality (FR-02)
3. Recomm-endations (FR-23) — keep semantic search (FR-22), it is the more impressive demo
4. Announcements (FR-30, FR-08)

**Never cut:** Milestone 1, the guest path, RLS, or Milestone 6.
