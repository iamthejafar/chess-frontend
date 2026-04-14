import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../../utils/chess_utils.dart';

// ─── Piece Image Renderer ─────────────────────────────────────────────────────
class PieceRenderer {
  PieceRenderer._();

  static Widget getPieceImage(String piece) {
    final color = ChessUtils.isBlackPiece(piece) ? 'b' : 'w';
    final type  = piece.toLowerCase();
    return Image.asset(
      'assets/images/$color$type.png',
      fit: BoxFit.contain,
    );
  }
}

// ─── Square Content ───────────────────────────────────────────────────────────
class SquareContent extends StatelessWidget {
  final String piece;
  final bool isPossibleMove;
  final bool isEmpty;

  const SquareContent({
    super.key,
    required this.piece,
    required this.isPossibleMove,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        // Piece image with padding so it never clips at edges
        if (piece.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(4),
            child: PieceRenderer.getPieceImage(piece),
          ),

        // Move dot — empty square
        if (isPossibleMove && isEmpty)
          Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.28),
              ),
            ),
          ),

        // Capture ring — occupied square
        if (isPossibleMove && !isEmpty)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: kCaptureBorder,
                  width: 3.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}