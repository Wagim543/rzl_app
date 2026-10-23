---
name: RZL Smart Discovery
description: Load when implementing or debugging event summaries, semantic search, or personalised recommendations (FR-21, FR-22, FR-23), or when wiring embeddings, pgvector queries, or the Edge Function that calls an embedding or LLM provider.
---

# RZL — Smart Discovery (ML Layer)

Three features, one principle: **the demo must survive without the network.**

| FR | Feature | Cost rule |
|---|---|---|
| FR-21 | Auto event summary | Generated once on publish, cached in `events.summary` |
| FR-22 | Semantic search | Embedding per search; keyword fallback |
| FR-23 | Personalised recommendations | Computed query-side; no per-render LLM call |

Budget: `docs/spec/cost-model.md` — roughly ₱4,200/year for both embeddings and summaries.
That budget only holds if nothing is generated on read. AD-06 and AD-07 record this.

## Approach (locked)

`pgvector` in Supabase + a hosted embedding model via an Edge Function.
`text-embedding-3-small` → 1536 dimensions, matching `events.embedding vector(1536)`.

Rejected alternatives and why (use these when asked):

| Alternative | Why rejected |
|---|---|
| On-device TFLite embeddings | Offline novelty is high, but model size, Dart interop, and index rebuilds would consume the schedule |
| Elasticsearch / a vector DB | Extra infrastructure and a second bill for a corpus of a few hundred events |
| Full-text search only (`tsvector`) | Does not satisfy "understands meaning rather than exact keywords" (FR-22) |
| Per-read LLM summaries | Cost grows with traffic, not with content |

## Architecture

```
Flutter client
   │  (1) admin publishes event
   ▼
Edge Function: generate-event-content
   ├─► LLM: 1–3 sentence summary        → events.summary
   └─► Embedding model                  → events.embedding
   │
   │  (2) user searches
   ▼
Edge Function: search-events
   ├─► embed the query
   └─► rpc('match_events', { query_embedding })   → cosine similarity
        on failure ─► fall back to ilike keyword search
```

The Edge Function exists so the provider key never ships in the APK. A key in the client is
an immediate finding for the IT-professional evaluators.

## FR-21 — Event summary

Trigger: on transition to `status = 'published'`, and on republish after a material edit
(TC-068). Never on read (TC-051).

```ts
// supabase/functions/generate-event-content/index.ts
const res = await fetch('https://api.openai.com/v1/chat/completions', {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'gpt-4o-mini',
    temperature: 0.2,
    max_tokens: 120,
    messages: [
      {
        role: 'system',
        content:
          'Summarise a Philippine local government event in 1-3 sentences. ' +
          'Plain text only. Include what, when, and where. No marketing language. ' +
          'Under 60 words.',
      },
      { role: 'user', content: event.description },
    ],
  }),
});
```

Rules:
- `temperature: 0.2` — summaries must be stable, not creative.
- **Truncate input** to ~2,000 tokens. Long descriptions must not raise cost.
- **On any failure**, fall back to `description.substring(0, 200)` and still persist. Publish
  must never fail because the summariser is down (TC-050).
- Store `summary_generated_at` so staleness is visible and testable.
- Never let the LLM invent a date or venue. If the description lacks them, the prompt should
  omit them rather than guess — a hallucinated venue on a government event is a safety
  issue (ISO 25010 *Safety*, item 23).

## FR-22 — Semantic search

Query flow:
1. Embed the query via `search-events`.
2. `rpc('match_events', { query_embedding, match_threshold: 0.5, match_count: 20 })`.
3. Return rows; the existing `event_stats` view supplies counts.

The SQL function is in `rzl-supabase/SKILL.md`. Notes:

- `<=>` is cosine distance; similarity is `1 - distance`. Getting this backwards silently
  ranks the worst results first — verify with a query you know the answer to.
- `where status = 'published'` is mandatory inside the function. Do not rely on the caller
  (TC-054).
- Keep `match_threshold` around 0.5. Too high returns nothing, too low makes semantic search
  indistinguishable from browsing.
- Cache the query embedding for repeat searches within a session.

Fallback: on any embedding error, run `ilike '%query%'` on `title` and `description` and show
a subtle "showing keyword results" notice (TC-053). Never show an empty screen when keyword
results exist.

## FR-23 — Recommendations

Score a candidate event, then rank:

```
score = 0.55 · similarity(user_taste_vector, event.embedding)
      + 0.25 · interestMatch(event.category, profiles.interests)
      + 0.15 · proximityBonus(event.municipality, profiles.municipality, user_type)
      + 0.05 · recencyBonus(event.starts_at)
```

`user_taste_vector` = mean of the embeddings of events the user liked, bookmarked, or RSVP'd.
Compute it in a server-side function, not on every card render.

| Situation | Behaviour |
|---|---|
| No history (cold start) | Most popular upcoming events with `municipality_id = profiles.municipality_id`, ranked by `going_count` (TC-055) |
| `user_type = 'tourist'` | Proximity bonus uses distance to the *current filter* or the last viewed event, not home municipality (AD/FR-11) |
| No municipality set | Province-wide popular events |
| Guest | No recommendations at all — harder requirement: never call this for an unauthenticated user |
| Fewer than 5 candidates | Append upcoming events to fill the list rather than showing a short list |

Weights live in one constants file so Chapter 3 can cite them and the panel can ask why.
Never surface `draft`, `archived`, or ended events (TC-057).

## Testing these features

The ML TCs are TCs 049–057. Three of them exist specifically to catch the failure modes that
look fine in development:

| TC | Failure it catches |
|---|---|
| TC-051 | Accidental per-read generation (cost blowout, invisible until billing) |
| TC-053 | No fallback, so venue Wi-Fi failure kills the demo |
| TC-057 | Draft leakage through the recommendation query |

Add a fourth check yourself: run `match_events` with a deliberately wrong threshold and
confirm results actually change. A function that ignores its parameter passes a naive test.

## Explaining it honestly

Do not call this machine learning in the colloquial sense without qualification. Say:

> The system uses pretrained embedding models to represent event text as vectors, then
> applies cosine similarity and a weighted ranking function. No model is trained from
> scratch; the intelligence comes from the pretrained representation plus project-specific
> ranking weights.

That sentence is accurate, and it pre-empts "so where is your training data?".
