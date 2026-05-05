# Firestore Export/Import CLI Tool

A powerful command-line tool for seamlessly importing and exporting data between JSON files and Firestore collections. Perfect for data migrations, backups, and development workflows.

## 🚀 Quick Start

### Prerequisites
- Dart SDK installed
- Google Cloud service account with Firestore access permissions
- Service account JSON credentials file

### Installation
1. Navigate to the tool directory:
   ```bash
   cd tool/firestore_export_import
   ```

2. Install dependencies:
   ```bash
   dart pub get
   ```

## 📖 Usage

The tool provides two main commands: `import` and `export`.

### Import Data from Firestore

Download data from a Firestore collection and save it to a JSON file:

```bash
dart run bin/firestore_export_import.dart import \
  --collection your_collection_name \
  --secrets path/to/service_account.json \
  --output path/to/output.json
```

**Example:**
```bash
dart run bin/firestore_export_import.dart import \
  --collection app_config \
  --secrets .data/service_account.json \
  --output .data/app_config_backup.json
```

### Export Data to Firestore

Upload data from a JSON file to a Firestore collection:

```bash
dart run bin/firestore_export_import.dart export \
  --collection your_collection_name \
  --secrets path/to/service_account.json \
  --path path/to/input.json
```

**Example:**
```bash
dart run bin/firestore_export_import.dart export \
  --collection user_settings \
  --secrets .data/service_account.json \
  --path .data/user_settings.json
```

## 🔧 Command Options

### Import Command
| Option | Short | Required | Description |
|--------|-------|----------|-------------|
| `--collection` | `-c` | ✅ | Name of the Firestore collection to download from |
| `--secrets` | `-s` | ✅ | Path to your service account JSON credentials file |
| `--output` | `-o` | ✅ | Path where the downloaded data will be saved |

### Export Command
| Option | Short | Required | Description |
|--------|-------|----------|-------------|
| `--collection` | `-c` | ✅ | Name of the Firestore collection to upload to |
| `--secrets` | `-s` | ✅ | Path to your service account JSON credentials file |
| `--path` | `-p` | ✅ | Path to the JSON file containing data to upload |

## 🔐 Setting Up Service Account

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **IAM & Admin** > **Service Accounts**
4. Create a new service account or select an existing one
5. Assign the following roles:
   - `Cloud Datastore User` or
   - `Firebase Admin SDK Administrator Service Agent`
6. Generate and download the JSON key file
7. Keep this file secure and reference it in the `--secrets` parameter

## 📝 Common Use Cases

dart run bin/firestore_export_import.dart export --collection portfolio --secrets .data/service_account.json --path .data/portfolio.json

### Backup Collections
```bash
# Backup all app configuration
dart run bin/firestore_export_import.dart import \
  --collection app_config \
  --secrets .secrets/service_account.json \
  --output backups/app_config_$(date +%Y%m%d).json
```

### Environment Migration
```bash
# Export from staging
dart run bin/firestore_export_import.dart import \
  --collection products \
  --secrets .secrets/staging_account.json \
  --output staging_products.json

# Import to production
dart run bin/firestore_export_import.dart export \
  --collection products \
  --secrets .secrets/prod_account.json \
  --path staging_products.json
```

### Development Setup
```bash
# Load test data into development environment
dart run bin/firestore_export_import.dart export \
  --collection test_users \
  --secrets .secrets/dev_account.json \
  --path test_data/sample_users.json
```

## ⚠️ Troubleshooting

### Permission Denied (403 Error)
- Verify your service account has the correct IAM roles
- Ensure the service account JSON file is valid and not expired
- Check that Firestore is enabled for your project

### No Output or Logs
- Confirm all required parameters are provided
- Verify file paths exist and are accessible
- Check that the collection name is correct

### Connection Issues
- Ensure you have internet connectivity
- Verify your Google Cloud project ID is correct
- Check if there are any firewall restrictions

## 🔍 Getting Help

Run the tool without arguments to see available commands:
```bash
dart run bin/firestore_export_import.dart
```

Get help for a specific command:
```bash
dart run bin/firestore_export_import.dart import --help
dart run bin/firestore_export_import.dart export --help
```

## 📄 JSON File Format

The tool works with standard JSON format. Exported files will contain an array of documents with their field data preserved according to Firestore's data types.

---

**Note:** Always test with non-production data first and ensure you have proper backups before performing bulk operations.
