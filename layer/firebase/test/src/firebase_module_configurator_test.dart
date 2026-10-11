import 'package:firebase/firebase.dart';
import 'package:firebase_ai/firebase_ai.dart' show FirebaseAI;
import 'package:flutter_test/flutter_test.dart';
import 'package:module_injector/module_injector.dart';

void main() {
  for (final backend in FbAiBackend.values) {
    test(
      'should register AI lazily when the configured backend is $backend',
      () async {
        final locator = ModuleInjectorController().serviceLocator;
        await locator.reset();
        addTearDown(locator.reset);
        final configurator = FirebaseModuleConfigurator(
          isFirebaseEnabled: false,
          firebaseOptions: const FirebaseOptions(
            apiKey: 'unit-test-placeholder',
            appId: 'unit-test-app',
            messagingSenderId: 'unit-test-sender',
            projectId: 'unit-test-project',
          ),
          appCheckWebSiteKey: '',
          storageBucketUrl: '',
          aiBackend: backend,
          aiLocation: 'europe-west4',
        );

        // Deliberately do not initialize Firebase or run App Check setup.
        await configurator.registerDependencies(locator);

        expect(locator.isRegistered<FirebaseAI>(), isTrue);
        expect(locator.isRegistered<FbAiController>(), isTrue);
        expect(configurator.aiBackend, backend);
        expect(configurator.aiLocation, 'europe-west4');
      },
    );
  }
}
