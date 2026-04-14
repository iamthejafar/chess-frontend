// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String?,
  name: json['name'] as String?,
  username: json['username'] as String,
  isGuest: json['guest'] as bool,
  picture: json['picture'] as String?,
  googleId: json['googleId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  rating: (json['rating'] as num?)?.toInt(),
  gamesPlayed: (json['gamesPlayed'] as num?)?.toInt(),
  gamesWon: (json['gamesWon'] as num?)?.toInt(),
  gamesLost: (json['gamesLost'] as num?)?.toInt(),
  gamesDraw: (json['gamesDraw'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'username': instance.username,
  'picture': instance.picture,
  'googleId': instance.googleId,
  'guest': instance.isGuest,
  'createdAt': instance.createdAt?.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'rating': instance.rating,
  'gamesPlayed': instance.gamesPlayed,
  'gamesWon': instance.gamesWon,
  'gamesLost': instance.gamesLost,
  'gamesDraw': instance.gamesDraw,
};
