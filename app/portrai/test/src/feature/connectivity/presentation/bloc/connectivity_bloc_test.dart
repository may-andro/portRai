import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/connectivity/domain/_domain.dart';
import 'package:portrai/src/feature/connectivity/presentation/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/connectivity/domain/use_case/mock_check_internet_connection_use_case.dart';
import '../../../../../mock/feature/connectivity/domain/use_case/mock_watch_internet_connection_use_case.dart';

void main() {
  group('ConnectivityBloc', () {
    late MockCheckInternetConnectionUseCase checkUseCase;
    late MockWatchInternetConnectionUseCase watchUseCase;
    late StreamController<bool> controller;

    ConnectivityBloc buildBloc() => ConnectivityBloc(
      checkInternetConnectionUseCase: checkUseCase,
      watchInternetConnectionUseCase: watchUseCase,
    );

    setUp(() {
      checkUseCase = MockCheckInternetConnectionUseCase();
      watchUseCase = MockWatchInternetConnectionUseCase();
      controller = StreamController<bool>();
      watchUseCase.stubCall(
        controller.stream.map(Right<WatchInternetConnectionFailure, bool>.new),
      );
    });

    tearDown(() {
      unawaited(controller.close());
    });

    blocTest<ConnectivityBloc, ConnectivityState>(
      'should emit offline when the initial check finds no internet',
      setUp: () => checkUseCase.stubCall(
        const Right<CheckInternetConnectionFailure, bool>(false),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const StartConnectivityMonitoringEvent()),
      expect: () => const [ConnectivityOfflineState()],
    );

    blocTest<ConnectivityBloc, ConnectivityState>(
      'should emit offline then online when the connection drops and returns',
      setUp: () => checkUseCase.stubCall(
        const Right<CheckInternetConnectionFailure, bool>(true),
      ),
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const StartConnectivityMonitoringEvent());
        await Future<void>.delayed(Duration.zero);
        controller.add(false);
        await Future<void>.delayed(Duration.zero);
        controller.add(true);
      },
      wait: const Duration(milliseconds: 10),
      expect: () => const [
        ConnectivityOnlineState(),
        ConnectivityOfflineState(),
        ConnectivityOnlineState(),
      ],
    );
  });
}
