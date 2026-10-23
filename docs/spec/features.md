# RZL — Functional Requirements

Source of truth for **what the system does**. Every feature carries an `FR-` ID that is
referenced by the code, the test matrix, and Chapters 3–4.

Status legend: `spec` = documented, not built · `wip` = in progress · `done` = built and
passing its test case · `cut` = removed from scope (needs a note in Chapter 1).

> **Rule:** a feature without an `FR-` ID does not exist. A feature with an `FR-` ID but no
> `TC-` test case in `docs/qa/test-cases.md` is not done.

---

## A. Discovery — guest accessible (no account)

| ID | Feature | Role | Priority | Acceptance criteria | Status |
|---|---|---|---|---|---|
| FR-01 | Browse published events | guest | Must | Feed lists only `status = 'published'` events whose `ends_at` is null or in the future, newest-starting-first. Renders without any auth token. | wip |
| FR-02 | Filter by municipality | guest | Must | Selecting a municipality restricts the feed to events in that municipality; an "All" option clears the filter. | wip |
| FR-03 | Filter by barangay | guest | Must | Barangay options are scoped to the selected municipality. Selecting a barangay without a municipality auto-selects its parent. | spec |
| FR-04 | Filter by category | guest | Must | Multi-select of categories; results are the union. Shows a count badge per category. | spec |
| FR-05 | Filter by schedule | guest | Must | Presets: Today, This week, This month, Custom date range. Boundary is `starts_at` inclusive, `ends_at` exclusive. | spec |
| FR-06 | Event detail view | guest | Must | Shows title, summary, full description, cover image, venue, schedule, category, municipality/barangay, engagement counts, map link. Fully readable while logged out. | wip |
| FR-07 | Search events by keyword | guest | Must | Text query matches `title` and `description` case-insensitively. Debounced 300 ms. See FR-18 for semantic mode. | spec |
| FR-08 | Read published announcements | guest | Should | Announcements list shows only `published_at <= now()`, newest first. | spec |

## B. Account

| ID | Feature | Role | Priority | Acceptance criteria | Status |
|---|---|---|---|---|---|
| FR-09 | Register account | guest | Must | Email + password + full name. On success a `profiles` row is created with `role = 'resident'`. Email confirmation state handled without a dead end. | spec |
| FR-10 | Log in / log out | resident, tourist, admin | Must | Session persists across app restarts. Log out clears the session and returns the app to guest mode — the feed must remain usable. | spec |
| FR-11 | Choose resident or tourist | resident, tourist | Should | Onboarding asks whether the user lives in Rizal and which municipality. Stored as `profiles.user_type`; drives recommendation weighting (FR-19). | spec |
| FR-12 | Edit profile | resident, tourist, admin | Should | Change full name, municipality, avatar, and interest tags. Writes restricted to own row. | spec |

## C. Engagement — requires an account

| ID | Feature | Role | Priority | Acceptance criteria | Status |
|---|---|---|---|---|---|
| FR-13 | Bookmark event | resident, tourist | Must | Toggles a `bookmarks` row. Bookmarked state survives reload and appears in a "Saved" tab. | spec |
| FR-14 | Save event to device calendar | resident, tourist | Must | Opens the OS calendar insert sheet with title, start, end, venue, and description prefilled. Uses the platform calendar plugin; no write to Supabase. | spec |
| FR-15 | Mark "I'm Going" | resident, tourist | Must | Sets `attendance.status = 'going'`. Public count increments by one and persists. Toggling back removes the row. Cannot be set for an event that has already ended. | spec |
| FR-16 | Like event | resident, tourist | Must | One like per user per event (unique constraint). Count reflects real rows. Toggle removes the like. | spec |
| FR-17 | Comment on event | resident, tourist | Must | Body 1–1000 chars, trimmed, non-empty after trim. Visible to guests. Author may delete their own; admin may hide. | spec |
| FR-18 | Review event | resident, tourist | Must | Rating 1–5 plus optional body. One review per user per event. Aggregate average is shown on the detail page and rounded to 1 decimal. | spec |
| FR-19 | In-app notifications | resident, tourist | Should | Notifications are created for: event starting within 24 h for RSVP'd/bookmarked events, admin cancellation of an RSVP'd event, and admin announcement. Unread badge clears on open. | spec |
| FR-20 | Dark mode | all | Should | Follows the OS setting by default; user override persists across restarts. Both themes meet 4.5:1 contrast for body text. | spec |

## D. Smart discovery — ML features

| ID | Feature | Role | Priority | Acceptance criteria | Status |
|---|---|---|---|---|---|
| FR-21 | Automatic event summary | guest | Should | On publish, a 1–3 sentence summary is generated and cached in `events.summary` with `summary_generated_at`. Falls back to the first 200 chars of the description when generation fails. Never generated on read. | spec |
| FR-22 | Semantic search | guest | Must | Query is embedded and ranked by cosine similarity against `events.embedding`, filtered to published events. Falls back to keyword search (FR-07) when the embedding provider is unavailable. | spec |
| FR-23 | Personalised recommendations | resident, tourist | Must | Ranks published upcoming events by similarity to the user's liked/bookmarked/RSVP'd event embeddings, weighted by interest tags, then by municipality proximity. Cold start falls back to popular upcoming events in the user's municipality. | spec |

## E. Nearby and navigation

| ID | Feature | Role | Priority | Acceptance criteria | Status |
|---|---|---|---|---|---|
| FR-24 | Nearby attractions, restaurants, hotels | guest | Should | Lists seeded `places` within a configurable radius of the event venue, grouped by type, max 10 per type. No live Places API call at runtime. | spec |
| FR-25 | Basic route guidance | guest | Should | "Get directions" opens the installed maps app via `url_launcher` with the venue address/coordinates. Handles the no-maps-app-installed case with a copyable address. | spec |

## F. Administration

| ID | Feature | Role | Priority | Acceptance criteria | Status |
|---|---|---|---|---|---|
| FR-26 | Create event | admin, lgu | Must | Required: title, description, category, municipality, barangay, venue, start, end. Validates `end > start`. Saves as draft or published. Generates summary + embedding on publish. | spec |
| FR-27 | Update event | admin, lgu | Must | Edits any field. Republishing after a material change regenerates the summary. Past events cannot be moved to a future date without an explicit confirmation. | spec |
| FR-28 | Delete / unpublish event | admin, lgu | Must | Archiving sets `status = 'archived'` and hides the event from all guest surfaces while retaining engagement rows. Hard delete is not exposed in the UI. | spec |
| FR-29 | Upload event image | admin, lgu | Must | Writes to the `event-images` storage bucket, max 5 MB, image mime types only. Stores the public URL on the event row. | spec |
| FR-30 | Publish announcement | admin, lgu | Must | Title + body; appears in the guest announcements list and generates notifications for residents in the target municipality. | spec |
| FR-31 | View engagement report log | admin, lgu | Must | Per event and per date range: views, likes, comments, reviews, average rating, "I'm Going" count, bookmarks. Exportable summary table. | spec |
| FR-32 | Moderate comments and reviews | admin, lgu | Should | Hides a comment or review without deleting the row, preserving report integrity. | spec |

## G. System

| ID | Feature | Role | Priority | Acceptance criteria | Status |
|---|---|---|---|---|---|
| FR-33 | Offline / degraded network handling | all | Must | Every remote read shows a retry affordance on failure. Cached content is shown when available rather than an empty screen. | spec |
| FR-34 | Empty and error states | all | Must | Every list has a distinct empty state, and every failure has a message plus retry. No bare spinners that can hang forever. | spec |

---

## Traceability rules

- FR IDs are **stable**. Never renumber. Cut an FR by setting `Status = cut` and adding a
  reason; do not reuse the number.
- One `FR-` → at least one `TC-` in `docs/qa/test-cases.md`.
- Chapter 3's "Scope and Limitation" must list the same FR set. Chapter 4's results table
  must report the same TC set.

## Counting for the 90% gate

The pass rate is computed over **test cases**, not features:

```
pass rate = passed TCs ÷ total TCs × 100
```

With 34 features and one TC each (34 TCs), 90% requires **31 passing**.
Because most features need 2–3 TCs (happy path, empty, unauthorised), the realistic
denominator is ~80 TCs, which needs **72 passing**. Keep the denominator explicit and
frozen at least a week before the defense — moving it late reads as gaming the metric.
