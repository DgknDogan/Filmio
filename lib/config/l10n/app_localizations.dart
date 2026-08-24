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

  /// Enters the app as a guest, from the login screen
  ///
  /// In en, this message translates to:
  /// **'Look around without an account'**
  String get authContinueAsGuest;

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

  /// Stands in for the name on the account tab when there is no account
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestName;

  /// Explains on the account tab what an account adds
  ///
  /// In en, this message translates to:
  /// **'Create an account to keep the films and series you like, and to get recommendations built from them.'**
  String get guestAccountPrompt;

  /// Leaves the guest session for the sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get guestCreateAccount;

  /// Dismisses the prompt to create an account
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get guestNotNow;

  /// Headline of the prompt shown when a guest taps the heart
  ///
  /// In en, this message translates to:
  /// **'Keep this one?'**
  String get guestLikeTitle;

  /// Explains why the heart needs an account
  ///
  /// In en, this message translates to:
  /// **'Liking a title needs an account — it is where your list lives, and what the recommendations are built from.'**
  String get guestLikeBody;

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

  /// Shown at the head of the films tab when the recommendation service has nothing to suggest yet
  ///
  /// In en, this message translates to:
  /// **'Like a few films and we\'ll have something to recommend.'**
  String get recommendedEmpty;

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

  /// Accessibility label of the trailer card, which hands the video to YouTube
  ///
  /// In en, this message translates to:
  /// **'Play trailer on YouTube'**
  String get trailerPlay;

  /// Shown when the device has nothing that can open a YouTube link
  ///
  /// In en, this message translates to:
  /// **'Could not open YouTube on this device.'**
  String get trailerOpenFailed;

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

  /// Shown in place of a review the content filter flagged
  ///
  /// In en, this message translates to:
  /// **'This review may contain offensive language.'**
  String get reviewsFlaggedWarning;

  /// Opens a review that was folded behind the offensive-language warning
  ///
  /// In en, this message translates to:
  /// **'Show anyway'**
  String get reviewsShowAnyway;

  /// Accessibility label of the menu button on a review card
  ///
  /// In en, this message translates to:
  /// **'Report or hide this review'**
  String get reviewsMoreActions;

  /// Menu action that opens the report dialog
  ///
  /// In en, this message translates to:
  /// **'Report review'**
  String get reviewsReport;

  /// Menu action that blocks everything one author writes
  ///
  /// In en, this message translates to:
  /// **'Hide reviews by this author'**
  String get reviewsBlockAuthor;

  /// Confirms that an author has been blocked
  ///
  /// In en, this message translates to:
  /// **'You will not see reviews by {author} again.'**
  String reviewsAuthorBlocked(String author);

  /// Headline of the report dialog
  ///
  /// In en, this message translates to:
  /// **'Report this review'**
  String get reportTitle;

  /// Line under the report dialog's headline
  ///
  /// In en, this message translates to:
  /// **'Pick what is wrong with it. Reports are read by a person, and we answer within three days.'**
  String get reportBody;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Offensive language'**
  String get reportReasonOffensiveLanguage;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Hate speech or harassment'**
  String get reportReasonHateOrHarassment;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Spam or advertising'**
  String get reportReasonSpam;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Unmarked spoiler'**
  String get reportReasonSpoiler;

  /// Report reason
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportReasonOther;

  /// Confirms a report was filed
  ///
  /// In en, this message translates to:
  /// **'Thank you. That review is hidden and we will look at it.'**
  String get reportSent;

  /// Shown when filing a report did not work
  ///
  /// In en, this message translates to:
  /// **'Could not send the report. Try again.'**
  String get reportFailed;

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

  /// Takes a guest to the sign-in screen; stands where Log Out does for an account
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get settingsLeaveGuest;

  /// Heading of the credits section in settings
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// Attribution TMDB's API terms of use require every app calling the API to display
  ///
  /// In en, this message translates to:
  /// **'This product uses the TMDB API but is not endorsed or certified by TMDB.'**
  String get settingsTmdbAttribution;

  /// Row in settings that opens the privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// Row in settings that opens a mail draft to the support address
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get settingsSupport;

  /// Shown when the device cannot open a mail draft, with the address to write to by hand
  ///
  /// In en, this message translates to:
  /// **'No mail app to open. Write to {address}.'**
  String settingsSupportFailed(String address);

  /// Subject line of the mail draft the support row opens
  ///
  /// In en, this message translates to:
  /// **'Filmio support'**
  String get settingsSupportSubject;

  /// Heading of the destructive section at the foot of settings
  ///
  /// In en, this message translates to:
  /// **'Account removal'**
  String get settingsDangerZone;

  /// Opens the confirmation dialog that deletes the account
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// Headline of the delete-account confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountTitle;

  /// What deleting the account actually removes
  ///
  /// In en, this message translates to:
  /// **'Your account, the films and series you have liked, and everything else stored against it will be removed permanently. This cannot be undone.'**
  String get deleteAccountBody;

  /// Line above the password field in the delete-account dialog
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm.'**
  String get deleteAccountPasswordPrompt;

  /// Destructive action of the delete-account dialog
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountConfirm;

  /// Dismisses the search screen
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Line above the register button, before the link to the privacy policy
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to the'**
  String get authConsentPrompt;

  /// Title of the privacy policy screen
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// When the policy was last changed
  ///
  /// In en, this message translates to:
  /// **'Last updated 24 August 2026'**
  String get privacyUpdated;

  /// Opening paragraph of the privacy policy
  ///
  /// In en, this message translates to:
  /// **'Filmio is a catalogue for browsing films and series. This policy explains what the app stores about you, why, and how to get rid of it.'**
  String get privacyIntro;

  /// Heading of the data collection section
  ///
  /// In en, this message translates to:
  /// **'What we collect'**
  String get privacyCollectTitle;

  /// Body of the data collection section
  ///
  /// In en, this message translates to:
  /// **'When you create an account we store your e-mail address, the display name you choose, and which of the app\'s built-in avatars you pick. As you use the app we store the films and series you like, against an account identifier issued by Firebase Authentication. That is everything. Filmio asks for no access to your location, contacts, photos, camera, or microphone, and contains no analytics or advertising software.'**
  String get privacyCollectBody;

  /// Heading of the data use section
  ///
  /// In en, this message translates to:
  /// **'What it is used for'**
  String get privacyUseTitle;

  /// Body of the data use section
  ///
  /// In en, this message translates to:
  /// **'Your e-mail address and password identify you when you sign in. Your name and avatar appear on your own account screen. Your liked titles fill your lists and feed the recommendations on the home screen. None of it is used for advertising, profiling, or sold to anyone.'**
  String get privacyUseBody;

  /// Heading of the data sharing section
  ///
  /// In en, this message translates to:
  /// **'Who else sees it'**
  String get privacyShareTitle;

  /// Body of the data sharing section
  ///
  /// In en, this message translates to:
  /// **'Google Firebase hosts the sign-in service and the database, so your account data is stored on their infrastructure under their own privacy terms. Filmio\'s recommendation service receives the titles you have liked, so that it can suggest others; it is operated by us and keeps no copy beyond the request. Catalogue data — posters, synopses, ratings, reviews — comes from TMDB, and requests for it carry nothing that identifies you.'**
  String get privacyShareBody;

  /// Heading of the retention section
  ///
  /// In en, this message translates to:
  /// **'How long it is kept'**
  String get privacyKeepTitle;

  /// Body of the retention section
  ///
  /// In en, this message translates to:
  /// **'Your data is kept for as long as the account exists. Deleting your account removes the account and everything stored against it immediately and permanently — there is no backup we can restore it from.'**
  String get privacyKeepBody;

  /// Heading of the user rights section
  ///
  /// In en, this message translates to:
  /// **'Your choices'**
  String get privacyRightsTitle;

  /// Body of the user rights section
  ///
  /// In en, this message translates to:
  /// **'You can see what is stored about you on the account screen, and you can delete all of it from Settings, under Account removal. If you would rather have a copy of your data, or want anything corrected, write to us and we will answer within thirty days.'**
  String get privacyRightsBody;

  /// Heading of the children section
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get privacyChildrenTitle;

  /// Body of the children section
  ///
  /// In en, this message translates to:
  /// **'Filmio is not directed at children under 13 and we do not knowingly collect anything from them. If you believe a child has created an account, write to us and we will remove it.'**
  String get privacyChildrenBody;

  /// Heading of the policy changes section
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get privacyChangesTitle;

  /// Body of the policy changes section
  ///
  /// In en, this message translates to:
  /// **'If this policy changes, the new version appears here with a new date. Continuing to use the app after that means the new version applies.'**
  String get privacyChangesBody;

  /// Heading of the contact section
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyContactTitle;

  /// Line introducing the contact address
  ///
  /// In en, this message translates to:
  /// **'Questions about this policy, or about your data, go to:'**
  String get privacyContactBody;

  /// The address users write to about privacy and support. App Review guideline 1.5 requires it to be reachable, so it must stay a monitored inbox.
  ///
  /// In en, this message translates to:
  /// **'support.filmio@gmail.com'**
  String get privacyContactEmail;

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
