import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application name, and the alt text of the logo on the auth banner
  ///
  /// In en, this message translates to:
  /// **'Filmio'**
  String get appName;

  /// Headline of the login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// Line under the login headline
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off.'**
  String get authLoginSubtitle;

  /// Headline of the register screen
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authRegisterTitle;

  /// Line under the register headline
  ///
  /// In en, this message translates to:
  /// **'Keep every film you love in one place.'**
  String get authRegisterSubtitle;

  /// Label of the e-mail field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// Label of the password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Label of the second password field on the register screen
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// Tooltip of the eye button while the password is hidden
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Tooltip of the eye button while the password is visible
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Checkbox that keeps the user signed in
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get authRememberMe;

  /// Prompt before the link from login to register
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get authNoAccount;

  /// Link from login to the register screen
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authSignUp;

  /// Prompt before the link from register to login
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// Link from register back to login
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// Submit button on the login screen
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogIn;

  /// Submit button on the register screen
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegister;

  /// Hint for the display-name field during profile setup
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authName;

  /// Shown when login is submitted with an empty field
  ///
  /// In en, this message translates to:
  /// **'Enter your e-mail and password.'**
  String get authMissingCredentials;

  /// Validation message under an empty e-mail field
  ///
  /// In en, this message translates to:
  /// **'Enter your e-mail address.'**
  String get authEmailRequired;

  /// Validation message under a malformed e-mail field
  ///
  /// In en, this message translates to:
  /// **'That does not look like an e-mail address.'**
  String get authEmailInvalid;

  /// Validation message under an empty password field
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get authPasswordRequired;

  /// Validation message under a too-short password
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters.'**
  String get authPasswordTooShort;

  /// Validation message under the confirm-password field
  ///
  /// In en, this message translates to:
  /// **'The two passwords do not match.'**
  String get authPasswordMismatch;

  /// Heading of the avatar picker during profile setup
  ///
  /// In en, this message translates to:
  /// **'Set a profile picture'**
  String get authSetProfilePicture;

  /// Advances to the next step of profile setup
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Completes profile setup
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Title of the movies tab
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get moviesTitle;

  /// Placeholder in the movie search field
  ///
  /// In en, this message translates to:
  /// **'Search a movie'**
  String get moviesSearchHint;

  /// Heading of the popular movies row
  ///
  /// In en, this message translates to:
  /// **'Popular Movies'**
  String get moviesPopular;

  /// Heading of the top rated movies row
  ///
  /// In en, this message translates to:
  /// **'Top Movies'**
  String get moviesTop;

  /// Title of the account tab
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// Title of the series tab
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get seriesTitle;

  /// Placeholder in the series search field
  ///
  /// In en, this message translates to:
  /// **'Search a series'**
  String get seriesSearchHint;

  /// Heading of the popular series row
  ///
  /// In en, this message translates to:
  /// **'Popular Series'**
  String get seriesPopular;

  /// Heading of the top rated series row
  ///
  /// In en, this message translates to:
  /// **'Top Series'**
  String get seriesTop;

  /// Label over the featured poster
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// Heading of the overview block on a details screen
  ///
  /// In en, this message translates to:
  /// **'Synopsis'**
  String get detailsSynopsis;

  /// Hint at the foot of the collapsed details sheet
  ///
  /// In en, this message translates to:
  /// **'Swipe up for details'**
  String get detailsSwipeUp;

  /// How many ratings produced the score
  ///
  /// In en, this message translates to:
  /// **'{count} votes'**
  String detailsVotes(String count);

  /// Opens the full, filterable list for a home row
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get seeAll;

  /// Heading of the filter sheet
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// Resets every filter in the sheet
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filtersClear;

  /// Applies the chosen filters and closes the sheet
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filtersApply;

  /// Heading of the genre chips in the filter sheet
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get filtersGenre;

  /// Heading of the vote average range in the filter sheet
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get filtersRating;

  /// Heading of the release year range in the filter sheet
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get filtersYear;

  /// Value shown for a range left at its full width, i.e. not filtering
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get filtersAny;

  /// The control that opens the filter sheet, with how many filters are set
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Filter} other{Filter ({count})}}'**
  String filtersAction(int count);

  /// How many titles the current filters match, across every page
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No titles} =1{1 title} other{{count} titles}}'**
  String browseResultCount(int count);

  /// Shown when a filtered browse returns no titles
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters.'**
  String get browseEmpty;

  /// Heading of the trailer block on a details screen
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get trailerTitle;

  /// Opens the trailer player
  ///
  /// In en, this message translates to:
  /// **'Play trailer'**
  String get trailerPlay;

  /// Shown when the player cannot open the video the title points at
  ///
  /// In en, this message translates to:
  /// **'The trailer could not be loaded.'**
  String get trailerLoadFailed;

  /// Shown when a video is on a host other than YouTube or Vimeo
  ///
  /// In en, this message translates to:
  /// **'This trailer is hosted somewhere the app cannot play.'**
  String get trailerUnsupported;

  /// Heading of the reviews block on a details screen
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// How many reviews a title has, across every page
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reviews yet} =1{1 review} other{{count} reviews}}'**
  String reviewsCount(int count);

  /// Fetches the next page of reviews
  ///
  /// In en, this message translates to:
  /// **'Load more reviews'**
  String get reviewsLoadMore;

  /// Opens a review that is cut off after a few lines
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get reviewsReadMore;

  /// Collapses a review back to a few lines
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get reviewsShowLess;

  /// Credit for a review whose author TMDB does not name
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get reviewsUnknownAuthor;

  /// Heading of the similar series row on a series' details screen
  ///
  /// In en, this message translates to:
  /// **'Similar series'**
  String get similarSeries;

  /// Heading of the related titles row on a details screen
  ///
  /// In en, this message translates to:
  /// **'Similar movies'**
  String get similarTitles;

  /// Opens the featured title's details from the tab hero
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsAction;

  /// Adds a title to the liked list
  ///
  /// In en, this message translates to:
  /// **'Add to liked'**
  String get likeAction;

  /// Removes a title from the liked list
  ///
  /// In en, this message translates to:
  /// **'Remove from liked'**
  String get unlikeAction;

  /// Returns to the previous screen
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backAction;

  /// Opens the full list for a row
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// Title of the liked movies screen
  ///
  /// In en, this message translates to:
  /// **'Liked Movies'**
  String get likedMovies;

  /// Row opening the liked series list
  ///
  /// In en, this message translates to:
  /// **'Liked Series'**
  String get likedSeries;

  /// How many titles are in the liked list
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No titles} =1{1 title} other{{count} titles}}'**
  String likedMoviesCount(int count);

  /// Shown when the user has liked nothing
  ///
  /// In en, this message translates to:
  /// **'No liked movies yet.'**
  String get likedMoviesEmpty;

  /// Shown when the user has liked no series
  ///
  /// In en, this message translates to:
  /// **'No liked series yet.'**
  String get likedSeriesEmpty;

  /// Title of the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Heading of the theme section in settings
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Label next to the theme picker
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get settingsSelectTheme;

  /// Signs the user out
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogOut;

  /// Always use the light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Always use the dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Follow the device setting
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// How many titles a query returned
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String searchResultCount(int count);

  /// Shown when a search returns nothing. Both the film and the series search use it, so it names neither.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get searchNoResults;

  /// Dismisses the search screen
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Retries the request that failed
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError('AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
