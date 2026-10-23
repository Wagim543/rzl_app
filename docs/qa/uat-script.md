# RZL — User Acceptance Testing (UAT) Script

For **5 LGU personnel** of Binangonan. These are the domain experts: they know what an
event listing *should* contain, and they are the ones who would actually operate the admin
side.

Format: observed task completion + short debrief. **Not** a satisfaction survey (that is
the TAM instrument). Record what they could not do.

## 1. Session setup

| Item | Detail |
|---|---|
| Duration | 30–45 minutes per participant |
| Device | One mid-range Android phone, app pre-installed, clean state |
| Roles needed | Facilitator + note-taker (one of the 5 developers each) |
| Recording | Screen recording + audio **with written consent** |
| Accounts | One pre-provisioned `lgu` account per participant |
| Data | A realistic event set seeded for Binangonan, at least 3 categories |

Do not help unless the participant is stuck for more than 60 seconds. Note the stall —
that stall is your finding.

## 2. Task scenarios

Each task is pass/fail. Tick as you observe. Do not ask "is this okay?" — ask them to do it.

### Task 1 — Find an event (guest flow)

> "You heard there is a fiesta in Binangonan this month. Using the app, find it and tell me
> when and where it is."

| Step | Observed |
|---|---|
| Opens the app without being told where to tap | ☐ |
| Locates the category or municipality filter | ☐ |
| Opens the correct event | ☐ |
| States the correct date and venue | ☐ |

Corresponding TCs: TC-001, TC-005, TC-009, TC-012

### Task 2 — Create and publish an event (admin flow)

> "You are organizing a barangay health drive on the 15th at the barangay hall. Enter it
> into the system so residents can see it."

| Step | Observed |
|---|---|
| Finds the admin area unaided | ☐ |
| Completes all required fields | ☐ |
| Sets date and time without errors | ☐ |
| Uploads an image | ☐ |
| Publishes successfully | ☐ |

Corresponding TCs: TC-063, TC-065, TC-066, TC-070

### Task 3 — Edit and archive

> "The venue changed to the covered court. Update the event. Then the event is cancelled —
> take it down."

| Step | Observed |
|---|---|
| Locates the existing event | ☐ |
| Edits the venue | ☐ |
| Confirms the change is reflected | ☐ |
| Archives the event | ☐ |
| Understands the difference between archive and delete | ☐ |

Corresponding TCs: TC-067, TC-069

### Task 4 — Read engagement data

> "Tell me how many residents said they are going, and how many liked it."

| Step | Observed |
|---|---|
| Finds the engagement report | ☐ |
| Reads going / likes / comments correctly | ☐ |
| Interprets average rating | ☐ |

Corresponding TCs: TC-074, TC-075

### Task 5 — Publish an announcement

> "Announce that the health drive is postponed by one week."

| Step | Observed |
|---|---|
| Finds the announcements feature | ☐ |
| Writes and publishes | ☐ |
| Confirms it appears for residents | ☐ |

Corresponding TCs: TC-073

## 3. Debrief questions

Ask these **after** all tasks, so they do not influence navigation.

1. What did you expect the app to do that it did not?
2. Which screen required the most thinking?
3. Would this replace the way you currently announce events? Why or why not?
4. What information is missing from an event listing that your office would normally include?
5. If you had to train a colleague in five minutes, what would you show them first?
6. What would make you stop using this?

Questions 4 and 6 produce the most useful Chapter 5 recommendations. Write the answers
verbatim — direct quotes are strong evidence.

## 4. Results table for Chapter 4

| Participant | Role / Office | T1 | T2 | T3 | T4 | T5 | Tasks passed |
|---|---|---|---|---|---|---|---|
| P1 | | ☐ | ☐ | ☐ | ☐ | ☐ | /5 |
| P2 | | ☐ | ☐ | ☐ | ☐ | ☐ | /5 |
| P3 | | ☐ | ☐ | ☐ | ☐ | ☐ | /5 |
| P4 | | ☐ | ☐ | ☐ | ☐ | ☐ | /5 |
| P5 | | ☐ | ☐ | ☐ | ☐ | ☐ | /5 |

Report: `UAT completion = total tasks passed ÷ 25 × 100`.

Target ≥ 90%, which means at most 2 failed task-steps across all five participants.

## 5. Findings log

| # | Observation (what happened) | Severity | Task | Fix | Status |
|---|---|---|---|---|---|
| 1 | | | | | |
| 2 | | | | | |

Severity: `Blocker` (task cannot complete) · `Major` (completes with difficulty) ·
`Minor` (cosmetic or hesitation only).

Every Blocker must be fixed and re-tested, or explicitly declared out of scope with a
reason in Chapter 5.

## 6. Ethics

- Written informed consent before recording.
- Explain that the app is a student prototype and that they are evaluating it, not being
  evaluated.
- No personal data beyond role and office in the transcript.
- Offer to demonstrate the fix afterward — LGU partners are also your future adopters, and
  the panel notices whether the partnership looks real.
