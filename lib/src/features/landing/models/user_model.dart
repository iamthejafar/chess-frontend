import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String uid;
  final String displayName;
  final String type;
  final String token;
  final String username;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.type,
    required this.token,
    required this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
