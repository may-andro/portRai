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
  const CvExportLoadingState();
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
  ];
}

class CvExportErrorState extends CvExportState {
  const CvExportErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
