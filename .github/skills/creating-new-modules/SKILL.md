---
description: 'Step-by-step instructions for creating a new shared layer package (layer/*) or a new app feature module (app/portrai/lib/src/feature/*) in this melos workspace, including DI wiring and routing. Use when asked to scaffold, bootstrap, or add a new layer/package/feature/module.'
---

# Creating New Modules

This repo is a melos workspace with two kinds of modules: shared **layers** (`layer/*`, plain
Dart/Flutter packages) and **app features** (`app/portrai/lib/src/feature/*`, folders inside the
`portrai` app, not separate packages). Pick the right one before scaffolding — most new business
functionality is an app feature, not a new layer.

## Deciding: new layer vs. new app feature
- **New layer** (`layer/<name>`): only when the code is a standalone, reusable concern with no
  UI/feature-specific logic, consumed by multiple apps or clearly separable (e.g. `cache`,
  `tracking`, `log_reporter`, `use_case`). Ask before creating one if unsure — most work is an
  app feature.
- **New app feature** (`app/portrai/lib/src/feature/<name>`): the default for product
  functionality (screens, feature-specific domain/data logic). See the
  `flutter-architecture-conventions` skill for the internal `data/domain/presentation` layout.

Layers are feature-independent. Their API names, doc comments, README examples and tests never
mention an app feature or its data (collections, fields, business terms); use neutral
placeholders instead. When a feature needs a new layer capability, add it in generic terms and
keep the feature-specific usage in the feature. See the content rules in `readme-conventions`.

## A. Creating a new layer package

1. Create the directory and standard skeleton:
   ```bash
   mkdir -p layer/my_layer/lib/src
   ```
2. Add `layer/my_layer/pubspec.yaml`:
   ```yaml
   name: my_layer
   description: <what this layer provides>
   publish_to: 'none'
   resolution: workspace

   environment:
     sdk: ^3.11.0

   dependencies:
     flutter:
       sdk: flutter
     module_injector: any   # if it registers DI dependencies

   dev_dependencies:
     flutter_test:
       sdk: flutter
     mocktail: ^1.0.4

   flutter:
     uses-material-design: true
   ```
3. Register the package in the root `pubspec.yaml` under `workspace:`.
4. Create the public barrel file `layer/my_layer/lib/my_layer.dart` that exports the layer's
   public API only (e.g. `export 'src/log/log_reporter.dart';`), plus its module configurator if
   it has one: `export 'src/my_layer_module_configurator.dart';`. Internal `src/` files should
   not be imported directly by consumers.
5. If the layer registers dependencies, add `lib/src/my_layer_module_configurator.dart`
   implementing `ModuleConfigurator` (from `module_injector`) with
   `registerDependencies`/`preDependenciesSetup`/`postDependenciesSetup`. See
   `layer/log_reporter/lib/src/log_reporter_module_configurator.dart` as the reference example.
6. Run `melos bootstrap` (or `melos run get`) so the new package resolves in the workspace.
7. Write a `layer/my_layer/README.md` following the pattern of existing layer READMEs (e.g.
   `layer/log_reporter/README.md`, `layer/use_case/README.md`): purpose, public API, usage
   example.
8. If the app consumes it, add it as a dependency in `app/portrai/pubspec.yaml` and wire its
   `ModuleConfigurator` into `getModuleConfigurators()` in
   `app/portrai/lib/src/module_configurator/module_configurators.dart` (order roughly follows
   dependency order — foundational layers like logging/DI first, feature layers/features last).

## B. Creating a new app feature module

App features live under `app/portrai/lib/src/feature/<feature_name>/` and are **not** separate
packages — no `pubspec.yaml`, they're part of the `portrai` app package.

1. Create the folder skeleton (adapt based on whether the feature has a screen — see the
   `flutter-architecture-conventions` skill for the full `presentation/screen/<name>/` layout
   rules):
   ```
   feature/<feature_name>/
     data/
       _data.dart                       // exports repository/_repository.dart (+ cache/, mapper/, model/ as needed)
       repository/
         _repository.dart
         <feature>_repository_impl.dart
     domain/
       _domain.dart                     // exports repository/ + use_case/ barrels (+ entity/, exception/ as needed)
       entity/
         _entity.dart
         <feature>_entity.dart
       exception/
         _exception.dart
         <feature>_exception.dart
       repository/
         _repository.dart
         <feature>_repository.dart       // abstract interface
       use_case/
         _use_case.dart
         get_<feature>_use_case.dart      // extends BaseUseCase/BaseNoParamUseCase (see flutter-architecture-conventions)
         watch_<feature>_use_case.dart    // streams: extends BaseStreamUseCase/BaseNoParamStreamUseCase
     presentation/
       _presentation.dart                // exports route/_route.dart (if any) + screen/_screen.dart
       route/                            // only if the feature has a screen
         _route.dart
         <feature>_module_route.dart
       screen/
         _screen.dart
         <screen_name>/
           _<screen_name>.dart
           <screen_name>_screen.dart
           bloc/
             _bloc.dart
             bloc_extension.dart
             <screen_name>_bloc.dart
             <screen_name>_event.dart
             <screen_name>_state.dart
           tracking/
             _tracking.dart
             <screen_name>_tracking_delegate.dart
           widget/
             _widget.dart
     <feature_name>.dart                  // top-level barrel: exports the module configurator plus the use cases, entities, routes, screens and widgets other code uses
     <feature_name>_module_configurator.dart
   ```
   For features with no real screen (e.g. a bottom sheet, like `force_update`), skip the
   `screen/<name>/` nesting and put `bloc/`, `tracking/`, `widget/` directly under
   `presentation/`.

2. Create `<feature_name>_module_configurator.dart` using the generated-configurator pattern
   (uses `module_injector`'s code generation, run via `melos run gen` / `build_runner`):
   ```dart
   import 'package:module_injector/module_injector.dart';
   import 'package:portrai/src/feature/<feature_name>/<feature_name>_module_configurator.di.g.dart';
   import 'package:portrai/src/feature/<feature_name>/presentation/_presentation.dart';
   import 'package:portrai/src/route/core/module_route_controller.dart';

   @generateConfigurator
   class <FeatureName>ModuleConfigurator extends SimpleModuleConfigurator {
     @override
     void registerDependencies(ServiceLocator sl) {
       $register<FeatureName>Dependencies(sl);
     }

     // Only override this if the feature has a screen/route to register:
     @override
     Future<void> postDependenciesSetup(ServiceLocator sl) async {
       sl.get<ModuleRouteController>().register(<FeatureName>ModuleRoute.<name>);
     }
   }
   ```
   Run `melos run gen` (build_runner) to generate
   `<feature_name>_module_configurator.di.g.dart` with `$register<FeatureName>Dependencies`.
   `app/portrai/lib/src/feature/experience/experience_module_configurator.dart` is a complete
   example.

3. If the feature has a screen, define its route(s) in
   `presentation/route/<feature_name>_module_route.dart` as a `ModuleRoute` subclass (see
   `app/portrai/lib/src/feature/experience/presentation/route/experience_module_route.dart` for
   the pattern with nested child routes).

4. Register the feature in the app-wide DI graph: add the import and an entry to
   `getModuleConfigurators()` in
   `app/portrai/lib/src/module_configurator/module_configurators.dart`, appended after other
   feature configurators (foundational/core configurators stay first).

5. Follow the `flutter-architecture-conventions` skill for use case, bloc, and widget-splitting
   rules within the feature, and the `flutter-testing-conventions` skill for
   `test/src/feature/<feature_name>/...` and `test/mock/feature/<feature_name>/...` mirroring.

6. Run `melos run gen`, `melos run analyze`, and `melos run test` before opening a PR (see the
   pr-and-branch-conventions skill for branch naming — new features typically use `app/<name>`).
