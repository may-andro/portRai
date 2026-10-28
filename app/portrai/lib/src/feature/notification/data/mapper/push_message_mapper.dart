import 'package:core/core.dart';
import 'package:firebase/firebase.dart' as firebase;
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

/// Reads the `kind` the sender puts in the message data.
@register
class PushMessageMapper
    implements Mapper<firebase.FbPushMessage, PushMessageEntity> {
  const PushMessageMapper();

  @override
  PushMessageEntity map(firebase.FbPushMessage from) => PushMessageEntity(
    kind: switch (from.data['kind']) {
      'job_openings' => PushMessageKind.jobOpenings,
      'call_request' => PushMessageKind.appointmentRequest,
      'portfolio_update' => PushMessageKind.portfolioUpdate,
      _ => PushMessageKind.unknown,
    },
    title: from.title,
    body: from.body,
  );
}
