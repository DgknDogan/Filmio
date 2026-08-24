// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Filmio';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle => 'Pick up where you left off.';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authRegisterSubtitle => 'Keep every film you love in one place.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authRememberMe => 'Remember Me';

  @override
  String get authNoAccount => 'New here?';

  @override
  String get authSignUp => 'Create an account';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authContinueAsGuest => 'Look around without an account';

  @override
  String get authLogIn => 'Log in';

  @override
  String get authRegister => 'Create account';

  @override
  String get authName => 'Name';

  @override
  String get authMissingCredentials => 'Enter your e-mail and password.';

  @override
  String get authEmailRequired => 'Enter your e-mail address.';

  @override
  String get authEmailInvalid => 'That does not look like an e-mail address.';

  @override
  String get authPasswordRequired => 'Enter your password.';

  @override
  String get authPasswordTooShort => 'Use at least 6 characters.';

  @override
  String get authPasswordMismatch => 'The two passwords do not match.';

  @override
  String get authSetProfilePicture => 'Set a profile picture';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get moviesTitle => 'Movies';

  @override
  String get moviesSearchHint => 'Search a movie';

  @override
  String get moviesPopular => 'Popular Movies';

  @override
  String get moviesTop => 'Top Movies';

  @override
  String get accountTitle => 'Account';

  @override
  String get guestName => 'Guest';

  @override
  String get guestAccountPrompt => 'Create an account to keep the films and series you like, and to get recommendations built from them.';

  @override
  String get guestCreateAccount => 'Create an account';

  @override
  String get guestNotNow => 'Not now';

  @override
  String get guestLikeTitle => 'Keep this one?';

  @override
  String get guestLikeBody => 'Liking a title needs an account — it is where your list lives, and what the recommendations are built from.';

  @override
  String get seriesTitle => 'Series';

  @override
  String get seriesSearchHint => 'Search a series';

  @override
  String get seriesPopular => 'Popular Series';

  @override
  String get seriesTop => 'Top Series';

  @override
  String get recommendedForYou => 'Recommended for you';

  @override
  String get recommendedEmpty => 'Like a few films and we\'ll have something to recommend.';

  @override
  String get detailsSynopsis => 'Synopsis';

  @override
  String get detailsSwipeUp => 'Swipe up for details';

  @override
  String detailsVotes(String count) {
    return '$count votes';
  }

  @override
  String get seeAll => 'All';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filtersClear => 'Clear';

  @override
  String get filtersApply => 'Apply';

  @override
  String get filtersGenre => 'Genre';

  @override
  String get filtersRating => 'Rating';

  @override
  String get filtersYear => 'Year';

  @override
  String get filtersAny => 'Any';

  @override
  String filtersAction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filter ($count)',
      zero: 'Filter',
    );
    return '$_temp0';
  }

  @override
  String browseResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles',
      one: '1 title',
      zero: 'No titles',
    );
    return '$_temp0';
  }

  @override
  String get browseEmpty => 'Nothing matches these filters.';

  @override
  String get trailerTitle => 'Trailer';

  @override
  String get trailerPlay => 'Play trailer on YouTube';

  @override
  String get trailerOpenFailed => 'Could not open YouTube on this device.';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews yet',
    );
    return '$_temp0';
  }

  @override
  String get reviewsLoadMore => 'Load more reviews';

  @override
  String get reviewsReadMore => 'Read more';

  @override
  String get reviewsShowLess => 'Show less';

  @override
  String get reviewsUnknownAuthor => 'Anonymous';

  @override
  String get reviewsFlaggedWarning => 'This review may contain offensive language.';

  @override
  String get reviewsShowAnyway => 'Show anyway';

  @override
  String get reviewsMoreActions => 'Report or hide this review';

  @override
  String get reviewsReport => 'Report review';

  @override
  String get reviewsBlockAuthor => 'Hide reviews by this author';

  @override
  String reviewsAuthorBlocked(String author) {
    return 'You will not see reviews by $author again.';
  }

  @override
  String get reportTitle => 'Report this review';

  @override
  String get reportBody => 'Pick what is wrong with it. Reports are read by a person, and we answer within three days.';

  @override
  String get reportReasonOffensiveLanguage => 'Offensive language';

  @override
  String get reportReasonHateOrHarassment => 'Hate speech or harassment';

  @override
  String get reportReasonSpam => 'Spam or advertising';

  @override
  String get reportReasonSpoiler => 'Unmarked spoiler';

  @override
  String get reportReasonOther => 'Something else';

  @override
  String get reportSent => 'Thank you. That review is hidden and we will look at it.';

  @override
  String get reportFailed => 'Could not send the report. Try again.';

  @override
  String get similarSeries => 'Similar series';

  @override
  String get similarTitles => 'Similar movies';

  @override
  String get detailsAction => 'Details';

  @override
  String get likeAction => 'Add to liked';

  @override
  String get unlikeAction => 'Remove from liked';

  @override
  String get backAction => 'Back';

  @override
  String get seeMore => 'See more';

  @override
  String get likedMovies => 'Liked Movies';

  @override
  String get likedSeries => 'Liked Series';

  @override
  String likedMoviesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titles',
      one: '1 title',
      zero: 'No titles',
    );
    return '$_temp0';
  }

  @override
  String get likedMoviesEmpty => 'No liked movies yet.';

  @override
  String get likedSeriesEmpty => 'No liked series yet.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsSelectTheme => 'Select Theme';

  @override
  String get settingsLogOut => 'Log Out';

  @override
  String get settingsLeaveGuest => 'Sign in';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsTmdbAttribution => 'This product uses the TMDB API but is not endorsed or certified by TMDB.';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsSupport => 'Contact support';

  @override
  String settingsSupportFailed(String address) {
    return 'No mail app to open. Write to $address.';
  }

  @override
  String get settingsSupportSubject => 'Filmio support';

  @override
  String get settingsDangerZone => 'Account removal';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'Your account, the films and series you have liked, and everything else stored against it will be removed permanently. This cannot be undone.';

  @override
  String get deleteAccountPasswordPrompt => 'Enter your password to confirm.';

  @override
  String get deleteAccountConfirm => 'Delete account';

  @override
  String get cancel => 'Cancel';

  @override
  String get authConsentPrompt => 'By creating an account you agree to the';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyUpdated => 'Last updated 24 August 2026';

  @override
  String get privacyIntro =>
      'Filmio is a catalogue for browsing films and series. This policy explains what the app stores about you, why, and how to get rid of it.';

  @override
  String get privacyCollectTitle => 'What we collect';

  @override
  String get privacyCollectBody =>
      'When you create an account we store your e-mail address, the display name you choose, and which of the app\'s built-in avatars you pick. As you use the app we store the films and series you like, against an account identifier issued by Firebase Authentication. That is everything. Filmio asks for no access to your location, contacts, photos, camera, or microphone, and contains no analytics or advertising software.';

  @override
  String get privacyUseTitle => 'What it is used for';

  @override
  String get privacyUseBody =>
      'Your e-mail address and password identify you when you sign in. Your name and avatar appear on your own account screen. Your liked titles fill your lists and feed the recommendations on the home screen. None of it is used for advertising, profiling, or sold to anyone.';

  @override
  String get privacyShareTitle => 'Who else sees it';

  @override
  String get privacyShareBody =>
      'Google Firebase hosts the sign-in service and the database, so your account data is stored on their infrastructure under their own privacy terms. Filmio\'s recommendation service receives the titles you have liked, so that it can suggest others; it is operated by us and keeps no copy beyond the request. Catalogue data — posters, synopses, ratings, reviews — comes from TMDB, and requests for it carry nothing that identifies you.';

  @override
  String get privacyKeepTitle => 'How long it is kept';

  @override
  String get privacyKeepBody =>
      'Your data is kept for as long as the account exists. Deleting your account removes the account and everything stored against it immediately and permanently — there is no backup we can restore it from.';

  @override
  String get privacyRightsTitle => 'Your choices';

  @override
  String get privacyRightsBody =>
      'You can see what is stored about you on the account screen, and you can delete all of it from Settings, under Account removal. If you would rather have a copy of your data, or want anything corrected, write to us and we will answer within thirty days.';

  @override
  String get privacyChildrenTitle => 'Children';

  @override
  String get privacyChildrenBody =>
      'Filmio is not directed at children under 13 and we do not knowingly collect anything from them. If you believe a child has created an account, write to us and we will remove it.';

  @override
  String get privacyChangesTitle => 'Changes';

  @override
  String get privacyChangesBody =>
      'If this policy changes, the new version appears here with a new date. Continuing to use the app after that means the new version applies.';

  @override
  String get privacyContactTitle => 'Contact';

  @override
  String get privacyContactBody => 'Questions about this policy, or about your data, go to:';

  @override
  String get privacyContactEmail => 'support.filmio@gmail.com';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get searchNoResults => 'No results found.';

  @override
  String get tryAgain => 'Try again';
}
