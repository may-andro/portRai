import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/developer_mode/domain/entity/_entity.dart';
import 'package:portrai/src/feature/developer_mode/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetTrackingEventsFailure extends BasicFailure {
  const GetTrackingEventsFailure({super.cause});
}

@Localizable('errorTrackingEventsNotKept')
class TrackingEventsNotKeptFailure extends GetTrackingEventsFailure {
  const TrackingEventsNotKeptFailure({super.cause});
}

@Localizable('errorTrackingEventsUnknown')
class TrackingEventsUnknownFailure extends GetTrackingEventsFailure {
  const TrackingEventsUnknownFailure({super.cause});
}

/// The tracking events sent in this session, in the order they were sent.
@register
class GetTrackingEventsUseCase
    extends
        BaseNoParamUseCase<
          List<TrackingEventEntity>,
          GetTrackingEventsFailure
        > {
  GetTrackingEventsUseCase(this._trackingEventRepository);

  final TrackingEventRepository _trackingEventRepository;

  @protected
  @override
  FutureOr<Either<GetTrackingEventsFailure, List<TrackingEventEntity>>>
  execute() {
    final trackingEvents = _trackingEventRepository.getSentTrackingEvents();
    if (trackingEvents == null) {
      return const Left(TrackingEventsNotKeptFailure());
    }
    return Right(trackingEvents);
  }

  @protected
  @override
  GetTrackingEventsFailure mapErrorToFailure(Object e, StackTrace st) =>
      TrackingEventsUnknownFailure(cause: e);
}
