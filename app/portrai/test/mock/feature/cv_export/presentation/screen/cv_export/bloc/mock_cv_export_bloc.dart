// ignore_for_file: avoid_implementing_value_types

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/_bloc.dart';

class MockCvExportBloc extends MockBloc<CvExportEvent, CvExportState>
    implements CvExportBloc {}

class FakeCvExportEvent extends Fake implements CvExportEvent {}

extension MockCvExportBlocStub on MockCvExportBloc {
  void stubState(CvExportState state) {
    when(() => this.state).thenReturn(state);
    whenListen(this, const Stream<CvExportState>.empty(), initialState: state);
  }
}
