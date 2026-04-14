import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';
@JsonSerializable()
class UserModel {
  final String id;
  final String? email;
  final String? name;
  final String username;
  final String? picture;
  final String? googleId;

  @JsonKey(name: 'guest')
  final bool isGuest;

  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final int? rating;
  final int? gamesPlayed;
  final int? gamesWon;
  final int? gamesLost;
  final int? gamesDraw;

  UserModel({
    required this.id,
    this.email,
    this.name,
    required this.username,
    required this.isGuest,
    this.picture,
    this.googleId,
    this.createdAt,
    this.lastLoginAt,
    this.rating,
    this.gamesPlayed,
    this.gamesWon,
    this.gamesLost,
    this.gamesDraw,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
