---
name: RZL Maps
description: Load when implementing nearby attractions, restaurants, and hotels (FR-24) or route guidance (FR-25), or when working with the places table, radius filtering, geolocation, or url_launcher handoff to the device maps app.
---

# RZL — Nearby Places and Route Guidance

Two features, both deliberately cheap. The budget rule is absolute: **no paid maps or places
API at runtime** (AD-08, AD-09, NG-B1, NG-B3).

| FR | Feature | Implementation |
|---|---|---|
| FR-24 | Nearby attractions / restaurants / hotels | Seeded `places` table + haversine radius filter, client-side |
| FR-25 | Route guidance | `url_launcher` handoff to the installed maps app |

## Why no live Places API

Google Places Nearby Search is roughly ₱950 per 1,000 calls. A demo week with five
researchers browsing, plus UAT with 30 participants, exceeds the ₱37,100 annual budget for a
single feature. The study area is fixed — Binangonan — so freshness is worth less than
accuracy and reliability. Seeded data is also *verifiable*: you can defend every row.

Say exactly this if asked. "We chose seeded data for cost and determinism" is a stronger
answer than a vague "we didn't have API access".

## FR-24 — Nearby places

Data lives in `places` (`docs/design/schema.md` §6), seeded by
`rzl-supabase/scripts/seed.sql`. 15–30 real establishments in Binangonan is enough; more
than that slows the seeded query for no benefit.

Query strategy — **filter client-side**. The dataset is small and fully cached:

```dart
const earthRadiusKm = 6371.0;

double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) * math.cos(_rad(lat2)) *
          math.sin(dLon / 2) * math.sin(dLon / 2);
  return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}
```

Rules:
- Default radius **3 km**, user-adjustable to 2 / 5 / 10.
- Group by `place_type`, cap at **10 per group**, sorted by distance.
- Show distance as `1.2 km` (one decimal under 10 km, whole numbers above).
- Sort within a group by distance, not by name — distance is the whole point.
- If `events.latitude` is null, hide the section entirely rather than showing an error.
- No group within radius → grouped empty state per type (TC-059).
- Cache the `places` result per event for the session; do not refetch on every rebuild.

`places` is read-only to all roles including staff — see `docs/design/roles.md`. Adding a
place is a migration or seed change, not an in-app admin feature.

## FR-25 — Route guidance

Do **not** embed a map. Hand off:

```dart
Future<void> openDirections({
  required double lat,
  required double lng,
  required String label,
}) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '&destination=$lat,$lng'
    '&destination_place_id=${Uri.encodeComponent(label)}',
  );

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    // TC-062: no maps app installed — degrade gracefully
    await Clipboard.setData(ClipboardData(text: '$label ($lat, $lng)'));
    showSnackBar('Address copied. Open your maps app to navigate.');
  }
}
```

Rules:
- `LaunchMode.externalApplication` — do not open an in-app webview.
- Always handle `false` from `launchUrl` (TC-062). A silently dead button is a failed UAT
  task.
- No API key, no billing, no SDK. If a key appears in `pubspec.yaml` for maps, the decision
  log was ignored.
- Label the button "Get directions", not "Navigate" — it is a handoff, and the paper calls
  it "basic route guidance".

## Optional: current-location distance

Not required by FR-24. If added:
- Request permission only when the user taps "near me", never at app launch.
- Handle denied and permanently-denied states with an explanation, not a silent no-op.
- This introduces a privacy statement obligation in Chapter 1 — weigh whether it earns its
  place. It probably does not; the event venue is already the reference point.

## Testing

| TC | What it verifies |
|---|---|
| TC-058 | Grouped nearby list appears for a Binangonan event |
| TC-059 | Empty state when nothing is within radius |
| TC-060 | **Zero runtime Places API calls** — verify by watching network traffic |
| TC-061 | Maps app opens with the correct destination |
| TC-062 | Graceful degradation with no maps app |

TC-060 is a budget test, and it is the one an IT-professional respondent would appreciate
most. Prove it by recording the network inspector during a nearby-tab visit.

## Anti-patterns

| Don't | Why |
|---|---|
| Google Places / Maps SDK in `pubspec.yaml` | Breaks the cost model; needs an AD row |
| Fetching `places` on every widget rebuild | Obvious lag on low-end devices |
| Storage/DB write access for `places` | Content is curated; keeps the surface small |
| Opening maps in a webview | Worse UX, extra dependency, still no benefit |
| Requesting location at launch | Permission prompt before any value = uninstall |
