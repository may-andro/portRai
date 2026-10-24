import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// A push message as the app sees it: the displayed notification, if any,
/// and the data sent with it.
class FbPushMessage extends Equatable {
  const FbPushMessage({this.title, this.body, this.data = const {}});

  factory FbPushMessage.fromRemoteMessage(RemoteMessage message) {
    return FbPushMessage(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data.map(
        (key, dataValue) => MapEntry(key, dataValue.toString()),
      ),
    );
  }

  final String? title;
  final String? body;
  final Map<String, String> data;

  @override
  List<Object?> get props => [title, body, data];
}
