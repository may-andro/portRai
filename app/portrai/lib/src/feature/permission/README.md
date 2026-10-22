# Permission

The `permission` feature reads and requests system permissions and opens the app's page in the
device settings. Other features use it through its use cases instead of calling a permission
plugin themselves.

## Features

- `GetPermissionStatusUseCase` returns whether the user allows an `AppPermission`, without
  asking.
- `RequestPermissionUseCase` shows the system prompt when the permission is not decided yet and
  returns the resulting `AppPermissionStatus`. A granted permission, or one only the device
  settings can change, is returned without a prompt.
- `OpenPermissionSettingsUseCase` opens the app's page in the device settings.
- `IsPermissionSupportedUseCase` tells whether the platform has the permission, so other
  features can hide what depends on it.
- `NotificationPermissionCardWidget` is the Settings switch for notifications. It shows the
  system permission and reads it again when the card appears or the app returns to the
  foreground. Turning it on shows the system prompt while the system still offers one;
  otherwise, and when turning it off, it opens the app's page in the device settings, because an
  app cannot withdraw its own permission.

`AppPermissionStatus` has three values:

| Status | Meaning |
|---|---|
| `granted` | Allowed, including a provisional or limited grant. |
| `denied` | Not allowed yet; requesting shows the system prompt. |
| `permanentlyDenied` | The system no longer prompts, or a device policy restricts it. Only the device settings can allow it. |

## Getting started

Register `PermissionModuleConfigurator` before the features that use it, and import
`permission.dart`:

```dart
final statusEither = await requestPermissionUseCase(AppPermission.notifications);
if (statusEither.isRight && statusEither.right.isGranted) {
  // Use the permission.
}
```

## Configuration

`PermissionHandlerPermissionRepository` uses `permission_handler`. Each `AppPermission` needs its
platform setup:

| Permission | Android | iOS |
|---|---|---|
| `notifications` | `POST_NOTIFICATIONS` in `AndroidManifest.xml` | `PERMISSION_NOTIFICATIONS=1` in the `Podfile` `post_install` preprocessor definitions |

Notifications are supported on Android and iOS. `permission_handler` 13 requires compiling
against Android API 37, so the app uses 12.

To add a permission, add a value to `AppPermission`, map it in `AppPermissionMapper`, and add its
manifest entry, `Info.plist` usage description and `Podfile` definition as `permission_handler`
documents.

## Testing

```bash
flutter test test/src/feature/permission
```
