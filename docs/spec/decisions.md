# RZL — Architecture Decision Log

Append-only. Every locked-in technical choice gets one row, with the reason a panel would
accept. Never delete a row; supersede it with a new one.

| # | Date | Decision | Alternatives rejected | Reason |
|---|---|---|---|---|
| AD-01 | 2026-10 | Backend is Supabase (hosted Postgres) | Firebase, custom Node API, MySQL + PHP | Relational model fits events/RSVP/reporting; RLS enforces per-role access at the database; Realtime and Storage included; single managed bill. |
| AD-02 | 2026-10 | Client is Flutter (single codebase) | Native Android, React Native | One codebase for Android + iOS, team already trained on Dart, strong form/CRUD tooling. |
| AD-03 | 2026-10 | State management is Riverpod | `setState`, Bloc, Provider | Compile-safe dependency injection, `AsyncValue` gives loading/error/data for free — matches our four-state rule. |
| AD-04 | 2026-10 | Routing is `go_router` | Navigator 1.0, auto_route | Declarative, deep-link ready (event URLs), redirect-based auth guard without widget rebuild hacks. |
| AD-05 | 2026-10 | Guests read events through RLS, not a mock | Require login to browse | Hard product requirement: residents must browse without an account. |
| AD-06 | 2026-10 | Semantic search uses `pgvector` + hosted embeddings | On-device TFLite, Elasticsearch | No extra infrastructure; similarity search lives next to the data; keyword fallback keeps the demo working offline. |
| AD-07 | 2026-10 | Event summaries cached on publish | Generate on read | Cost control (AD-07 budget) and latency; a summary is stable content, not a live query. |
| AD-08 | 2026-10 | Nearby places is a seeded table | Google Places API at runtime | Cost: ~₱950/1,000 calls breaks the ₱37,100/yr budget. Accuracy matters more than freshness for a fixed study area. |
| AD-09 | 2026-10 | Route guidance hands off to the OS maps app | `google_maps_flutter` in-app | Zero cost, zero keys, less failure surface, and satisfies "basic route guidance". |
| AD-10 | 2026-10 | Moderation is a soft `is_hidden` flag | Row deletion | Engagement report logs (FR-31) must remain complete and auditable. |
| AD-11 | 2026-10 | Realtime for comments/likes with polling fallback | Realtime only | Venue Wi-Fi at the defense is unreliable; the fallback keeps the demo alive. |
| AD-12 | 2026-10 | Testing limited to Binangonan, design covers all of Rizal | Province-wide pilot | Stated research scope; 30 participants from 5 LGU personnel, 20 residents/tourists, 5 IT professionals. |
| AD-13 | 2026-10 | Entities are plain immutable classes; no `freezed`, no `build_runner`, no `json_serializable` | `freezed` + `json_serializable`, `built_value` | Removes a codegen step from every model change. For a five-person team, stale generated files cause more build failures than the boilerplate they save. `fromJson` is written by hand next to the constructor, so Postgres column names stay visible at the mapping site. Supersedes the model row of the original stack table. |
| AD-14 | 2026-10 | Automatic provider retry is disabled (`retry: (_, _) => null`) | Riverpod 3 default backoff, manual timer loops | Riverpod 3 retries failed `FutureProvider`s indefinitely with backoff while a listener exists. That is invisible to the user, prevents a stable error state, and made a widget test record 11 fetch attempts before any user action. Retries are the user's decision via the explicit "Try again" button (FR-34). |
| AD-15 | 2026-10 | `events.created_by` is nullable (`on delete set null`) | `not null`, cascade delete | Seeded and migrated LGU content has no natural author, and an event must survive the deletion of the admin who entered it — engagement rows reference the event, not the author. Supersedes `docs/design/schema.md` §3, which now records the nullable form. |

## How to add a decision

1. Number it `AD-nn` (next integer, never reuse).
2. Date it.
3. State what was chosen, what was rejected, and **why a panel would accept it**.
4. If it supersedes an earlier row, say so explicitly rather than editing the old row.
5. If the decision changes `pubspec.yaml`, update `docs/spec/cost-model.md` in the same commit.
