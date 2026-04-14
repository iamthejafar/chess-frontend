import 'package:chess/src/core/colors.dart';
import 'package:chess/src/features/ches_board/widgets/knight_logo.dart';
import 'package:chess/src/features/landing/bloc/auth_bloc.dart';
import 'package:chess/src/features/landing/models/user_model.dart';
import 'package:chess/src/features/landing/repositories/user_repository.dart';
import 'package:chess/src/features/profile/bloc/profile_bloc.dart';
import 'package:chess/src/features/profile/models/game_history_models.dart';
import 'package:chess/src/services/storage_service.dart';
import 'package:chess/src/shared/widgets/ghost_button.dart';
import 'package:chess/src/shared/widgets/primary_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../l10n/app_localizations.dart';

// ─── Data Holders ─────────────────────────────────────────────────────────────

/// Bundles the six identical history-related params that every layout widget
/// previously declared separately. Pass one [_HistoryProps] instead.
class _HistoryProps {
  const _HistoryProps({
    required this.games,
    required this.isLoading,
    required this.hasMore,
    required this.error,
    required this.onLoadMore,
  });

  final List<GameHistoryItem> games;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final VoidCallback onLoadMore;
}

/// Returned by [_EditProfileDialog] on confirm.
class _EditProfileData {
  const _EditProfileData({required this.name, required this.username});
  final String name;
  final String username;
}

// ─── Date Formatter (single source of truth) ─────────────────────────────────

abstract class _DateFormatters {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Returns "Jan 5, 2024".
  static String date(DateTime dt) =>
      '${_months[dt.month - 1]} ${dt.day}, ${dt.year}';

  /// Returns "Jan 5, 2024 14:30". Falls back to [fallback] when null.
  static String dateTime(DateTime? value, {required String fallback}) {
    if (value == null) return fallback;
    final local = value.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${date(local)} $hh:$mm';
  }
}

// ─── Entry Point ──────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.userId,
    required this.viewerUserId,
  });

  final String userId;
  final String? viewerUserId;

  bool get _canEdit => viewerUserId == userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(
        userRepository: UserRepository(),
        storageService: StorageService(),
      )..add(ProfileLoadRequested(userId: userId)),
      child: _ProfileView(userId: userId, canEdit: _canEdit),
    );
  }
}

// ─── Profile View ─────────────────────────────────────────────────────────────

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.userId, required this.canEdit});

  final String userId;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: _handleState,
      builder: (context, state) => Scaffold(
        backgroundColor: kAppBg,
        body: _ProfileBodySwitcher(
          state: state,
          userId: userId,
          canEdit: canEdit,
          onEdit: (user) => _showEditDialog(context, user),
          onUploadPhoto: (uid) => _pickAndUploadPhoto(context, uid),
        ),
      ),
    );
  }

  void _handleState(BuildContext context, ProfileState state) {
    if (state is ProfileUpdateSuccess) {
      _showSnackBar(
        context,
        icon: Icons.check_circle_outline,
        iconColor: kSuccess,
        message: state.message,
      );
    } else if (state is ProfileError) {
      _showSnackBar(
        context,
        icon: Icons.error_outline,
        iconColor: kGoldLight,
        message: state.message,
        expanded: true,
      );
    } else if (state is ProfileDeleted) {
      context.read<AuthBloc>().add(SignOutRequested());
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _showSnackBar(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String message,
        bool expanded = false,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const Gap(8),
            expanded ? Expanded(child: Text(message)) : Text(message),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, UserModel user) async {
    final bloc = context.read<ProfileBloc>();
    final result = await showDialog<_EditProfileData>(
      context: context,
      builder: (_) => _EditProfileDialog(user: user),
    );
    if (result == null) return;
    bloc.add(ProfileUpdateRequested(
      userId: user.id,
      name: result.name,
      username: result.username,
    ));
  }

  Future<void> _pickAndUploadPhoto(BuildContext context, String uid) async {
    final bloc = context.read<ProfileBloc>();
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.single;
    final hasPath = file.path != null && file.path!.isNotEmpty;
    final hasBytes = file.bytes != null && file.bytes!.isNotEmpty;
    if (!hasPath && !hasBytes) return;
    bloc.add(ProfilePhotoUploadRequested(
      userId: uid,
      filePath: hasPath ? file.path : null,
      fileBytes: hasBytes ? file.bytes : null,
      fileName: file.name,
    ));
  }
}

// ─── Body Switcher ────────────────────────────────────────────────────────────

/// Replaces the `_buildBody` method-on-widget anti-pattern with a proper widget.
class _ProfileBodySwitcher extends StatelessWidget {
  const _ProfileBodySwitcher({
    required this.state,
    required this.userId,
    required this.canEdit,
    required this.onEdit,
    required this.onUploadPhoto,
  });

  final ProfileState state;
  final String userId;
  final bool canEdit;
  final void Function(UserModel) onEdit;
  final void Function(String) onUploadPhoto;

  @override
  Widget build(BuildContext context) {
    if (state is ProfileLoading || state is ProfileInitial) {
      return const Center(child: CircularProgressIndicator(color: kGold));
    }

    if (state is ProfileError) {
      return _ErrorView(
        message: (state as ProfileError).message,
        onRetry: () => context
            .read<ProfileBloc>()
            .add(ProfileLoadRequested(userId: userId)),
      );
    }

    if (state is ProfileLoaded) {
      final loaded = state as ProfileLoaded;
      final history = _HistoryProps(
        games: loaded.games,
        isLoading: loaded.isHistoryLoading,
        hasMore: loaded.hasMoreHistory,
        error: loaded.historyError,
        onLoadMore: () => context
            .read<ProfileBloc>()
            .add(ProfileHistoryLoadRequested(userId: loaded.user.id)),
      );

      return Stack(
        children: [
          _ProfilePage(
            user: loaded.user,
            canEdit: canEdit,
            isBusy: loaded.isBusy,
            history: history,
            onEdit: () => onEdit(loaded.user),
            onUploadPhoto: () => onUploadPhoto(loaded.user.id),
          ),
          if (loaded.isBusy) _BusyOverlay(message: loaded.busyMessage),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── Profile Page Shell ───────────────────────────────────────────────────────

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({
    required this.user,
    required this.canEdit,
    required this.isBusy,
    required this.history,
    required this.onEdit,
    required this.onUploadPhoto,
  });

  final UserModel user;
  final bool canEdit;
  final bool isBusy;
  final _HistoryProps history;
  final VoidCallback onEdit;
  final VoidCallback onUploadPhoto;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 280;
    if (_scrollController.position.pixels >= threshold) {
      widget.history.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopNav(
          canEdit: widget.canEdit,
          isBusy: widget.isBusy,
          onEdit: widget.onEdit,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroBanner(
                  user: widget.user,
                  canEdit: widget.canEdit,
                  onUploadPhoto: widget.onUploadPhoto,
                ),
                ScreenTypeLayout.builder(
                  mobile: (_) => _MobileLayout(
                    user: widget.user,
                    history: widget.history,
                  ),
                  tablet: (_) => _TabletLayout(
                    user: widget.user,
                    history: widget.history,
                  ),
                  desktop: (_) => _DesktopLayout(
                    user: widget.user,
                    history: widget.history,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Top Nav ──────────────────────────────────────────────────────────────────

class _TopNav extends StatelessWidget {
  const _TopNav({
    required this.canEdit,
    required this.isBusy,
    required this.onEdit,
  });

  final bool canEdit;
  final bool isBusy;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: kAppBg,
        border: Border(bottom: BorderSide(color: kAppBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          KnightLogo(size: 36),
          const Spacer(),
          if (canEdit)
            _NavActionButton(
              icon: Icons.edit_outlined,
              label: l10n.profileEditButton,
              onTap: isBusy ? null : onEdit,
            ),
        ],
      ),
    );
  }
}

// ─── Nav Action Button ────────────────────────────────────────────────────────
//
// Kept as a custom widget because GhostButton is label-only and does not
// support a leading icon. If GhostButton gains an `icon` parameter in the
// future, this can be replaced.

class _NavActionButton extends StatefulWidget {
  const _NavActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_NavActionButton> createState() => _NavActionButtonState();
}

class _NavActionButtonState extends State<_NavActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered && !disabled ? kAppSurface2 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kAppBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: disabled ? kTextMuted : kTextPrimary,
              ),
              const Gap(6),
              Text(
                widget.label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: disabled ? kTextMuted : kTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hero Banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.user,
    required this.canEdit,
    required this.onUploadPhoto,
  });

  final UserModel user;
  final bool canEdit;
  final VoidCallback onUploadPhoto;

  @override
  Widget build(BuildContext context) {
    final horizontalPad = getValueForScreenType<double>(
      context: context,
      mobile: 20,
      tablet: 40,
      desktop: 64,
    );

    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: _ChessPatternPainter())),
          Positioned.fill(
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, kAppBg],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: horizontalPad,
            right: horizontalPad,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _AvatarStack(
                  user: user,
                  canEdit: canEdit,
                  onUploadPhoto: onUploadPhoto,
                ),
                const Gap(16),
                Expanded(child: _UserMeta(user: user)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar Stack ─────────────────────────────────────────────────────────────
//
// Extracted from _HeroBanner to eliminate the initials duplication that existed
// between the main avatar and the errorBuilder fallback.

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({
    required this.user,
    required this.canEdit,
    required this.onUploadPhoto,
  });

  final UserModel user;
  final bool canEdit;
  final VoidCallback onUploadPhoto;

  String get _initials =>
      user.username.isNotEmpty ? user.username[0].toUpperCase() : '?';

  String? get _imageUrl {
    final picture = user.picture;
    if (picture == null || picture.isEmpty) return null;
    if (picture.startsWith('http')) return picture;
    return UserRepository().getProfilePhotoUrl(picture);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kAppBg, width: 3),
            boxShadow: [
              BoxShadow(color: kGold.withValues(alpha: 0.18), blurRadius: 18),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: _imageUrl == null
                ? _AvatarFallback(initials: _initials)
                : Image.network(
              _imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _AvatarFallback(initials: _initials),
            ),
          ),
        ),
        if (canEdit)
          Positioned(
            right: -5,
            bottom: -5,
            child: GestureDetector(
              onTap: onUploadPhoto,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: kGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: kAppBg, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 13,
                  color: kAppBg,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Initials fallback used both as the default avatar and as the Image error
/// builder — previously duplicated inline inside _HeroBanner.
class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kAppSurface2,
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: kGold,
          ),
        ),
      ),
    );
  }
}

// ─── User Meta ────────────────────────────────────────────────────────────────

class _UserMeta extends StatelessWidget {
  const _UserMeta({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName =
    user.name?.trim().isNotEmpty == true ? user.name! : user.username;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                displayName,
                style: GoogleFonts.playfairDisplay(
                  color: kTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isGuest) ...[
              const Gap(8),
              _Chip(label: l10n.profileChipGuest, color: kTextMuted),
            ],
          ],
        ),
        const Gap(3),
        Text(
          '@${user.username}',
          style: GoogleFonts.dmSans(
            color: kGold,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(8),
        _RatingPill(rating: user.rating ?? 0),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LAYOUTS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Desktop (≥ 1200 px) ─────────────────────────────────────────────────────
//
//  ┌─────────────┬─────────────────────────────────┐
//  │ Account     │ Performance                     │
//  │ Stats       │ Game History                    │
//  └─────────────┴─────────────────────────────────┘

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.user, required this.history});

  final UserModel user;
  final _HistoryProps history;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(64, 28, 64, 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              SizedBox(width: 260, child: _AccountCard(user: user)),
              const Gap(16),
              SizedBox(width: 260, child: _StatsCard(user: user)),
            ],
          ),
          const Gap(16),
          Expanded(
            child: Column(
              children: [
                _PerformanceCard(user: user),
                const Gap(16),
                _GameHistoryCard(userId: user.id, history: history),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tablet (600–1199 px) ─────────────────────────────────────────────────────
//
//  ┌──────────────────────┬──────────────┐
//  │ Stats (flex)         │ Account 220  │
//  ├──────────────────────┴──────────────┤
//  │ Performance                         │
//  │ Game History                        │
//  └─────────────────────────────────────┘

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.user, required this.history});

  final UserModel user;
  final _HistoryProps history;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 24, 40, 48),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _StatsCard(user: user)),
              const Gap(16),
              SizedBox(width: 220, child: _AccountCard(user: user)),
            ],
          ),
          const Gap(16),
          _PerformanceCard(user: user),
          const Gap(16),
          _GameHistoryCard(userId: user.id, history: history),
        ],
      ),
    );
  }
}

// ─── Mobile (< 600 px) ───────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.user, required this.history});

  final UserModel user;
  final _HistoryProps history;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Column(
        children: [
          _StatsCard(user: user),
          const Gap(14),
          _PerformanceCard(user: user),
          const Gap(14),
          _AccountCard(user: user),
          const Gap(14),
          _GameHistoryCard(userId: user.id, history: history),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARDS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Account Card ─────────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasEmail = user.email?.isNotEmpty == true;
    final hasDate = user.createdAt != null;
    if (!hasEmail && !hasDate) return const SizedBox.shrink();

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.person_outline_rounded,
            title: l10n.profileSectionAccount,
          ),
          if (hasEmail)
            _InfoTile(
              icon: Icons.email_outlined,
              label: l10n.profileAccountEmail,
              value: user.email!,
              showDivider: hasDate,
            ),
          if (hasDate)
            _InfoTile(
              icon: Icons.calendar_today_outlined,
              label: l10n.profileAccountMemberSince,
              // _DateFormatters.date is the unified path — no more _formatDate in card
              value: _DateFormatters.date(user.createdAt!),
              showDivider: false,
            ),
        ],
      ),
    );
  }
}

// ─── Stats Card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.bar_chart_rounded,
            title: l10n.profileSectionStats,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: l10n.profileStatGames,
                        value: '${user.gamesPlayed ?? 0}',
                        color: kGold,
                      ),
                    ),
                    _VerticalDivider(),
                    Expanded(
                      child: _StatTile(
                        label: l10n.profileStatWon,
                        value: '${user.gamesWon ?? 0}',
                        color: kSuccess,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: l10n.profileStatLost,
                        value: '${user.gamesLost ?? 0}',
                        color: kError,
                      ),
                    ),
                    _VerticalDivider(),
                    Expanded(
                      child: _StatTile(
                        label: l10n.profileStatDraw,
                        value: '${user.gamesDraw ?? 0}',
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Performance Card ─────────────────────────────────────────────────────────

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = user.gamesPlayed ?? 0;
    final won = user.gamesWon ?? 0;
    final lost = user.gamesLost ?? 0;
    final draw = user.gamesDraw ?? 0;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.emoji_events_outlined,
            title: l10n.profileSectionPerformance,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                _BarRow(
                  label: l10n.profilePerfWinRate,
                  value: total > 0 ? won / total : 0.0,
                  color: kSuccess,
                ),
                const Gap(12),
                _BarRow(
                  label: l10n.profilePerfLossRate,
                  value: total > 0 ? lost / total : 0.0,
                  color: kError,
                ),
                const Gap(12),
                _BarRow(
                  label: l10n.profilePerfDrawRate,
                  value: total > 0 ? draw / total : 0.0,
                  color: kTextSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Game History Card ────────────────────────────────────────────────────────

class _GameHistoryCard extends StatelessWidget {
  const _GameHistoryCard({required this.userId, required this.history});

  final String userId;
  final _HistoryProps history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.history_toggle_off_rounded,
            title: l10n.profileSectionHistory,
          ),
          _GameHistoryBody(
            userId: userId,
            history: history,
          ),
        ],
      ),
    );
  }
}

/// Body extracted so `_GameHistoryCard` stays focused on its card shell.
class _GameHistoryBody extends StatelessWidget {
  const _GameHistoryBody({required this.userId, required this.history});

  final String userId;
  final _HistoryProps history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (history.games.isEmpty && history.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: kGold)),
      );
    }

    if (history.games.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Text(
          history.error ?? l10n.profileHistoryNoGames,
          style: GoogleFonts.dmSans(color: kTextSecondary, fontSize: 13),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          for (var i = 0; i < history.games.length; i++)
            _GameHistoryRow(
              userId: userId,
              game: history.games[i],
              showDivider: i < history.games.length - 1,
            ),
          if (history.error != null)
            _HistoryErrorFooter(
              message: history.error!,
              onRetry: history.onLoadMore,
            ),
          if (history.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: CircularProgressIndicator(color: kGold, strokeWidth: 2),
            )
          else if (!history.hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                l10n.profileHistoryEndReached,
                style: GoogleFonts.dmSans(color: kTextMuted, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

/// Extracted so the inline TextButton in _GameHistoryCard is replaced by
/// GhostButton and the row stays readable.
class _HistoryErrorFooter extends StatelessWidget {
  const _HistoryErrorFooter({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(color: kError, fontSize: 12),
            ),
          ),
          GhostButton(label: l10n.profileHistoryRetry, onTap: onRetry),
        ],
      ),
    );
  }
}

// ─── Game History Row ─────────────────────────────────────────────────────────

class _GameHistoryRow extends StatelessWidget {
  const _GameHistoryRow({
    required this.userId,
    required this.game,
    required this.showDivider,
  });

  final String userId;
  final GameHistoryItem game;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = _GameResult.fromGame(game: game, userId: userId);
    final when = _DateFormatters.dateTime(
      game.endTime ?? game.startTime,
      fallback: l10n.profileDateUnknown,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultBadge(result: result),
              const Gap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileHistoryVs(game.opponentUserId),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        color: kTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(3),
                    Text(
                      '${game.userColor.toUpperCase()} — '
                          '${l10n.profileHistoryMoves(game.moveCount ?? 0)}',
                      style: GoogleFonts.dmSans(
                          color: kTextSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Gap(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    result.label(l10n),
                    style: GoogleFonts.dmSans(
                      color: result.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(3),
                  Text(
                    when,
                    style: GoogleFonts.dmSans(color: kTextMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: kAppBorder),
      ],
    );
  }
}

// ─── Result Badge ─────────────────────────────────────────────────────────────

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.result});
  final _GameResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: result.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        result.shortLabel(l10n),
        style: GoogleFonts.dmSans(
          color: result.color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ─── Game Result ──────────────────────────────────────────────────────────────

enum _GameResult {
  win,
  loss,
  draw,
  inProgress;

  Color get color => switch (this) {
    _GameResult.win => kSuccess,
    _GameResult.loss => kError,
    _GameResult.draw => kTextSecondary,
    _GameResult.inProgress => kGoldLight,
  };

  String label(AppLocalizations l10n) => switch (this) {
    _GameResult.win => l10n.profileResultWin,
    _GameResult.loss => l10n.profileResultLoss,
    _GameResult.draw => l10n.profileResultDraw,
    _GameResult.inProgress => l10n.profileHistoryInProgress,
  };

  String shortLabel(AppLocalizations l10n) => switch (this) {
    _GameResult.win => l10n.profileResultWinShort,
    _GameResult.loss => l10n.profileResultLossShort,
    _GameResult.draw => l10n.profileResultDrawShort,
    _GameResult.inProgress => l10n.profileResultInProgressShort,
  };

  static _GameResult fromGame({
    required GameHistoryItem game,
    required String userId,
  }) {
    final winner = game.winnerUserId;
    final resultText = (game.result ?? '').toUpperCase();

    if (winner != null && winner.isNotEmpty) {
      return winner == userId ? _GameResult.win : _GameResult.loss;
    }
    if (resultText.contains('DRAW')) return _GameResult.draw;
    if (resultText.contains('WIN')) return _GameResult.win;
    if (resultText.contains('LOSS')) return _GameResult.loss;
    if (game.gameOver == true) return _GameResult.draw;
    return _GameResult.inProgress;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REUSABLE PRIMITIVES
// ═══════════════════════════════════════════════════════════════════════════════

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kAppSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAppBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kAppBorder)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: kGold),
          const Gap(8),
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: kTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label,
              style: GoogleFonts.dmSans(color: kTextMuted, fontSize: 12)),
        ),
        const Gap(12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: kAppBorder,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const Gap(10),
        SizedBox(
          width: 36,
          child: Text(
            '${(value * 100).toStringAsFixed(0)}%',
            textAlign: TextAlign.end,
            style: GoogleFonts.dmSans(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 16, color: kGold),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                      GoogleFonts.dmSans(color: kTextMuted, fontSize: 11)),
                  const Gap(2),
                  Text(value,
                      style: GoogleFonts.dmSans(
                        color: kTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: kAppBorder, indent: 44),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(4),
          Text(label,
              style: GoogleFonts.dmSans(color: kTextMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 44, color: kAppBorder);
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating});
  final int rating;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: kGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kGold.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, color: kGold, size: 14),
          const Gap(5),
          Text(
            l10n.profileRatingElo(rating),
            style: GoogleFonts.dmSans(
              color: kGold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// OVERLAYS & FULL-SCREEN STATES
// ═══════════════════════════════════════════════════════════════════════════════

class _BusyOverlay extends StatelessWidget {
  const _BusyOverlay({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            decoration: BoxDecoration(
              color: kAppSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kAppBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                    color: kGold, strokeWidth: 2.5),
                if (message != null) ...[
                  const Gap(14),
                  Text(message!,
                      style: GoogleFonts.dmSans(
                          color: kTextSecondary, fontSize: 13)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: kError.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.signal_wifi_bad_outlined,
                  color: kError, size: 30),
            ),
            const Gap(20),
            Text(
              l10n.profileErrorTitle,
              style: GoogleFonts.playfairDisplay(
                color: kTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: kTextSecondary, fontSize: 13),
            ),
            const Gap(24),
            PrimaryButton(label: l10n.profileErrorRetry, onTap: onRetry),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PAINTERS
// ═══════════════════════════════════════════════════════════════════════════════
//
// TODO: Move to lib/src/shared/painters/chess_pattern_painter.dart so it can
// be shared with landing_screen.dart without duplication.

class _ChessPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kGold.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    const tileSize = 28.0;
    for (double x = 0; x < size.width + tileSize; x += tileSize) {
      for (double y = 0; y < size.height + tileSize; y += tileSize) {
        final col = (x / tileSize).floor();
        final row = (y / tileSize).floor();
        if ((col + row) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, tileSize, tileSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// EDIT PROFILE DIALOG
// ═══════════════════════════════════════════════════════════════════════════════

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.user});
  final UserModel user;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name ?? '');
    _usernameController =
        TextEditingController(text: widget.user.username);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: kAppSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kAppBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogHeader(label: l10n.profileEditDialogTitle),
                const Gap(24),
                _ProfileField(
                  label: l10n.profileEditFieldName,
                  controller: _nameController,
                  icon: Icons.badge_outlined,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.profileEditNameRequired
                      : null,
                ),
                const Gap(14),
                _ProfileField(
                  label: l10n.profileEditFieldUsername,
                  controller: _usernameController,
                  icon: Icons.alternate_email_rounded,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? l10n.profileEditUsernameRequired
                      : null,
                ),
                const Gap(24),
                Row(
                  children: [
                    Expanded(
                      child: GhostButton(
                        label: l10n.dialogCancel,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: PrimaryButton(
                        label: l10n.profileEditSave,
                        onTap: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      _EditProfileData(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
      ),
    );
  }
}

/// Header row used at the top of the edit dialog.
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kGoldSubtle,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.edit_outlined, color: kGold, size: 16),
        ),
        const Gap(12),
        Text(
          label,
          style: GoogleFonts.playfairDisplay(
            color: kTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Styled [TextFormField] used in the edit dialog.
class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.dmSans(color: kTextPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(color: kTextMuted, fontSize: 13),
        prefixIcon: Icon(icon, size: 17, color: kGold),
        filled: true,
        fillColor: kAppSurface2,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kAppBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kError, width: 1.5),
        ),
      ),
    );
  }
}