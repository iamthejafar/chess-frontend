# Knightly Chess (Flutter Web)

Knightly Chess is a real-time multiplayer chess client built with Flutter.
It focuses on responsive UX, clean architecture, and production-oriented state management for web delivery.

## Project Context

The app is designed as a playable chess experience with:

- Fast onboarding (guest sign-in and Google sign-in)
- Real-time match lifecycle over WebSocket
- Interactive board and move timeline/navigation
- Player profile with stats, editing, photo upload, and paginated game history
- Responsive layouts for desktop, tablet, and mobile
- Localization-ready app shell (`flutter_localizations` + generated `l10n` files)

## What This Project Demonstrates (Flutter Skills)

- Feature-first architecture with clear separation of UI, BLoC, repositories, and services
- Event-driven state management using `flutter_bloc` (`AuthBloc`, `GameBloc`, `ProfileBloc`)
- Real-time communication patterns with `web_socket_channel`
- Network abstraction and error handling using `dio` + typed API wrapper patterns
- Adaptive UI with `responsive_builder` and dedicated layouts per form factor
- Complex UI composition in reusable widgets and custom painters
- Route handling with dynamic paths and argument-based navigation
- Local persistence/session recovery with `get_storage`
- JSON model serialization strategy (`json_annotation` / generated models)

## Architecture Overview

The app follows a layered, feature-first structure:

- `lib/src/core` - app shell (routes, theme, global config)
- `lib/src/features` - feature modules (`landing`, `ches_board`, `profile`)
- `lib/src/services` - shared infrastructure (API client, storage, WebSocket)
- `lib/src/shared` - reusable UI components
- `lib/src/utils` - utility helpers and enums

### Layer Responsibilities

- UI layer: screens/widgets render state and dispatch events
- BLoC layer: orchestrates feature workflows and state transitions
- Repository layer: domain/data operations and backend coordination
- Service layer: transport and persistence primitives (HTTP, WS, local storage)

### Runtime Flow (High-Level)

1. `main()` validates runtime config and initializes storage/auth bootstrap.
2. `AuthBloc` reacts to auth stream changes from `AuthRepository`.
3. `GameBloc` starts live sessions and processes WebSocket updates into board state.
4. `ProfileBloc` handles profile CRUD and paginated history loading.
5. Routing (`AppRoutes`) keeps navigation explicit and supports deep-link style game/profile paths.

## Tech Stack

- Flutter (Dart SDK `^3.10.8`)
- `flutter_bloc` for state management
- `dio` for HTTP networking
- `web_socket_channel` for live gameplay events
- `bishop` for chess logic integration
- `responsive_builder` for adaptive UI
- `google_sign_in` for OAuth-based sign-in
- `get_storage` and `shared_preferences` for local persistence
- `google_fonts` + custom theming for UI polish

## Repository Structure

```text
lib/
  main.dart
  src/
    core/
    features/
      landing/
      ches_board/
      profile/
    services/
    shared/
    utils/
  l10n/
assets/
  images/
web/
```

## Running the Project

Install dependencies:

```bash
flutter pub get
```

Run on Chrome (example config):

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
```

Build production web bundle:

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=WS_URL=wss://api.example.com/chess \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-google-web-client-id.apps.googleusercontent.com
```
