# RZL — Cost Model

Must reconcile with the Chapter 5 cost–benefit analysis. **Do not add a paid dependency
without updating this file and telling the team.**

| | Amount |
|---|---|
| Initial cost | ₱147,415 |
| Recurring cost | ₱37,100 / year |

## Where the money actually goes

| Item | Type | Monthly | Yearly | Notes |
|---|---|---|---|---|
| Supabase Pro | recurring | ~₱1,400 | ~₱16,800 | Postgres, Auth, Storage, Realtime, pgvector, 100 GB egress |
| Domain (`rzl.app` or similar) | recurring | ~₱75 | ~₱900 | Admin/landing only |
| Play Store developer account | one-time | — | ~₱4,500 | $25 once; amortise in initial cost |
| Embedding API (semantic search) | recurring | ~₱200 | ~₱2,400 | `text-embedding-3-small`, one call per event publish + per search |
| LLM summaries | recurring | ~₱150 | ~₱1,800 | One call per publish, cached; ~₱0.05/event |
| Device testing / misc | one-time | — | ~₱15,000 | Hands-on devices if not owned |
| Figma | recurring | ₱0 | ₱0 | Free tier is sufficient |
| Riverpod, go_router, freezed, url_launcher | recurring | ₱0 | ₱0 | Open source |
| Google Maps handoff via `url_launcher` | recurring | ₱0 | ₱0 | No SDK, no key, no billing |
| OSM / seeded `places` table | recurring | ₱0 | ₱0 | Static seed data |

**Recurring subtotal ≈ ₱21,900.** The published ₱37,100 leaves roughly ₱15,000/yr of
headroom — keep it that way. That headroom is what absorbs a contest/defense year, a
domain renewal, or a brief paid API spike.

## Hard rules

1. **No Google Places Nearby Search at runtime.** ~₱950 per 1,000 calls will exceed the
   annual budget during a demo week. `places` is seeded (see `docs/design/schema.md`).
2. **No per-read LLM calls.** Summaries are generated once on publish and cached.
3. **Embeddings are generated on write and on search only**, never on feed render.
4. **No in-app maps SDK.** Route guidance is a `url_launcher` handoff.
5. If a new cost appears, it must be approved and this table updated *before* the code lands.

## Panel questions this file answers

- "Where does ₱37,100 a year go?" → the table above.
- "Why no Google Maps in the app?" → NG-B3, zero marginal cost, and the requirement is
  "basic route guidance".
- "How does this scale to all of Rizal?" → Supabase Pro covers it; the cost driver is
  egress, not compute.
