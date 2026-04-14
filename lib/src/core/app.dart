import 'package:chess/src/core/app_theme.dart';
import 'package:chess/src/core/app_routes.dart';
import 'package:chess/src/features/ches_board/screens/chess_screen.dart';
import 'package:chess/src/features/landing/bloc/auth_bloc.dart';
import 'package:chess/src/features/landing/repositories/auth_repository.dart';
import 'package:chess/src/features/landing/screens/landing_screen.dart';
import 'package:chess/src/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:chess/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_builder/responsive_builder.dart';

class App extends StatelessWidget {
  final AuthRepository authRepository;
  const App({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthBloc(authRepository: authRepository),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.dark,
            initialRoute: AppRoutes.home,
            onGenerateRoute: _onGenerateRoute,
            onUnknownRoute: (settings) => MaterialPageRoute(
              settings: settings,
              builder: (_) => _RouteErrorScreen(routeName: settings.name),
            ),
          ),
        );
      },
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.home;
    final uri = Uri.parse(routeName);

    if (uri.path == '/' || uri.path == AppRoutes.home) {
      return MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.home),
        builder: (_) => LandingScreen(),
      );
    }

    if (uri.path == AppRoutes.game) {
      return MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.game),
        builder: (_) => const ChessScreen(),
      );
    }

    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'game') {
      final gameId = uri.pathSegments[1];
      return MaterialPageRoute(
        settings: RouteSettings(name: AppRoutes.gameWithId(gameId)),
        builder: (_) => const ChessScreen(),
      );
    }

    if (uri.path == AppRoutes.profile) {
      final args = settings.arguments;
      final routeArgs = args is ProfileRouteArgs ? args : null;
      final userId = routeArgs?.userId ?? uri.queryParameters['userId'];
      final viewerUserId =
          routeArgs?.viewerUserId ?? uri.queryParameters['viewerUserId'];

      if (userId == null || userId.isEmpty) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => _RouteErrorScreen(routeName: settings.name),
        );
      }

      return MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.profile),
        builder: (_) =>
            ProfileScreen(userId: userId, viewerUserId: viewerUserId),
      );
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => _RouteErrorScreen(routeName: settings.name),
    );
  }
}

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({required this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Text(
          l10n.routeNotFound(routeName ?? l10n.unknownRoute),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
