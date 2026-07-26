# Peconote Project Guidelines

Peconote is a Flutter mobile application for automatic personal finance tracking.
The app targets Android and iOS, uses a Django REST Framework backend, and is
designed as a long-term product rather than a short-lived prototype.

This document defines the expected architecture, development rules, and project
decisions that should guide future implementation.

## Product Scope

The app focuses on personal finance accounting.

Core entities:

- `User`
- `Transaction`
- `Category`
- `Rule`
- `Account`
- `Project`

Planned capabilities:

- User authentication.
- Automatic transaction import from Ukrainian bank APIs.
- Manual transaction creation.
- Category management with fixed and user-created categories.
- Category icons.
- Offline transaction creation with later synchronization.
- Cross-device synchronization.
- Analytics and reports.
- Push notifications.
- Ukrainian and English localization.
- Security features such as secure token storage, biometric/PIN protection, and
  protection of sensitive financial data.

Out of initial scope:

- Multi-currency support.
- Paid subscriptions.
- Advanced budget management.
- Advanced recurring payment logic.

These features may be added later, so the architecture should not block them.

## Architecture

Use Clean Architecture with a feature-based folder structure.

Recommended structure:

```text
lib/
  app/
    bootstrap/
    localization/
    router/
    theme/
  core/
    auth/
    errors/
    network/
    security/
    storage/
    sync/
    utils/
  features/
    auth/
      application/
      data/
      domain/
      presentation/
    onboarding/
      application/
      data/
      domain/
      presentation/
    transactions/
      application/
      data/
      domain/
      presentation/
    categories/
      application/
      data/
      domain/
      presentation/
    accounts/
      application/
      data/
      domain/
      presentation/
    rules/
      application/
      data/
      domain/
      presentation/
    projects/
      application/
      data/
      domain/
      presentation/
    analytics/
      application/
      data/
      domain/
      presentation/
```

Each feature should follow this structure:

```text
domain/
  entities/
  repositories/
  use_cases/

data/
  models/
  mappers/
  remote/
  local/
  repositories/

application/
  providers/
  controllers/
  state/

presentation/
  screens/
  widgets/
```

### Layer Responsibilities

`presentation`:

- Flutter screens and widgets.
- UI state rendering.
- User interaction handling.
- No direct API or database access.

`application`:

- State management.
- Screen controllers.
- Calls to use cases.
- Async state handling.

`domain`:

- Business entities.
- Repository interfaces.
- Use cases.
- Business rules.
- No Flutter, HTTP, database, or package-specific implementation details.

`data`:

- API clients.
- Local database sources.
- DTOs and persistence models.
- Repository implementations.
- Mapping between API/local models and domain entities.

`core`:

- Shared infrastructure used by multiple features.
- Network client.
- Secure storage.
- Sync engine.
- Error handling.
- Auth token management.
- App-wide utilities.

## State Management

Use Riverpod as the default state management and dependency injection solution.

Recommended package:

```yaml
flutter_riverpod
```

Rules:

- UI should depend on providers/controllers, not repositories directly.
- Repositories should be injected through providers.
- Use cases should be small and focused.
- Keep business rules out of widgets.
- Avoid global mutable state.

## Navigation

Use `go_router` for app routing.

Recommended package:

```yaml
go_router
```

Navigation must support:

- Splash/startup flow.
- Onboarding only on first launch.
- Authentication guard.
- Redirect to login when the user is not authenticated.
- Redirect to the main app when the user is authenticated.
- Future deep links.

Startup flow:

```text
App starts
  -> load app settings
  -> check whether onboarding was completed
  -> check access/refresh token state
  -> if first launch: onboarding
  -> else if unauthenticated: auth
  -> else: main app
```

Avoid placing navigation decisions directly inside random widgets when the logic
belongs to app startup, authentication, or route guards.

## Backend

The backend is Django REST Framework.

The Flutter app should communicate with the backend through a dedicated network
layer. UI code must not call HTTP clients directly.

Recommended package:

```yaml
dio
```

Expected backend conventions:

- Use stable IDs for all synchronized entities.
- Include `created_at`, `updated_at`, and `deleted_at` where synchronization is
  needed.
- Prefer soft delete for synchronized entities.
- Support fetching changes after a timestamp where possible.
- Keep API responses predictable and versionable.

Example fields for synchronized objects:

```json
{
  "id": "server-id",
  "created_at": "2026-07-15T10:00:00Z",
  "updated_at": "2026-07-15T10:00:00Z",
  "deleted_at": null
}
```

## Authentication

Anonymous mode is not supported.

The app must support user authentication through the DRF backend.

Rules:

- Store access and refresh tokens only in secure storage.
- Do not store tokens in plain shared preferences.
- Use a network interceptor for attaching access tokens.
- Use a refresh-token flow when access tokens expire.
- Log out the user when refresh fails.
- Do not log tokens or sensitive user data.

Recommended package:

```yaml
flutter_secure_storage
```

## Offline Support and Synchronization

The app must support creating transactions while offline.

When the user creates a transaction without internet:

1. Save the transaction locally.
2. Mark it with a pending sync status.
3. Add a sync operation to the local sync queue.
4. Retry synchronization when internet is available.
5. Send the transaction to the backend API.
6. Replace or link the local ID with the server ID returned by the backend.
7. Mark the local transaction as synced.

Synchronized local records should include technical sync fields:

```text
localId
serverId
syncStatus
createdAt
updatedAt
deletedAt
lastSyncedAt
```

Possible sync statuses:

```text
synced
pendingCreate
pendingUpdate
pendingDelete
failed
```

Use a dedicated `core/sync` module for sync logic. Do not duplicate sync logic
inside screens or feature controllers.

The sync module should handle:

- Pending local creates.
- Pending local updates.
- Pending local deletes.
- Retry strategy.
- Connectivity changes.
- API failures.
- Conflict rules.

Default conflict strategy for early versions:

```text
latest updatedAt wins
```

This can be improved later if conflict resolution becomes more complex.

## Local Storage

The app needs local storage for:

- Offline-created transactions.
- Sync queue.
- Cached user data.
- Cached categories.
- Cached accounts.
- App settings such as onboarding completion.
- Possibly cached analytics inputs.

For financial data, prefer a structured local database.

Recommended option:

```yaml
drift
```

Reason:

- Good fit for financial data.
- SQL queries are useful for reports and analytics.
- Works well with structured relations such as transactions, accounts,
  categories, projects, and sync operations.

App settings may use a simpler key-value store, but sensitive values must go to
secure storage.

## Security

Financial data is sensitive. Security must be treated as a core requirement.

Required practices:

- Store tokens in secure storage.
- Use biometric/PIN protection where applicable.
- Protect access to the app after backgrounding.
- Avoid logging financial payloads.
- Avoid logging bank API responses.
- Avoid logging tokens.
- Use HTTPS only for production API calls.
- Keep secrets out of the repository.

Recommended packages:

```yaml
flutter_secure_storage
local_auth
```

Local database encryption should be evaluated before storing significant
financial data offline.

## Localization

The app should support Ukrainian and English.

Rules:

- Do not hardcode user-facing text in widgets once localization is introduced.
- Use Flutter localization tooling.
- Keep translation keys stable and descriptive.
- Add new strings to both Ukrainian and English translation files.

Recommended setup:

```yaml
flutter_localizations:
  sdk: flutter
intl
```

## Categories

Categories are required.

Category rules:

- The app should provide fixed default categories.
- Users should be able to create custom categories.
- Categories should support icons.
- Categories should be syncable.
- Categories should not be deleted in a way that breaks existing transactions.

Preferred behavior when deleting a category:

- Use soft delete.
- Keep old transactions readable.
- Prevent assigning new transactions to deleted categories.

## Rules

Rules are used for automatic categorization, especially for bank-imported
transactions.

Example rule inputs:

- Merchant name.
- Transaction description.
- Account.
- Amount range.
- Direction: income or expense.

Example rule output:

- Category.
- Project.

Rules should live in the domain layer as business logic and be backed by local
and remote persistence.

## Transactions

Transactions are central to the app.

Expected fields may include:

```text
id/serverId
localId
accountId
categoryId
projectId
amount
currency
type
description
merchantName
occurredAt
createdAt
updatedAt
deletedAt
syncStatus
source
```

Possible transaction sources:

```text
manual
bankImport
sync
```

For now, the app targets Ukrainian banks and UAH cards, so multi-currency can be
postponed. Still, using a `currency` field with default `UAH` is acceptable if
it does not add unnecessary complexity.

## Analytics

Analytics are planned and should be considered when designing data models.

Do not calculate long-term analytics directly in widgets.

Analytics should use:

- Use cases.
- Repository queries.
- Dedicated view models/state objects.

Examples:

- Spending by category.
- Spending by account.
- Spending by project.
- Monthly income/expense summary.
- Trend charts.

## Push Notifications

Push notifications are planned.

Possible notification types:

- Sync failures.
- Budget alerts in the future.
- Bank connection issues.
- Reminders.

Notification logic should not be mixed into UI screens. Use a dedicated service
inside `core` or a dedicated notifications feature when it grows.

## Testing

Initial testing expectations are minimal, but important business logic should be
testable.

Prioritize tests for:

- Auth state decisions.
- Sync queue behavior.
- Transaction creation.
- Transaction mapping.
- Category rules.
- Route guards.

Keep domain use cases independent from Flutter so they can be unit-tested
without widget tests.

## Coding Rules

- Keep widgets focused on UI.
- Keep business rules out of widgets.
- Keep API models separate from domain entities.
- Use mappers between data models and domain entities.
- Prefer explicit names over vague names.
- Avoid large files that mix several responsibilities.
- Avoid direct `Navigator` calls for app-level flow once `go_router` is added.
- Avoid direct HTTP calls from screens.
- Avoid direct local database calls from screens.
- Keep shared UI components in a clear widgets/design-system location.
- Add comments only when they explain non-obvious behavior.

## Recommended Dependencies

Likely dependencies for the architecture:

```yaml
dependencies:
  flutter_riverpod:
  go_router:
  dio:
  drift:
  sqlite3_flutter_libs:
  path_provider:
  path:
  flutter_secure_storage:
  local_auth:
  connectivity_plus:
  intl:
```

Exact versions should be selected when the implementation starts.

## Current Implementation Direction

The current app has early UI screens for splash, onboarding, authentication, and
initial choice flows.

Next recommended steps:

1. Introduce the Clean Architecture folder structure.
2. Move existing screens and widgets into feature/app/core folders.
3. Add `go_router` and centralize routing.
4. Add Riverpod.
5. Add startup state handling for onboarding and authentication.
6. Prepare API and secure storage abstractions.
7. Prepare local database and sync queue abstractions.
8. Implement real auth integration with the DRF backend.
9. Implement offline manual transaction creation.

## Decision Log

Current decisions:

- Flutter app for Android and iOS.
- Backend: Django REST Framework.
- No anonymous mode.
- Authorization is required.
- Offline creation of transactions is required.
- Cross-device synchronization is required.
- Clean Architecture is required.
- Long-term product architecture is preferred over quick prototype structure.
- Initial languages: English and Ukrainian.
- Initial currency focus: UAH.
- Initial theme: light theme only.
- Onboarding should be shown only on first launch.

