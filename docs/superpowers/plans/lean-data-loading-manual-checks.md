# Lean data loading — on-device checks

Run a **debug** build (`flutter run -t lib/main_development.dart`). Every API call prints as
`[api #N] GET /path query…`. From the debug console you can call
`RequestStatsInterceptor.instance.reset()` before a flow and `.report()` after it.
Highest risk first. Fill in the Before/After counts in `lean-data-loading-baseline.md`.

1. **Receipt upload** — Expenses → upload a receipt to an entry. The receipt appears right away and the log shows `GET /allocation-entries`. Tap the header Refresh: a GET is logged every time.
2. **Approve on a slow network** — Network Link Conditioner "Very Bad Network". Open a requisition, pull to refresh, approve straight away. After the sheet closes, the status reads Approved both on the details screen and in Approvals → Closed.
3. **Offline history scroll** — Load Past missions online, switch to airplane mode, scroll to the bottom. The list stays visible (no full-screen error). Repeat for Past events and Closed requisitions.
4. **Sign out, sign in as another leader** — Sign out and sign in as a different leader. Members, Missions and Approvals log requests and show only that leader's data. *(Known gap: if a list was still loading at the moment of sign-out, rows from the first leader can briefly reappear — see "Known gaps".)*
5. **Save on a timed-out network** — On a throttled network add an expense and let it time out. The log shows one `POST /allocation-entries`; after refresh there is no duplicate.
6. **Pull-to-refresh always fetches** — On every pull-to-refresh screen, pull right after it loads; a GET is logged every time. Screens: Missions (3 tabs), Events (2), Approvals (3), Mission details (People, Sessions, Feedback), Requisitions under an event, Requisition details, School past missions.
7. **History paging, newest first** — Past missions: one `GET /missions … limit=30&sort=-start_date`, newest at the top; scrolling appends older ones; the end shows no stuck spinner. Leave, return within 5 minutes, scroll again: no stuck spinner, no missing block. Same for Past events (`-start_date`) and Closed requisitions (`-created_at`).
8. **Create or approve while a list is fresh** — Add a member and a school: each appears with no GET after the POST. Create a mission while on the Past tab, switch to Upcoming: it shows. Approve a requisition, go back, open Closed: it is at the top. Request review from Drafts: it leaves Drafts.
9. **Mission details tabs** — Open mission A, view People and Feedback; go back, open mission B and swipe to People: no flash of A's people. Each tab shows its data; no sub-list request is logged until the tab is opened.
10. **Mission details on open** — One `GET /missions/{ulid}` with full includes; contacts and finance show; the Refresh action logs a GET. Reopening the same mission shows it immediately (no full-screen spinner). On a slow network, note how long approve/reject stay disabled behind the small spinner.
11. **Contacts** — Open a school: contacts show with no `GET /school-contacts`. Add/edit a contact from school details and from the Contacts page: the sheet closes, a success message shows, the contact appears after the school refetch. Open another contact sheet afterwards: it is not stuck loading.
12. **Expenses figures** — Opening logs one `GET /accounting-events/{ulid}?include=refunds,latestRefund`; `GET /allocation-entries` has no refunds include. Add a token: totals update. Add a refund: refunds update. Cancel the refund sheet: nothing is logged. Offline: credits/debits show; the refund figure says it needs a connection.
13. **Freshness** — Members → back → Members within 5 minutes: 0 requests; after 5 minutes: 1. Airplane mode on a never-opened list, then back online and reopen: it fetches. Open the member form twice: lookups load once, then 0 for 12 hours.
14. **Lazy tabs** — Missions: tap Past, Schools, Upcoming: one GET per tab on first visit, none on returning to Upcoming, never two identical lines per tap. Approvals opens with one `GET /requisitions`; Closed and Drafts load only when tapped.
15. **Request sharing** — Open the member form twice quickly: no duplicate concurrent lookup GETs.
16. **Notification token** — Cold start twice: `update-profile` is logged only the first time. Sign out and in: logged again.
17. **Create activity** — Events → create an activity: the sheet closes after saving.
18. **Finance offline for never-opened missions** — Offline, open a mission only ever seen in the list: Finance shows "unavailable" (expected — open each mission once online).

## Known gaps (not fixed)

- **Approver picker lists every member.** The server chooses executive-committee members by user role (a tenant setting the app never receives), so the app can't filter its cache. Needs an API field (e.g. `is_executive_committee_member` on members) or caching the IDs the server returns.
- **Sign-out race.** A list refresh that started before sign-out can still save the previous leader's rows into the cache after it is wiped. Fix: in `ResourceCubit`, compare `FetchLedger.instance.epoch` with the value captured at the start before every `persistEntities` (in `_refreshAllInBackground`, `loadNextPage`, `loadMore`), not only before `markFetched`.
- `HiveService.clearAllTables()` stops at the first box that fails to clear; wrap each box in try/catch.
- After a failed reload following a money change, the expenses header still shows the last totals without a "may be out of date" marker.
- A failed next page quietly ends the history list (no "couldn't load more" hint).
