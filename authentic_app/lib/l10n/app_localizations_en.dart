// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navTrending => 'Trending';

  @override
  String get navYourBids => 'Your bids';

  @override
  String get navAccount => 'Account';

  @override
  String get tryAgain => 'Try again';

  @override
  String get seeAll => 'See all';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get notifications => 'Notifications';

  @override
  String notificationsUnread(int count) {
    return 'Notifications, $count unread';
  }

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to bid, sell and track your orders';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get enterEmailFirst => 'Enter your email first.';

  @override
  String get resetEmailSent => 'Password reset email sent.';

  @override
  String get createAccountTitle => 'Create your account';

  @override
  String get createAccountSubtitle => 'One account to buy and sell';

  @override
  String get username => 'Username';

  @override
  String get usernameHint => 'Shown masked when you bid (a***b)';

  @override
  String get atLeast3 => 'At least 3 characters';

  @override
  String get atLeast8 => 'At least 8 characters';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get phoneInvalid => 'Use an Indonesian number starting with 08';

  @override
  String get agreePrefix => 'I agree to the ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get createAccount => 'Create account';

  @override
  String get verifyNote => 'We\'ll email you a link to verify your account before you can bid.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get verifyTitle => 'Verify your email';

  @override
  String verifyBody(String email) {
    return 'We sent a link to $email. Open it to activate your account, then come back and tap \"I\'ve verified\".';
  }

  @override
  String get iveVerified => 'I\'ve verified';

  @override
  String get resendEmail => 'Resend email';

  @override
  String resendEmailIn(int seconds) {
    return 'Resend email (${seconds}s)';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get checkSpam => 'Can\'t find it? Check your spam folder.';

  @override
  String get notVerifiedYet => 'Not verified yet. Open the link in the email first.';

  @override
  String get verificationSent => 'Verification email sent.';

  @override
  String get searchAuctions => 'Search auctions';

  @override
  String get all => 'All';

  @override
  String get endingSoon => 'Ending soon';

  @override
  String get allAuctions => 'All auctions';

  @override
  String get noActiveAuctions => 'No active auctions yet';

  @override
  String get noEndingSoon => 'No auctions ending soon.';

  @override
  String get sell => 'Sell';

  @override
  String get sellAnItem => 'Sell an item';

  @override
  String get endsIn => 'Ends in ';

  @override
  String get trendingSubtitle => 'Updated live from bids and watchers';

  @override
  String get mostBids => 'Most bids';

  @override
  String get mostWatched => 'Most watched';

  @override
  String get newToday => 'New today';

  @override
  String get hotCategories => 'Hot categories';

  @override
  String get nothingNewToday => 'Nothing new in the last 24 hours.';

  @override
  String get noLiveCategories => 'No live categories yet.';

  @override
  String liveCount(int count) {
    return '$count live';
  }

  @override
  String get bidding => 'Bidding';

  @override
  String biddingCount(int count) {
    return 'Bidding ($count)';
  }

  @override
  String get won => 'Won';

  @override
  String wonCount(int count) {
    return 'Won ($count)';
  }

  @override
  String get didntWin => 'Didn\'t win';

  @override
  String get watchlist => 'Watchlist';

  @override
  String get winning => 'Winning';

  @override
  String get outbid => 'Outbid';

  @override
  String get toPay => 'To pay';

  @override
  String get emptyBidding => 'You have no active bids';

  @override
  String get emptyWon => 'Items you win will appear here';

  @override
  String get emptyLost => 'Nothing here yet';

  @override
  String get emptyWatchlist => 'Tap the heart on an auction to watch it';

  @override
  String get raiseMaxBid => 'Raise max bid';

  @override
  String get placeMaxBid => 'Place max bid';

  @override
  String get payNow => 'Pay now';

  @override
  String get trackOrder => 'Track order';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get earlier => 'Earlier';

  @override
  String get notificationsEmpty => 'Outbid alerts, wins and sales will show up here.';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get undo => 'Undo';

  @override
  String get justNow => 'Just now';

  @override
  String minAgo(int n) {
    return '$n min ago';
  }

  @override
  String hoursAgo(int n) {
    return '$n h ago';
  }

  @override
  String daysAgo(int n) {
    return '$n days ago';
  }

  @override
  String get selling => 'Selling';

  @override
  String get sold => 'Sold';

  @override
  String get purchases => 'Purchases';

  @override
  String get buying => 'Buying';

  @override
  String get settings => 'Settings';

  @override
  String get myListings => 'My listings';

  @override
  String activeCount(int count) {
    return '$count active';
  }

  @override
  String get ordersToShip => 'Orders to ship';

  @override
  String get payoutAccount => 'Payout account';

  @override
  String get notSet => 'Not set';

  @override
  String get purchasesAndOrders => 'Purchases & orders';

  @override
  String get addresses => 'Addresses';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get adminPanel => 'Admin panel';

  @override
  String get adminsOnly => 'admins only';

  @override
  String get helpTermsPrivacy => 'Help, terms & privacy';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get verified => 'Verified';

  @override
  String memberSince(int year) {
    return 'Member since $year';
  }

  @override
  String get noRatingsYet => 'No ratings yet';

  @override
  String ratingSummary(int pct, int count) {
    return '$pct% positive · $count ratings';
  }
}
