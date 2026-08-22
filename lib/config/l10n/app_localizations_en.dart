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
  String get trailerPlay => 'Play trailer';

  @override
  String get trailerLoadFailed => 'The trailer could not be loaded.';

  @override
  String get trailerUnsupported => 'This trailer is hosted somewhere the app cannot play.';

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
  String get cancel => 'Cancel';

  @override
  String get tryAgain => 'Try again';
}
