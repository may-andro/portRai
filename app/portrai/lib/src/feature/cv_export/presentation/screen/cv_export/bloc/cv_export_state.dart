import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';
import 'package:use_case/use_case.dart';

sealed class CvExportState extends Equatable {
  const CvExportState();

  @override
  List<Object?> get props => [];
}

class CvExportInitialState extends CvExportState {
  const CvExportInitialState();
}

class CvExportLoadingState extends CvExportState {
  const CvExportLoadingState({this.isTailoring = false});

  final bool isTailoring;

  @override
  List<Object?> get props => [isTailoring];
}

class CvExportLoadedState extends CvExportState {
  const CvExportLoadedState({
    required this.document,
    required this.options,
    required this.labels,
    this.pdfBytes,
    this.pdfRevision = 0,
    this.isGenerating = false,
    this.isDownloading = false,
    this.failure,
    this.tailoringTarget,
    this.tailoringFailure,
  });

  final CvDocumentEntity document;
  final CvOptionsEntity options;
  final CvLabelsEntity labels;

  /// The last successfully generated PDF; kept while a new one is generated.
  final Uint8List? pdfBytes;

  /// Increases with every generated PDF so the preview knows to refresh.
  final int pdfRevision;
  final bool isGenerating;
  final bool isDownloading;
  final Failure? failure;

  /// The job [document] is tailored for; null for the standard CV.
  final CvTailoringTargetEntity? tailoringTarget;

  /// Why the CV could not be tailored; [document] is the standard CV then.
  final Failure? tailoringFailure;

  CvExportLoadedState copyWith({
    CvOptionsEntity? options,
    Uint8List? pdfBytes,
    int? pdfRevision,
    bool? isGenerating,
    bool? isDownloading,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CvExportLoadedState(
      document: document,
      options: options ?? this.options,
      labels: labels,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      pdfRevision: pdfRevision ?? this.pdfRevision,
      isGenerating: isGenerating ?? this.isGenerating,
      isDownloading: isDownloading ?? this.isDownloading,
      failure: clearFailure ? null : (failure ?? this.failure),
      tailoringTarget: tailoringTarget,
      tailoringFailure: tailoringFailure,
    );
  }

  @override
  List<Object?> get props => [
    document,
    options,
    labels,
    pdfRevision,
    isGenerating,
    isDownloading,
    failure,
    tailoringTarget,
    tailoringFailure,
  ];
}

class CvExportErrorState extends CvExportState {
  const CvExportErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
