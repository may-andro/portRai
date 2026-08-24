# Port-Rai Workspace

A modular Flutter portfolio application built with clean architecture principles, featuring a comprehensive design system with 12 themes and organized into discrete, testable layers.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Workspace Structure](#workspace-structure)
- [Getting Started](#getting-started)
- [Development](#development)
- [Scripts](#scripts)
- [Testing](#testing)
- [Contributing](#contributing)

## Overview

Port-Rai is a professional portfolio application built with Flutter, showcasing best practices in:

- **Modular Architecture**: Separated into layers, apps, and tools for maximum reusability
- **Clean Architecture**: Clear separation of concerns with well-defined dependencies
- **Design System**: 12 custom themes with atomic design principles (atoms → molecules → organisms)
- **Type Safety**: Leveraging Dart's strong typing with comprehensive code generation
- **Testing**: Full golden testing across all themes and comprehensive unit tests
- **Monorepo Management**: Using Melos for efficient workspace management

## Architecture

The workspace follows a layered architecture pattern:

```
port-rai/
├── app/              # Application entry points
│   ├── portrai/      # Main portfolio application
│   └── storybook/    # Component library showcase
├── layer/            # Feature and infrastructure layers
│   ├── cache/        # Caching abstraction (Memory, KV, DB)
│   ├── core/         # Core utilities and extensions
│   ├── design_system/# UI components and theming (12 themes)
│   ├── error_reporter/# Error reporting integration
│   ├── feature_flag/ # Feature flag management
│   ├── firebase/     # Firebase integration
│   ├── log_reporter/ # Logging infrastructure
│   ├── module_injector/# Dependency injection
│   ├── remote/       # API client and data sources
│   ├── tracking/     # Analytics tracking
│   └── use_case/     # Business logic use cases
└── tool/             # Development and automation tools
    ├── portrai_analyzer/# Custom lint rules
    └── firestore_export_import/# Firestore data management CLI
```

### Dependency Flow

```
Apps (portrai, storybook)
    ↓
Feature Layers (use_case)
    ↓
Infrastructure Layers (firebase, remote, cache, tracking, error_reporter, log_reporter, feature_flag)
    ↓
Foundation Layers (design_system, core, module_injector)
```

## Workspace Structure

### Apps

- **[portrai](app/portrai/README.md)**: Main portfolio application showcasing projects, skills, and experience
- **[storybook](app/storybook/README.md)**: Component library and design system documentation

### Layers

#### Foundation
- **[core](layer/core/README.md)**: Essential utilities, extensions, and base models
- **[design_system](layer/design_system/README.md)**: Complete design system with 12 themes, atomic components
- **[module_injector](layer/module_injector/README.md)**: Dependency injection framework

#### Infrastructure
- **[cache](layer/cache/README.md)**: Multi-strategy caching (Memory, SharedPreferences, SQLite)
- **[firebase](layer/firebase/README.md)**: Firebase integration and configuration
- **[remote](layer/remote/README.md)**: API client and remote data sources
- **[error_reporter](layer/error_reporter/README.md)**: Centralized error reporting
- **[log_reporter](layer/log_reporter/README.md)**: Structured logging infrastructure
- **[tracking](layer/tracking/README.md)**: Analytics and event tracking
- **[feature_flag](layer/feature_flag/README.md)**: Feature flag management

#### Business Logic
- **[use_case](layer/use_case/README.md)**: Base classes and patterns for implementing use cases with error handling and interceptors

### Tools

- **[portrai_analyzer](tool/portrai_analyzer/readme.md)**: Custom Dart analyzer plugin enforcing workspace rules
- **[firestore_export_import](tool/firestore_export_import/README.md)**: CLI for Firestore data import/export

## Getting Started

### Prerequisites

- **Flutter**: ^3.47.0
- **Dart SDK**: ^3.11.0
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Melos**: For workspace management

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/port-rai.git
   cd port-rai
   ```

2. **Install Melos** (if not already installed):
   ```bash
   dart pub global activate melos
   ```

3. **Bootstrap the workspace**:
   ```bash
   melos bootstrap
   ```
   This will:
   - Link all workspace packages
   - Run `flutter pub get` for all packages
   - Run code generation with `build_runner`

4. **Verify installation**:
   ```bash
   melos analyze
   ```

## Development

### Running the Apps

Each app has specific run configurations and parameters. See their respective READMEs for detailed instructions:

- **Main Portfolio App**: See [app/portrai/README.md](app/portrai/README.md) for run configurations, build flavors, and deployment
- **Component Storybook**: See [app/storybook/README.md](app/storybook/README.md) for running the design system showcase

### Code Generation

```bash
# Generate code for all packages
melos gen

# Generate for specific package
cd layer/cache
dart run build_runner build --delete-conflicting-outputs
```

### Running Tests

```bash
# Run all tests (excluding golden tests)
melos test

# Run golden tests
melos test_golden

# Update golden baselines
melos update_golden

# Run tests with coverage
melos test_with_coverage
```

### Formatting and Analysis

```bash
# Check formatting
melos format_check

# Analyze all packages
melos analyze

# Auto-fix analysis issues
melos analyze_fix
```

## Scripts

The workspace includes comprehensive Melos scripts for common tasks:

### Package Management

```bash
melos get              # Run flutter pub get for all packages
melos get_cli          # Run dart pub get for CLI packages
melos flutter_upgrade  # Upgrade all package dependencies
melos clean_cache      # Clean Flutter cache and rebuild
melos clean_ios        # Deep clean iOS build artifacts
```

### Code Generation

```bash
melos gen              # Run build_runner for all packages
melos gen_splash       # Generate splash screens
melos gen_icon         # Generate app icons
melos gen_l10n         # Generate localizations
```

### Testing

```bash
melos test                # Run all unit tests
melos test_golden         # Run golden (screenshot) tests
melos update_golden       # Update golden test baselines
melos test_golden_ci      # Run golden tests in CI mode
melos test_with_coverage  # Run tests with coverage reports
```

### Quality Assurance

```bash
melos format_check     # Check code formatting
melos analyze          # Analyze all packages for issues
melos analyze_fix      # Auto-fix analysis issues
```

### Deployment

```bash
melos deploy_portrai            # Deploy main app to Firebase Hosting
melos deploy_widgetbook         # Deploy storybook to Firebase Hosting
melos deploy_privacy_policy     # Deploy privacy policy page
melos deploy_terms_and_conditions  # Deploy terms & conditions page
melos deploy_functions          # Deploy Firebase Cloud Functions
```

### Firestore Data Management

```bash
melos firestore_import   # Import all Firestore collections to JSON
melos firestore_export   # Export JSON data to Firestore
```

## Testing

### Unit Tests

All layers include comprehensive unit tests:

```bash
# Run all tests
melos test

# Run tests for specific package
cd layer/cache
flutter test
```

### Golden Tests

The design system includes golden (screenshot) tests for all components across all 12 themes:

```bash
# Run golden tests
melos test_golden

# Update golden baselines (after intentional UI changes)
melos update_golden

# Run in CI mode (strict comparison)
melos test_golden_ci
```

### Code Coverage

```bash
# Generate coverage reports
melos test_with_coverage

# Coverage reports are saved as test-results.json in each package
```

## Project Structure

```
port-rai/
├── .github/                  # GitHub workflows and templates
├── app/
│   ├── portrai/             # Main application
│   └── storybook/           # Component showcase
├── layer/
│   ├── cache/               # Caching layer
│   ├── core/                # Core utilities
│   ├── design_system/       # UI components
│   ├── error_reporter/      # Error handling
│   ├── feature_flag/        # Feature flags
│   ├── firebase/            # Firebase integration
│   ├── log_reporter/        # Logging
│   ├── module_injector/     # DI framework
│   ├── remote/              # API layer
│   ├── tracking/            # Analytics
│   └── use_case/            # Business logic
├── tool/
│   ├── portrai_analyzer/    # Custom lint rules
│   └── firestore_export_import/  # Firestore CLI
├── pubspec.yaml             # Workspace configuration
├── analysis_options.yaml    # Lint rules
└── melos.yaml              # Melos configuration
```

## Contributing

### Development Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes in appropriate layer(s)**

3. **Run code generation** (if needed):
   ```bash
   melos gen
   ```

4. **Format and analyze**:
   ```bash
   melos format_check
   melos analyze
   ```

5. **Run tests**:
   ```bash
   melos test
   ```

6. **Commit and push**:
   ```bash
   git add .
   git commit -m "feat: add my feature"
   git push origin feature/my-feature
   ```

7. **Create Pull Request** following the [PR template](.github/pull_request_template.md)

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use the provided `analysis_options.yaml` for consistent linting
- Run `melos format_check` before committing
- Custom analyzer rules enforce workspace-specific patterns

### Adding a New Layer

1. Create the layer directory structure:
   ```bash
   mkdir -p layer/my_layer/lib/src
   ```

2. Create `pubspec.yaml` with workspace resolution:
   ```yaml
   name: my_layer
   description: My layer description
   publish_to: 'none'
   resolution: workspace
   
   environment:
     sdk: ^3.11.0
   ```

3. Add to workspace in root `pubspec.yaml`:
   ```yaml
   workspace:
     - layer/my_layer
   ```

4. Run `melos bootstrap`

5. Create comprehensive README following the layer README pattern

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Monorepo managed with [Melos](https://melos.invertase.dev)
- Design system inspired by atomic design principles
- Clean architecture patterns from Uncle Bob's Clean Architecture

---

**Maintained by**: Raima  
**Version**: 1.0.0  
**Last Updated**: August 2026
