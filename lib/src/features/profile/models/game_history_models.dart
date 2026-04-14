class GameHistoryItem {
  GameHistoryItem({
    required this.gameId,
    required this.userColor,
    required this.opponentUserId,
    this.whiteUserId,
    this.blackUserId,
    this.moveCount,
    this.startTime,
    this.endTime,
    this.gameOver,
    this.result,
    this.endReason,
    this.winnerUserId,
  });

  final String gameId;
  final String userColor;
  final String opponentUserId;
  final String? whiteUserId;
  final String? blackUserId;
  final int? moveCount;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool? gameOver;
  final String? result;
  final String? endReason;
  final String? winnerUserId;

  factory GameHistoryItem.fromJson(Map<String, dynamic> json) {
    return GameHistoryItem(
      gameId: (json['gameId'] ?? '').toString(),
      userColor: (json['userColor'] ?? '').toString(),
      opponentUserId: (json['opponentUserId'] ?? '').toString(),
      whiteUserId: json['whiteUserId']?.toString(),
      blackUserId: json['blackUserId']?.toString(),
      moveCount: _toInt(json['moveCount']),
      startTime: _toDateTime(json['startTime']),
      endTime: _toDateTime(json['endTime']),
      gameOver: _toBool(json['gameOver']),
      result: json['result']?.toString(),
      endReason: json['endReason']?.toString(),
      winnerUserId: json['winnerUserId']?.toString(),
    );
  }
}

class GameHistoryPage {
  GameHistoryPage({
    required this.userId,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.games,
  });

  final String userId;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final List<GameHistoryItem> games;

  factory GameHistoryPage.fromJson(Map<String, dynamic> json) {
    final gameList = (json['games'] as List?) ?? const [];
    return GameHistoryPage(
      userId: (json['userId'] ?? '').toString(),
      page: _toInt(json['page']) ?? 0,
      size: _toInt(json['size']) ?? 0,
      totalElements: _toInt(json['totalElements']) ?? 0,
      totalPages: _toInt(json['totalPages']) ?? 0,
      hasNext: _toBool(json['hasNext']) ?? false,
      games: gameList
          .whereType<Map>()
          .map((raw) => GameHistoryItem.fromJson(Map<String, dynamic>.from(raw)))
          .toList(),
    );
  }
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool? _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
  }
  return null;
}

DateTime? _toDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

