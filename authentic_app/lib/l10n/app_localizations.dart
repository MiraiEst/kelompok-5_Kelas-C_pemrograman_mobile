import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('id')];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get navTrending;

  /// No description provided for @navYourBids.
  ///
  /// In en, this message translates to:
  /// **'Your bids'**
  String get navYourBids;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsUnread.
  ///
  /// In en, this message translates to:
  /// **'Notifications, {count} unread'**
  String notificationsUnread(int count);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to bid, sell and track your orders'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your email first.'**
  String get enterEmailFirst;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get resetEmailSent;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One account to buy and sell'**
  String get createAccountSubtitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Shown masked when you bid (a***b)'**
  String get usernameHint;

  /// No description provided for @atLeast3.
  ///
  /// In en, this message translates to:
  /// **'At least 3 characters'**
  String get atLeast3;

  /// No description provided for @atLeast8.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use an Indonesian number starting with 08'**
  String get phoneInvalid;

  /// No description provided for @agreePrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreePrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @verifyNote.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email you a link to verify your account before you can bid.'**
  String get verifyNote;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyTitle;

  /// No description provided for @verifyBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a link to {email}. Open it to activate your account, then come back and tap \"I\'ve verified\".'**
  String verifyBody(String email);

  /// No description provided for @iveVerified.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified'**
  String get iveVerified;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @resendEmailIn.
  ///
  /// In en, this message translates to:
  /// **'Resend email ({seconds}s)'**
  String resendEmailIn(int seconds);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @checkSpam.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find it? Check your spam folder.'**
  String get checkSpam;

  /// No description provided for @notVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet. Open the link in the email first.'**
  String get notVerifiedYet;

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent.'**
  String get verificationSent;

  /// No description provided for @searchAuctions.
  ///
  /// In en, this message translates to:
  /// **'Search auctions'**
  String get searchAuctions;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @endingSoon.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get endingSoon;

  /// No description provided for @allAuctions.
  ///
  /// In en, this message translates to:
  /// **'All auctions'**
  String get allAuctions;

  /// No description provided for @noActiveAuctions.
  ///
  /// In en, this message translates to:
  /// **'No active auctions yet'**
  String get noActiveAuctions;

  /// No description provided for @noEndingSoon.
  ///
  /// In en, this message translates to:
  /// **'No auctions ending soon.'**
  String get noEndingSoon;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @sellAnItem.
  ///
  /// In en, this message translates to:
  /// **'Sell an item'**
  String get sellAnItem;

  /// No description provided for @endsIn.
  ///
  /// In en, this message translates to:
  /// **'Ends in '**
  String get endsIn;

  /// No description provided for @trendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Updated live from bids and watchers'**
  String get trendingSubtitle;

  /// No description provided for @mostBids.
  ///
  /// In en, this message translates to:
  /// **'Most bids'**
  String get mostBids;

  /// No description provided for @mostWatched.
  ///
  /// In en, this message translates to:
  /// **'Most watched'**
  String get mostWatched;

  /// No description provided for @newToday.
  ///
  /// In en, this message translates to:
  /// **'New today'**
  String get newToday;

  /// No description provided for @hotCategories.
  ///
  /// In en, this message translates to:
  /// **'Hot categories'**
  String get hotCategories;

  /// No description provided for @nothingNewToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing new in the last 24 hours.'**
  String get nothingNewToday;

  /// No description provided for @noLiveCategories.
  ///
  /// In en, this message translates to:
  /// **'No live categories yet.'**
  String get noLiveCategories;

  /// No description provided for @liveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} live'**
  String liveCount(int count);

  /// No description provided for @bidding.
  ///
  /// In en, this message translates to:
  /// **'Bidding'**
  String get bidding;

  /// No description provided for @biddingCount.
  ///
  /// In en, this message translates to:
  /// **'Bidding ({count})'**
  String biddingCount(int count);

  /// No description provided for @won.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get won;

  /// No description provided for @wonCount.
  ///
  /// In en, this message translates to:
  /// **'Won ({count})'**
  String wonCount(int count);

  /// No description provided for @didntWin.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t win'**
  String get didntWin;

  /// No description provided for @watchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlist;

  /// No description provided for @winning.
  ///
  /// In en, this message translates to:
  /// **'Winning'**
  String get winning;

  /// No description provided for @outbid.
  ///
  /// In en, this message translates to:
  /// **'Outbid'**
  String get outbid;

  /// No description provided for @toPay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get toPay;

  /// No description provided for @emptyBidding.
  ///
  /// In en, this message translates to:
  /// **'You have no active bids'**
  String get emptyBidding;

  /// No description provided for @emptyWon.
  ///
  /// In en, this message translates to:
  /// **'Items you win will appear here'**
  String get emptyWon;

  /// No description provided for @emptyLost.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyLost;

  /// No description provided for @emptyWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on an auction to watch it'**
  String get emptyWatchlist;

  /// No description provided for @raiseMaxBid.
  ///
  /// In en, this message translates to:
  /// **'Raise max bid'**
  String get raiseMaxBid;

  /// No description provided for @placeMaxBid.
  ///
  /// In en, this message translates to:
  /// **'Place max bid'**
  String get placeMaxBid;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get payNow;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get trackOrder;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Outbid alerts, wins and sales will show up here.'**
  String get notificationsEmpty;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String minAgo(int n);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} h ago'**
  String hoursAgo(int n);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} days ago'**
  String daysAgo(int n);

  /// No description provided for @selling.
  ///
  /// In en, this message translates to:
  /// **'Selling'**
  String get selling;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @purchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// No description provided for @buying.
  ///
  /// In en, this message translates to:
  /// **'Buying'**
  String get buying;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get myListings;

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeCount(int count);

  /// No description provided for @ordersToShip.
  ///
  /// In en, this message translates to:
  /// **'Orders to ship'**
  String get ordersToShip;

  /// No description provided for @payoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Payout account'**
  String get payoutAccount;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @purchasesAndOrders.
  ///
  /// In en, this message translates to:
  /// **'Purchases & orders'**
  String get purchasesAndOrders;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettings;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get adminPanel;

  /// No description provided for @adminsOnly.
  ///
  /// In en, this message translates to:
  /// **'admins only'**
  String get adminsOnly;

  /// No description provided for @helpTermsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Help, terms & privacy'**
  String get helpTermsPrivacy;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {year}'**
  String memberSince(int year);

  /// No description provided for @noRatingsYet.
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get noRatingsYet;

  /// No description provided for @ratingSummary.
  ///
  /// In en, this message translates to:
  /// **'{pct}% positive · {count} ratings'**
  String ratingSummary(int pct, int count);

  /// No description provided for @statusAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get statusAwaitingPayment;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get statusShipped;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get statusInTransit;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @listingActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get listingActive;

  /// No description provided for @listingSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get listingSold;

  /// No description provided for @listingUnsold.
  ///
  /// In en, this message translates to:
  /// **'Unsold'**
  String get listingUnsold;

  /// No description provided for @listingEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get listingEnded;

  /// No description provided for @conditionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get conditionNew;

  /// No description provided for @conditionUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get conditionUsed;

  /// No description provided for @conditionForParts.
  ///
  /// In en, this message translates to:
  /// **'For parts'**
  String get conditionForParts;

  /// No description provided for @formatAuction.
  ///
  /// In en, this message translates to:
  /// **'Auction'**
  String get formatAuction;

  /// No description provided for @formatBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy It Now'**
  String get formatBuyNow;

  /// No description provided for @formatBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get formatBoth;

  /// No description provided for @durationTest.
  ///
  /// In en, this message translates to:
  /// **'5 min (test)'**
  String get durationTest;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'{n}d'**
  String durationDays(int n);

  /// No description provided for @prefOutbid.
  ///
  /// In en, this message translates to:
  /// **'Outbid'**
  String get prefOutbid;

  /// No description provided for @prefEndingSoon.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get prefEndingSoon;

  /// No description provided for @prefWonLost.
  ///
  /// In en, this message translates to:
  /// **'Won / lost'**
  String get prefWonLost;

  /// No description provided for @prefNewBid.
  ///
  /// In en, this message translates to:
  /// **'New bid on my item'**
  String get prefNewBid;

  /// No description provided for @prefReserveMet.
  ///
  /// In en, this message translates to:
  /// **'Reserve met'**
  String get prefReserveMet;

  /// No description provided for @prefOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders & shipping'**
  String get prefOrders;

  /// No description provided for @prefSecondChance.
  ///
  /// In en, this message translates to:
  /// **'Second chance'**
  String get prefSecondChance;

  /// No description provided for @listingEndedSnack.
  ///
  /// In en, this message translates to:
  /// **'Listing ended.'**
  String get listingEndedSnack;

  /// No description provided for @relistedSnack.
  ///
  /// In en, this message translates to:
  /// **'Relisted for 7 days.'**
  String get relistedSnack;

  /// No description provided for @noListingsHere.
  ///
  /// In en, this message translates to:
  /// **'No listings here.'**
  String get noListingsHere;

  /// No description provided for @endListing.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endListing;

  /// No description provided for @relist.
  ///
  /// In en, this message translates to:
  /// **'Relist'**
  String get relist;

  /// No description provided for @bidsWatching.
  ///
  /// In en, this message translates to:
  /// **'{bids} bids · {watchers} watching'**
  String bidsWatching(int bids, int watchers);

  /// No description provided for @nothingToShip.
  ///
  /// In en, this message translates to:
  /// **'Nothing to ship right now.'**
  String get nothingToShip;

  /// No description provided for @purchasesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Items you buy will appear here.'**
  String get purchasesEmpty;

  /// No description provided for @payoutSaved.
  ///
  /// In en, this message translates to:
  /// **'Payout account saved.'**
  String get payoutSaved;

  /// No description provided for @payoutIntro.
  ///
  /// In en, this message translates to:
  /// **'Sale proceeds are paid to this account after the buyer confirms delivery.'**
  String get payoutIntro;

  /// No description provided for @changeAccount.
  ///
  /// In en, this message translates to:
  /// **'Change account'**
  String get changeAccount;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @chooseYourBank.
  ///
  /// In en, this message translates to:
  /// **'Choose your bank'**
  String get chooseYourBank;

  /// No description provided for @chooseABank.
  ///
  /// In en, this message translates to:
  /// **'Choose a bank'**
  String get chooseABank;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountNumber;

  /// No description provided for @enterValidAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid account number'**
  String get enterValidAccountNumber;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account holder name'**
  String get accountHolderName;

  /// No description provided for @enterAccountName.
  ///
  /// In en, this message translates to:
  /// **'Enter the name on the account'**
  String get enterAccountName;

  /// No description provided for @push.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get push;

  /// No description provided for @notifSettingsNote.
  ///
  /// In en, this message translates to:
  /// **'In-app notifications always appear in the Notifications list. These switches control pushes to your phone.'**
  String get notifSettingsNote;

  /// No description provided for @faqProxyQ.
  ///
  /// In en, this message translates to:
  /// **'How does proxy bidding work?'**
  String get faqProxyQ;

  /// No description provided for @faqProxyA.
  ///
  /// In en, this message translates to:
  /// **'Enter the most you are willing to pay. We bid for you only as much as needed to keep you in the lead, up to that maximum. Nobody else ever sees your maximum.'**
  String get faqProxyA;

  /// No description provided for @faqReserveQ.
  ///
  /// In en, this message translates to:
  /// **'What is a reserve price?'**
  String get faqReserveQ;

  /// No description provided for @faqReserveA.
  ///
  /// In en, this message translates to:
  /// **'A hidden minimum set by the seller. If bidding ends below it, the item does not sell. The listing shows \"Reserve met\" once a bid reaches it.'**
  String get faqReserveA;

  /// No description provided for @faqProtectionQ.
  ///
  /// In en, this message translates to:
  /// **'What is buyer protection?'**
  String get faqProtectionQ;

  /// No description provided for @faqProtectionA.
  ///
  /// In en, this message translates to:
  /// **'Your payment is held by Authentic and only released to the seller after you confirm delivery. If the item does not arrive or is not as described, use \"Report a problem\" on the order.'**
  String get faqProtectionA;

  /// No description provided for @faqCostQ.
  ///
  /// In en, this message translates to:
  /// **'What does it cost?'**
  String get faqCostQ;

  /// No description provided for @faqCostA.
  ///
  /// In en, this message translates to:
  /// **'Buyers pay the winning price, shipping and a service fee of {service}% (max Rp 10.000). Sellers pay a final value fee of {fee}% of the sale price.'**
  String faqCostA(int service, int fee);

  /// No description provided for @legalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: November 2026'**
  String get legalUpdated;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @shownMasked.
  ///
  /// In en, this message translates to:
  /// **'Shown masked when you bid'**
  String get shownMasked;

  /// No description provided for @emailCantChange.
  ///
  /// In en, this message translates to:
  /// **'Email can\'t be changed here.'**
  String get emailCantChange;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @deleteAddressQ.
  ///
  /// In en, this message translates to:
  /// **'Delete this address?'**
  String get deleteAddressQ;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @chooseAddress.
  ///
  /// In en, this message translates to:
  /// **'Choose address'**
  String get chooseAddress;

  /// No description provided for @noAddresses.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet.'**
  String get noAddresses;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addAddress;

  /// No description provided for @addressOptions.
  ///
  /// In en, this message translates to:
  /// **'Address options'**
  String get addressOptions;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get editAddress;

  /// No description provided for @recipientName.
  ///
  /// In en, this message translates to:
  /// **'Recipient name'**
  String get recipientName;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get streetAddress;

  /// No description provided for @streetHint.
  ///
  /// In en, this message translates to:
  /// **'Street, number, RT/RW, district'**
  String get streetHint;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get postalCode;

  /// No description provided for @enter5Digits.
  ///
  /// In en, this message translates to:
  /// **'Enter 5 digits'**
  String get enter5Digits;

  /// No description provided for @useAsDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Use as default address'**
  String get useAsDefaultAddress;

  /// No description provided for @saveAddress.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get saveAddress;

  /// No description provided for @paymentExpired.
  ///
  /// In en, this message translates to:
  /// **'The payment window for this order has expired.'**
  String get paymentExpired;

  /// No description provided for @couldNotOpenPayment.
  ///
  /// In en, this message translates to:
  /// **'Could not open the payment page.'**
  String get couldNotOpenPayment;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get noConnection;

  /// No description provided for @orderCantBePaid.
  ///
  /// In en, this message translates to:
  /// **'This order can no longer be paid.'**
  String get orderCantBePaid;

  /// No description provided for @paymentsNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Payments are not set up yet (Cloud Functions not deployed).'**
  String get paymentsNotSetUp;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get paymentFailed;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @orderPreparing.
  ///
  /// In en, this message translates to:
  /// **'Your order is being prepared. Check back in a moment.'**
  String get orderPreparing;

  /// No description provided for @wonFor.
  ///
  /// In en, this message translates to:
  /// **'Won for {price}'**
  String wonFor(String price);

  /// No description provided for @payWithin.
  ///
  /// In en, this message translates to:
  /// **'Pay within'**
  String get payWithin;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping address'**
  String get shippingAddress;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @addShippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Add shipping address'**
  String get addShippingAddress;

  /// No description provided for @courier.
  ///
  /// In en, this message translates to:
  /// **'Courier'**
  String get courier;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @etaDays.
  ///
  /// In en, this message translates to:
  /// **'{range} days'**
  String etaDays(String range);

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @payVirtualAccount.
  ///
  /// In en, this message translates to:
  /// **'Virtual account'**
  String get payVirtualAccount;

  /// No description provided for @payQris.
  ///
  /// In en, this message translates to:
  /// **'QRIS'**
  String get payQris;

  /// No description provided for @payQrisDetail.
  ///
  /// In en, this message translates to:
  /// **'Scan with any banking or e-wallet app'**
  String get payQrisDetail;

  /// No description provided for @payEWallet.
  ///
  /// In en, this message translates to:
  /// **'E-wallet'**
  String get payEWallet;

  /// No description provided for @heldNote.
  ///
  /// In en, this message translates to:
  /// **'Your money is held by Authentic and only released to the seller after you confirm delivery.'**
  String get heldNote;

  /// No description provided for @winningPrice.
  ///
  /// In en, this message translates to:
  /// **'Winning price'**
  String get winningPrice;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @serviceFee.
  ///
  /// In en, this message translates to:
  /// **'Service fee'**
  String get serviceFee;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @payWithXendit.
  ///
  /// In en, this message translates to:
  /// **'Pay with Xendit'**
  String get payWithXendit;

  /// No description provided for @orderIsPaid.
  ///
  /// In en, this message translates to:
  /// **'This order is paid.'**
  String get orderIsPaid;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get paymentReceived;

  /// No description provided for @paymentReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ve told the seller. You\'ll get a notification when it ships.'**
  String get paymentReceivedBody;

  /// No description provided for @youreHighestBidder.
  ///
  /// In en, this message translates to:
  /// **'You\'re the highest bidder'**
  String get youreHighestBidder;

  /// No description provided for @outbidByMax.
  ///
  /// In en, this message translates to:
  /// **'Another bidder\'s max is higher. Current price is now {price}. Try a higher max.'**
  String outbidByMax(String price);

  /// No description provided for @couldNotPlaceBid.
  ///
  /// In en, this message translates to:
  /// **'Could not place bid: {error}'**
  String couldNotPlaceBid(String error);

  /// No description provided for @enterMoreThanMax.
  ///
  /// In en, this message translates to:
  /// **'Enter more than your current max {amount}'**
  String enterMoreThanMax(String amount);

  /// No description provided for @enterOrMore.
  ///
  /// In en, this message translates to:
  /// **'Enter {amount} or more'**
  String enterOrMore(String amount);

  /// No description provided for @currentPriceBids.
  ///
  /// In en, this message translates to:
  /// **'Current {price} · {count} bids ·'**
  String currentPriceBids(String price, int count);

  /// No description provided for @timeLeftSuffix.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get timeLeftSuffix;

  /// No description provided for @raiseYourMaxBid.
  ///
  /// In en, this message translates to:
  /// **'Raise your maximum bid'**
  String get raiseYourMaxBid;

  /// No description provided for @placeYourMaxBid.
  ///
  /// In en, this message translates to:
  /// **'Place your maximum bid'**
  String get placeYourMaxBid;

  /// No description provided for @yourMaxBid.
  ///
  /// In en, this message translates to:
  /// **'Your maximum bid'**
  String get yourMaxBid;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works:'**
  String get howItWorks;

  /// No description provided for @howItWorksBody.
  ///
  /// In en, this message translates to:
  /// **'we bid for you only as much as needed to keep you in the lead, up to your maximum. Others never see your maximum.'**
  String get howItWorksBody;

  /// No description provided for @agreeToBuy.
  ///
  /// In en, this message translates to:
  /// **'By confirming, you agree to buy if you win.'**
  String get agreeToBuy;

  /// No description provided for @bidsBinding.
  ///
  /// In en, this message translates to:
  /// **'Bids are binding.'**
  String get bidsBinding;

  /// No description provided for @auctionHasEnded.
  ///
  /// In en, this message translates to:
  /// **'This auction has ended'**
  String get auctionHasEnded;

  /// No description provided for @confirmBid.
  ///
  /// In en, this message translates to:
  /// **'Confirm bid'**
  String get confirmBid;

  /// No description provided for @confirmBidAmount.
  ///
  /// In en, this message translates to:
  /// **'Confirm bid · {amount}'**
  String confirmBidAmount(String amount);

  /// No description provided for @rejectClosed.
  ///
  /// In en, this message translates to:
  /// **'This auction has ended.'**
  String get rejectClosed;

  /// No description provided for @rejectSeller.
  ///
  /// In en, this message translates to:
  /// **'Sellers cannot bid on their own listings.'**
  String get rejectSeller;

  /// No description provided for @rejectInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get rejectInvalid;

  /// No description provided for @rejectBelowMin.
  ///
  /// In en, this message translates to:
  /// **'Your maximum must be at least {amount}.'**
  String rejectBelowMin(String amount);

  /// No description provided for @rejectCannotLower.
  ///
  /// In en, this message translates to:
  /// **'You are already leading with a maximum of {amount}. You can only raise it.'**
  String rejectCannotLower(String amount);

  /// No description provided for @countdownEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get countdownEnded;

  /// No description provided for @listingGone.
  ///
  /// In en, this message translates to:
  /// **'This listing no longer exists.'**
  String get listingGone;

  /// No description provided for @shipsFrom.
  ///
  /// In en, this message translates to:
  /// **'Ships from {place}'**
  String shipsFrom(String place);

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'{title} · {price} on Authentic'**
  String shareText(String title, String price);

  /// No description provided for @photoOf.
  ///
  /// In en, this message translates to:
  /// **'Photo {n} of {total}. Tap to zoom.'**
  String photoOf(int n, int total);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @removeFromWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Remove from watchlist'**
  String get removeFromWatchlist;

  /// No description provided for @addToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Add to watchlist'**
  String get addToWatchlist;

  /// No description provided for @newSeller.
  ///
  /// In en, this message translates to:
  /// **'New seller'**
  String get newSeller;

  /// No description provided for @sellerSemantics.
  ///
  /// In en, this message translates to:
  /// **'Seller {name}, {rating}'**
  String sellerSemantics(String name, String rating);

  /// No description provided for @nameSeller.
  ///
  /// In en, this message translates to:
  /// **'{name} (seller)'**
  String nameSeller(String name);

  /// No description provided for @youWonItem.
  ///
  /// In en, this message translates to:
  /// **'You won this item!'**
  String get youWonItem;

  /// No description provided for @youDidntWin.
  ///
  /// In en, this message translates to:
  /// **'You didn\'t win this item.'**
  String get youDidntWin;

  /// No description provided for @youreHighestMax.
  ///
  /// In en, this message translates to:
  /// **'You\'re the highest bidder · your max {amount}'**
  String youreHighestMax(String amount);

  /// No description provided for @youveBeenOutbid.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been outbid. Raise your max to get back in.'**
  String get youveBeenOutbid;

  /// No description provided for @buyNowPrice.
  ///
  /// In en, this message translates to:
  /// **'Buy It Now price'**
  String get buyNowPrice;

  /// No description provided for @currentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current price'**
  String get currentPrice;

  /// No description provided for @finalPrice.
  ///
  /// In en, this message translates to:
  /// **'Final price'**
  String get finalPrice;

  /// No description provided for @nBids.
  ///
  /// In en, this message translates to:
  /// **'{count} bids'**
  String nBids(int count);

  /// No description provided for @nBidders.
  ///
  /// In en, this message translates to:
  /// **'{count} bidders'**
  String nBidders(int count);

  /// No description provided for @nWatching.
  ///
  /// In en, this message translates to:
  /// **'{count} watching'**
  String nWatching(int count);

  /// No description provided for @reserveMet.
  ///
  /// In en, this message translates to:
  /// **'Reserve met'**
  String get reserveMet;

  /// No description provided for @reserveNotMet.
  ///
  /// In en, this message translates to:
  /// **'Reserve not met'**
  String get reserveNotMet;

  /// No description provided for @endedNotSold.
  ///
  /// In en, this message translates to:
  /// **'Ended · not sold'**
  String get endedNotSold;

  /// No description provided for @endedBySeller.
  ///
  /// In en, this message translates to:
  /// **'Ended by seller'**
  String get endedBySeller;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @freeCouriers.
  ///
  /// In en, this message translates to:
  /// **'Free · JNE / SiCepat'**
  String get freeCouriers;

  /// No description provided for @handlingTime.
  ///
  /// In en, this message translates to:
  /// **'Handling time'**
  String get handlingTime;

  /// No description provided for @shipsInDays.
  ///
  /// In en, this message translates to:
  /// **'Ships in {n} days'**
  String shipsInDays(int n);

  /// No description provided for @returns.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get returns;

  /// No description provided for @returnDaysProtection.
  ///
  /// In en, this message translates to:
  /// **'{n} days · buyer protection'**
  String returnDaysProtection(int n);

  /// No description provided for @noReturns.
  ///
  /// In en, this message translates to:
  /// **'No returns'**
  String get noReturns;

  /// No description provided for @bidHistory.
  ///
  /// In en, this message translates to:
  /// **'Bid history'**
  String get bidHistory;

  /// No description provided for @noBidsYet.
  ///
  /// In en, this message translates to:
  /// **'No bids yet.'**
  String get noBidsYet;

  /// No description provided for @allNBids.
  ///
  /// In en, this message translates to:
  /// **'All {count} bids'**
  String allNBids(int count);

  /// No description provided for @seeAllNBids.
  ///
  /// In en, this message translates to:
  /// **'See all {count} bids'**
  String seeAllNBids(int count);

  /// No description provided for @namesMasked.
  ///
  /// In en, this message translates to:
  /// **'Names are masked. Nobody\'s maximum bid is ever shown.'**
  String get namesMasked;

  /// No description provided for @endListingQ.
  ///
  /// In en, this message translates to:
  /// **'End this listing?'**
  String get endListingQ;

  /// No description provided for @endListingBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from search right away.'**
  String get endListingBody;

  /// No description provided for @endListingAction.
  ///
  /// In en, this message translates to:
  /// **'End listing'**
  String get endListingAction;

  /// No description provided for @adminControls.
  ///
  /// In en, this message translates to:
  /// **'Admin controls'**
  String get adminControls;

  /// No description provided for @relist7Days.
  ///
  /// In en, this message translates to:
  /// **'Relist (7 days)'**
  String get relist7Days;

  /// No description provided for @buyItNow.
  ///
  /// In en, this message translates to:
  /// **'Buy It Now'**
  String get buyItNow;

  /// No description provided for @buyNowConfirm.
  ///
  /// In en, this message translates to:
  /// **'Buy \"{title}\" for {price}? This ends the listing.'**
  String buyNowConfirm(String title, String price);

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @youBoughtIt.
  ///
  /// In en, this message translates to:
  /// **'You bought it!'**
  String get youBoughtIt;

  /// No description provided for @buyItNowPrice.
  ///
  /// In en, this message translates to:
  /// **'Buy It Now · {price}'**
  String buyItNowPrice(String price);

  /// No description provided for @minimumBid.
  ///
  /// In en, this message translates to:
  /// **'Minimum bid'**
  String get minimumBid;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{number}'**
  String orderNumber(String number);

  /// No description provided for @soldTo.
  ///
  /// In en, this message translates to:
  /// **'Sold to {name}'**
  String soldTo(String name);

  /// No description provided for @boughtFrom.
  ///
  /// In en, this message translates to:
  /// **'Bought from {name}'**
  String boughtFrom(String name);

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found.'**
  String get orderNotFound;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'{amount} paid'**
  String amountPaid(String amount);

  /// No description provided for @problemReportedBanner.
  ///
  /// In en, this message translates to:
  /// **'A problem was reported. Payment to the seller is on hold until it is resolved.'**
  String get problemReportedBanner;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled.'**
  String get orderCancelled;

  /// No description provided for @markInTransit.
  ///
  /// In en, this message translates to:
  /// **'Mark in transit'**
  String get markInTransit;

  /// No description provided for @markedInTransit.
  ///
  /// In en, this message translates to:
  /// **'Marked in transit.'**
  String get markedInTransit;

  /// No description provided for @markDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark delivered'**
  String get markDelivered;

  /// No description provided for @markedDelivered.
  ///
  /// In en, this message translates to:
  /// **'Marked delivered.'**
  String get markedDelivered;

  /// No description provided for @shipTo.
  ///
  /// In en, this message translates to:
  /// **'Ship to'**
  String get shipTo;

  /// No description provided for @iReceivedItem.
  ///
  /// In en, this message translates to:
  /// **'I received the item'**
  String get iReceivedItem;

  /// No description provided for @confirmReceivedQ.
  ///
  /// In en, this message translates to:
  /// **'Confirm you received the item?'**
  String get confirmReceivedQ;

  /// No description provided for @confirmReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'This completes the order and releases the payment to the seller.'**
  String get confirmReceivedBody;

  /// No description provided for @notYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get notYet;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @orderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Order completed.'**
  String get orderCompleted;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportProblem;

  /// No description provided for @buyerProtectionNote.
  ///
  /// In en, this message translates to:
  /// **'Not received or not as described? You\'re covered by buyer protection.'**
  String get buyerProtectionNote;

  /// No description provided for @waitingForPayment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment'**
  String get waitingForPayment;

  /// No description provided for @buyerHas.
  ///
  /// In en, this message translates to:
  /// **'Buyer has'**
  String get buyerHas;

  /// No description provided for @toPaySuffix.
  ///
  /// In en, this message translates to:
  /// **'to pay'**
  String get toPaySuffix;

  /// No description provided for @autoConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Auto-confirmed {days} days after delivery'**
  String autoConfirmed(int days);

  /// No description provided for @trackingCopied.
  ///
  /// In en, this message translates to:
  /// **'Tracking number copied.'**
  String get trackingCopied;

  /// No description provided for @copyTracking.
  ///
  /// In en, this message translates to:
  /// **'Copy tracking number'**
  String get copyTracking;

  /// No description provided for @stepDone.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get stepDone;

  /// No description provided for @stepCurrent.
  ///
  /// In en, this message translates to:
  /// **'in progress'**
  String get stepCurrent;

  /// No description provided for @stepUpcoming.
  ///
  /// In en, this message translates to:
  /// **'upcoming'**
  String get stepUpcoming;

  /// No description provided for @markedShipped.
  ///
  /// In en, this message translates to:
  /// **'Marked as shipped. The buyer has been notified.'**
  String get markedShipped;

  /// No description provided for @shipThisOrder.
  ///
  /// In en, this message translates to:
  /// **'Ship this order'**
  String get shipThisOrder;

  /// No description provided for @shipWithinDays.
  ///
  /// In en, this message translates to:
  /// **'Ship within {days} days of payment.'**
  String shipWithinDays(int days);

  /// No description provided for @trackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking number'**
  String get trackingNumber;

  /// No description provided for @enterTracking.
  ///
  /// In en, this message translates to:
  /// **'Enter the tracking number'**
  String get enterTracking;

  /// No description provided for @markAsShipped.
  ///
  /// In en, this message translates to:
  /// **'Mark as shipped'**
  String get markAsShipped;

  /// No description provided for @reasonNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Not received'**
  String get reasonNotReceived;

  /// No description provided for @reasonNotAsDescribed.
  ///
  /// In en, this message translates to:
  /// **'Not as described'**
  String get reasonNotAsDescribed;

  /// No description provided for @reasonDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get reasonDamaged;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @describeProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem in a few words (10+ characters).'**
  String get describeProblem;

  /// No description provided for @problemReported.
  ///
  /// In en, this message translates to:
  /// **'Problem reported. We\'ll look into it.'**
  String get problemReported;

  /// No description provided for @whatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get whatHappened;

  /// No description provided for @whatHappenedHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what is wrong with the item or delivery'**
  String get whatHappenedHint;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @addPhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Add photo (optional)'**
  String get addPhotoOptional;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get submitReport;

  /// No description provided for @ratingPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get ratingPositive;

  /// No description provided for @ratingNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get ratingNeutral;

  /// No description provided for @ratingNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get ratingNegative;

  /// No description provided for @thanksFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get thanksFeedback;

  /// No description provided for @rateSeller.
  ///
  /// In en, this message translates to:
  /// **'Rate the seller'**
  String get rateSeller;

  /// No description provided for @rateBuyer.
  ///
  /// In en, this message translates to:
  /// **'Rate the buyer'**
  String get rateBuyer;

  /// No description provided for @ratedSeller.
  ///
  /// In en, this message translates to:
  /// **'You rated this seller. Thanks!'**
  String get ratedSeller;

  /// No description provided for @ratedBuyer.
  ///
  /// In en, this message translates to:
  /// **'You rated this buyer. Thanks!'**
  String get ratedBuyer;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @sendRating.
  ///
  /// In en, this message translates to:
  /// **'Send rating'**
  String get sendRating;

  /// No description provided for @buyerFallback.
  ///
  /// In en, this message translates to:
  /// **'buyer'**
  String get buyerFallback;

  /// No description provided for @sellerFallback.
  ///
  /// In en, this message translates to:
  /// **'seller'**
  String get sellerFallback;

  /// No description provided for @errNoPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add at least 1 photo'**
  String get errNoPhotos;

  /// No description provided for @errTooManyPhotos.
  ///
  /// In en, this message translates to:
  /// **'Maximum {max} photos'**
  String errTooManyPhotos(int max);

  /// No description provided for @errPickCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get errPickCategory;

  /// No description provided for @errPriceTooLow.
  ///
  /// In en, this message translates to:
  /// **'At least Rp 1.000'**
  String get errPriceTooLow;

  /// No description provided for @errNotAboveStart.
  ///
  /// In en, this message translates to:
  /// **'Must be higher than the starting price'**
  String get errNotAboveStart;

  /// No description provided for @errNoBuyNow.
  ///
  /// In en, this message translates to:
  /// **'Enter the Buy It Now price'**
  String get errNoBuyNow;

  /// No description provided for @errBelowReserve.
  ///
  /// In en, this message translates to:
  /// **'Must be at least the reserve price'**
  String get errBelowReserve;

  /// No description provided for @continueDraftQ.
  ///
  /// In en, this message translates to:
  /// **'Continue your draft?'**
  String get continueDraftQ;

  /// No description provided for @draftSavedAs.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" was saved as a draft.'**
  String draftSavedAs(String title);

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @startNew.
  ///
  /// In en, this message translates to:
  /// **'Start new'**
  String get startNew;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved.'**
  String get draftSaved;

  /// No description provided for @couldNotSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Could not save draft: {error}'**
  String couldNotSaveDraft(String error);

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @onlyNPhotos.
  ///
  /// In en, this message translates to:
  /// **'Only {max} photos allowed.'**
  String onlyNPhotos(int max);

  /// No description provided for @rateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate unavailable. Enter the starting price yourself.'**
  String get rateUnavailable;

  /// No description provided for @couldNotCreateListing.
  ///
  /// In en, this message translates to:
  /// **'Could not create listing: {error}'**
  String couldNotCreateListing(String error);

  /// No description provided for @discardQ.
  ///
  /// In en, this message translates to:
  /// **'Discard this listing?'**
  String get discardQ;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'Your changes will be lost. Tap \"Save draft\" to keep them.'**
  String get discardBody;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @importFromCatalog.
  ///
  /// In en, this message translates to:
  /// **'Import from catalog'**
  String get importFromCatalog;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Brand, model, size, colour'**
  String get titleHint;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Condition, what\'s included, any flaws'**
  String get descriptionHint;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @buyNowOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'Fixed price, no bids. The first buyer gets it.'**
  String get buyNowOnlyNote;

  /// No description provided for @startingPrice.
  ///
  /// In en, this message translates to:
  /// **'Starting price'**
  String get startingPrice;

  /// No description provided for @reservePrice.
  ///
  /// In en, this message translates to:
  /// **'Reserve price'**
  String get reservePrice;

  /// No description provided for @optionalHidden.
  ///
  /// In en, this message translates to:
  /// **'(optional, hidden)'**
  String get optionalHidden;

  /// No description provided for @reserveHelper.
  ///
  /// In en, this message translates to:
  /// **'The item won\'t sell below this price'**
  String get reserveHelper;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @endsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends {date}'**
  String endsOn(String date);

  /// No description provided for @shippingAndReturns.
  ///
  /// In en, this message translates to:
  /// **'Shipping & returns'**
  String get shippingAndReturns;

  /// No description provided for @shippingCost.
  ///
  /// In en, this message translates to:
  /// **'Shipping cost'**
  String get shippingCost;

  /// No description provided for @zeroFree.
  ///
  /// In en, this message translates to:
  /// **'0 = free'**
  String get zeroFree;

  /// No description provided for @shipsWithin.
  ///
  /// In en, this message translates to:
  /// **'Ships within'**
  String get shipsWithin;

  /// No description provided for @nDays.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 day} other{{n} days}}'**
  String nDays(int n);

  /// No description provided for @itemLocation.
  ///
  /// In en, this message translates to:
  /// **'Item location'**
  String get itemLocation;

  /// No description provided for @itemLocationHint.
  ///
  /// In en, this message translates to:
  /// **'City, e.g. Makassar'**
  String get itemLocationHint;

  /// No description provided for @acceptReturns.
  ///
  /// In en, this message translates to:
  /// **'Accept returns'**
  String get acceptReturns;

  /// No description provided for @within7Days.
  ///
  /// In en, this message translates to:
  /// **'Within 7 days'**
  String get within7Days;

  /// No description provided for @listItem.
  ///
  /// In en, this message translates to:
  /// **'List item'**
  String get listItem;

  /// No description provided for @finalValueFee.
  ///
  /// In en, this message translates to:
  /// **'Final value fee: {fee}% of the sale price'**
  String finalValueFee(int fee);

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @reorderHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press to reorder. The first photo is the cover.'**
  String get reorderHint;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addPhotos;

  /// No description provided for @cover.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get cover;

  /// No description provided for @uploadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo {n}'**
  String uploadingPhoto(int n);

  /// No description provided for @removePhotoN.
  ///
  /// In en, this message translates to:
  /// **'Remove photo {n}'**
  String removePhotoN(int n);

  /// No description provided for @photo1Cover.
  ///
  /// In en, this message translates to:
  /// **'Photo 1, cover'**
  String get photo1Cover;

  /// No description provided for @photoN.
  ///
  /// In en, this message translates to:
  /// **'Photo {n}'**
  String photoN(int n);

  /// No description provided for @searchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search products, e.g. \"watch\", \"laptop\"'**
  String get searchProductsHint;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get noProductsFound;

  /// No description provided for @couldNotSignOut.
  ///
  /// In en, this message translates to:
  /// **'Could not sign out: {error}'**
  String couldNotSignOut(String error);

  /// No description provided for @deleteAccountQ.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountQ;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile, addresses, payout account, drafts and watchlist will be deleted. Finished orders are kept for the other party. This cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteWord.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteWord;

  /// No description provided for @typeToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type {word} to confirm'**
  String typeToConfirm(String word);

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account was deleted.'**
  String get accountDeleted;

  /// No description provided for @wrongPasswordNothingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Wrong password. Nothing was deleted.'**
  String get wrongPasswordNothingDeleted;

  /// No description provided for @cancelledNothingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Cancelled. Nothing was deleted.'**
  String get cancelledNothingDeleted;

  /// No description provided for @couldNotDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the account.'**
  String get couldNotDeleteAccount;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @liveAuctionsBlockDelete.
  ///
  /// In en, this message translates to:
  /// **'You have live auctions with bids. Wait until they end.'**
  String get liveAuctionsBlockDelete;

  /// No description provided for @highestBidder.
  ///
  /// In en, this message translates to:
  /// **'Highest bidder'**
  String get highestBidder;

  /// No description provided for @yourMaxSuffix.
  ///
  /// In en, this message translates to:
  /// **'· your max {amount}'**
  String yourMaxSuffix(String amount);

  /// No description provided for @endedLabel.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get endedLabel;

  /// No description provided for @finalAmount.
  ///
  /// In en, this message translates to:
  /// **'Final {amount}'**
  String finalAmount(String amount);

  /// No description provided for @watching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get watching;

  /// No description provided for @trendingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}, {title}, {price}, {count} bids'**
  String trendingSemantics(int rank, String title, String price, int count);

  /// No description provided for @recentBidsSemantics.
  ///
  /// In en, this message translates to:
  /// **', {count} bids in the last hour'**
  String recentBidsSemantics(int count);

  /// No description provided for @unreadPrefix.
  ///
  /// In en, this message translates to:
  /// **'Unread.'**
  String get unreadPrefix;

  /// No description provided for @avatarOf.
  ///
  /// In en, this message translates to:
  /// **'Avatar of {name}'**
  String avatarOf(String name);

  /// No description provided for @buyItNowSpace.
  ///
  /// In en, this message translates to:
  /// **'Buy It Now {price}'**
  String buyItNowSpace(String price);

  /// No description provided for @buyItNowPrefix.
  ///
  /// In en, this message translates to:
  /// **'Buy It Now ·'**
  String get buyItNowPrefix;

  /// No description provided for @nBidsPrefix.
  ///
  /// In en, this message translates to:
  /// **'{count} bids ·'**
  String nBidsPrefix(int count);

  /// No description provided for @adminsOnlyMsg.
  ///
  /// In en, this message translates to:
  /// **'Admins only.'**
  String get adminsOnlyMsg;

  /// No description provided for @adminAllListings.
  ///
  /// In en, this message translates to:
  /// **'Admin · All listings'**
  String get adminAllListings;

  /// No description provided for @noListings.
  ///
  /// In en, this message translates to:
  /// **'No listings.'**
  String get noListings;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done.'**
  String get done;

  /// No description provided for @endListingNow.
  ///
  /// In en, this message translates to:
  /// **'End listing now'**
  String get endListingNow;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete listing'**
  String get deleteListing;

  /// No description provided for @noPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do that.'**
  String get noPermission;

  /// No description provided for @cannotBuyOwn.
  ///
  /// In en, this message translates to:
  /// **'You cannot buy your own item.'**
  String get cannotBuyOwn;

  /// No description provided for @buyNowUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Buy It Now is no longer available.'**
  String get buyNowUnavailable;

  /// No description provided for @cannotEndWithBids.
  ///
  /// In en, this message translates to:
  /// **'Listings with bids cannot be ended early.'**
  String get cannotEndWithBids;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in.'**
  String get notSignedIn;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'That email address is not valid.'**
  String get authInvalidEmail;

  /// No description provided for @authDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authDisabled;

  /// No description provided for @authEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for that email.'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters for the password.'**
  String get authWeakPassword;

  /// No description provided for @authWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get authWrongCredentials;

  /// No description provided for @authTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get authTooMany;

  /// No description provided for @authGoogleCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get authGoogleCancelled;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed.'**
  String get authFailed;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String somethingWrong(String error);

  /// No description provided for @bidsWatchingPrefix.
  ///
  /// In en, this message translates to:
  /// **'{bids} bids · {watchers} watching ·'**
  String bidsWatchingPrefix(int bids, int watchers);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'loading'**
  String get loading;

  /// No description provided for @labelLoading.
  ///
  /// In en, this message translates to:
  /// **'{label}, loading'**
  String labelLoading(String label);

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'your email'**
  String get yourEmail;

  /// No description provided for @auctionCardSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}, {price}, {count} bids'**
  String auctionCardSemantics(String title, String price, int count);

  /// No description provided for @reminder1h.
  ///
  /// In en, this message translates to:
  /// **'1 hour left'**
  String get reminder1h;

  /// No description provided for @reminder10m.
  ///
  /// In en, this message translates to:
  /// **'10 minutes left'**
  String get reminder10m;

  /// No description provided for @reminderBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" ends soon. Check the price and place your final bid.'**
  String reminderBody(String title);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
