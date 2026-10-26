# Permission

The `permission` feature reads and requests system permissions and opens the app's page in the
device settings. Other features use it through its use cases instead of calling a permission
plugin themselves.

## Features

- `GetPermissionStatusUseCase` returns whether the user allows an `AppPermission`, without
  asking.
- `RequestPermissionUseCase` shows the system prompt when the status is `denied` and returns the
  resulting `AppPermissionStatus`. A `granted` or `permanentlyDenied` status is returned without a
  prompt.
- `OpenPermissionSettingsUseCase` opens the app's page in the device settings, and fails when it
  could not be opened.
- `IsPermissionSupportedUseCase` tells whether the platform has the permission, so other
  features can hide what depends on it.
- `NotificationPermissionCardWidget` is a settings card with a switch for the notification
  permission. It reads the system status when the card appears, when its route becomes visible
  again and when the app returns to the foreground; the switch is disabled until the status is
  known. Turning it on shows the system prompt while the status is `denied`. Otherwise, and when
  turning it off, it opens the app's page in the device settings, because an app cannot withdraw
  its own permission. A failure is shown as translated text below the description.

`AppPermissionStatus` has three values:

| Status              | Meaning                                                                                             |
| ------------------- | --------------------------------------------------------------------------------------------------- |
| `granted`           | Allowed, including a provisional or limited grant.                                                  |
| `denied`            | Not allowed yet; requesting shows the system prompt.                                                |
| `permanentlyDenied` | The system no longer prompts, or the permission is restricted. Only the device settings can allow it. |

## Getting started

Register `PermissionModuleConfigurator` in `module_configurators.dart`, and import
`permission.dart`:

```dart
final statusEither = await requestPermissionUseCase(AppPermission.notifications);
if (statusEither.isRight && statusEither.right.isGranted) {
  // Use the permission.
}
```

## Configuration

`PermissionHandlerPermissionRepository` uses `permission_handler`. `AppPermissionMapper` maps each
`AppPermission` to a `permission_handler` permission, and `AppPermissionStatusMapper` maps the
plugin's status to `AppPermissionStatus`. Each `AppPermission` needs its platform setup:

| Permission      | Supported on     | Android                                       | iOS                                                                                   |
| --------------- | ---------------- | --------------------------------------------- | ------------------------------------------------------------------------------------- |
| `notifications` | Android and iOS  | `POST_NOTIFICATIONS` in `AndroidManifest.xml` | `PERMISSION_NOTIFICATIONS=1` in the `Podfile` `post_install` preprocessor definitions |

To add a permission, add a value to `AppPermission`, map it in `AppPermissionMapper`, return its
platforms from `PermissionHandlerPermissionRepository.isSupported`, and add its manifest entry,
`Info.plist` usage description and `Podfile` definition as `permission_handler` documents.

## Testing

```bash
flutter test test/src/feature/permission
```
