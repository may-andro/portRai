import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';

/// Parameters that repeat the event's name, area and action type.
const _summaryParameterKeys = {'event', 'area', 'action'};

extension TrackingEventExtension on TrackingEventEntity {
  /// Time of day the event was sent, to the millisecond.
  String get formattedSentAt => DateFormat('HH:mm:ss.SSS').format(sentAt);

  /// Whether the event marks a screen becoming visible.
  bool get isScreenView => name == 'screen_view';

  /// Time between [previous] and this event, such as `+340 ms` or `+7.4 s`.
  String formattedElapsedSince(
    BuildContext context,
    TrackingEventEntity previous,
  ) {
    final elapsedMilliseconds = sentAt
        .difference(previous.sentAt)
        .inMilliseconds;
    if (elapsedMilliseconds < Duration.millisecondsPerSecond) {
      return context.localizations.trackingEventsElapsedMilliseconds(
        elapsedMilliseconds,
      );
    }
    final secondsFormat = NumberFormat(
      '0.0',
      Localizations.localeOf(context).toString(),
    );
    return context.localizations.trackingEventsElapsedSeconds(
      secondsFormat.format(
        elapsedMilliseconds / Duration.millisecondsPerSecond,
      ),
    );
  }

  IconData get icon => switch (actionType) {
    'click' => Icons.touch_app_outlined,
    'view' => Icons.visibility_outlined,
    'setup' => Icons.settings_suggest_outlined,
    _ => Icons.web_asset_outlined,
  };

  /// The parameters other than the name, area and action type, as
  /// `key: value` pairs; empty when there are none.
  String get parameterSummary => parameters.entries
      .where((parameter) => !_summaryParameterKeys.contains(parameter.key))
      .map((parameter) => '${parameter.key}: ${parameter.value}')
      .join(' · ');

  /// The sent parameters as indented JSON.
  String get payload => const JsonEncoder.withIndent('  ').convert(parameters);
}
