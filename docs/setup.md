# RZL — Local Setup

Get a new team member from clone to running app.

## 1. Prerequisites

| Tool | Version | Check |
|---|---|---|
| Flutter | 3.47.5 (stable) | `flutter --version` |
| Dart | 3.13.4 | `dart --version` |
| Android SDK | API 24+ | `flutter doctor` |
| Supabase CLI | latest | `supabase --version` |
| Git | any | `git --version` |

`flutter doctor -v` must show no red entries for Android toolchain before you continue.

## 2. Clone and install

```bash
git clone <repo-url> rzl_app
cd rzl_app
flutter pub get
```

## 3. Environment file

Configuration is injected at build time. **Never commit values.**

```bash
cp env.example.json env.json
```

Fill it in:

```json
{
  "SUPABASE_URL": "https://yfsguhnsdciedbcqwlsq.supabase.co",
  "SUPABASE_ANON_KEY": "<anon key from the Supabase dashboard>",
  "EMBEDDING_FN_URL": "https://<project>.supabase.co/functions/v1"
}
```

`env.json` is gitignored. Ask the team lead for the dev project's keys — do not use the
production project for development.

> The anon key is designed to be public. It is still not committed, because committing keys
> trains the wrong habit and makes environment switching painful.

## 4. Run

```bash
flutter run --dart-define-from-file=env.json
```

Every `flutter run` and `flutter build` needs that flag. Without it, `Env.assertConfigured()`
fails fast with a message naming the missing values — which is better than a blank screen.

Add a VS Code launch config so you cannot forget:

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "rzl (dev)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--dart-define-from-file=env.json"]
    }
  ]
}
```

## 5. Database

Migrations and seed data live in `supabase/migrations/` and `supabase/seed.sql`, and
`supabase/config.toml` wires the seed into `db reset`. Never make schema changes in the
dashboard: they cannot be reproduced on another machine and do not survive a reset.

### Local (recommended for development)

Requires Docker.

```bash
supabase start
supabase db reset                    # migrations, then seed.sql — automatic
```

Local Studio runs at `http://localhost:54323`. Point `env.json` at the `API URL` and
`anon key` printed by `supabase start`.

### Remote (the shared dev project)

```bash
supabase login                                  # once per machine, opens a browser
supabase link --project-ref <project-ref>       # asks for the database password
supabase db push                                # applies supabase/migrations/*
```

`db push` applies migrations only — it does not load demo data. To get the seeded events,
either insert them by hand or, on a development project **with no real data**, run:

```bash
supabase db reset --linked           # DESTRUCTIVE: drops and rebuilds the database
```

Confirm the guest read path after pushing, because a missing `to anon` grant looks like an
empty app rather than an error:

```sql
set role anon;
select count(*) from events;         -- must be greater than zero
reset role;
```

## 6. Verify the setup

Run these four checks before claiming the environment works:

```bash
flutter analyze                 # no issues
flutter test                    # tests pass
dart format --output=none --set-exit-if-changed lib test
flutter build apk --debug --dart-define-from-file=env.json
```

Then launch and confirm the **guest feed** loads real events. If it does not, check RLS
before blaming the client — see `docs/design/rls-policies.md` §4.

## 7. Common problems

| Symptom | Cause | Fix |
|---|---|---|
| `Missing --dart-define values` | Forgot the flag | Add `--dart-define-from-file=env.json` |
| Feed empty but admin sees events | Missing `to anon` on the `events` select policy | See `rls-policies.md` Shape A |
| `row level security` violation | Policy missing for that operation | Check the permission matrix in `roles.md` |
| Session lost on restart | Not initialising Supabase before `runApp` | `main.dart` must `await initSupabase()` |
| `Execution failed for task ':app:...'` | Stale build | `flutter clean && flutter pub get` |
| Gradle cannot find keystore | `key.properties` missing | Only needed for release builds — see `rzl-release` |
| Emoji/garbled text in a script | PowerShell 5 encoding | Scripts are ASCII-only by design; do not add emoji to `*.ps1` |

## 8. Before your first commit

- [ ] `env.json` exists and is **not** staged (`git status` should not list it)
- [ ] `flutter analyze` clean
- [ ] `flutter run` shows the guest feed
- [ ] You can log in, bookmark an event, and log out back to a working feed
- [ ] You have read `AGENTS.md`
