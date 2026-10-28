# Portfolio

The `portfolio` feature shows the portfolio screen, built from the profile, expertise, projects,
services, experiences and testimonials features, and keeps their cached data up to date.

## Features

- `PortfolioModuleRoute.portfolio` (`/`) shows `PortfolioScreen`. It starts with the intro
  section, followed by the other sections in an order that depends on the visitor's role
  (developer, recruiter, or other and unknown). Empty sections are left out. For a recruiter,
  a section after About offers booking a call when the
  [`call_booking`](../call_booking/README.md) feature is on, which is read once on loading. A
  pinned header has a tab per section on desktop, and a drawer and Settings button on mobile and
  tablet.
- When an assistant is available, a floating button opens the remote assistant, or the
  on-device assistant when only that one is available.
- `GetPortfolioUseCase` reads the six sections concurrently. The profile is required; a section
  that fails to load is shown empty.
- `PortfolioUpdateListenerWidget` wraps the router's content in the app's `builder` for the whole
  app run and checks for updates when the app starts and whenever it returns to the foreground. A
  tapped or received "Portfolio updated" notification checks too (see the
  [`notification`](../notification/README.md) feature).
- `UpdatePortfolioUseCase` reads when each section of the app's language last changed and
  refreshes only the sections that changed after the change they were last refreshed for. Each
  refresh loads the section first and then replaces its cache, so a section that fails to load
  keeps its cache and is tried again on the next check. The use case is a singleton, so checks
  run one after another.
- `WatchRefreshedPortfolioSectionsUseCase` reports the sections each check refreshed. The
  portfolio screen reloads in place, and keeps what it shows when reloading fails.

Staging builds show the bundled portfolio, so their checks read no change times and refresh
nothing.

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

A missing document or field means that section has not changed, and the app keeps its cache.
`PortfolioUpdateCache` stores on the device, under the `portfolio_update_cache` key, the change
time each section was last refreshed for, keyed by `<language>/<section>`.

## Testing

```bash
flutter test test/src/feature/portfolio
```
