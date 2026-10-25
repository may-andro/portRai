# Notification

The `notification` feature keeps this device's push notifications in step with the app and
opens the screen a tapped notification is about. It runs on Android and iOS; on the web it does
nothing.

## Features

- `NotificationListenerWidget` sits above the router for the whole app run. It syncs when the
  app starts, returns to the foreground, changes language, gets a new device token, and when a
  user signs in or out.
- `SyncNotificationsUseCase` does nothing until notifications are allowed (the Settings switch
  of the [`permission`](../permission/README.md) feature). Then it subscribes the device to the
  portfolio updates in the app's language, `portfolio_updates_<language>`, and unsubscribes it
  from the other languages. When a user is signed in, it also registers the device as theirs.
- When a user signs out, `ResetDeviceTokenUseCase` replaces the device token. The signed-out
  user's registration holds the old token, so their notifications no longer reach the device,
  and the server deletes the registration the next time a send to it fails. The next sync
  subscribes the new token to the portfolio updates again.
- A tapped notification opens its screen, also when it started the app:

  | `kind` in the message data | Opens                                         |
  | -------------------------- | --------------------------------------------- |
  | `job_openings`             | `/job-openings`, which asks for sign-in first |
  | `portfolio_update`         | The portfolio                                 |
  | anything else              | Nothing                                       |

- The system does not show notifications while the app is in the foreground, so the listener
  shows their title and text in a snackbar.

The repository subscribes and registers again only when the language, user or token changed
since the last time in the same run.

## Configuration

A registered device is stored at `users/{uid}/devices/{token}`, which only the signed-in user
may write (see the [Firestore rules](../../../../../../tool/firestore/README.md)):

| Field       | Type      | Content                       |
| ----------- | --------- | ----------------------------- |
| `locale`    | string    | The app's language            |
| `platform`  | string    | `android` or `ios`            |
| `updatedAt` | timestamp | Server time of the last write |

The [functions](../../../../../../tool/functions/README.md) send to these devices and topics.
iOS needs the Push Notifications capability (`aps-environment` in `Runner.entitlements`), an
APNs key uploaded to the Firebase project, and provisioning profiles that include push.

## Testing

```bash
flutter test test/src/feature/notification
```
