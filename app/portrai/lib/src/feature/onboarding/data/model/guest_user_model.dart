import 'package:json_annotation/json_annotation.dart';

part 'guest_user_model.g.dart';

@JsonSerializable()
class GuestUserModel {
  const GuestUserModel({required this.role});

  factory GuestUserModel.fromJson(Map<String, dynamic> json) =>
      _$GuestUserModelFromJson(json);

  final String role;

  Map<String, dynamic> toJson() => _$GuestUserModelToJson(this);
}
