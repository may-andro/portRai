# Portfolio

The `portfolio` feature shows the portfolio screen, built from the profile, expertise, projects,
services, experiences and testimonials features, and keeps their cached data up to date.

## Features

- `GetPortfolioUseCase` reads the six sections at once. The profile is required; a section that
  fails to load is shown empty.
- `PortfolioUpdateListenerWidget` sits above the router for the whole app run and checks for
  updates when the app starts and whenever it returns to the foreground. A tapped or received
  "Portfolio updated" notification checks too (see the
  [`notification`](../notification/README.md) feature).
- `UpdatePortfolioUseCase` reads when each section of the app's language last changed and
  refreshes only the sections that changed after the change they were last refreshed for. Each
  refresh loads the section first and then replaces its cache, so a section that fails to load
  keeps its cache and is tried again on the next check. Checks run one after another.
- `WatchRefreshedPortfolioSectionsUseCase` reports the sections each check refreshed. The
  portfolio screen reloads in place, and keeps what it shows when reloading fails.

Staging builds show the bundled portfolio, so they never check for updates.

## Configuration

The [functions](../../../../../../tool/functions/README.md) write the change times to
`portfolio_versions/{locale}`, which anyone may read (see the
[Firestore rules](../../../../../../tool/firestore/README.md)):

| Field          | Type      | Content                            |
| -------------- | --------- | ---------------------------------- |
| `profile`      | timestamp | When the profile last changed      |
| `experiences`  | timestamp | When the experiences last changed  |
| `expertise`    | timestamp | When the expertise last changed    |
| `projects`     | timestamp | When the projects last changed     |
| `services`     | timestamp | When the services last changed     |
| `testimonials` | timestamp | When the testimonials last changed |

A field is missing until its section first changes, and the app then keeps its cache. The change
time each section was last refreshed for is stored on the device in `portfolio_update_cache`, keyed
by `<language>/<section>`.

## Testing

```bash
flutter test test/src/feature/portfolio
```
