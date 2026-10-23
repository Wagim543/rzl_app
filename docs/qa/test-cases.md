# RZL — Test Case Matrix

This file **is** the 90% functionality evidence. Chapter 4 reports its totals; the defense
appendix prints it.

```
pass rate = passed ÷ total × 100
```

Update `Status` as you go. Never bulk-fill at the end — panels ask to see a live run.

Status: `☐ not run` · `✅ pass` · `❌ fail` · `⏭ not applicable` (needs a reason) · `🚫 blocked`

---

## A. Discovery (guest, no account)

| TC | FR | Test case | Expected result | Pri | Status |
|---|---|---|---|---|---|
| TC-001 | FR-01 | Open app while logged out, no cached session | Feed lists published upcoming events. No login wall, no blank screen. | High | ☐ |
| TC-002 | FR-01 | Open app with 0 published events in DB | Empty state with message and a refresh control — not a spinner. | High | ☐ |
| TC-003 | FR-01 | Publish an event with `ends_at` in the past, reload feed | Event is absent from the guest feed. | High | ☐ |
| TC-004 | FR-01 | Change an event `status` to `draft`, reload feed | Event disappears for guests; still visible to admin. | High | ☐ |
| TC-005 | FR-02 | Select municipality "Binangonan" | Only Binangonan events remain; "All" restores the full list. | High | ☐ |
| TC-006 | FR-02 | Select a municipality with no events | Empty state names the filter, with "clear filters". | Med | ☐ |
| TC-007 | FR-03 | Select municipality, then open barangay filter | Barangay options belong only to that municipality. | High | ☐ |
| TC-008 | FR-03 | Select barangay without municipality | Parent municipality auto-selects; results narrow correctly. | Med | ☐ |
| TC-009 | FR-04 | Select two categories | Results are the union; category badge counts match. | High | ☐ |
| TC-010 | FR-05 | Select "Today" preset | Only events overlapping today appear. | High | ☐ |
| TC-011 | FR-05 | Custom range where start = end | Events on that single day appear. | Med | ☐ |
| TC-012 | FR-06 | Open event detail while logged out | All content visible: image, summary, venue, schedule, counts, map link. No "login to view". | High | ☐ |
| TC-013 | FR-06 | Open a non-existent / archived event id | Friendly "event unavailable" screen with back action. No crash. | Med | ☐ |
| TC-014 | FR-07 | Search "fiesta" with mixed case | Matching titles/descriptions returned, case-insensitive. | High | ☐ |
| TC-015 | FR-07 | Search a term with zero matches | Empty state with "no results for …". | Med | ☐ |
| TC-016 | FR-08 | Open announcements as a guest | Only `published_at <= now()` items, newest first. | Med | ☐ |

## B. Account

| TC | FR | Test case | Expected result | Pri | Status |
|---|---|---|---|---|---|
| TC-017 | FR-09 | Register with valid email + password | Account created, `profiles` row exists with `role = 'resident'`. | High | ☐ |
| TC-018 | FR-09 | Register with an already-used email | Clear inline error, no crash, no partial row. | High | ☐ |
| TC-019 | FR-09 | Register with password < 8 chars | Validation error before any network call. | High | ☐ |
| TC-020 | FR-09 | Register with email confirmation enabled | User is told to confirm, not left on a dead screen. | High | ☐ |
| TC-021 | FR-10 | Log in with valid credentials | Session established, profile loads, user menu shows the name. | High | ☐ |
| TC-022 | FR-10 | Kill and reopen the app while logged in | Session persists; no re-login prompt. | High | ☐ |
| TC-023 | FR-10 | Log out | Session cleared; app returns to guest mode and the feed still works. | High | ☐ |
| TC-024 | FR-10 | Log in with wrong password | Inline error, no crash, no session. | High | ☐ |
| TC-025 | FR-11 | Complete onboarding as a tourist | `profiles.user_type = 'tourist'`; recommendations weight nearby. | Med | ☐ |
| TC-026 | FR-12 | Edit own profile name and municipality | Changes persist after restart. | Med | ☐ |
| TC-027 | FR-12 | Attempt `update profiles set role='admin'` from the client | Request is rejected by RLS. Role unchanged. | High | ☐ |

## C. Engagement (authenticated)

| TC | FR | Test case | Expected result | Pri | Status |
|---|---|---|---|---|---|
| TC-028 | FR-13 | Bookmark an event, restart app | Event is still bookmarked and listed under "Saved". | High | ☐ |
| TC-029 | FR-13 | Tap bookmark twice | Single `bookmarks` row; state toggles back. No duplicates. | High | ☐ |
| TC-030 | FR-13 | Open "Saved" with no bookmarks | Empty state, not a spinner. | Med | ☐ |
| TC-031 | FR-14 | Tap "Add to calendar" | OS insert sheet opens with title, start, end, venue, description prefilled. | High | ☐ |
| TC-032 | FR-14 | Cancel the calendar sheet | Returns to app with no error shown. | Med | ☐ |
| TC-033 | FR-15 | Tap "I'm Going" | Going count +1 and persists after reload. | High | ☐ |
| TC-034 | FR-15 | Tap "I'm Going" on an ended event | Action is disabled with a reason. | Med | ☐ |
| TC-035 | FR-15 | Tap "I'm Going" twice | Toggles off; count returns to previous value. | High | ☐ |
| TC-036 | FR-16 | Like an event | Like count +1, one row per user per event. | High | ☐ |
| TC-037 | FR-16 | Like the same event twice | Toggles off; no duplicate row. | High | ☐ |
| TC-038 | FR-17 | Post a comment | Appears immediately for the author and on reload. | High | ☐ |
| TC-039 | FR-17 | Post a comment of only spaces | Rejected client-side; nothing written. | Med | ☐ |
| TC-040 | FR-17 | Guest views an event with comments | Comments are visible and readable. | High | ☐ |
| TC-041 | FR-18 | Submit a 5-star review with text | Saved; average rating updates on the detail page. | High | ☐ |
| TC-042 | FR-18 | Submit a second review on the same event | Rejected by the unique constraint; UI updates the existing review instead. | High | ☐ |
| TC-043 | FR-18 | Submit rating 0 or 6 | Rejected by validation and the DB check constraint. | Med | ☐ |
| TC-044 | FR-19 | RSVP an event starting within 24 h | Notification appears; unread badge increments. | Med | ☐ |
| TC-045 | FR-19 | Open the notification list | Badge clears; items marked read. | Med | ☐ |
| TC-046 | FR-20 | Set OS to dark mode | App renders dark without restart. | Med | ☐ |
| TC-047 | FR-20 | Override theme to light manually, restart | Override persists. | Med | ☐ |
| TC-048 | FR-20 | Contrast check on body text in both themes | Meets 4.5:1 minimum. | Low | ☐ |

## D. Smart discovery (ML)

| TC | FR | Test case | Expected result | Pri | Status |
|---|---|---|---|---|---|
| TC-049 | FR-21 | Publish an event with a 3-paragraph description | A 1–3 sentence summary is stored in `events.summary`; `summary_generated_at` set. | High | ☐ |
| TC-050 | FR-21 | Publish with the summariser unavailable (key removed) | Fallback to a truncated description; publish still succeeds. | High | ☐ |
| TC-051 | FR-21 | Open event detail 5 times | Summary is not regenerated per view (no per-read calls). | High | ☐ |
| TC-052 | FR-22 | Search "mga piyesta sa Hunyo" (semantic, not literal) | Returns June festival events that do not contain the literal query. | High | ☐ |
| TC-053 | FR-22 | Semantic mode with embeddings unavailable | Falls back to keyword results with a subtle notice; no empty screen. | High | ☐ |
| TC-054 | FR-22 | Semantic search as a guest | Returns only published events — never drafts. | High | ☐ |
| TC-055 | FR-23 | New user with no history opens recommendations | Cold-start popular events in their municipality are shown. | High | ☐ |
| TC-056 | FR-23 | Like 3 sports events, reopen recommendations | Sports events rank above unrelated categories. | High | ☐ |
| TC-057 | FR-23 | Recommendations include a draft event | Impossible — drafts never surface. Verified against the DB. | High | ☐ |

## E. Nearby and navigation

| TC | FR | Test case | Expected result | Pri | Status |
|---|---|---|---|---|---|
| TC-058 | FR-24 | Open an event in Binangonan town proper | Nearby places list shows attractions, restaurants, hotels grouped by type. | Med | ☐ |
| TC-059 | FR-24 | Event with no places within radius | Grouped empty state; no error. | Med | ☐ |
| TC-060 | FR-24 | Count network calls while opening the nearby tab | Zero calls to any Places API — seeded data only. | High | ☐ |
| TC-061 | FR-25 | Tap "Get directions" with a maps app installed | Maps app opens with the venue destination. | Med | ☐ |
| TC-062 | FR-25 | Tap "Get directions" with no maps app | Shows the address with a copy action instead of failing. | Med | ☐ |

## F. Administration

| TC | FR | Test case | Expected result | Pri | Status |
|---|---|---|---|---|---|
| TC-063 | FR-26 | Admin creates a complete event and publishes | Event appears in the guest feed immediately. | High | ☐ |
| TC-064 | FR-26 | Submit `end` before `start` | Validation blocks submit; nothing written. | High | ☐ |
| TC-065 | FR-26 | Submit with required fields blank | Inline field errors; nothing written. | High | ☐ |
| TC-066 | FR-26 | Admin creates a draft | Draft is invisible to guests. | High | ☐ |
| TC-067 | FR-27 | Admin edits a published event title | Guest detail reflects the change on reload. | High | ☐ |
| TC-068 | FR-27 | Admin edits the description and republishes | Summary regenerates. | Med | ☐ |
| TC-069 | FR-28 | Admin archives an event | Vanishes from all guest surfaces; engagement rows still exist in DB. | High | ☐ |
| TC-070 | FR-29 | Upload a 2 MB JPEG as a cover | Uploaded to `event-images`, public URL stored, image renders. | High | ☐ |
| TC-071 | FR-29 | Upload a 12 MB file | Rejected before upload with a size message. | Med | ☐ |
| TC-072 | FR-29 | Upload a `.pdf` | Rejected by mime-type validation. | Med | ☐ |
| TC-073 | FR-30 | Admin publishes an announcement | Visible to guests; target-municipality residents get a notification. | High | ☐ |
| TC-074 | FR-31 | Open the engagement report for one event | Views, likes, comments, reviews, avg rating, going count, bookmarks all match the DB. | High | ☐ |
| TC-075 | FR-31 | Change the report date range | Totals rescope correctly. | Med | ☐ |
| TC-076 | FR-32 | Admin hides a comment | Comment disappears for guests; row still exists with `is_hidden = true`; report count unchanged. | Med | ☐ |
| TC-077 | — | `resident` account opens the admin route directly | Denied by router guard **and** by RLS. | High | ☐ |
| TC-078 | — | Guest calls the events insert endpoint directly | Rejected by RLS. | High | ☐ |

## G. System

| TC | FR | Test case | Expected result | Pri | Status |
|---|---|---|---|---|---|
| TC-079 | FR-33 | Open the feed with airplane mode on | Retry affordance or cached content. Never an infinite spinner. | High | ☐ |
| TC-080 | FR-33 | Kill the network mid-scroll, then restore | Recovers without an app restart. | Med | ☐ |
| TC-081 | FR-34 | Visit every list screen with an empty database | Each shows a distinct, human-readable empty state. | High | ☐ |
| TC-082 | FR-34 | Force a 500 from the API | Friendly error plus retry; no raw exception text. | High | ☐ |
| TC-083 | — | Cold start on a low-end device | First meaningful paint under 3 s on Wi-Fi. | Med | ☐ |
| TC-084 | — | Rotate the device on every major screen | Layout holds; no overflow warnings. | Low | ☐ |

---

## Totals

| Metric | Value |
|---|---|
| Total test cases | **84** |
| Passing needed for 90% | **76** (`ceil(84 × 0.90)`) |
| Currently passing | 0 |
| Current pass rate | 0.0% |

Recalculate with:

```
required passes = ceil(total TCs × 0.90)
```

Keep the total frozen from **one week before the defense**. Adding test cases after results
are collected is indefensible; adding them earlier is just thoroughness.

## Priority guidance

If you are behind schedule, High-priority TCs are the 90% target. Medium and Low are the
buffer — but do not delete them, because a shrunken denominator is the first thing a panel
will question.
