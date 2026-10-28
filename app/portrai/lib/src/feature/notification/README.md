# Notification

The `notification` feature keeps this device's push notification subscriptions in step with the
app and opens the screen a tapped notification is about. Notifications are delivered on Android
and iOS; on the web the listener does nothing.

## Features

- `NotificationListenerWidget` wraps the router's content in the app's `builder` for the whole
  app run. Through `NotificationListenerBloc` it syncs when the signed-in session is restored at
  start, when the app returns to the foreground, the language changes, the device gets a new
  token, and a user signs in or out. Syncs run one after another.
- `SyncNotificationsUseCase` does nothing until the system notification permission is granted
  (read through the [`permission`](../permission/README.md) feature) and the device has a token.
  Then it subscribes the device to the portfolio updates in the app's language,
  `portfolio_updates_<language>`, and unsubscribes it from the other languages the app supports.
  When a user is signed in, it also registers the device as theirs.
- When a user signs out, `ResetDeviceTokenUseCase` deletes the device token, so the device gets a
  new one. The signed-out user's registration holds the old token, so their notifications no
  longer reach the device; the job openings function deletes a registration when a send reports
  its token as no longer registered. The next sync subscribes the new token to the portfolio
  updates again.
- A tapped notification opens its screen, also when it started the app:

  | `kind` in the message data | Opens                                                 |
  | -------------------------- | ----------------------------------------------------- |
  | `job_openings`             | `/job-openings`, which asks for sign-in first         |
  | `call_request`             | `/appointment-requests`, which asks for sign-in first |
  | `portfolio_update`         | The portfolio (`/`)                                   |
  | anything else              | Nothing                                               |

- The system does not show notifications while the app is in the foreground, so the listener
  shows their title and text in a snackbar.
- A `portfolio_update` message that is tapped, opens the app or arrives in the foreground also
  runs `UpdatePortfolioUseCase` of the [`portfolio`](../portfolio/README.md) feature, which
  refreshes the cached sections that changed.

`FirebaseNotificationRepository` is a singleton. Within one app run it subscribes again only
when the language changed or the token was deleted, and registers again only when the user,
token or language changed.

## Configuration

A registered device is stored at `users/{uid}/devices/{token}`, which only that signed-in user
may write (see the [Firestore rules](../../../../../../tool/firestore/README.md)):

| Field       | Type      | Content                                  |
| ----------- | --------- | ---------------------------------------- |
| `locale`    | string    | The app's language code, such as `es`    |
| `platform`  | string    | `ios` on iOS, `android` otherwise        |
| `updatedAt` | timestamp | Server time of the last write            |

The [functions](../../../../../../tool/functions/README.md) send portfolio updates to the
`portfolio_updates_<language>` topics and job alerts to the registered devices.

iOS needs the Push Notifications capability (`aps-environment` in `Runner.entitlements`), an
APNs key uploaded to the Firebase project, and provisioning profiles that include push. On
Android, notifications shown while the app is in the background use the white `ic_notification`
icon and the `notification_accent` color, both set in `AndroidManifest.xml`.

## Testing

```bash
flutter test test/src/feature/notification
```
