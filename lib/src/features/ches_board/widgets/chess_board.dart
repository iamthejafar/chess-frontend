import 'dart:math' as math;

import 'package:bishop/bishop.dart';
import 'package:chess/src/core/app_routes.dart';
import 'package:chess/src/features/landing/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/colors.dart';
import '../../../shared/widgets/ghost_button.dart';
import '../../../shared/widgets/primary_button.dart';
import '../bloc/game_bloc.dart';
import '../../../utils/chess_utils.dart';
import 'square_content.dart';

// ─── Square Color Utility ─────────────────────────────────────────────────────

/// Single source of truth for chess square coloring.
abstract class _SquareColors {
  static bool isLight(int index) => (index ~/ 8 + index % 8) % 2 == 0;

  static Color base(int index) => isLight(index) ? kSquareLight : kSquareDark;

  static Color selected(int index) => isLight(index)
      ? const Color(0xFFF6E27A)
      : const Color(0xFFD4AC24);

  static Color resolve({required int index, required bool isSelected}) =>
      isSelected ? selected(index) : base(index);
}

// ─── Profile Navigation Helper ────────────────────────────────────────────────

void _pushProfile(
    BuildContext context, {
      required String userId,
      required String? viewerUserId,
    }) {
  Navigator.of(context).pushNamed(
    AppRoutes.profile,
    arguments: ProfileRouteArgs(userId: userId, viewerUserId: viewerUserId),
  );
}

// ─── Root ─────────────────────────────────────────────────────────────────────

class ChessBoard extends StatelessWidget {
  const ChessBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listenWhen: _shouldShowPromotionPicker,
      listener: _onPromotionRequired,
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) => _BoardContentSwitcher(state: state),
      ),
    );
  }

  bool _shouldShowPromotionPicker(GameState previous, GameState current) {
    if (current is! GameInProgress || !current.isAwaitingPromotionChoice) {
      return false;
    }
    if (previous is! GameInProgress) return true;
    return !previous.isAwaitingPromotionChoice ||
        previous.pendingPromotionFrom != current.pendingPromotionFrom ||
        previous.pendingPromotionTo != current.pendingPromotionTo;
  }

  Future<void> _onPromotionRequired(BuildContext context, GameState state) async {
    if (state is! GameInProgress || !state.isAwaitingPromotionChoice) return;

    final selectedPiece = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PromotionPickerDialog(isWhite: state.isWhite),
    );

    if (!context.mounted) return;

    context.read<GameBloc>().add(
      selectedPiece == null
          ? PromotionSelectionCancelled()
          : PromotionPieceSelected(selectedPiece),
    );
  }
}

// ─── Board Content Switcher ───────────────────────────────────────────────────

/// Switches between game states and renders the appropriate widget.
class _BoardContentSwitcher extends StatelessWidget {
  final GameState state;
  const _BoardContentSwitcher({required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      GameInitial() => Center(child: _StartPrompt()),
      GameWaitingForOpponent() => const Center(child: _WaitingCard()),
      GameLoading() => const Center(
        child: CircularProgressIndicator(color: kGold, strokeWidth: 2),
      ),
      GameError(:final message) => Center(child: _ErrorCard(message: message)),
      GameInProgress() || GameOver() => _GameBoard(state: state as GameInProgress),
      _ => const SizedBox.shrink(),
    };
  }
}

// ─── Game Board (Player Cards + Board + Overlays) ─────────────────────────────
//
// Uses LayoutBuilder to derive the largest square that fits the available space
// after accounting for the two player cards. The board is then explicitly sized
// to boardSize × boardSize so it is always square regardless of the parent.

class _GameBoard extends StatelessWidget {
  final GameInProgress state;
  const _GameBoard({required this.state});

  // Player card: vertical padding (7*2=14) + avatar height (32) = 46px.
  // Add the 8px gap above and below → 54px total per player area.
  static const double _playerAreaHeight = 54.0;

  @override
  Widget build(BuildContext context) {
    final bool hasOpponent = state.opponentUser != null;
    final bool hasMe = state.user != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double verticalOverhead =
            (hasOpponent ? _playerAreaHeight : 0) +
                (hasMe ? _playerAreaHeight : 0);

        // In a scrollable context maxHeight is infinite — fall back to width.
        final double availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight - verticalOverhead
            : constraints.maxWidth;

        final double boardSize = math.max(
          0,
          math.min(constraints.maxWidth, availableHeight),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: boardSize,
              child: _PlayerCard(
                user: state.opponentUser!,
                isOpponent: true,
                onTap: () => _pushProfile(
                  context,
                  userId: state.opponentUser!.id,
                  viewerUserId: state.user?.id,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Explicit square size — the single source of truth for board dimensions.
            SizedBox(
              width: boardSize,
              height: boardSize,
              child: Stack(
                children: [
                  _BoardWithLabels(state: state),
                  _BoardOverlayLayer(state: state),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: boardSize,
              child: _PlayerCard(
                user: state.user!,
                isOpponent: false,
                onTap: () => _pushProfile(
                  context,
                  userId: state.user!.id,
                  viewerUserId: state.user?.id,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Board with Coordinate Labels ─────────────────────────────────────────────

class _BoardWithLabels extends StatelessWidget {
  final GameInProgress state;
  const _BoardWithLabels({required this.state});

  static const _labelStyle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    color: Color(0x88F0EAE0),
  );

  @override
  Widget build(BuildContext context) {
    final files = state.isWhite
        ? ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
        : ['h', 'g', 'f', 'e', 'd', 'c', 'b', 'a'];
    final ranks = state.isWhite
        ? ['8', '7', '6', '5', '4', '3', '2', '1']
        : ['1', '2', '3', '4', '5', '6', '7', '8'];

    final boardSymbols = state.isAtLivePosition
        ? state.game.boardSymbols()
        : Game(fen: state.viewingFen!).boardSymbols();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final cellSize = size / 8;

        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kAppBorder),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                _BoardGrid(
                  state: state,
                  boardSymbols: boardSymbols,
                  isInteractive: state.isAtLivePosition,
                ),
                // Rank labels — left edge
                ...List.generate(8, (r) => Positioned(
                  top: r * cellSize + 2,
                  left: 3,
                  child: Text(ranks[r], style: _labelStyle),
                )),
                // File labels — bottom edge
                ...List.generate(8, (c) => Positioned(
                  bottom: 2,
                  left: c * cellSize + cellSize - 10,
                  child: Text(files[c], style: _labelStyle),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Board Grid ───────────────────────────────────────────────────────────────

class _BoardGrid extends StatelessWidget {
  final GameInProgress state;
  final List<String> boardSymbols;
  final bool isInteractive;

  const _BoardGrid({
    required this.state,
    required this.boardSymbols,
    required this.isInteractive,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemCount: 64,
      itemBuilder: (context, index) => _buildSquare(context, index),
    );
  }

  Widget _buildSquare(BuildContext context, int index) {
    final actualIndex = state.isWhite ? index : 63 - index;
    final piece = boardSymbols[actualIndex];
    final isPossible = isInteractive && state.possibleMoves.contains(actualIndex);
    final isSelected = isInteractive && state.selectedSquare == actualIndex;

    return GestureDetector(
      onTap: isInteractive ? () => _handleTap(context, actualIndex, piece, isPossible) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _SquareColors.resolve(index: actualIndex, isSelected: isSelected),
        child: SquareContent(
          piece: piece,
          isPossibleMove: isPossible,
          isEmpty: piece.isEmpty,
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, int index, String piece, bool isPossible) {
    final bloc = context.read<GameBloc>();
    if (isPossible) {
      bloc.add(SquareSelected(index));
    } else if (piece.isNotEmpty && ChessUtils.isWhitePiece(piece) == state.isWhite) {
      bloc.add(PieceSelected(index, piece));
    }
  }
}

// ─── Player Card ──────────────────────────────────────────────────────────────

class _PlayerCard extends StatelessWidget {
  final UserModel user;
  final bool isOpponent;
  final VoidCallback? onTap;

  const _PlayerCard({
    required this.user,
    required this.isOpponent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: kAppSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kAppBorder),
        ),
        child: Row(
          children: [
            _PlayerAvatar(username: user.username),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                user.username,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _PieceSideIndicator(isOpponent: isOpponent),
          ],
        ),
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  final String username;
  const _PlayerAvatar({required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: kGoldGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: GoogleFonts.playfairDisplay(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: kAppBg,
        ),
      ),
    );
  }
}

class _PieceSideIndicator extends StatelessWidget {
  final bool isOpponent;
  const _PieceSideIndicator({required this.isOpponent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOpponent ? const Color(0xFF2C2C2C) : Colors.white,
        border: Border.all(color: kAppBorder),
      ),
    );
  }
}

// ─── State Cards ──────────────────────────────────────────────────────────────

class _StartPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kAppSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAppBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('♞', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            l10n.gameStartTitle,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.gameStartSubtitle,
            style: GoogleFonts.dmSans(fontSize: 13, color: kTextMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: l10n.gameStartButton,
            onTap: () => context.read<GameBloc>().add(StartGame()),
          ),
        ],
      ),
    );
  }
}

class _WaitingCard extends StatelessWidget {
  const _WaitingCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: kAppSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAppBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: kGold, strokeWidth: 2),
          const SizedBox(height: 20),
          Text(
            l10n.gameFindingOpponent,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kError.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kError.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: GoogleFonts.dmSans(color: const Color(0xFFE57373), fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─── Board Overlay Layer ──────────────────────────────────────────────────────

class _BoardOverlayLayer extends StatelessWidget {
  final GameInProgress state;
  const _BoardOverlayLayer({required this.state});

  @override
  Widget build(BuildContext context) {
    Widget overlay = const SizedBox.shrink(key: ValueKey('overlay-none'));

    if (state.isAtLivePosition) {
      if (state.isGameOver) {
        overlay = _GameOverOverlay(
          key: const ValueKey('overlay-game-over'),
          state: state,
        );
      } else if (state.isDrawOfferedByOpponent) {
        overlay = const _DrawOfferOverlay(key: ValueKey('overlay-offer'));
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      reverseDuration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final isOffer = (child.key as ValueKey?)?.value == 'overlay-offer';
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: isOffer ? const Offset(0, -0.06) : const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(fade),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(fade),
              child: child,
            ),
          ),
        );
      },
      child: overlay,
    );
  }
}

// ─── Draw Offer Overlay ───────────────────────────────────────────────────────

class _DrawOfferOverlay extends StatelessWidget {
  const _DrawOfferOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GameBloc>();
    final l10n = AppLocalizations.of(context)!;

    return IgnorePointer(
      ignoring: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: kAppSurface.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGold.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.handshake_outlined, size: 18, color: kGold),
              const SizedBox(width: 8),
              Text(
                l10n.drawOfferLabel,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(width: 12),
              GhostButton(
                label: l10n.drawDecline,
                onTap: () => bloc.add(DeclineDrawRequested()),
              ),
              const SizedBox(width: 6),
              PrimaryButton(
                label: l10n.drawAccept,
                onTap: () => bloc.add(AcceptDrawRequested()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Game Over Overlay ────────────────────────────────────────────────────────

class _GameOverOverlay extends StatelessWidget {
  final GameInProgress state;
  const _GameOverOverlay({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = state.gameResult;
    final winnerId = result?.winnerUserId;
    final myId = state.user?.id;
    final isDraw = result?.isDraw ?? winnerId == null;
    final iWon = !isDraw && myId != null && winnerId == myId;
    final reason = result?.endReason.displayName ?? l10n.gameOver;

    final title = isDraw ? l10n.gameDraw : iWon ? l10n.gameVictory : l10n.gameDefeat;
    final subtitle = isDraw
        ? l10n.gameResultDraw(reason)
        : iWon
        ? l10n.gameResultWon(reason)
        : l10n.gameResultLost(reason);

    return Container(
      color: Colors.black.withValues(alpha: 0.38),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B2A26), Color(0xFF1D1B18)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold.withValues(alpha: 0.45)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ResultIcon(isDraw: isDraw, iWon: iWon),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                color: kTextPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: kTextSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: l10n.gameStartNew,
              onTap: () => context.read<GameBloc>().add(StartGame()),
              wide: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultIcon extends StatelessWidget {
  final bool isDraw;
  final bool iWon;
  const _ResultIcon({required this.isDraw, required this.iWon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kGold.withValues(alpha: 0.14),
        border: Border.all(color: kGold.withValues(alpha: 0.42)),
      ),
      child: Icon(
        isDraw
            ? Icons.handshake_outlined
            : iWon
            ? Icons.emoji_events_outlined
            : Icons.flag_outlined,
        color: kGold,
        size: 28,
      ),
    );
  }
}

// ─── Promotion Picker ─────────────────────────────────────────────────────────

class _PromotionPickerDialog extends StatelessWidget {
  final bool isWhite;
  const _PromotionPickerDialog({required this.isWhite});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      MapEntry('q', isWhite ? 'Q' : 'q'),
      MapEntry('r', isWhite ? 'R' : 'r'),
      MapEntry('b', isWhite ? 'B' : 'b'),
      MapEntry('n', isWhite ? 'N' : 'n'),
    ];

    return AlertDialog(
      backgroundColor: kAppSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: kAppBorder),
      ),
      title: Text(
        l10n.promotionDialogTitle,
        style: GoogleFonts.dmSans(
          color: kTextPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 160,
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: options
              .map((e) => _PromotionPieceButton(
            promotion: e.key,
            pieceSymbol: e.value,
          ))
              .toList(),
        ),
      ),
      actions: [
        GhostButton(
          label: l10n.promotionCancel,
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _PromotionPieceButton extends StatelessWidget {
  final String promotion;
  final String pieceSymbol;
  const _PromotionPieceButton({
    required this.promotion,
    required this.pieceSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(context).pop(promotion),
      child: Ink(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kAppBorder),
          color: const Color(0x0DFFFFFF),
        ),
        child: PieceRenderer.getPieceImage(pieceSymbol),
      ),
    );
  }
}