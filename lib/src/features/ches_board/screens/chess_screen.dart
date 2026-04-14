import 'package:chess/src/core/app_routes.dart';
import 'package:chess/src/features/ches_board/bloc/game_bloc.dart';
import 'package:chess/src/features/ches_board/widgets/chess_data.dart';
import 'package:chess/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/colors.dart';
import '../widgets/chess_board.dart';
import '../widgets/knight_logo.dart';

// ─── Layout Constants ─────────────────────────────────────────────────────────

abstract class _Sizes {
  static const navRailDesktop   = 64.0;
  static const dataPanelDesktop = 260.0;
  static const dataPanelTablet  = 220.0;
  static const mobileLogoSize   = 32.0;
  static const mobileTitleFont  = 20.0;
  static const mobileBarHeight  = 56.0;
}

// ─── Root ─────────────────────────────────────────────────────────────────────

class ChessScreen extends StatelessWidget {
  const ChessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(),
      child: Scaffold(
        backgroundColor: kAppBg,
        body: MultiBlocListener(
          listeners: [
            BlocListener<GameBloc, GameState>(
              listenWhen: _isDrawDeclined,
              listener: _onDrawDeclined,
            ),
            BlocListener<GameBloc, GameState>(
              listenWhen: _isGameIdChanged,
              listener: _onGameIdChanged,
            ),
          ],
          child: ScreenTypeLayout.builder(
            desktop: (_) => const _DesktopLayout(),
            tablet:  (_) => const _TabletLayout(),
            mobile:  (_) => const _MobileLayout(),
          ),
        ),
      ),
    );
  }

  bool _isDrawDeclined(GameState prev, GameState curr) {
    if (prev is! GameInProgress || curr is! GameInProgress) return false;
    return prev.isDrawOfferedByMe && !curr.hasPendingDrawOffer && !curr.isGameOver;
  }

  void _onDrawDeclined(BuildContext context, GameState state) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.drawOfferDeclinedByOpponent)));
  }

  bool _isGameIdChanged(GameState prev, GameState curr) {
    if (curr is! GameInProgress || curr.gameId.isEmpty) return false;
    return (prev is GameInProgress ? prev.gameId : null) != curr.gameId;
  }

  void _onGameIdChanged(BuildContext context, GameState state) {
    if (state is! GameInProgress) return;
    SystemNavigator.routeInformationUpdated(
      location: AppRoutes.gameWithId(state.gameId),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP  ┌─────────┬────────────────────────────────┬───────────────┐
//          │  Nav    │                                │               │
//          │  Rail   │   Board  (square, centered)    │  Data Panel   │
//          │  64 px  │                                │    260 px     │
//          └─────────┴────────────────────────────────┴───────────────┘
// ═══════════════════════════════════════════════════════════════════════════════

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _NavRail(width: _Sizes.navRailDesktop),
        const Expanded(
          child: Center(child: ChessBoard()),
        ),
        _DataPanelContainer(
          width: _Sizes.dataPanelDesktop,
          border: const Border(left: BorderSide(color: kAppBorder)),
          child: ChessData(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TABLET   ┌──────────────────────────────────┬───────────────┐
//          │                                  │               │
//          │   Board  (square, centered)      │  Data Panel   │
//          │                                  │    220 px     │
//          └──────────────────────────────────┴───────────────┘
//
//  No nav rail — too narrow. Profile reachable via player cards.
// ═══════════════════════════════════════════════════════════════════════════════

class _TabletLayout extends StatelessWidget {
  const _TabletLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Center(child: ChessBoard()),
        ),
        _DataPanelContainer(
          width: _Sizes.dataPanelTablet,
          border: const Border(left: BorderSide(color: kAppBorder)),
          child: ChessData(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MOBILE   ┌──────────────────────┐
//          │  App Bar  (56 px)    │
//          ├──────────────────────┤
//          │  ╔══════════════╗    │
//          │  ║ Board        ║    │  flex 3 — takes ~60% of remaining height
//          │  ║ (square)     ║    │  ChessBoard self-constrains to a square
//          │  ╚══════════════╝    │
//          ├──────────────────────┤
//          │  Chess Data          │  flex 2 — takes ~40%, internally scrollable
//          └──────────────────────┘
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const _MobileAppBar(),
          const Divider(color: kAppBorder, height: 1),
          const Expanded(
            flex: 3,
            child: Center(child: ChessBoard()),
          ),
          const Divider(color: kAppBorder, height: 1),
          Expanded(
            flex: 2,
            child: _DataPanelContainer(
              border: const Border(top: BorderSide(color: kAppBorder)),
              child: ChessData(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared: Data Panel Container ────────────────────────────────────────────
//
// Used for desktop/tablet side panel (with explicit width) and mobile
// bottom panel (no width — fills parent via Expanded).

class _DataPanelContainer extends StatelessWidget {
  final Widget child;
  final Border border;
  final double? width;

  const _DataPanelContainer({
    required this.child,
    required this.border,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(color: kAppSurface, border: border),
      child: child,
    );
  }
}

// ─── Mobile App Bar ───────────────────────────────────────────────────────────

class _MobileAppBar extends StatelessWidget {
  const _MobileAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: _Sizes.mobileBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            KnightLogo(size: _Sizes.mobileLogoSize),
            const SizedBox(width: 10),
            Text(
              l10n.appTitle.toUpperCase(),
              style: GoogleFonts.playfairDisplay(
                fontSize: _Sizes.mobileTitleFont,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                letterSpacing: 4,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: kTextSecondary),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Nav Rail (desktop only) ──────────────────────────────────────────────────

class _NavRail extends StatelessWidget {
  final double width;
  const _NavRail({required this.width});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: kAppSurface,
        border: Border(right: BorderSide(color: kAppBorder)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          KnightLogo(size: 36),
          const SizedBox(height: 32),
          _NavIcon(icon: Icons.grid_4x4_rounded, tooltip: l10n.navBoard, active: true),
          const Spacer(),
          _NavIcon(
            icon: Icons.person_outline_rounded,
            tooltip: l10n.navProfile,
            onTap: () => _navigateToProfile(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _navigateToProfile(BuildContext context) async {
    final userId = await StorageService().getUserId();
    if (userId != null && context.mounted) {
      Navigator.of(context).pushNamed(
        AppRoutes.profile,
        arguments: ProfileRouteArgs(userId: userId, viewerUserId: userId),
      );
    }
  }
}

// ─── Nav Icon ─────────────────────────────────────────────────────────────────

class _NavIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback? onTap;

  const _NavIcon({
    required this.icon,
    required this.tooltip,
    this.active = false,
    this.onTap,
  });

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.active
                  ? kGold.withOpacity(0.12)
                  : _hovered ? kAppBorder : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: widget.active
                  ? Border.all(color: kGold.withOpacity(0.3))
                  : null,
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: widget.active
                  ? kGold
                  : _hovered ? kTextPrimary : kTextMuted,
            ),
          ),
        ),
      ),
    );
  }
}