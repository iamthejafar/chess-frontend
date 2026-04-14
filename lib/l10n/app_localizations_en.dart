// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Knightly';

  @override
  String get landingTitle => 'KNIGHTLY';

  @override
  String get landingTagline => 'The board is set.';

  @override
  String get landingTaglineMobile =>
      'Where classic chess meets modern mastery.';

  @override
  String get landingBody =>
      'Discover the thrill of strategic gameplay where classic chess meets modern design. Play, learn, and challenge yourself - for enthusiasts of all levels.';

  @override
  String get landingGuestCta => 'Play as Guest';

  @override
  String get unknownRoute => 'unknown';

  @override
  String routeNotFound(String routeName) {
    return 'Route not found: $routeName';
  }

  @override
  String get navBoard => 'Board';

  @override
  String get navProfile => 'Profile';

  @override
  String get gameStartTitle => 'Ready to play?';

  @override
  String get gameStartSubtitle => 'Find a match and challenge your mind.';

  @override
  String get gameStartButton => 'Start Game';

  @override
  String get gameStartNew => 'Start New Game';

  @override
  String get gameFindingOpponent => 'Finding opponent…';

  @override
  String get gameVictory => 'Victory';

  @override
  String get gameDefeat => 'Defeat';

  @override
  String get gameDraw => 'Draw';

  @override
  String gameResultWon(String reason) {
    return 'You won by $reason.';
  }

  @override
  String gameResultLost(String reason) {
    return 'You lost by $reason.';
  }

  @override
  String gameResultDraw(String reason) {
    return 'No winner this time. Reason: $reason.';
  }

  @override
  String get gameOver => 'Game Over';

  @override
  String get drawOfferLabel => 'Draw offer';

  @override
  String get drawAccept => 'Accept';

  @override
  String get drawDecline => 'Decline';

  @override
  String get drawOfferDeclinedByOpponent => 'Opponent declined your draw offer';

  @override
  String get promotionDialogTitle => 'Choose promotion piece';

  @override
  String get promotionCancel => 'Cancel';

  @override
  String get dataSectionGameInfo => 'GAME INFO';

  @override
  String get dataSectionMoves => 'MOVES';

  @override
  String get dataSectionTurn => 'TURN';

  @override
  String get turnWhite => 'White';

  @override
  String get turnBlack => 'Black';

  @override
  String get movesNone => 'No moves yet';

  @override
  String get drawBannerOpponentOffered =>
      'Opponent offered a draw (respond on board)';

  @override
  String get drawBannerSent => 'Draw offer sent';

  @override
  String get controlTooltipFirstMove => 'First move';

  @override
  String get controlTooltipPrevMove => 'Previous';

  @override
  String get controlTooltipNextMove => 'Next';

  @override
  String get controlTooltipLastMove => 'Last move';

  @override
  String get controlTooltipOfferDraw => 'Offer draw';

  @override
  String get controlTooltipDrawPending => 'Draw offer pending';

  @override
  String get controlTooltipResign => 'Resign';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get offerDrawDialogTitle => 'Offer draw?';

  @override
  String get offerDrawDialogContent => 'Send a draw offer to your opponent?';

  @override
  String get offerDrawDialogConfirm => 'Offer';

  @override
  String get resignDialogTitle => 'Resign?';

  @override
  String get resignDialogContent =>
      'Are you sure you want to resign this game?';

  @override
  String get resignDialogConfirm => 'Resign';

  @override
  String get profileEditButton => 'Edit';

  @override
  String get profileEditDialogTitle => 'Edit Profile';

  @override
  String get profileEditFieldName => 'Display Name';

  @override
  String get profileEditFieldUsername => 'Username';

  @override
  String get profileEditNameRequired => 'Name is required';

  @override
  String get profileEditUsernameRequired => 'Username is required';

  @override
  String get profileEditSave => 'Save';

  @override
  String get profileUpdateSuccess => 'Profile updated';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileSectionStats => 'Statistics';

  @override
  String get profileSectionPerformance => 'Performance';

  @override
  String get profileSectionHistory => 'Recent Games';

  @override
  String get profileAccountEmail => 'Email';

  @override
  String get profileAccountMemberSince => 'Member since';

  @override
  String get profileStatGames => 'Games';

  @override
  String get profileStatWon => 'Won';

  @override
  String get profileStatLost => 'Lost';

  @override
  String get profileStatDraw => 'Draw';

  @override
  String get profilePerfWinRate => 'Win rate';

  @override
  String get profilePerfLossRate => 'Loss rate';

  @override
  String get profilePerfDrawRate => 'Draw rate';

  @override
  String get profileHistoryNoGames =>
      'No games yet. Start a match to build your history.';

  @override
  String get profileHistoryEndReached =>
      'You have reached the end of your history.';

  @override
  String get profileHistoryRetry => 'Retry';

  @override
  String get profileHistoryInProgress => 'In Progress';

  @override
  String get profileResultWin => 'Win';

  @override
  String get profileResultLoss => 'Loss';

  @override
  String get profileResultDraw => 'Draw';

  @override
  String get profileResultWinShort => 'W';

  @override
  String get profileResultLossShort => 'L';

  @override
  String get profileResultDrawShort => 'D';

  @override
  String get profileResultInProgressShort => '-';

  @override
  String get profileChipGuest => 'Guest';

  @override
  String profileHistoryMoves(int count) {
    return '$count moves';
  }

  @override
  String profileHistoryVs(String opponentId) {
    return 'vs $opponentId';
  }

  @override
  String profileRatingElo(int rating) {
    return '$rating ELO';
  }

  @override
  String get profileErrorTitle => 'Something went wrong';

  @override
  String get profileErrorRetry => 'Try again';

  @override
  String get profileDateUnknown => 'Unknown date';
}
