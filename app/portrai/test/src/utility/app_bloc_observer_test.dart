import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/utility/app_bloc_observer.dart';

import '../../mock/utility/mock_bloc.dart';
import '../../mock/utility/mock_log_reporter.dart';

void main() {
  group('AppBlocObserver', () {
    late AppBlocObserver observer;
    late MockLogReporter mockLogReporter;
    late MockBloc mockBloc;

    setUp(() {
      mockLogReporter = MockLogReporter();
      observer = AppBlocObserver(mockLogReporter);
      mockBloc = MockBloc();
    });

    test(
      'should delegate debug log to logReporter when onChange is called',
      () {
        const change = Change<int>(currentState: 0, nextState: 1);

        observer.onChange(mockBloc, change);

        verify(
          () => mockLogReporter.debug(
            '${mockBloc.runtimeType} $change',
            tag: 'AppBlocObserver',
          ),
        ).called(1);
      },
    );

    test('should not throw when onChange calls super', () {
      const change = Change<int>(currentState: 1, nextState: 2);
      // Should not throw — verifies super.onChange is called safely
      expect(() => observer.onChange(mockBloc, change), returnsNormally);
    });

    test(
      'should log each transition when onChange is called multiple times',
      () {
        const change1 = Change<int>(currentState: 0, nextState: 5);
        const change2 = Change<int>(currentState: 5, nextState: 10);

        observer.onChange(mockBloc, change1);
        observer.onChange(mockBloc, change2);

        verify(
          () => mockLogReporter.debug(any(), tag: 'AppBlocObserver'),
        ).called(2);
      },
    );
  });
}
