import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

abstract class CvExportEvent extends Equatable {
  const CvExportEvent();

  @override
  List<Object?> get props => [];
}

class LoadCvExportEvent extends CvExportEvent {
  const LoadCvExportEvent(this.labels, {this.tailoringTarget});

  final CvLabelsEntity labels;

  /// The job to tailor the CV for, or null for the standard CV.
  final CvTailoringTargetEntity? tailoringTarget;

  @override
  List<Object?> get props => [labels, tailoringTarget];
}

class SelectCvTemplateClickEvent extends CvExportEvent {
  const SelectCvTemplateClickEvent(this.template);

  final CvTemplate template;

  @override
  List<Object?> get props => [template];
}

class SelectCvAccentClickEvent extends CvExportEvent {
  const SelectCvAccentClickEvent(this.accent);

  final CvAccent accent;

  @override
  List<Object?> get props => [accent];
}

class ToggleCvPhotoClickEvent extends CvExportEvent {
  const ToggleCvPhotoClickEvent({required this.isIncluded});

  final bool isIncluded;

  @override
  List<Object?> get props => [isIncluded];
}

class SelectCvPhotoClickEvent extends CvExportEvent {
  const SelectCvPhotoClickEvent({required this.photoUrl, required this.index});

  final String photoUrl;
  final int index;

  @override
  List<Object?> get props => [photoUrl, index];
}

class ToggleCvSectionClickEvent extends CvExportEvent {
  const ToggleCvSectionClickEvent(this.section);

  final CvSection section;

  @override
  List<Object?> get props => [section];
}

class DownloadCvClickEvent extends CvExportEvent {
  const DownloadCvClickEvent();
}
