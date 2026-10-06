# Offline sync lifecycle

## Architecture inspected

`pubspec.yaml` already provided Flutter Riverpod 2, sqflite, Supabase Flutter,
connectivity_plus, uuid, and skeletonizer. No production dependency was added.
SQLite FFI and HTTP mocks are development-only dependencies for regression tests.

Before this change:

- `main.dart` initialized Supabase, then `AuthGate` selected login or `MainScreen`.
  Reading the sync provider registered a connectivity listener; it did not start
  a login/startup download or dispose the listener on logout.
- Riverpod providers called use cases and repositories. SQLite supplied expenses
  and categories; profile reads sometimes fell back to Supabase directly.
- Repositories launched independent background network calls. Downloads did not
  invalidate the UI. Category/profile pulls could replace unsent mutations.
- The sync service only pushed mutations and swallowed per-record failures.
  Category/profile pending queues were not scoped to the authenticated account.
- Editing an unsent insert turned it into an update. Acknowledgements could mark
  a newer edit clean. Deleting an unsent expense discarded its ID even if an
  upload had already started. Category creation discarded the local UUID remotely.
- Both category deletion choices moved expenses; local movement matched names,
  although the editor stored category IDs. Remote deletes were not reconciled.
- Home and All Expenses already used skeletonizer for list loading, local
  FutureProviders for data, and slivers for empty/error states. Pull-to-refresh
  re-read SQLite while separate background requests continued.

## Current flow

1. Each authenticated session owns a fresh Riverpod container. Logout disposes
   the sync service, retry timer, connectivity subscription, and cached UI state.
   SQLite retains each account's cache and unsent mutations for its next login.
2. Startup deliberately synchronizes. Resume, reconnection (including Ethernet
   and VPN), successful local writes, pull-to-refresh, and Retry use the same
   serialized service. Failed attempts retry with 5–300 second backoff while the
   app process is alive. Connectivity is a trigger, not proof of internet access.
3. The UI reads only SQLite. A persisted, per-account hydration marker distinguishes
   an undownloaded cache from a verified empty account. First-use providers wait
   for the initial attempt, preserving existing skeletons. A failed first download
   shows a specific explanation instead of a false empty state. Returning devices
   can read cached data immediately.
4. A local mutation and its pending status/revision are saved atomically. An edit
   to an unsent insert stays an insert. Deletions retain tombstones, even for
   inserts whose network outcome is unknown. Acknowledgements compare revision
   and status, preserving later edits and deletes made during a request.
5. Upload order is category inserts/edits, expense deletes/edits/inserts, category
   deletions, then profile updates. UUIDs are retained on retry. Insert retries are
   upserts; ordinary edits are PATCH requests so a remotely deleted record is not
   recreated. For previously synced rows, remote deletion wins over an offline edit.
6. Category deletion stores the chosen mode and fallback category ID. Moving
   expenses or marking them deleted happens in the same SQLite transaction as
   the category tombstone. Remote operations cover the account's entire category,
   including expenses not previously downloaded. Shared categories keep their
   `user_id = null` ownership and cannot be edited/deleted locally.
7. The Supabase adapter explicitly scopes every account request, includes shared
   categories, and fetches all pages in stable ID order. It continues after short
   pages so a server row cap cannot silently truncate hydration. A failed page
   never yields a partial snapshot for reconciliation.
8. One SQLite transaction merges the completed snapshot and hydration marker.
   Pending rows are preserved; clean rows missing remotely are removed. A failed
   upload does not prevent downloading other cloud data, but the attempt remains
   unsuccessful and the mutation remains pending.
9. The presentation coordinator refreshes Home, paginated All Expenses, categories,
   and profile before showing “All changes synced.” The small status row uses the
   existing theme, a thin progress line, offline/failure wording, and Retry.
   Existing skeletons and the date-filter behavior are preserved.

SQLite schema version 3 adds revision counters, category deletion metadata,
account indexes, and a hydration table. Upgrades from versions 1 and 2 preserve
existing data. Legacy category tombstones lacked mode information; recovery uses
move-to-Other, matching the previous implementation's actual behavior.

## Main files

- `lib/services/sync_service.dart`: serialized lifecycle, retries, state and disposal.
- `lib/services/sync_store.dart`: transactional mutations, revision checks, snapshots.
- `lib/services/sync_remote.dart`: the sole expense/category/profile Supabase adapter.
- `lib/services/sync_providers.dart`: account dependencies and UI refresh coordinator.
- `lib/utils/database_helper.dart`: v3 migration and concurrent database-open guard.
- `lib/features/auth/presentation/widgets/auth_gate.dart`: isolated account sessions.
- `lib/features/navigation/screens/main_screen.dart`: app-resume trigger.
- Expense/category/profile local sources, repositories and providers: local reads
  and writes routed through the shared sync lifecycle. The three old independent
  remote data sources were removed.
- `lib/widgets/sync_status.dart`, Home, All Expenses and Profile: sync feedback.
- `test/sync_test.dart`, `test/sync_providers_test.dart`, `test/sync_remote_test.dart`:
  real SQLite, provider, widget and mocked Supabase request regression tests.
- `pubspec.yaml` / `pubspec.lock`: development-only test dependencies.

## Validation and remaining limits

Run `flutter analyze` and `flutter test`. Tests cover hydration versus empty data,
offline recovery, returning-device reads, mutation races, restart durability,
account isolation, shared categories, both category-deletion choices, full snapshot
rollback, serialized requests, UI refresh before success, real provider wiring,
status/retry rendering, v1/v2 upgrades, and paginated Supabase request behavior.

No live account data or backend configuration was changed. This repository has no
Supabase schema migrations/RLS definitions, so live table constraints, category
foreign-key behavior, registration triggers, and row-level security still need a
staging two-device smoke test. Queries assume the existing `spendwise` schema and
columns already referenced by the app. Server RLS must enforce account ownership;
client filters are not a replacement for RLS. The request API is verified against
[Supabase's Dart documentation](https://supabase.com/docs/reference/dart/upsert).
Connectivity handling follows the package's warning that a connection type does
not establish internet availability ([connectivity_plus](https://pub.dev/packages/connectivity_plus)).

Conflict policy is last successful uploaded edit for concurrent edits, and deletion
wins for edits of previously synced records. There is no server change log, version
check, or deletion ledger. Consequently:

- A lost initial-insert response followed by a deletion on another device can still
  be ambiguous: retrying that insert may recreate it. Server-side mutation IDs and
  tombstones are needed to eliminate this distributed race completely.
- A paginated multi-table pull is not a server-wide transactional snapshot. Concurrent
  changes on another device converge on the next refresh. Full pulls favor correctness
  with the existing schema but cost more bandwidth as account history grows.
- Category reassignment/deletion uses multiple existing API calls, not a transactional
  RPC. Persisted intent makes retries safe, but another device can race these calls.
- A pending expense referencing a category deleted on another device may require the
  user to edit it and choose an available category. Permanent RLS/validation failures
  remain pending and show failure rather than silently dropping the local change.
- Earlier versions may already have overwritten pending data or created a server
  category with a different ID. The new code prevents these paths going forward;
  it cannot reconstruct data already lost by the previous implementation.
- Sync runs while the app is alive and on resume. This is not an OS background-job
  scheduler or a realtime subscription. First sign-in still requires authentication
  online; a previously authenticated device can continue using its local cache.

Suggested staging smoke test: existing account on an empty installation; restart
with cached data in airplane mode; offline add/edit/delete followed by reconnect;
category move/delete including records created on a second device; switch accounts
with pending changes; expire a session; test a network timeout and retry; verify
that a remote deletion disappears locally after refresh.
