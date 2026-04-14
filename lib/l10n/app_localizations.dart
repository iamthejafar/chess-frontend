import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Knightly'**
  String get appTitle;

  /// No description provided for @landingTitle.
  ///
  /// In en, this message translates to:
  /// **'KNIGHTLY'**
  String get landingTitle;

  /// No description provided for @landingTagline.
  ///
  /// In en, this message translates to:
  /// **'The board is set.'**
  String get landingTagline;

  /// No description provided for @landingTaglineMobile.
  ///
  /// In en, this message translates to:
  /// **'Where classic chess meets modern mastery.'**
  String get landingTaglineMobile;

  /// No description provided for @landingBody.
  ///
  /// In en, this message translates to:
  /// **'Discover the thrill of strategic gameplay where classic chess meets modern design. Play, learn, and challenge yourself - for enthusiasts of all levels.'**
  String get landingBody;

  /// No description provided for @landingGuestCta.
  ///
  /// In en, this message translates to:
  /// **'Play as Guest'**
  String get landingGuestCta;

  /// No description provided for @unknownRoute.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get unknownRoute;

  /// Shown when navigation receives an unknown route.
  ///
  /// In en, this message translates to:
  /// **'Route not found: {routeName}'**
  String routeNotFound(String routeName);

  /// No description provided for @navBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get navBoard;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @gameStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to play?'**
  String get gameStartTitle;

  /// No description provided for @gameStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find a match and challenge your mind.'**
  String get gameStartSubtitle;

  /// No description provided for @gameStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get gameStartButton;

  /// No description provided for @gameStartNew.
  ///
  /// In en, this message translates to:
  /// **'Start New Game'**
  String get gameStartNew;

  /// No description provided for @gameFindingOpponent.
  ///
  /// In en, this message translates to:
  /// **'Finding opponent…'**
  String get gameFindingOpponent;

  /// No description provided for @gameVictory.
  ///
  /// In en, this message translates to:
  /// **'Victory'**
  String get gameVictory;

  /// No description provided for @gameDefeat.
  ///
  /// In en, this message translates to:
  /// **'Defeat'**
  String get gameDefeat;

  /// No description provided for @gameDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get gameDraw;

  /// Shown when the player wins.
  ///
  /// In en, this message translates to:
  /// **'You won by {reason}.'**
  String gameResultWon(String reason);

  /// Shown when the player loses.
  ///
  /// In en, this message translates to:
  /// **'You lost by {reason}.'**
  String gameResultLost(String reason);

  /// Shown when the game ends in a draw.
  ///
  /// In en, this message translates to:
  /// **'No winner this time. Reason: {reason}.'**
  String gameResultDraw(String reason);

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @drawOfferLabel.
  ///
  /// In en, this message translates to:
  /// **'Draw offer'**
  String get drawOfferLabel;

  /// No description provided for @drawAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get drawAccept;

  /// No description provided for @drawDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get drawDecline;

  /// No description provided for @drawOfferDeclinedByOpponent.
  ///
  /// In en, this message translates to:
  /// **'Opponent declined your draw offer'**
  String get drawOfferDeclinedByOpponent;

  /// No description provided for @promotionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose promotion piece'**
  String get promotionDialogTitle;

  /// No description provided for @promotionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get promotionCancel;

  /// No description provided for @dataSectionGameInfo.
  ///
  /// In en, this message translates to:
  /// **'GAME INFO'**
  String get dataSectionGameInfo;

  /// No description provided for @dataSectionMoves.
  ///
  /// In en, this message translates to:
  /// **'MOVES'**
  String get dataSectionMoves;

  /// No description provided for @dataSectionTurn.
  ///
  /// In en, this message translates to:
  /// **'TURN'**
  String get dataSectionTurn;

  /// No description provided for @turnWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get turnWhite;

  /// No description provided for @turnBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get turnBlack;

  /// No description provided for @movesNone.
  ///
  /// In en, this message translates to:
  /// **'No moves yet'**
  String get movesNone;

  /// No description provided for @drawBannerOpponentOffered.
  ///
  /// In en, this message translates to:
  /// **'Opponent offered a draw (respond on board)'**
  String get drawBannerOpponentOffered;

  /// No description provided for @drawBannerSent.
  ///
  /// In en, this message translates to:
  /// **'Draw offer sent'**
  String get drawBannerSent;

  /// No description provided for @controlTooltipFirstMove.
  ///
  /// In en, this message translates to:
  /// **'First move'**
  String get controlTooltipFirstMove;

  /// No description provided for @controlTooltipPrevMove.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get controlTooltipPrevMove;

  /// No description provided for @controlTooltipNextMove.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get controlTooltipNextMove;

  /// No description provided for @controlTooltipLastMove.
  ///
  /// In en, this message translates to:
  /// **'Last move'**
  String get controlTooltipLastMove;

  /// No description provided for @controlTooltipOfferDraw.
  ///
  /// In en, this message translates to:
  /// **'Offer draw'**
  String get controlTooltipOfferDraw;

  /// No description provided for @controlTooltipDrawPending.
  ///
  /// In en, this message translates to:
  /// **'Draw offer pending'**
  String get controlTooltipDrawPending;

  /// No description provided for @controlTooltipResign.
  ///
  /// In en, this message translates to:
  /// **'Resign'**
  String get controlTooltipResign;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @offerDrawDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer draw?'**
  String get offerDrawDialogTitle;

  /// No description provided for @offerDrawDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Send a draw offer to your opponent?'**
  String get offerDrawDialogContent;

  /// No description provided for @offerDrawDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offerDrawDialogConfirm;

  /// No description provided for @resignDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Resign?'**
  String get resignDialogTitle;

  /// No description provided for @resignDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to resign this game?'**
  String get resignDialogContent;

  /// No description provided for @resignDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Resign'**
  String get resignDialogConfirm;

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEditButton;

  /// No description provided for @profileEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditDialogTitle;

  /// No description provided for @profileEditFieldName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileEditFieldName;

  /// No description provided for @profileEditFieldUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get profileEditFieldUsername;

  /// No description provided for @profileEditNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get profileEditNameRequired;

  /// No description provided for @profileEditUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get profileEditUsernameRequired;

  /// No description provided for @profileEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileEditSave;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdateSuccess;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get profileSectionStats;

  /// No description provided for @profileSectionPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get profileSectionPerformance;

  /// No description provided for @profileSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent Games'**
  String get profileSectionHistory;

  /// No description provided for @profileAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileAccountEmail;

  /// No description provided for @profileAccountMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get profileAccountMemberSince;

  /// No description provided for @profileStatGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get profileStatGames;

  /// No description provided for @profileStatWon.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get profileStatWon;

  /// No description provided for @profileStatLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get profileStatLost;

  /// No description provided for @profileStatDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get profileStatDraw;

  /// No description provided for @profilePerfWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get profilePerfWinRate;

  /// No description provided for @profilePerfLossRate.
  ///
  /// In en, this message translates to:
  /// **'Loss rate'**
  String get profilePerfLossRate;

  /// No description provided for @profilePerfDrawRate.
  ///
  /// In en, this message translates to:
  /// **'Draw rate'**
  String get profilePerfDrawRate;

  /// No description provided for @profileHistoryNoGames.
  ///
  /// In en, this message translates to:
  /// **'No games yet. Start a match to build your history.'**
  String get profileHistoryNoGames;

  /// No description provided for @profileHistoryEndReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached the end of your history.'**
  String get profileHistoryEndReached;

  /// No description provided for @profileHistoryRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get profileHistoryRetry;

  /// No description provided for @profileHistoryInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get profileHistoryInProgress;

  /// No description provided for @profileResultWin.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get profileResultWin;

  /// No description provided for @profileResultLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get profileResultLoss;

  /// No description provided for @profileResultDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get profileResultDraw;

  /// No description provided for @profileResultWinShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get profileResultWinShort;

  /// No description provided for @profileResultLossShort.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get profileResultLossShort;

  /// No description provided for @profileResultDrawShort.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get profileResultDrawShort;

  /// No description provided for @profileResultInProgressShort.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get profileResultInProgressShort;

  /// No description provided for @profileChipGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileChipGuest;

  /// Move count shown in game history row.
  ///
  /// In en, this message translates to:
  /// **'{count} moves'**
  String profileHistoryMoves(int count);

  /// Opponent label in game history row.
  ///
  /// In en, this message translates to:
  /// **'vs {opponentId}'**
  String profileHistoryVs(String opponentId);

  /// ELO rating pill label.
  ///
  /// In en, this message translates to:
  /// **'{rating} ELO'**
  String profileRatingElo(int rating);

  /// No description provided for @profileErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get profileErrorTitle;

  /// No description provided for @profileErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get profileErrorRetry;

  /// No description provided for @profileDateUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get profileDateUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
