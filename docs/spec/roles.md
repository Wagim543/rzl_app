# RZL — Roles and Permissions

Five roles. Every screen, RLS policy, and test case must name the role(s) it serves.

| Role | Auth | Description | Can | Cannot |
|---|---|---|---|---|
| `guest` | No account | Anyone opening the app | Browse and search published events, view event detail, filter by municipality / barangay / category / schedule, read published announcements, view engagement counts | Like, comment, review, bookmark, RSVP, receive notifications, personalize |
| `resident` | Authenticated | Rizal resident | Everything a guest can do, plus bookmark, RSVP ("I'm Going"), like, comment, review, save to device calendar, notifications, dark mode, personalised recommendations | Create or edit events |
| `tourist` | Authenticated | Visitor to Rizal | Same as `resident`, with recommendations weighted toward `nearby` rather than `home municipality` | Create or edit events |
| `admin` | Authenticated + `role = 'admin'` | Municipal/barangay event organizer | Full CRUD on events, publish/cancel events, publish announcements, upload images, view engagement report logs, moderate comments/reviews | Manage other admins, change system settings |
| `lgu_personnel` | Authenticated + `role in ('admin','lgu')` | LGU staff (UAT participants) | Same as `admin`. Treated as one permission tier with `admin` in the permission matrix, distinguished only for reporting | Manage other admins |

## Permission matrix

`R` = read, `W` = write, `O` = own rows only, `—` = denied.

| Resource | guest | resident / tourist | admin / lgu |
|---|---|---|---|
| `events` (published) | R | R | R |
| `events` (draft / archived) | — | — | R W |
| `categories`, `municipalities`, `barangays` | R | R | R |
| `places` (attractions, restaurants, hotels) | R | R | R |
| `announcements` (published) | R | R | R W |
| `profiles` | — | R W O | R W O |
| `bookmarks` | — | R W O | R W O |
| `attendance` | — | R W O | R |
| `likes` | — | R W O | R |
| `comments` | R | R W O | R W (moderate) |
| `reviews` | R | R W O | R W (moderate) |
| `notifications` | — | R W O | — |
| `event_views` / metrics | — | W (insert only) | R |
| Event images (storage bucket) | R | R | R W |

## Rules that fall out of this table

1. **Guests always read `events`.** A guest with an empty feed is a P0 bug, not a permissions
   edge case. It is the first thing a panel will test.
2. **`resident` and `tourist` are the same permission tier**, differing only in how
   recommendations are weighted. Do not build two auth paths for them.
3. **`admin` and `lgu_personnel` share one tier.** Distinguish with `role` for reporting only.
4. **Moderation is soft delete.** `comments.is_hidden` / `reviews.is_hidden`, never `DELETE`
   — engagement report logs must remain intact.
5. Every RLS policy maps to a row in this matrix. If a policy cannot be justified by this
   table, it is wrong.
