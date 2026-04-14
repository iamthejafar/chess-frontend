import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/colors.dart';
import '../models/move_model.dart';
import '../../../utils/chess_utils.dart';

class MoveWidget extends StatelessWidget {
  const MoveWidget({
    super.key,
    required this.move,
    this.highlight = false,
  });

  final MoveModel move;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final isWhite = move.pieceColor == 'w';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Piece icon (small asset image)
        if (move.piece.isNotEmpty)
          SizedBox(
            width: 18,
            height: 18,
            child: Image.asset(
              ChessUtils.getPieceAsset(move.piece),
              fit: BoxFit.contain,
            ),
          )
        else
          const SizedBox(width: 18),

        const SizedBox(width: 4),

        // Destination square
        Text(
          move.to,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            color: highlight
                ? kGold
                : isWhite
                ? kTextPrimary
                : kTextSecondary,
          ),
        ),
      ],
    );
  }
}