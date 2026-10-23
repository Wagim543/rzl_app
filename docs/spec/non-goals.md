# RZL — Non-Goals (Out of Scope)

These are **documented exclusions**, stated in Chapter 1 of the capstone paper. They exist
to protect the schedule. If a request falls here, the answer is: *"Documented non-goal — do
you want to formally change scope?"*

## Hard non-goals

| ID | Not building | Why | Stated limitation in the paper |
|---|---|---|---|
| NG-01 | Ticket scanning / QR check-in | Requires hardware + a gate workflow no LGU in scope has | "no ticket scanning" |
| NG-02 | Online payments / e-wallet | Requires PCI-DSS scope, merchant accounts, refund handling | "no online payments" |
| NG-03 | Attendance verification / proof-of-presence | Needs geofencing or scanning; ties to NG-01 | "no attendance verification" |
| NG-04 | Two-way native calendar sync | Platform-specific write-back is unreliable and out of budget | "calendar feature only exports to the native device calendar" |
| NG-05 | Guaranteed listing accuracy | Content comes from admins; we cannot verify every barangay event | "listing accuracy depends on what administrators submit" |
| NG-06 | Provincial-wide live deployment | Testing and data gathering happen in **Binangonan only**; the design covers all of Rizal | stated in scope section |
| NG-07 | Full turn-by-turn navigation | We hand off to Google Maps via `url_launcher` | "basic route guidance" |
| NG-08 | In-app chat / direct messaging | Not in the requirements; moderation cost is high | — |
| NG-09 | Web admin portal | Admin functions ship inside the same Flutter app | — |
| NG-10 | Multi-language / Tagalog localisation | Single-language UI for the study period | — |

## Soft non-goals (nice to have, only if everything else passes 90%)

- Event ticketing tiers or seat selection
- Organizer self-service signup (admins are provisioned)
- Offline-first caching of the full event catalogue
- Social sharing sheets beyond the OS share dialog
- Analytics dashboards beyond the engagement report log

## Budget-driven non-goals

| ID | Not doing | Reason |
|---|---|---|
| NG-B1 | Google Places Nearby Search at runtime | ~₱950 per 1,000 calls; would blow the ₱37,100/yr recurring budget |
| NG-B2 | Per-read LLM calls | Summaries are generated once at publish time and cached in `events.summary` |
| NG-B3 | Paid maps SDK in-app | Route guidance hands off to the installed maps app at zero cost |

See `docs/spec/cost-model.md`.

## How to handle a scope-change request

1. Check this file.
2. If listed: state the ID and the reason. Ask if this is a formal scope change.
3. If it is: it needs a new `FR-` ID, a cost note, a test case, and a line in Chapter 1.
   Never silently implement it.
