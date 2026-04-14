enum Messages {
  initGame,
  matched,
  move,
  resign,
  drawOffer,
  drawAccept,
  drawDecline,
  error,
}

extension MessagesExtension on Messages {
  String toJson() {
    switch (this) {
      case Messages.initGame:
        return 'INIT_GAME';
      case Messages.matched:
        return 'MATCHED';
      case Messages.move:
        return 'MOVE';
      case Messages.resign:
        return 'RESIGN';
      case Messages.drawOffer:
        return 'DRAW_OFFER';
      case Messages.drawAccept:
        return 'DRAW_ACCEPT';
      case Messages.drawDecline:
        return 'DRAW_DECLINE';
      case Messages.error:
        return 'ERROR';
    }
  }

  static Messages fromJson(String value) {
    switch (value) {
      case 'INIT_GAME':
        return Messages.initGame;
      case 'MATCHED':
        return Messages.matched;
      case 'MOVE':
        return Messages.move;
      case 'RESIGN':
        return Messages.resign;
      case 'DRAW_OFFER':
        return Messages.drawOffer;
      case 'DRAW_ACCEPT':
        return Messages.drawAccept;
      case 'DRAW_DECLINE':
        return Messages.drawDecline;
      case 'ERROR':
        return Messages.error;
      default:
        throw ArgumentError('Unknown Messages value: $value');
    }
  }
}
