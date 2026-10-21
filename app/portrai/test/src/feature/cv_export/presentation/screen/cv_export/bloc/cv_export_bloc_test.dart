import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/cv_export/domain/use_case/fake_cv_use_case_param.dart';
import '../../../../../../../mock/feature/cv_export/domain/use_case/mock_build_cv_document_use_case.dart';
import '../../../../../../../mock/feature/cv_export/domain/use_case/mock_generate_cv_pdf_use_case.dart';
import '../../../../../../../mock/feature/cv_export/domain/use_case/mock_share_cv_pdf_use_case.dart';
import '../../../../../../../mock/feature/cv_export/domain/use_case/mock_tailor_cv_document_use_case.dart';
import '../../../../../../../mock/feature/cv_export/presentation/screen/cv_export/tracking/mock_cv_export_tracking_delegate.dart';
import '../../../../../../../util/cv_export_test_fixture.dart';

void main() {
  final document = CvExportTestFixture.lightDocument();
  const labels = CvExportTestFixture.labels;
  final pdfBytes = Uint8List.fromList([1, 2, 3]);

  setUpAll(() {
    registerFallbackValue(FakeGenerateCvPdfParam());
    registerFallbackValue(FakeShareCvPdfParam());
    registerFallbackValue(FakeTailorCvDocumentParam());
  });

  group('CvExportBloc', () {
    late MockBuildCvDocumentUseCase buildDocument;
    late MockGenerateCvPdfUseCase generatePdf;
    late MockShareCvPdfUseCase sharePdf;
    late MockTailorCvDocumentUseCase tailorDocument;
    late MockCvExportTrackingDelegate tracking;

    CvExportBloc buildBloc() => CvExportBloc(
      buildDocument,
      tailorDocument,
      generatePdf,
      sharePdf,
      tracking,
    );

    CvExportLoadedState loadedState({
      CvOptionsEntity options = const CvOptionsEntity(),
      Uint8List? bytes,
      int revision = 0,
    }) {
      return CvExportLoadedState(
        document: document,
        options: options,
        labels: labels,
        pdfBytes: bytes,
        pdfRevision: revision,
      );
    }

    setUp(() {
      buildDocument = MockBuildCvDocumentUseCase()
        ..stubCall(Right<BuildCvDocumentFailure, CvDocumentEntity>(document));
      generatePdf = MockGenerateCvPdfUseCase()
        ..stubCall(Right<GenerateCvPdfFailure, Uint8List>(pdfBytes));
      sharePdf = MockShareCvPdfUseCase()
        ..stubCall(const Right<ShareCvPdfFailure, bool>(true));
      tailorDocument = MockTailorCvDocumentUseCase();
      tracking = MockCvExportTrackingDelegate();
    });

    const tailoringTarget = CvTailoringTargetEntity(
      title: 'Senior Flutter Developer',
      company: 'Acme Inc.',
      description: 'Build apps with Flutter.',
    );
    final tailoredDocument = CvExportTestFixture.heavyDocument();

    blocTest<CvExportBloc, CvExportState>(
      'should tailor the document for the job when a target is given',
      setUp: () => tailorDocument.stubCall(
        Right<TailorCvDocumentFailure, CvDocumentEntity>(tailoredDocument),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(
        const LoadCvExportEvent(labels, tailoringTarget: tailoringTarget),
      ),
      expect: () => [
        const CvExportLoadingState(),
        const CvExportLoadingState(isTailoring: true),
        CvExportLoadedState(
          document: tailoredDocument,
          options: const CvOptionsEntity(),
          labels: labels,
          tailoringTarget: tailoringTarget,
        ),
        CvExportLoadedState(
          document: tailoredDocument,
          options: const CvOptionsEntity(),
          labels: labels,
          tailoringTarget: tailoringTarget,
          isGenerating: true,
        ),
        CvExportLoadedState(
          document: tailoredDocument,
          options: const CvOptionsEntity(),
          labels: labels,
          tailoringTarget: tailoringTarget,
          pdfBytes: pdfBytes,
          pdfRevision: 1,
        ),
      ],
      verify: (_) {
        final param =
            verify(() => tailorDocument(captureAny())).captured.single
                as TailorCvDocumentParam;
        expect(param.document, document);
        expect(param.target, tailoringTarget);
        verify(() => tracking.trackViewEvent('cv_export_tailored')).called(1);
      },
    );

    blocTest<CvExportBloc, CvExportState>(
      'should show the standard document with the failure when tailoring '
      'fails',
      setUp: () => tailorDocument.stubCall(
        const Left<TailorCvDocumentFailure, CvDocumentEntity>(
          CvTailoringQuotaFailure(),
        ),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(
        const LoadCvExportEvent(labels, tailoringTarget: tailoringTarget),
      ),
      verify: (bloc) {
        final loaded = bloc.state as CvExportLoadedState;
        expect(loaded.document, document);
        expect(loaded.tailoringTarget, isNull);
        expect(loaded.tailoringFailure, const CvTailoringQuotaFailure());
        expect(loaded.pdfBytes, pdfBytes);
      },
    );

    blocTest<CvExportBloc, CvExportState>(
      'should add the company to the file name of a tailored CV',
      build: buildBloc,
      seed: () => CvExportLoadedState(
        document: document,
        options: const CvOptionsEntity(),
        labels: labels,
        pdfBytes: pdfBytes,
        pdfRevision: 1,
        tailoringTarget: tailoringTarget,
      ),
      act: (bloc) => bloc.add(const DownloadCvClickEvent()),
      verify: (_) {
        final captured =
            verify(() => sharePdf(captureAny())).captured.single
                as ShareCvPdfParam;
        expect(captured.fileName, 'Ada_Lovelace_Acme_Inc_CV.pdf');
      },
    );

    blocTest<CvExportBloc, CvExportState>(
      'should emit loaded with a generated pdf when the document loads',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadCvExportEvent(labels)),
      expect: () => [
        const CvExportLoadingState(),
        loadedState(),
        CvExportLoadedState(
          document: document,
          options: const CvOptionsEntity(),
          labels: labels,
          isGenerating: true,
        ),
        loadedState(bytes: pdfBytes, revision: 1),
      ],
      verify: (_) {
        verify(() => tracking.trackViewEvent('cv_export')).called(1);
      },
    );

    blocTest<CvExportBloc, CvExportState>(
      'should emit error when the document cannot be built',
      setUp: () {
        buildDocument.stubCall(
          const Left<BuildCvDocumentFailure, CvDocumentEntity>(
            CvDataUnavailableFailure(),
          ),
        );
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadCvExportEvent(labels)),
      expect: () => [
        const CvExportLoadingState(),
        const CvExportErrorState(CvDataUnavailableFailure()),
      ],
    );

    blocTest<CvExportBloc, CvExportState>(
      'should regenerate with the new template when a template is selected',
      build: buildBloc,
      seed: () => loadedState(bytes: pdfBytes, revision: 1),
      act: (bloc) =>
          bloc.add(const SelectCvTemplateClickEvent(CvTemplate.bold)),
      verify: (bloc) {
        final loaded = bloc.state as CvExportLoadedState;
        expect(loaded.options.template, CvTemplate.bold);
        expect(loaded.pdfRevision, 2);
        verify(() => tracking.trackTemplateSelection('bold')).called(1);
      },
    );

    blocTest<CvExportBloc, CvExportState>(
      'should remove the section when an included section is toggled',
      build: buildBloc,
      seed: () => loadedState(bytes: pdfBytes, revision: 1),
      act: (bloc) =>
          bloc.add(const ToggleCvSectionClickEvent(CvSection.projects)),
      verify: (bloc) {
        final loaded = bloc.state as CvExportLoadedState;
        expect(loaded.options.sections, isNot(contains(CvSection.projects)));
      },
    );

    blocTest<CvExportBloc, CvExportState>(
      'should include the photo when the photo is toggled on',
      build: buildBloc,
      seed: () => loadedState(bytes: pdfBytes, revision: 1),
      act: (bloc) => bloc.add(const ToggleCvPhotoClickEvent(isIncluded: true)),
      verify: (bloc) {
        final loaded = bloc.state as CvExportLoadedState;
        expect(loaded.options.isPhotoIncluded, isTrue);
      },
    );

    blocTest<CvExportBloc, CvExportState>(
      'should select the photo and include it when another photo is picked',
      build: buildBloc,
      seed: () => loadedState(bytes: pdfBytes, revision: 1),
      act: (bloc) => bloc.add(
        const SelectCvPhotoClickEvent(
          photoUrl: 'https://photo.test/2',
          index: 1,
        ),
      ),
      verify: (bloc) {
        final loaded = bloc.state as CvExportLoadedState;
        expect(loaded.options.photoUrl, 'https://photo.test/2');
        expect(loaded.options.isPhotoIncluded, isTrue);
      },
    );

    blocTest<CvExportBloc, CvExportState>(
      'should keep the previous pdf and expose the failure when generation fails',
      setUp: () {
        generatePdf.stubCall(
          const Left<GenerateCvPdfFailure, Uint8List>(CvPdfGenerationFailure()),
        );
      },
      build: buildBloc,
      seed: () => loadedState(bytes: pdfBytes, revision: 1),
      act: (bloc) => bloc.add(const SelectCvAccentClickEvent(CvAccent.indigo)),
      verify: (bloc) {
        final loaded = bloc.state as CvExportLoadedState;
        expect(loaded.failure, isA<CvPdfGenerationFailure>());
        expect(loaded.pdfBytes, pdfBytes);
        expect(loaded.isGenerating, isFalse);
      },
    );

    blocTest<CvExportBloc, CvExportState>(
      'should share the pdf with a sanitized file name when download is clicked',
      build: buildBloc,
      seed: () => loadedState(bytes: pdfBytes, revision: 1),
      act: (bloc) => bloc.add(const DownloadCvClickEvent()),
      verify: (bloc) {
        final captured =
            verify(() => sharePdf(captureAny())).captured.single
                as ShareCvPdfParam;
        expect(captured.fileName, 'Ada_Lovelace_CV.pdf');
        expect(captured.pdfBytes, pdfBytes);
        expect((bloc.state as CvExportLoadedState).isDownloading, isFalse);
        verify(() => tracking.trackDownload('sidebar')).called(1);
      },
    );

    blocTest<CvExportBloc, CvExportState>(
      'should expose the failure when sharing fails',
      setUp: () {
        sharePdf.stubCall(
          const Left<ShareCvPdfFailure, bool>(CvPdfShareFailure()),
        );
      },
      build: buildBloc,
      seed: () => loadedState(bytes: pdfBytes, revision: 1),
      act: (bloc) => bloc.add(const DownloadCvClickEvent()),
      verify: (bloc) {
        final loaded = bloc.state as CvExportLoadedState;
        expect(loaded.failure, isA<CvPdfShareFailure>());
        expect(loaded.isDownloading, isFalse);
      },
    );

    blocTest<CvExportBloc, CvExportState>(
      'should do nothing when download is clicked before a pdf exists',
      build: buildBloc,
      seed: loadedState,
      act: (bloc) => bloc.add(const DownloadCvClickEvent()),
      expect: () => <CvExportState>[],
      verify: (_) {
        verifyNever(() => sharePdf(any()));
      },
    );
  });
}
