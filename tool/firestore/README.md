# Firestore

Security rules for the project's Cloud Firestore database, with tests that run them on the
Firestore emulator.

## Features

- Gives clients read access to public portfolio content and to each signed-in user's own data,
  and refuses every other request.
- Tests the rules with allowed and refused requests on the Firestore emulator.
- Deploys the rules alone, without touching Hosting, Functions or indexes.

## Rules

The rules live in [`firestore.rules`](firestore.rules).

| Path                                                                                      | Client access                                                                           |
| ----------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `profile`, `experiences`, `expertise`, `projects`, `services`, `testimonials` `/{locale}` | Anyone can read a document by ID. Listing and writing are refused                       |
| `app_config/{configId}`                                                                   | Anyone can read a document by ID. Listing and writing are refused                       |
| `portfolio_versions/{locale}`                                                             | Anyone can read a document by ID. Listing and writing are refused                       |
| `users/{userId}`                                                                          | The signed-in user can read it and create or update only its `jobSearch` map            |
| `users/{userId}/job_openings/{jobOpeningId}`                                              | The signed-in user can list and read them. Writing is refused                           |
| `users/{userId}/devices/{token}`                                                          | The signed-in user can create, update, read and delete one by token. Listing is refused |
| Any other path                                                                            | Refused                                                                                 |

`jobSearch` may hold only a boolean `enabled` and an `updatedAt` equal to the server time of the
write, which `FieldValue.serverTimestamp()` produces. Users cannot delete their document.

A device document ID (the token) is at most 4096 characters. The document holds exactly a
`locale` string of up to 10 characters, a `platform` of `android`, `ios` or `web` and an
`updatedAt` equal to the server time of the write.

Server code authenticates with a service account, and security rules do not apply to it. The
Cloud Functions in [`tool/functions`](../functions/README.md) and the
[`firestore_export_import`](../firestore_export_import/README.md) tool write the documents that
clients can only read.

## Getting Started

### Prerequisites

- Node.js 22. The `volta` field in `package.json` pins the exact version for Volta users.
- Java 21 or later, which the Firestore emulator in `firebase-tools` requires.
- For deploying, a Firebase CLI login with access to the project that `.firebaserc` sets as
  `default`.

### Installation

From `tool/firestore`:

```bash
npm ci
```

## Usage

From `tool/firestore`:

```bash
npm run check          # format check, type check and rules tests
npm run format         # format with Prettier
npm run format:check   # check formatting only
npm run typecheck      # type check with tsc
```

From the workspace root, `melos run firestore_rules_check` runs `npm ci` and `npm run check`.

When a client starts reading or writing a new path, add a rule for it and tests for both allowed
and refused requests. Without a rule, the path is refused.

## Testing

```bash
npm test
```

This runs `firebase emulators:exec --only firestore --project demo-portrai "vitest run"`, which
starts the Firestore emulator on port 8080 with a demo project ID, so the tests never reach a
real project. The tests are in [`test/firestore_rules.test.ts`](test/firestore_rules.test.ts)
and run one file at a time against the shared emulator.

The [`firestore` workflow](../../.github/workflows/firestore.yaml) runs `npm run check` on pull
requests that change `tool/firestore`.

## Deployment

From the workspace root:

```bash
melos run deploy_firestore_rules
```

This runs `npm ci` and `npm run check`, then `npx firebase deploy --only firestore:rules` with
the CLI version from `package-lock.json`. The deployed rules replace the rules in the project.
