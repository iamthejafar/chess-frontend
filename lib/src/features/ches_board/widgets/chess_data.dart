import 'package:chess/src/features/ches_board/widgets/move_widget.dart';
import 'package:chess/src/utils/chess_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/colors.dart';
import '../../../shared/widgets/ghost_button.dart';
import '../../../shared/widgets/primary_button.dart';
import '../bloc/game_bloc.dart';

// ─── Root ─────────────────────────────────────────────────────────────────────

class ChessData extends StatelessWidget {
  const ChessData({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state is! GameInProgress) return const SizedBox.shrink();

        final l10n = AppLocalizations.of(context)!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(label: l10n.dataSectionGameInfo),
            const _SectionDivider(),
            Expanded(child: _GameDataPanel(state: state)),
          ],
        );
      },
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: kTextMuted,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ─── Game Data Panel ──────────────────────────────────────────────────────────

/// Renamed from `_DataPanel` to avoid ambiguity with `_DataPanel` in chess_screen.dart.
class _GameDataPanel extends StatelessWidget {
  final GameInProgress state;
  const _GameDataPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TurnBanner(isWhiteTurn: state.game.turn == 0),
        if (state.hasPendingDrawOffer && !state.isGameOver)
          _DrawOfferBanner(state: state),
        const _SectionDivider(),
        Expanded(child: _MoveHistory(state: state)),
        const _SectionDivider(),
        _Controls(state: state),
      ],
    );
  }
}

// ─── Draw Offer Banner ────────────────────────────────────────────────────────

class _DrawOfferBanner extends StatelessWidget {
  final GameInProgress state;
  const _DrawOfferBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = state.isDrawOfferedByOpponent
        ? l10n.drawBannerOpponentOffered
        : l10n.drawBannerSent;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kGold.withValues(alpha: 0.08),
        border: Border.all(color: kGold.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.handshake_outlined, size: 16, color: kGold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Turn Banner ──────────────────────────────────────────────────────────────

class _TurnBanner extends StatelessWidget {
  final bool isWhiteTurn;
  const _TurnBanner({required this.isWhiteTurn});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Text(
            l10n.dataSectionTurn,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kTextMuted,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _TurnPill(key: ValueKey(isWhiteTurn), isWhite: isWhiteTurn),
          ),
        ],
      ),
    );
  }
}

class _TurnPill extends StatelessWidget {
  final bool isWhite;
  const _TurnPill({super.key, required this.isWhite});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isWhite
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isWhite ? Colors.white.withValues(alpha: 0.2) : kAppBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWhite ? Colors.white : const Color(0xFF2A2A2A),
              border: Border.all(color: kAppBorder),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            isWhite ? l10n.turnWhite : l10n.turnBlack,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isWhite ? Colors.white : kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Move History ─────────────────────────────────────────────────────────────

class _MoveHistory extends StatelessWidget {
  final GameInProgress state;
  const _MoveHistory({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyCount = state.game.history.length - 1;

    if (historyCount == 0) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '♟',
                style: TextStyle(
                  fontSize: 28,
                  color: kTextMuted.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.movesNone,
                style: GoogleFonts.dmSans(fontSize: 13, color: kTextMuted),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: l10n.dataSectionMoves),
        Expanded(child: _MoveGrid(state: state, historyCount: historyCount)),
      ],
    );
  }
}

// ─── Move Grid ────────────────────────────────────────────────────────────────

class _MoveGrid extends StatelessWidget {
  final GameInProgress state;
  final int historyCount;
  const _MoveGrid({required this.state, required this.historyCount});

  @override
  Widget build(BuildContext context) {
    // viewingIndex 0 = initial position; viewingIndex N = move at history[N-1].
    final activeHistoryIndex = state.viewingIndex - 1;

    final pairs = <List<int>>[];
    for (var i = 0; i < historyCount; i += 2) {
      pairs.add([i, if (i + 1 < historyCount) i + 1]);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: pairs.length,
      itemBuilder: (context, pairIndex) {
        final indices = pairs[pairIndex];
        final rowActive = indices.any((i) => i == activeHistoryIndex);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: rowActive ? kGold.withValues(alpha: 0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: rowActive
                ? Border.all(color: kGold.withValues(alpha: 0.15))
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${pairIndex + 1}.',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kTextMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: _MoveTile(
                    index: indices[0],
                    state: state,
                    highlight: indices[0] == activeHistoryIndex,
                  ),
                ),
                Expanded(
                  child: indices.length > 1
                      ? _MoveTile(
                    index: indices[1],
                    state: state,
                    highlight: indices[1] == activeHistoryIndex,
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Move Tile ────────────────────────────────────────────────────────────────

class _MoveTile extends StatelessWidget {
  final int index;
  final GameInProgress state;
  final bool highlight;
  const _MoveTile({
    required this.index,
    required this.state,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final move = ChessUtils.extractMoveDetails(state.game.history[index + 1]);
    if (move == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.read<GameBloc>().add(NavigateToMove(index + 1)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: MoveWidget(move: move, highlight: highlight),
      ),
    );
  }
}

// ─── Controls ─────────────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  final GameInProgress state;
  const _Controls({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<GameBloc>();
    final canAct = !state.isGameOver;
    final drawPending = state.hasPendingDrawOffer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SizedBox(
        height: 40,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ControlBtn(
                icon: Icons.skip_previous_rounded,
                tooltip: l10n.controlTooltipFirstMove,
                enabled: state.canGoBack,
                onTap: () => bloc.add(NavigateFirstMove()),
              ),
              _ControlBtn(
                icon: Icons.chevron_left_rounded,
                tooltip: l10n.controlTooltipPrevMove,
                enabled: state.canGoBack,
                onTap: () => bloc.add(NavigatePreviousMove()),
              ),
              _ControlBtn(
                icon: Icons.chevron_right_rounded,
                tooltip: l10n.controlTooltipNextMove,
                enabled: state.canGoForward,
                onTap: () => bloc.add(NavigateNextMove()),
              ),
              _ControlBtn(
                icon: Icons.skip_next_rounded,
                tooltip: l10n.controlTooltipLastMove,
                enabled: state.canGoForward,
                onTap: () => bloc.add(NavigateLastMove()),
              ),
              const SizedBox(width: 12),
              _ControlBtn(
                icon: Icons.handshake_outlined,
                tooltip: drawPending
                    ? l10n.controlTooltipDrawPending
                    : l10n.controlTooltipOfferDraw,
                enabled: canAct && !drawPending,
                onTap: () => _OfferDrawDialog.show(context),
                color: kGold,
              ),
              _ControlBtn(
                icon: Icons.flag_outlined,
                tooltip: l10n.controlTooltipResign,
                enabled: canAct,
                onTap: () => _ResignDialog.show(context),
                color: kError,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared: Confirmation Dialog ──────────────────────────────────────────────

/// Base for simple two-action (cancel / confirm) dialogs used in this screen.
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.title,
    required this.content,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: kAppSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: kAppBorder),
      ),
      title: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          color: kTextPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        content,
        style: GoogleFonts.dmSans(color: kTextSecondary, fontSize: 14),
      ),
      actions: [
        GhostButton(
          label: l10n.dialogCancel,
          onTap: () => Navigator.pop(context),
        ),
        PrimaryButton(
          label: confirmLabel,
          onTap: () {
            Navigator.pop(context);
            onConfirm();
          },
        ),
      ],
    );
  }
}

// ─── Offer Draw Dialog ────────────────────────────────────────────────────────

class _OfferDrawDialog {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: l10n.offerDrawDialogTitle,
        content: l10n.offerDrawDialogContent,
        confirmLabel: l10n.offerDrawDialogConfirm,
        onConfirm: () => context.read<GameBloc>().add(OfferDrawRequested()),
      ),
    );
  }
}

// ─── Resign Dialog ────────────────────────────────────────────────────────────

class _ResignDialog {
  static void show(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: l10n.resignDialogTitle,
        content: l10n.resignDialogContent,
        confirmLabel: l10n.resignDialogConfirm,
        onConfirm: () => context.read<GameBloc>().add(ResignRequested()),
      ),
    );
  }
}

// ─── Control Button ───────────────────────────────────────────────────────────

class _ControlBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;
  final bool enabled;

  const _ControlBtn({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color,
    this.enabled = true,
  });

  @override
  State<_ControlBtn> createState() => _ControlBtnState();
}

class _ControlBtnState extends State<_ControlBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? kTextSecondary;

    return MouseRegion(
      onEnter: (_) { if (widget.enabled) setState(() => _hovered = true); },
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _hovered && widget.enabled ? kAppBorder : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: !widget.enabled
                  ? kTextMuted.withValues(alpha: 0.3)
                  : _hovered
                  ? (widget.color ?? kTextPrimary)
                  : activeColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared Divider ───────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: kAppBorder);
}