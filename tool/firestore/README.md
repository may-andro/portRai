# Firestore

Security rules for the project's Cloud Firestore database, with tests that run them on the
Firestore emulator.

## Features

- Gives clients only the access the app needs and denies everything else.
- Tests every rule with allowed and refused requests on the emulator, locally and in CI.
- Deploys the rules alone, without touching Hosting, Functions or indexes.

## Rules

| Path                                                                                  | Client access                                                     |
| ------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `profile`, `experiences`, `expertise`, `projects`, `services`, `testimonials` `/{id}` | Anyone can read a document by ID. Listing and writing are refused |
| `app_config/{id}`                                                                     | Anyone can read a document by ID. Listing and writing are refused |
| `users/{uid}`                                                                         | The signed-in user can read it and write only its `jobSearch` map |
| `users/{uid}/job_openings/{id}`                                                       | The signed-in user can list and read them. Writing is refused     |
| Any other path                                                                        | Refused                                                           |

`jobSearch` may hold only a boolean `enabled` and an `updatedAt` equal to the server time of the
write, which `FieldValue.serverTimestamp()` produces. Users cannot delete their document.

Server code authenticates with a service account, and security rules do not apply to it. The
Cloud Functions in [`tool/functions`](../functions/README.md) and the
[`firestore_export_import`](../firestore_export_import/README.md) tool keep writing portfolio
content and job openings.

## Getting Started

### Requirements

- Node.js 22. The `volta` field in `package.json` pins it for Volta users.
- Java 11 or later, for the Firestore emulator.
- For deploying, a Firebase CLI login with access to the project. `.firebaserc` sets the project.

### Development

From `tool/firestore`:

```bash
npm ci            # install from package-lock.json
npm run check     # format check, type check and rules tests
npm test          # rules tests only, on the Firestore emulator
npm run format    # format with Prettier
```

`npm test` starts the emulator with a demo project ID, so it never reaches a real project. From
the workspace root, `melos run firestore_rules_check` runs `npm ci` and `npm run check`.

When a client starts reading or writing a new path, add a rule for it and tests for both allowed
and refused requests. Without a rule, the path stays refused.

## Deployment

```bash
melos run deploy_firestore_rules
```

This runs the checks and then `firebase deploy --only firestore:rules` with the CLI version from
`package-lock.json`. The deployed rules replace the ones in the Firebase console.
