enum GameResultType {
  checkmate,
  resignation,
  draw,
  timeout,
  abandoned;

  static GameResultType fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'CHECKMATE':
        return GameResultType.checkmate;
      case 'RESIGNATION':
        return GameResultType.resignation;
      case 'DRAW':
        return GameResultType.draw;
      case 'TIMEOUT':
        return GameResultType.timeout;
      case 'ABANDONED':
        return GameResultType.abandoned;
      default:
        return GameResultType.draw;
    }
  }

  String toJson() => name.toUpperCase();
}

enum EndReason {
  checkmate,
  resignation,
  stalemate,
  insufficientMaterial,
  threefoldRepetition,
  fiftyMoveRule,
  mutualAgreement,
  timeout,
  abandoned;

  static EndReason fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'CHECKMATE':
        return EndReason.checkmate;
      case 'RESIGNATION':
        return EndReason.resignation;
      case 'STALEMATE':
        return EndReason.stalemate;
      case 'INSUFFICIENT_MATERIAL':
        return EndReason.insufficientMaterial;
      case 'THREEFOLD_REPETITION':
        return EndReason.threefoldRepetition;
      case 'FIFTY_MOVE_RULE':
        return EndReason.fiftyMoveRule;
      case 'MUTUAL_AGREEMENT':
        return EndReason.mutualAgreement;
      case 'TIMEOUT':
        return EndReason.timeout;
      case 'ABANDONED':
        return EndReason.abandoned;
      default:
        return EndReason.checkmate;
    }
  }

  String toJson() {
    switch (this) {
      case EndReason.insufficientMaterial:
        return 'INSUFFICIENT_MATERIAL';
      case EndReason.threefoldRepetition:
        return 'THREEFOLD_REPETITION';
      case EndReason.fiftyMoveRule:
        return 'FIFTY_MOVE_RULE';
      case EndReason.mutualAgreement:
        return 'MUTUAL_AGREEMENT';
      default:
        return name.toUpperCase();
    }
  }

  String get displayName {
    switch (this) {
      case EndReason.checkmate:
        return 'Checkmate';
      case EndReason.resignation:
        return 'Resignation';
      case EndReason.stalemate:
        return 'Stalemate';
      case EndReason.insufficientMaterial:
        return 'Insufficient Material';
      case EndReason.threefoldRepetition:
        return 'Threefold Repetition';
      case EndReason.fiftyMoveRule:
        return '50-Move Rule';
      case EndReason.mutualAgreement:
        return 'Draw by Agreement';
      case EndReason.timeout:
        return 'Timeout';
      case EndReason.abandoned:
        return 'Abandoned';
    }
  }
}

