import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

const _generateConfiguratorUrl =
    'package:module_injector/src/annotation/generate_configurator.dart#GenerateConfigurator';
const _registerUrl =
    'package:module_injector/src/annotation/register.dart#Register';
const _registerSingletonUrl =
    'package:module_injector/src/annotation/register_singleton.dart#RegisterSingleton';
const _injectUrl = 'package:module_injector/src/annotation/inject.dart#Inject';

const _generateConfiguratorChecker = TypeChecker.fromUrl(
  _generateConfiguratorUrl,
);
const _registerChecker = TypeChecker.fromUrl(_registerUrl);
const _registerSingletonChecker = TypeChecker.fromUrl(_registerSingletonUrl);
const _injectChecker = TypeChecker.fromUrl(_injectUrl);

/// Custom [Builder] that generates a standalone `.di.g.dart` library file
/// (with its own `import` directives) for every class annotated with
/// `@generateConfigurator`.
///
/// **Discovery strategy**: instead of following the configurator's Dart
/// imports, the builder globs every `.dart` file that lives under the same
/// directory as the configurator and scans them for `@register` /
/// `@registerSingleton` annotations.  This means configurator files only
/// need the imports that the Dart compiler itself requires — no
/// `// ignore: unused_import` workarounds.
class ModuleInjectorBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    '.dart': ['.di.g.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) return;

    final library = await buildStep.resolver.libraryFor(buildStep.inputId);
    final reader = LibraryReader(library);

    final annotatedElements = reader
        .annotatedWith(_generateConfiguratorChecker)
        .toList();
    if (annotatedElements.isEmpty) return;

    final element = annotatedElements.first.element;
    if (element is! ClassElement) return;

    final className = element.name ?? 'Unknown';
    final moduleName = className.replaceAll('ModuleConfigurator', '');
    final functionName = '\$register${moduleName}Dependencies';

    final registrations = <_Registration>[];
    final importUris = <String>{'package:module_injector/module_injector.dart'};
    final visited = <String>{};

    // Derive the feature directory from the configurator's asset path.
    // e.g. "lib/src/feature/expertise/expertise_module_configurator.dart"
    //   -> "lib/src/feature/expertise/"
    final inputPath = buildStep.inputId.path;
    final lastSlash = inputPath.lastIndexOf('/');
    final featureDir = lastSlash >= 0
        ? inputPath.substring(0, lastSlash + 1)
        : 'lib/';

    // Glob every Dart file under the feature directory and scan for
    // @register / @registerSingleton annotations.
    // Sort by path for deterministic output across machines and runs.
    final glob = Glob('$featureDir**.dart');
    final assets = await buildStep.findAssets(glob).toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final asset in assets) {
      // Skip the configurator file itself and generated files.
      if (asset == buildStep.inputId) continue;
      if (asset.path.endsWith('.di.g.dart') || asset.path.endsWith('.g.dart')) {
        continue;
      }

      if (!await buildStep.resolver.isLibrary(asset)) continue;

      final lib = await buildStep.resolver.libraryFor(asset);
      _scanLibrary(lib, registrations, importUris, visited);
    }

    if (registrations.isEmpty) {
      final outputId = buildStep.allowedOutputs.first;
      await buildStep.writeAsString(
        outputId,
        "${_buildFileHeader()}import 'package:module_injector/module_injector.dart';\n\nvoid $functionName(ServiceLocator sl) {}\n",
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.write(_buildFileHeader());

    final sortedImports = importUris.toList()..sort();
    for (final uri in sortedImports) {
      buffer.writeln("import '$uri';");
    }
    buffer.writeln();

    buffer.writeln('void $functionName(ServiceLocator sl) {');
    for (final reg in registrations) {
      final method = reg.isSingleton ? 'registerSingleton' : 'registerFactory';
      final registrationType = reg.abstractType ?? reg.concreteType;
      final constructorArgs = reg.constructorParams
          .map(_buildParamCode)
          .join(', ');

      final constructorCall = constructorArgs.isEmpty
          ? '${reg.isConst ? 'const ' : ''}${reg.concreteType}()'
          : '${reg.concreteType}($constructorArgs)';

      buffer.writeln('  sl.$method<$registrationType>(');
      buffer.writeln('    () => $constructorCall,');
      if (reg.disposeMethodName != null) {
        buffer.writeln('    dispose: (it) => it.${reg.disposeMethodName}(),');
      }
      if (reg.shouldOverride) {
        buffer.writeln('    shouldOverride: true,');
      }
      buffer.writeln('  );');
    }
    buffer.writeln('}');

    final outputId = buildStep.allowedOutputs.first;
    await buildStep.writeAsString(outputId, buffer.toString());
  }

  // ---------------------------------------------------------------------------
  // Scanning
  // ---------------------------------------------------------------------------

  void _scanLibrary(
    LibraryElement library,
    List<_Registration> registrations,
    Set<String> importUris,
    Set<String> visited,
  ) {
    final uri = library.uri.toString();
    if (visited.contains(uri)) return;
    visited.add(uri);

    for (final fragment in library.fragments) {
      for (final classFragment in fragment.classes) {
        final classEl = classFragment.element;
        if (classEl.isPrivate) continue;

        final registerAnnotation = _registerChecker.firstAnnotationOf(classEl);
        final singletonAnnotation = _registerSingletonChecker.firstAnnotationOf(
          classEl,
        );

        if (registerAnnotation == null && singletonAnnotation == null) continue;

        final isSingleton = singletonAnnotation != null;
        final annotationObj = registerAnnotation ?? singletonAnnotation!;

        _addLibraryUri(classEl.library.uri.toString(), importUris);

        final asType = annotationObj.getField('as');
        String? abstractType;
        if (asType != null && !asType.isNull) {
          final typeValue = asType.toTypeValue();
          if (typeValue != null) {
            abstractType = typeValue.getDisplayString();
            _addTypeImport(typeValue, importUris);
          }
        }

        final shouldOverride =
            annotationObj.getField('shouldOverride')?.toBoolValue() ?? false;

        String? disposeMethodName;
        if (isSingleton) {
          final disposeField = annotationObj.getField('disposeMethodName');
          if (disposeField != null && !disposeField.isNull) {
            disposeMethodName = disposeField.toStringValue();
          }
        }

        final constructor = classEl.unnamedConstructor;
        if (constructor == null) {
          throw InvalidGenerationSourceError(
            '${classEl.name} must have an unnamed constructor for @register/@registerSingleton.',
            element: classEl,
          );
        }

        final params = constructor.formalParameters.map((
          FormalParameterElement p,
        ) {
          _addTypeImport(p.type, importUris);

          String? injectOverrideType;
          final injectAnnotation = _injectChecker.firstAnnotationOf(p);
          if (injectAnnotation != null) {
            final typeField = injectAnnotation.getField('type');
            if (typeField != null && !typeField.isNull) {
              final typeValue = typeField.toTypeValue();
              if (typeValue != null) {
                injectOverrideType = typeValue.getDisplayString();
                _addTypeImport(typeValue, importUris);
              }
            }
          }

          return _ConstructorParam(
            name: p.name ?? '',
            type: p.type.getDisplayString(),
            isNamed: p.isNamed,
            injectOverrideType: injectOverrideType,
          );
        }).toList();

        registrations.add(
          _Registration(
            concreteType: classEl.name ?? '',
            abstractType: abstractType,
            isSingleton: isSingleton,
            isConst: constructor.isConst,
            shouldOverride: shouldOverride,
            disposeMethodName: disposeMethodName,
            constructorParams: params,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Import helpers
  // ---------------------------------------------------------------------------

  void _addLibraryUri(String uri, Set<String> importUris) {
    if (!uri.startsWith('dart:')) importUris.add(uri);
  }

  void _addTypeImport(DartType type, Set<String> importUris) {
    if (type is InterfaceType) {
      _addLibraryUri(type.element.library.uri.toString(), importUris);
    } else if (type is! DynamicType && type is! VoidType) {
      log.warning(
        'module_injector: unhandled parameter type "${type.getDisplayString()}" (${type.runtimeType}) — import not added automatically.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Code generation
  // ---------------------------------------------------------------------------

  String _buildFileHeader() => '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import

''';

  String _buildParamCode(_ConstructorParam param) {
    final resolvedType = param.injectOverrideType ?? param.type;
    final getter = 'sl.get<$resolvedType>()';
    return param.isNamed ? '${param.name}: $getter' : getter;
  }
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

class _Registration {
  _Registration({
    required this.concreteType,
    required this.abstractType,
    required this.isSingleton,
    required this.isConst,
    required this.shouldOverride,
    required this.disposeMethodName,
    required this.constructorParams,
  });

  final String concreteType;
  final String? abstractType;
  final bool isSingleton;
  final bool isConst;
  final bool shouldOverride;
  final String? disposeMethodName;
  final List<_ConstructorParam> constructorParams;
}

class _ConstructorParam {
  _ConstructorParam({
    required this.name,
    required this.type,
    required this.isNamed,
    this.injectOverrideType,
  });

  final String name;
  final String type;
  final bool isNamed;

  /// When set via `@Inject(ConcreteType)`, overrides the declared [type]
  /// in the generated `sl.get<>()` call.
  final String? injectOverrideType;
}
