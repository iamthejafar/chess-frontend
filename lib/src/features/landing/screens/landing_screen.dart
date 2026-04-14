import 'dart:math' as math;

import 'package:chess/l10n/app_localizations.dart';
import 'package:chess/src/core/app_routes.dart';
import 'package:chess/src/features/landing/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:logger/logger.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../core/colors.dart';
import '../../../shared/widgets/gold_divider.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../ches_board/widgets/knight_logo.dart';


class LandingScreen extends StatelessWidget {
  final Logger _logger = Logger();
  LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _handleAuthState,
      builder: (context, state) => Scaffold(
        backgroundColor: kBg,
        body: ScreenTypeLayout.builder(
          desktop: (_) => _HorizontalLayout(authState: state, variant: _LayoutVariant.desktop),
          tablet: (_) => _HorizontalLayout(authState: state, variant: _LayoutVariant.tablet),
          mobile: (_) => _MobileLayout(authState: state),
        ),
      ),
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      _logger.i('User authenticated: ${state.user.username}');
      Navigator.of(context).pushReplacementNamed(AppRoutes.game);
    } else if (state is AuthError) {
      _showErrorSnackbar(context, state.error);
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.dmSans(color: Colors.white)),
        backgroundColor: const Color(0xFF8B2020),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─── Layout Variant ───────────────────────────────────────────────────────────

enum _LayoutVariant { desktop, tablet }

extension _LayoutVariantX on _LayoutVariant {
  bool get isDesktop => this == _LayoutVariant.desktop;

  double titleFontSize(double width) => _lerp(
    width,
    min: isDesktop ? 64 : 24,
    max: isDesktop ? 88 : 48,
  );

  double taglineFontSize(double width) => _lerp(width, min: isDesktop ? 18 : 16, max: 24);

  double bodyWidth(Size size) => isDesktop ? 420 : size.width * 0.3;

  double _lerp(double width, {required double min, required double max}) =>
      (min + (max - min) * ((width - 900) / 600)).clamp(min, max);
}

// ─── Chess Board Background ───────────────────────────────────────────────────

class _ChessBoardPainter extends CustomPainter {
  const _ChessBoardPainter();

  static const _tileSize = 60.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cols = (size.width / _tileSize).ceil() + 1;
    final rows = (size.height / _tileSize).ceil() + 1;
    final paint = Paint();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final isDark = (r + c) % 2 == 0;
        paint.color =
        isDark ? const Color.fromRGBO(255, 255, 255, 0.018) : Colors.transparent;
        canvas.drawRect(
          Rect.fromLTWH(c * _tileSize, r * _tileSize, _tileSize, _tileSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ChessBoardPainter old) => false;
}

// ─── Reusable: Glow Circle ────────────────────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlowCircle({required this.size, this.opacity = 0.07});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [kGold.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }
}

// ─── Reusable: Scene Background ───────────────────────────────────────────────

class _SceneBackground extends StatelessWidget {
  final List<_GlowPlacement> glows;

  const _SceneBackground({required this.glows});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _ChessBoardPainter())),
        ...glows.map((g) => Positioned(
          left: g.left,
          right: g.right,
          top: g.top,
          bottom: g.bottom,
          child: _GlowCircle(size: g.size, opacity: g.opacity),
        )),
      ],
    );
  }
}

class _GlowPlacement {
  final double? left, right, top, bottom;
  final double size;
  final double opacity;

  const _GlowPlacement({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
    this.opacity = 0.07,
  });
}

// ─── Reusable: CTA Group ──────────────────────────────────────────────────────

class _AuthButton extends StatelessWidget {
  final AuthState authState;
  final bool stacked;

  const _AuthButton({required this.authState, required this.stacked});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = authState is AuthLoading;
    final onGuestTap = isLoading
        ? null
        : () => context.read<AuthBloc>().add(GuestSignInRequested());

    final buttons = [
      PrimaryButton(
        label: l10n.landingGuestCta,
        onTap: onGuestTap,
        isLoading: isLoading,
      ),
      const Gap(12),
      web.renderButton(
        configuration: web.GSIButtonConfiguration(
          size: web.GSIButtonSize.large,
          type: web.GSIButtonType.standard,
        ),
      ),
    ];

    return stacked
        ? Column(children: buttons)
        : Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }
}

// ─── Reusable: Brand Text Column ──────────────────────────────────────────────

class _BrandContent extends StatelessWidget {
  final AuthState authState;
  final double titleSize;
  final double taglineSize;
  final double bodyWidth;
  final bool stackedCta;

  const _BrandContent({
    required this.authState,
    required this.titleSize,
    required this.taglineSize,
    required this.bodyWidth,
    required this.stackedCta,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GoldDivider(width: 20),
        const SizedBox(height: 24),
        Text(
          l10n.landingTitle,
          style: GoogleFonts.playfairDisplay(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            color: kCream,
            letterSpacing: 8,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.landingTagline,
          style: GoogleFonts.playfairDisplay(
            fontSize: taglineSize,
            fontStyle: FontStyle.italic,
            color: kGold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: bodyWidth,
          child: Text(
            l10n.landingBody,
            style: GoogleFonts.dmSans(fontSize: 16, color: kMuted, height: 1.7),
          ),
        ),
        const SizedBox(height: 32),
        _AuthButton(authState: authState, stacked: stackedCta),
      ],
    );
  }
}

// ─── Mobile Layout ────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final AuthState authState;
  const _MobileLayout({required this.authState});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      alignment: Alignment.center,
      children: [
        _SceneBackground(glows: [
          _GlowPlacement(left: 0, right: 0, top: -80, size: 320, opacity: 0.08),
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: KnightLogo(size: 110)),
              const SizedBox(height: 28),
              const GoldDivider(width: 20),
              const SizedBox(height: 18),
              Text(
                l10n.landingTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: kCream,
                  letterSpacing: 6,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.landingTaglineMobile,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: kMuted,
                  height: 1.65,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 28),
              _AuthButton(authState: authState, stacked: true),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Horizontal Layout (Desktop + Tablet) ─────────────────────────────────────

class _HorizontalLayout extends StatelessWidget {
  final AuthState authState;
  final _LayoutVariant variant;

  const _HorizontalLayout({
    required this.authState,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        _SceneBackground(glows: [
          _GlowPlacement(left: -100, top: size.height * 0.2, size: 400),
          _GlowPlacement(right: -80, top: size.height * 0.3, size: 500, opacity: 0.05),
        ]),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: _BrandContent(
                  authState: authState,
                  titleSize: variant.titleFontSize(size.width),
                  taglineSize: variant.taglineFontSize(size.width),
                  bodyWidth: variant.bodyWidth(size),
                  stackedCta: !variant.isDesktop,
                ),
              ),
              Expanded(
                flex: 4,
                child: Center(
                  child: KnightLogo(size: math.min(size.height * 0.55, 480)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}