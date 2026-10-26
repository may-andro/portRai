# Firestore Export Import

A Dart command-line tool that copies a Firestore collection to a JSON file and writes documents
from a JSON file to a Firestore collection, through the Firestore REST API.

## Features

- `import` downloads the documents of a collection and saves the response as a JSON file.
- `export` reads documents from a JSON file and writes them to a collection in one batch write.
- Authenticates with a service account key file.

The command names are from the point of view of the local files: `import` reads from Firestore,
`export` writes to it.

## Getting Started

### Prerequisites

- Dart SDK `^3.11.0`, as set in `pubspec.yaml`.
- A service account JSON key file for the Firebase project, with a role that can read and write
  Firestore documents.

### Installation

```bash
cd tool/firestore_export_import
dart pub get
```

## Usage

Run the commands from `tool/firestore_export_import`.

### Import

Downloads the documents of a collection and writes them to a file:

```bash
dart run bin/firestore_export_import.dart import \
  --collection items \
  --secrets path/to/service_account.json \
  --output path/to/items.json
```

| Option         | Abbreviation | Required | Description                          |
| -------------- | ------------ | -------- | ------------------------------------ |
| `--collection` | `-c`         | Yes      | Collection to download               |
| `--secrets`    | `-s`         | Yes      | Path to the service account key file |
| `--output`     | `-o`         | Yes      | Path of the file to write            |

### Export

Writes the documents in a file to a collection:

```bash
dart run bin/firestore_export_import.dart export \
  --collection items \
  --secrets path/to/service_account.json \
  --path path/to/items.json
```

| Option         | Abbreviation | Required | Description                          |
| -------------- | ------------ | -------- | ------------------------------------ |
| `--collection` | `-c`         | Yes      | Collection to write to               |
| `--secrets`    | `-s`         | Yes      | Path to the service account key file |
| `--path`       | `-p`         | Yes      | Path of the JSON file to upload      |

None of the options have defaults. If one is missing, the command logs an error and exits
without contacting Firestore.

### Help

```bash
dart run bin/firestore_export_import.dart --help
dart run bin/firestore_export_import.dart import --help
dart run bin/firestore_export_import.dart export --help
```

### Melos scripts

From the workspace root, `melos run firestore_import` and `melos run firestore_export` run the
two commands for each portfolio content collection, with the key file at
`.data/service_account.json` and one JSON file per collection in `.data/`. The `.data` folder is
git-ignored.

## File Formats

### Import output

The output file is the unmodified body of one Firestore REST `documents.list` response for the
collection: a `documents` array whose entries hold the full document `name`, typed `fields`,
`createTime` and `updateTime`. The tool does not follow `nextPageToken`, so it saves only the
first page of results. This format is not accepted by `export` as is.

### Export input

The file must be a JSON object in one of two shapes:

```json
{
  "documents": [
    { "docId": "first", "fields": { "title": "First", "order": 1 } }
  ]
}
```

```json
{
  "first": { "title": "First", "order": 1 },
  "second": { "title": "Second", "order": 2 }
}
```

Each document is sent as a full `update` write, so it is created if missing and replaces all
fields of an existing document. Field values convert as follows:

| JSON value                                                                                                     | Firestore value                    |
| -------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| String                                                                                                         | `stringValue`                      |
| Integer                                                                                                        | `integerValue`                     |
| Decimal number                                                                                                 | `doubleValue`                      |
| Boolean                                                                                                        | `booleanValue`                     |
| Array                                                                                                          | `arrayValue`                       |
| Object with an `integerValue`, `doubleValue`, `stringValue`, `booleanValue`, `geoPointValue` or `mapValue` key | Passed through as that typed value |
| Any other object                                                                                               | `mapValue`                         |

A `null` field is skipped, and a `null` inside an array stops the export with an error.

## Configuration

The Firebase project ID is set in code, in `lib/use_case/download_use_case.dart` and
`lib/use_case/upload_use_case.dart`; it is not read from the service account key file. The
access token is requested with the `https://www.googleapis.com/auth/cloud-platform` scope.

## Testing

```bash
cd tool/firestore_export_import
dart test
```

The tests mock the HTTP client and never call Firestore. The
[`firestore_export_import` workflow](../../.github/workflows/firestore_export_import.yaml) runs
`dart format --set-exit-if-changed .`, `dart analyze --fatal-infos .` and
`dart test --coverage=coverage` on pull requests that change this tool.
