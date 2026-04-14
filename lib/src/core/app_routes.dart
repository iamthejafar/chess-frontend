class AppRoutes {
  static const String home = '/home';
  static const String game = '/game';
  static const String profile = '/profile';

  static String gameWithId(String gameId) => '$game/$gameId';
}

class ProfileRouteArgs {
  final String userId;
  final String? viewerUserId;

  const ProfileRouteArgs({required this.userId, this.viewerUserId});
}
