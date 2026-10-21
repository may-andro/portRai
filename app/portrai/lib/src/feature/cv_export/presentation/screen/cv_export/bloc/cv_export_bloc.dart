import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/cv_export_event.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/bloc/cv_export_state.dart';
import 'package:portrai/src/feature/cv_export/presentation/screen/cv_export/tracking/_tracking.dart';
import 'package:use_case/use_case.dart';

@register
class CvExportBloc extends Bloc<CvExportEvent, CvExportState> {
  CvExportBloc(
    this._buildCvDocumentUseCase,
    this._tailorCvDocumentUseCase,
    this._generateCvPdfUseCase,
    this._shareCvPdfUseCase,
    this._trackingDelegate,
  ) : super(const CvExportInitialState()) {
    on<LoadCvExportEvent>(_mapLoadCvExportEventToState);
    on<SelectCvTemplateClickEvent>(_mapSelectCvTemplateClickEventToState);
    on<SelectCvAccentClickEvent>(_mapSelectCvAccentClickEventToState);
    on<ToggleCvPhotoClickEvent>(_mapToggleCvPhotoClickEventToState);
    on<SelectCvPhotoClickEvent>(_mapSelectCvPhotoClickEventToState);
    on<ToggleCvSectionClickEvent>(_mapToggleCvSectionClickEventToState);
    on<DownloadCvClickEvent>(_mapDownloadCvClickEventToState);
  }

  static const String _fileNameSuffix = 'CV.pdf';

  final BuildCvDocumentUseCase _buildCvDocumentUseCase;
  final TailorCvDocumentUseCase _tailorCvDocumentUseCase;
  final GenerateCvPdfUseCase _generateCvPdfUseCase;
  final ShareCvPdfUseCase _shareCvPdfUseCase;
  final CvExportTrackingDelegate _trackingDelegate;
  int _generationRevision = 0;

  Future<void> _mapLoadCvExportEventToState(
    LoadCvExportEvent event,
    Emitter<CvExportState> emit,
  ) async {
    _trackingDelegate.trackViewEvent('cv_export');
    emit(const CvExportLoadingState());

    final documentEither = await _buildCvDocumentUseCase();
    if (documentEither.isLeft) {
      emit(CvExportErrorState(documentEither.left));
      return;
    }

    var document = documentEither.right;
    final tailoringTarget = event.tailoringTarget;
    Failure? tailoringFailure;
    if (tailoringTarget != null) {
      _trackingDelegate.trackViewEvent('cv_export_tailored');
      emit(const CvExportLoadingState(isTailoring: true));
      final tailoredDocumentEither = await _tailorCvDocumentUseCase(
        TailorCvDocumentParam(document: document, target: tailoringTarget),
      );
      if (tailoredDocumentEither.isLeft) {
        tailoringFailure = tailoredDocumentEither.left;
      } else {
        document = tailoredDocumentEither.right;
      }
    }

    final loadedState = CvExportLoadedState(
      document: document,
      options: const CvOptionsEntity(),
      labels: event.labels,
      tailoringTarget: tailoringFailure == null ? tailoringTarget : null,
      tailoringFailure: tailoringFailure,
    );
    emit(loadedState);
    await _generatePdf(loadedState, emit);
  }

  Future<void> _mapSelectCvTemplateClickEventToState(
    SelectCvTemplateClickEvent event,
    Emitter<CvExportState> emit,
  ) async {
    _trackingDelegate.trackTemplateSelection(event.template.name);
    await _applyOptions(
      emit,
      (options) => options.copyWith(template: event.template),
    );
  }

  Future<void> _mapSelectCvAccentClickEventToState(
    SelectCvAccentClickEvent event,
    Emitter<CvExportState> emit,
  ) async {
    _trackingDelegate.trackAccentSelection(event.accent.name);
    await _applyOptions(
      emit,
      (options) => options.copyWith(accent: event.accent),
    );
  }

  Future<void> _mapToggleCvPhotoClickEventToState(
    ToggleCvPhotoClickEvent event,
    Emitter<CvExportState> emit,
  ) async {
    _trackingDelegate.trackPhotoToggle(isIncluded: event.isIncluded);
    await _applyOptions(
      emit,
      (options) => options.copyWith(isPhotoIncluded: event.isIncluded),
    );
  }

  Future<void> _mapSelectCvPhotoClickEventToState(
    SelectCvPhotoClickEvent event,
    Emitter<CvExportState> emit,
  ) async {
    _trackingDelegate.trackPhotoSelection(event.index);
    await _applyOptions(
      emit,
      (options) =>
          options.copyWith(photoUrl: event.photoUrl, isPhotoIncluded: true),
    );
  }

  Future<void> _mapToggleCvSectionClickEventToState(
    ToggleCvSectionClickEvent event,
    Emitter<CvExportState> emit,
  ) async {
    _trackingDelegate.trackSectionToggle(event.section.name);
    await _applyOptions(emit, (options) {
      final sections = {...options.sections};
      if (!sections.remove(event.section)) sections.add(event.section);
      return options.copyWith(sections: sections);
    });
  }

  Future<void> _mapDownloadCvClickEventToState(
    DownloadCvClickEvent event,
    Emitter<CvExportState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CvExportLoadedState ||
        currentState.isDownloading ||
        currentState.pdfBytes == null) {
      return;
    }
    _trackingDelegate.trackDownload(currentState.options.template.name);
    emit(currentState.copyWith(isDownloading: true, clearFailure: true));

    final shareEither = await _shareCvPdfUseCase(
      ShareCvPdfParam(
        pdfBytes: currentState.pdfBytes!,
        fileName: _fileNameOf(
          currentState.document,
          currentState.tailoringTarget,
        ),
      ),
    );
    if (emit.isDone || state is! CvExportLoadedState) return;
    final latestState = state as CvExportLoadedState;
    emit(
      shareEither.isLeft
          ? latestState.copyWith(
              isDownloading: false,
              failure: shareEither.left,
            )
          : latestState.copyWith(isDownloading: false),
    );
  }

  Future<void> _applyOptions(
    Emitter<CvExportState> emit,
    CvOptionsEntity Function(CvOptionsEntity options) update,
  ) async {
    final currentState = state;
    if (currentState is! CvExportLoadedState) return;
    final loadedState = currentState.copyWith(
      options: update(currentState.options),
    );
    emit(loadedState);
    await _generatePdf(loadedState, emit);
  }

  Future<void> _generatePdf(
    CvExportLoadedState loadedState,
    Emitter<CvExportState> emit,
  ) async {
    final revision = ++_generationRevision;
    emit(loadedState.copyWith(isGenerating: true, clearFailure: true));

    final pdfEither = await _generateCvPdfUseCase(
      GenerateCvPdfParam(
        document: loadedState.document,
        options: loadedState.options,
        labels: loadedState.labels,
      ),
    );
    // A newer option change owns the state now.
    if (emit.isDone || revision != _generationRevision) return;
    if (state is! CvExportLoadedState) return;
    final latestState = state as CvExportLoadedState;

    emit(
      pdfEither.isLeft
          ? latestState.copyWith(isGenerating: false, failure: pdfEither.left)
          : latestState.copyWith(
              isGenerating: false,
              pdfBytes: pdfEither.right,
              pdfRevision: latestState.pdfRevision + 1,
            ),
    );
  }

  /// For example `Jane_Doe_CV.pdf`, or `Jane_Doe_Acme_CV.pdf` when tailored.
  String _fileNameOf(
    CvDocumentEntity document,
    CvTailoringTargetEntity? tailoringTarget,
  ) {
    final namePart = [
      document.fullName,
      ?tailoringTarget?.company,
    ].map(_fileNamePartOf).where((part) => part.isNotEmpty).join('_');
    return namePart.isEmpty ? _fileNameSuffix : '${namePart}_$_fileNameSuffix';
  }

  static String _fileNamePartOf(String text) => text
      .trim()
      .replaceAll(RegExp(r'\s+'), '_')
      .replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '');
}
