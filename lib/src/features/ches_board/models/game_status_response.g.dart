// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameStatusResponse _$GameStatusResponseFromJson(Map<String, dynamic> json) =>
    GameStatusResponse(
      type: _messageFromJson(json['type'] as String),
      message: json['message'] as String,
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as String,
      opponentUserId: json['opponentUserId'] as String,
      gameId: json['gameId'] as String,
    );

Map<String, dynamic> _$GameStatusResponseToJson(GameStatusResponse instance) =>
    <String, dynamic>{
      'type': _messageToJson(instance.type),
      'message': instance.message,
      'userId': instance.userId,
      'sessionId': instance.sessionId,
      'opponentUserId': instance.opponentUserId,
      'gameId': instance.gameId,
    };
