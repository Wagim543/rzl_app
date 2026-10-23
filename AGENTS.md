# RZL — Agent Rules (always on)

Mobile Event Coordination and Community Engagement Platform for the Province of Rizal.
Capstone, BSIT, University of Rizal System — Binangonan.

> These rules apply to every task in this repository. They are not optional and they are
> not per-feature. Project playbooks live in `.opencode/skills/`; project data lives in `docs/`.

---

## 1. Never break these

1. **No secrets in source.** Supabase URL and keys come from `--dart-define`.
   See `lib/core/config/env.dart`. Never hardcode a key in a widget or a service.
2. **Never call `Supabase.instance` from a widget.** Go through a repository in
   `lib/features/<feature>/data/`.
3. **Every screen handles four states:** loading, error, empty, data. No exceptions.
   Use `AsyncValue.when` — do not hand-roll booleans.
4. **Every new feature gets an `FR-` ID** in `docs/spec/features.md` and **at least one
   `TC-` test case** in `docs/qa/test-cases.md` before it is called done.
5. **Never implement anything listed in `docs/spec/non-goals.md`.** If the user asks for
   one, say it is a documented non-goal and ask whether that is a scope change.
6. **Ask before adding a dependency that costs money or calls a paid API.**
   The whole project budget is ₱37,100/year recurring. See `docs/spec/cost-model.md`.
7. Run `flutter analyze` and `dart format .` before reporting a task complete.

## 2. Locked stack

| Layer | Choice |
|---|---|
| Client | Flutter / Dart |
| Backend | Supabase — Postgres, Auth, Storage, Realtime, pgvector |
| State | Riverpod (`flutter_riverpod`, no codegen) |
| Routing | `go_router` |
| Models | Plain immutable classes — no codegen |
| Design | Figma |
| Method | RAD (Requirements Planning → User Design → Construction → Cutover) |

Do not swap any of these without an explicit decision recorded in `docs/spec/decisions.md`.

## 3. Repository layout

```
lib/
├── main.dart                  # bootstrap only
├── app/                       # router, theme, app shell
├── core/                      # env, errors, supabase client, shared widgets
└── features/<feature>/
    ├── data/                  # repository implementations, DTOs
    ├── domain/                # entities, repository contracts
    └── presentation/          # screens, widgets, providers

docs/
├── spec/                      # source of truth: features, non-goals, roles, cost, decisions
├── design/                    # schema, RLS, ERD
└── qa/                        # test cases, results, instruments
```

## 4. Roles

`guest` (no account) · `resident` · `tourist` · `admin` · `lgu_personnel`

Guests **must** be able to browse events. This is a hard product requirement — never
gate the event feed behind authentication.

## 5. Definition of done

A task is done when **all** of these are true:

- [ ] `flutter analyze` reports no issues
- [ ] `dart format .` applied
- [ ] Loading / error / empty / data states all implemented
- [ ] Works for a guest **and** a logged-in user where the spec allows both
- [ ] Feature has an `FR-` ID and a `TC-` test case
- [ ] No new paid dependency without recorded approval

## 6. Team workflow

5 developers. One branch per task (`feat/`, `fix/`, `chore/`), PR into `main`.
Never commit directly to `main`. Never commit `env.json`, `*.jks`, `key.properties`,
or `google-services.json`.

## 7. Where to look

| Question | File |
|---|---|
| What are we building? | `docs/spec/features.md` |
| What are we NOT building? | `docs/spec/non-goals.md` |
| How do I structure code? | `.opencode/skills/rzl-flutter/SKILL.md` |
| How is the database shaped? | `docs/design/schema.md` |
| Who can read/write what? | `docs/design/rls-policies.md` |
| Is this feature passing? | `docs/qa/test-cases.md` |
| How do we write chapters? | `.opencode/skills/rzl-defense/SKILL.md` |
