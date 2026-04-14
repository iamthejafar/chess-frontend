import 'game_result_enums.dart';

class GameResultResponse {
  final GameResultType result;
  final EndReason endReason;
  final String? winnerUserId;

  GameResultResponse({
    required this.result,
    required this.endReason,
    this.winnerUserId,
  });

  factory GameResultResponse.fromJson(Map<String, dynamic> json) {
    return GameResultResponse(
      result: GameResultType.fromJson(json['result'] as String),
      endReason: EndReason.fromJson(json['endReason'] as String),
      winnerUserId: json['winnerUserId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'result': result.toJson(),
        'endReason': endReason.toJson(),
        'winnerUserId': winnerUserId,
      };

  bool get isDraw =>
      result == GameResultType.draw ||
      endReason == EndReason.stalemate ||
      endReason == EndReason.insufficientMaterial ||
      endReason == EndReason.threefoldRepetition ||
      endReason == EndReason.fiftyMoveRule ||
      endReason == EndReason.mutualAgreement;
}

