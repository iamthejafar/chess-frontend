import 'package:bishop/bishop.dart';

import '../features/ches_board/models/move_model.dart';

class ChessUtils {
  ChessUtils._();

  // ─── Game Constants ──────────────────────────────────────────────────────────
  static const String initialFen =
      'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

  // ─── Piece Helpers ───────────────────────────────────────────────────────────
  static bool isWhitePiece(String piece) {
    if (piece.isEmpty) return false;
    return piece.codeUnitAt(0) < 97; // uppercase = white
  }

  static bool isBlackPiece(String piece) {
    if (piece.isEmpty) return false;
    return piece.codeUnitAt(0) >= 97; // lowercase = black
  }

  static String getPieceColor(String piece) =>
      isWhitePiece(piece) ? 'w' : 'b';

  /// Returns the asset path for a given piece symbol.
  static String getPieceAsset(String piece) {
    final color = isBlackPiece(piece) ? 'b' : 'w';
    final type  = piece.toLowerCase();
    return 'assets/images/$color$type.png';
  }

  /// Human-readable piece name from a single letter symbol.
  static String getPieceName(String piece) {
    const names = {
      'k': 'King',   'q': 'Queen',  'r': 'Rook',
      'b': 'Bishop', 'n': 'Knight', 'p': 'Pawn',
    };
    return names[piece.toLowerCase()] ?? piece;
  }

  // ─── Square Conversion ───────────────────────────────────────────────────────
  static String indexToSquare(int index) {
    final row = 8 - (index ~/ 8);
    final col = String.fromCharCode('a'.codeUnitAt(0) + (index % 8));
    return '$col$row';
  }

  static int squareToIndex(String square) {
    final col = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final row = 8 - int.parse(square[1]);
    return row * 8 + col;
  }

  static bool isLightSquare(int index) =>
      (index ~/ 8 + index % 8) % 2 == 0;

  // ─── Move Helpers ────────────────────────────────────────────────────────────
  static MoveModel? extractMoveDetails(BishopState state) {
    if (state.move == null) return null;
    final move = state.move!;
    final fromSquare = state.meta?.variant.boardSize.squareName(move.from) ?? '';
    final toSquare   = state.meta?.variant.boardSize.squareName(move.to)   ?? '';
    final pieceMoved = state.pieceOnSquare(toSquare);

    return MoveModel(
      piece:      pieceMoved,
      from:       fromSquare,
      to:         toSquare,
      pieceColor: state.turn == 0 ? 'b' : 'w',
    );
  }

  static List<int> getPossibleMoves(int fromIndex, Game game) {
    final fromSquare  = indexToSquare(fromIndex);
    final moves       = game.generateLegalMoves();
    final result      = <int>[];

    for (final move in moves) {
      final squareName = game.variant.boardSize.squareName(move.from);
      if (squareName == fromSquare) {
        final toName = game.variant.boardSize.squareName(move.to);
        result.add(squareToIndex(toName));
      }
    }
    return result;
  }

  static String getTurnColor(Game game) =>
      game.turn == 1 ? 'white' : 'black';

  /// Returns the move number label for a given 0-based history index.
  /// Returns null for black's move (odd index).
  static String? getMoveNumberLabel(int index) {
    if (index == 0) return '1.';
    if (index % 2 == 0) return '${index ~/ 2 + 1}.';
    return null;
  }

  /// Formats a move as a compact algebraic-style string, e.g. "e2 → e4".
  static String formatMove(MoveModel move) =>
      '${move.from} → ${move.to}';

  // ─── Rank / File Label Lists ─────────────────────────────────────────────────
  static List<String> rankLabels({required bool isWhite}) =>
      isWhite
          ? ['8', '7', '6', '5', '4', '3', '2', '1']
          : ['1', '2', '3', '4', '5', '6', '7', '8'];

  static List<String> fileLabels({required bool isWhite}) =>
      isWhite
          ? ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
          : ['h', 'g', 'f', 'e', 'd', 'c', 'b', 'a'];
}