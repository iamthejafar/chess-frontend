import 'package:json_annotation/json_annotation.dart';
import 'messages_enum.dart';

part 'game_status_response.g.dart';

@JsonSerializable()
class GameStatusResponse {
  @JsonKey(fromJson: _messageFromJson, toJson: _messageToJson)
  final Messages type;

  final String message;
  final String userId;
  final String sessionId;
  final String opponentUserId;
  final String gameId;

  GameStatusResponse({
    required this.type,
    required this.message,
    required this.userId,
    required this.sessionId,
    required this.opponentUserId,
    required this.gameId,
  });

  factory GameStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$GameStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GameStatusResponseToJson(this);
}

Messages _messageFromJson(String value) => MessagesExtension.fromJson(value);

String _messageToJson(Messages value) => value.toJson();

