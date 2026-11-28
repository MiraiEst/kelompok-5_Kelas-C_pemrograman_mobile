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
  String get catElectronics => 'Electronics';

  @override
  String get catFashion => 'Fashion';

  @override
  String get catAntique => 'Antique';

  @override
  String get catHobbiesToys => 'Hobbies & Toys';

  @override
  String get catHome => 'Home';

  @override
  String get catAutomotive => 'Automotive';

  @override
  String get catOther => 'Other';

  @override
  String get hotDeals => 'Hot deals';

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
  String get verified => 'Verified user';

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

  @override
  String get statusAwaitingPayment => 'Awaiting payment';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusShipped => 'Shipped';

  @override
  String get statusInTransit => 'In transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get listingActive => 'Active';

  @override
  String get listingSold => 'Sold';

  @override
  String get listingUnsold => 'Unsold';

  @override
  String get listingEnded => 'Ended';

  @override
  String get conditionNew => 'New';

  @override
  String get conditionUsed => 'Used';

  @override
  String get conditionForParts => 'For parts';

  @override
  String get formatAuction => 'Auction';

  @override
  String get formatBuyNow => 'Buy It Now';

  @override
  String get formatBoth => 'Both';

  @override
  String get durationTest => '5 min (test)';

  @override
  String durationDays(int n) {
    return '${n}d';
  }

  @override
  String get prefOutbid => 'Outbid';

  @override
  String get prefEndingSoon => 'Ending soon';

  @override
  String get prefWonLost => 'Won / lost';

  @override
  String get prefNewBid => 'New bid on my item';

  @override
  String get prefReserveMet => 'Reserve met';

  @override
  String get prefOrders => 'Orders & shipping';

  @override
  String get prefSecondChance => 'Second chance';

  @override
  String get listingEndedSnack => 'Listing ended.';

  @override
  String get relistedSnack => 'Relisted for 7 days.';

  @override
  String get noListingsHere => 'No listings here.';

  @override
  String get endListing => 'End';

  @override
  String get relist => 'Relist';

  @override
  String bidsWatching(int bids, int watchers) {
    return '$bids bids · $watchers watching';
  }

  @override
  String get nothingToShip => 'Nothing to ship right now.';

  @override
  String get purchasesEmpty => 'Items you buy will appear here.';

  @override
  String get payoutSaved => 'Payout account saved.';

  @override
  String get payoutIntro =>
      'Sale proceeds are paid to this account after the buyer confirms delivery.';

  @override
  String get changeAccount => 'Change account';

  @override
  String get bank => 'Bank';

  @override
  String get chooseYourBank => 'Choose your bank';

  @override
  String get chooseABank => 'Choose a bank';

  @override
  String get accountNumber => 'Account number';

  @override
  String get enterValidAccountNumber => 'Enter a valid account number';

  @override
  String get accountHolderName => 'Account holder name';

  @override
  String get enterAccountName => 'Enter the name on the account';

  @override
  String get push => 'Push';

  @override
  String get notifSettingsNote =>
      'In-app notifications always appear in the Notifications list. These switches control pushes to your phone.';

  @override
  String get faqProxyQ => 'How does proxy bidding work?';

  @override
  String get faqProxyA =>
      'Enter the most you are willing to pay. We bid for you only as much as needed to keep you in the lead, up to that maximum. Nobody else ever sees your maximum.';

  @override
  String get faqReserveQ => 'What is a reserve price?';

  @override
  String get faqReserveA =>
      'A hidden minimum set by the seller. If bidding ends below it, the item does not sell. The listing shows \"Reserve met\" once a bid reaches it.';

  @override
  String get faqProtectionQ => 'What is buyer protection?';

  @override
  String get faqProtectionA =>
      'Your payment is held by Authentic and only released to the seller after you confirm delivery. If the item does not arrive or is not as described, use \"Report a problem\" on the order.';

  @override
  String get faqCostQ => 'What does it cost?';

  @override
  String faqCostA(int service, int fee) {
    return 'Buyers pay the winning price, shipping and a service fee of $service% (max Rp 10.000). Sellers pay a final value fee of $fee% of the sale price.';
  }

  @override
  String get legalUpdated => 'Last updated: November 2026';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get shownMasked => 'Shown masked when you bid';

  @override
  String get emailCantChange => 'Email can\'t be changed here.';

  @override
  String get defaultLabel => 'Default';

  @override
  String get deleteAddressQ => 'Delete this address?';

  @override
  String get delete => 'Delete';

  @override
  String get chooseAddress => 'Choose address';

  @override
  String get noAddresses => 'No saved addresses yet.';

  @override
  String get addAddress => 'Add address';

  @override
  String get addressOptions => 'Address options';

  @override
  String get edit => 'Edit';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get required => 'Required';

  @override
  String get editAddress => 'Edit address';

  @override
  String get recipientName => 'Recipient name';

  @override
  String get streetAddress => 'Street address';

  @override
  String get streetHint => 'Street, number, RT/RW, district';

  @override
  String get city => 'City';

  @override
  String get province => 'Province';

  @override
  String get postalCode => 'Postal code';

  @override
  String get enter5Digits => 'Enter 5 digits';

  @override
  String get useAsDefaultAddress => 'Use as default address';

  @override
  String get saveAddress => 'Save address';

  @override
  String get paymentExpired => 'The payment window for this order has expired.';

  @override
  String get couldNotOpenPayment => 'Could not open the payment page.';

  @override
  String get noConnection => 'No connection. Check your internet and try again.';

  @override
  String get orderCantBePaid => 'This order can no longer be paid.';

  @override
  String get paymentsNotSetUp => 'Payments are not set up yet (Cloud Functions not deployed).';

  @override
  String get paymentFailed => 'Payment failed. Please try again.';

  @override
  String get checkout => 'Checkout';

  @override
  String get orderPreparing => 'Your order is being prepared. Check back in a moment.';

  @override
  String wonFor(String price) {
    return 'Won for $price';
  }

  @override
  String get payWithin => 'Pay within';

  @override
  String get shippingAddress => 'Shipping address';

  @override
  String get add => 'Add';

  @override
  String get change => 'Change';

  @override
  String get addShippingAddress => 'Add shipping address';

  @override
  String get courier => 'Courier';

  @override
  String get free => 'Free';

  @override
  String etaDays(String range) {
    return '$range days';
  }

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get payVirtualAccount => 'Virtual account';

  @override
  String get payQris => 'QRIS';

  @override
  String get payQrisDetail => 'Scan with any banking or e-wallet app';

  @override
  String get payEWallet => 'E-wallet';

  @override
  String get heldNote =>
      'Your money is held by Authentic and only released to the seller after you confirm delivery.';

  @override
  String get winningPrice => 'Winning price';

  @override
  String get shipping => 'Shipping';

  @override
  String get serviceFee => 'Service fee';

  @override
  String get total => 'Total';

  @override
  String get payWithXendit => 'Pay with Xendit';

  @override
  String get orderIsPaid => 'This order is paid.';

  @override
  String get paymentReceived => 'Payment received';

  @override
  String get paymentReceivedBody =>
      'We\'ve told the seller. You\'ll get a notification when it ships.';

  @override
  String get youreHighestBidder => 'You\'re the highest bidder';

  @override
  String outbidByMax(String price) {
    return 'Another bidder\'s max is higher. Current price is now $price. Try a higher max.';
  }

  @override
  String couldNotPlaceBid(String error) {
    return 'Could not place bid: $error';
  }

  @override
  String enterMoreThanMax(String amount) {
    return 'Enter more than your current max $amount';
  }

  @override
  String enterOrMore(String amount) {
    return 'Enter $amount or more';
  }

  @override
  String currentPriceBids(String price, int count) {
    return 'Current $price · $count bids ·';
  }

  @override
  String get timeLeftSuffix => 'left';

  @override
  String get raiseYourMaxBid => 'Raise your maximum bid';

  @override
  String get placeYourMaxBid => 'Place your maximum bid';

  @override
  String get yourMaxBid => 'Your maximum bid';

  @override
  String get howItWorks => 'How it works:';

  @override
  String get howItWorksBody =>
      'we bid for you only as much as needed to keep you in the lead, up to your maximum. Others never see your maximum.';

  @override
  String get agreeToBuy => 'By confirming, you agree to buy if you win.';

  @override
  String get bidsBinding => 'Bids are binding.';

  @override
  String get auctionHasEnded => 'This auction has ended';

  @override
  String get confirmBid => 'Confirm bid';

  @override
  String confirmBidAmount(String amount) {
    return 'Confirm bid · $amount';
  }

  @override
  String get rejectClosed => 'This auction has ended.';

  @override
  String get rejectSeller => 'Sellers cannot bid on their own listings.';

  @override
  String get rejectInvalid => 'Enter a valid amount.';

  @override
  String rejectBelowMin(String amount) {
    return 'Your maximum must be at least $amount.';
  }

  @override
  String rejectCannotLower(String amount) {
    return 'You are already leading with a maximum of $amount. You can only raise it.';
  }

  @override
  String get countdownEnded => 'Ended';

  @override
  String get listingGone => 'This listing no longer exists.';

  @override
  String shipsFrom(String place) {
    return 'Ships from $place';
  }

  @override
  String get description => 'Description';

  @override
  String shareText(String title, String price) {
    return '$title · $price on Authentic';
  }

  @override
  String photoOf(int n, int total) {
    return 'Photo $n of $total. Tap to zoom.';
  }

  @override
  String get share => 'Share';

  @override
  String get removeFromWatchlist => 'Remove from watchlist';

  @override
  String get addToWatchlist => 'Add to watchlist';

  @override
  String get newSeller => 'New seller';

  @override
  String sellerSemantics(String name, String rating) {
    return 'Seller $name, $rating';
  }

  @override
  String nameSeller(String name) {
    return '$name (seller)';
  }

  @override
  String get youWonItem => 'You won this item!';

  @override
  String get youDidntWin => 'You didn\'t win this item.';

  @override
  String youreHighestMax(String amount) {
    return 'You\'re the highest bidder · your max $amount';
  }

  @override
  String get youveBeenOutbid => 'You\'ve been outbid. Raise your max to get back in.';

  @override
  String get buyNowPrice => 'Buy It Now price';

  @override
  String get currentPrice => 'Current price';

  @override
  String get finalPrice => 'Final price';

  @override
  String nBids(int count) {
    return '$count bids';
  }

  @override
  String nBidders(int count) {
    return '$count bidders';
  }

  @override
  String nWatching(int count) {
    return '$count watching';
  }

  @override
  String get reserveMet => 'Reserve met';

  @override
  String get reserveNotMet => 'Reserve not met';

  @override
  String get endedNotSold => 'Ended · not sold';

  @override
  String get endedBySeller => 'Ended by seller';

  @override
  String get showLess => 'Show less';

  @override
  String get readMore => 'Read more';

  @override
  String get freeCouriers => 'Free · JNE / SiCepat';

  @override
  String get handlingTime => 'Handling time';

  @override
  String shipsInDays(int n) {
    return 'Ships in $n days';
  }

  @override
  String get returns => 'Returns';

  @override
  String returnDaysProtection(int n) {
    return '$n days · buyer protection';
  }

  @override
  String get noReturns => 'No returns';

  @override
  String get bidHistory => 'Bid history';

  @override
  String get noBidsYet => 'No bids yet.';

  @override
  String allNBids(int count) {
    return 'All $count bids';
  }

  @override
  String seeAllNBids(int count) {
    return 'See all $count bids';
  }

  @override
  String get namesMasked => 'Names are masked. Nobody\'s maximum bid is ever shown.';

  @override
  String get endListingQ => 'End this listing?';

  @override
  String get endListingBody => 'It will be removed from search right away.';

  @override
  String get endListingAction => 'End listing';

  @override
  String get adminControls => 'Admin controls';

  @override
  String get relist7Days => 'Relist (7 days)';

  @override
  String get buyItNow => 'Buy It Now';

  @override
  String buyNowConfirm(String title, String price) {
    return 'Buy \"$title\" for $price? This ends the listing.';
  }

  @override
  String get buy => 'Buy';

  @override
  String get youBoughtIt => 'You bought it!';

  @override
  String buyItNowPrice(String price) {
    return 'Buy It Now · $price';
  }

  @override
  String get minimumBid => 'Minimum bid';

  @override
  String get order => 'Order';

  @override
  String orderNumber(String number) {
    return 'Order #$number';
  }

  @override
  String soldTo(String name) {
    return 'Sold to $name';
  }

  @override
  String boughtFrom(String name) {
    return 'Bought from $name';
  }

  @override
  String get orderNotFound => 'Order not found.';

  @override
  String amountPaid(String amount) {
    return '$amount paid';
  }

  @override
  String get problemReportedBanner =>
      'A problem was reported. Payment to the seller is on hold until it is resolved.';

  @override
  String get orderCancelled => 'This order was cancelled.';

  @override
  String get markInTransit => 'Mark in transit';

  @override
  String get markedInTransit => 'Marked in transit.';

  @override
  String get markDelivered => 'Mark delivered';

  @override
  String get markedDelivered => 'Marked delivered.';

  @override
  String get shipTo => 'Ship to';

  @override
  String get iReceivedItem => 'I received the item';

  @override
  String get confirmReceivedQ => 'Confirm you received the item?';

  @override
  String get confirmReceivedBody =>
      'This completes the order and releases the payment to the seller.';

  @override
  String get notYet => 'Not yet';

  @override
  String get confirm => 'Confirm';

  @override
  String get orderCompleted => 'Order completed.';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get buyerProtectionNote =>
      'Not received or not as described? You\'re covered by buyer protection.';

  @override
  String get waitingForPayment => 'Waiting for payment';

  @override
  String get buyerHas => 'Buyer has';

  @override
  String get toPaySuffix => 'to pay';

  @override
  String autoConfirmed(int days) {
    return 'Auto-confirmed $days days after delivery';
  }

  @override
  String get trackingCopied => 'Tracking number copied.';

  @override
  String get copyTracking => 'Copy tracking number';

  @override
  String get stepDone => 'done';

  @override
  String get stepCurrent => 'in progress';

  @override
  String get stepUpcoming => 'upcoming';

  @override
  String get markedShipped => 'Marked as shipped. The buyer has been notified.';

  @override
  String get shipThisOrder => 'Ship this order';

  @override
  String shipWithinDays(int days) {
    return 'Ship within $days days of payment.';
  }

  @override
  String get trackingNumber => 'Tracking number';

  @override
  String get enterTracking => 'Enter the tracking number';

  @override
  String get markAsShipped => 'Mark as shipped';

  @override
  String get reasonNotReceived => 'Not received';

  @override
  String get reasonNotAsDescribed => 'Not as described';

  @override
  String get reasonDamaged => 'Damaged';

  @override
  String get reasonOther => 'Other';

  @override
  String get describeProblem => 'Describe the problem in a few words (10+ characters).';

  @override
  String get problemReported => 'Problem reported. We\'ll look into it.';

  @override
  String get whatHappened => 'What happened?';

  @override
  String get whatHappenedHint => 'Tell us what is wrong with the item or delivery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get addPhotoOptional => 'Add photo (optional)';

  @override
  String get submitReport => 'Submit report';

  @override
  String get ratingPositive => 'Positive';

  @override
  String get ratingNeutral => 'Neutral';

  @override
  String get ratingNegative => 'Negative';

  @override
  String get thanksFeedback => 'Thanks for your feedback!';

  @override
  String get rateSeller => 'Rate the seller';

  @override
  String get rateBuyer => 'Rate the buyer';

  @override
  String get ratedSeller => 'You rated this seller. Thanks!';

  @override
  String get ratedBuyer => 'You rated this buyer. Thanks!';

  @override
  String get commentHint => 'How was the item and shipping?';

  @override
  String nStars(int count) {
    return '$count stars';
  }

  @override
  String get addThreeZeros => 'Add three zeros';

  @override
  String get comment => 'Comment';

  @override
  String get sendRating => 'Send rating';

  @override
  String get buyerFallback => 'buyer';

  @override
  String get sellerFallback => 'seller';

  @override
  String get errNoPhotos => 'Add at least 1 photo';

  @override
  String errTooManyPhotos(int max) {
    return 'Maximum $max photos';
  }

  @override
  String get errPickCategory => 'Pick a category';

  @override
  String get errPriceTooLow => 'At least Rp 1.000';

  @override
  String get errNotAboveStart => 'Must be higher than the starting price';

  @override
  String get errNoBuyNow => 'Enter the Buy It Now price';

  @override
  String get errBelowReserve => 'Must be at least the reserve price';

  @override
  String get continueDraftQ => 'Continue your draft?';

  @override
  String draftSavedAs(String title) {
    return '\"$title\" was saved as a draft.';
  }

  @override
  String get untitled => 'Untitled';

  @override
  String get startNew => 'Start new';

  @override
  String get continueLabel => 'Continue';

  @override
  String get draftSaved => 'Draft saved.';

  @override
  String couldNotSaveDraft(String error) {
    return 'Could not save draft: $error';
  }

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String onlyNPhotos(int max) {
    return 'Only $max photos allowed.';
  }

  @override
  String get rateUnavailable => 'Exchange rate unavailable. Enter the starting price yourself.';

  @override
  String couldNotCreateListing(String error) {
    return 'Could not create listing: $error';
  }

  @override
  String get discardQ => 'Discard this listing?';

  @override
  String get discardBody => 'Your changes will be lost. Tap \"Save draft\" to keep them.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get saveDraft => 'Save draft';

  @override
  String get importFromCatalog => 'Import from catalog';

  @override
  String get title => 'Title';

  @override
  String get titleHint => 'Brand, model, size, colour';

  @override
  String get descriptionHint => 'Condition, what\'s included, any flaws';

  @override
  String get category => 'Category';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get condition => 'Condition';

  @override
  String get format => 'Format';

  @override
  String get buyNowOnlyNote => 'Fixed price, no bids. The first buyer gets it.';

  @override
  String get startingPrice => 'Starting price';

  @override
  String get reservePrice => 'Reserve price';

  @override
  String get optionalHidden => '(optional, hidden)';

  @override
  String get reserveHelper => 'The item won\'t sell below this price';

  @override
  String get duration => 'Duration';

  @override
  String endsOn(String date) {
    return 'Ends $date';
  }

  @override
  String get shippingAndReturns => 'Shipping & returns';

  @override
  String get shippingCost => 'Shipping cost';

  @override
  String get zeroFree => '0 = free';

  @override
  String get shipsWithin => 'Ships within';

  @override
  String nDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n days', one: '1 day');
    return '$_temp0';
  }

  @override
  String get itemLocation => 'Item location';

  @override
  String get itemLocationHint => 'City, e.g. Makassar';

  @override
  String get acceptReturns => 'Accept returns';

  @override
  String get within7Days => 'Within 7 days';

  @override
  String get listItem => 'List item';

  @override
  String finalValueFee(int fee) {
    return 'Final value fee: $fee% of the sale price';
  }

  @override
  String get photos => 'Photos';

  @override
  String get reorderHint => 'Long-press to reorder. The first photo is the cover.';

  @override
  String get addPhotos => 'Add photos';

  @override
  String get cover => 'Cover';

  @override
  String uploadingPhoto(int n) {
    return 'Uploading photo $n';
  }

  @override
  String removePhotoN(int n) {
    return 'Remove photo $n';
  }

  @override
  String get photo1Cover => 'Photo 1, cover';

  @override
  String photoN(int n) {
    return 'Photo $n';
  }

  @override
  String get searchProductsHint => 'Search products, e.g. \"watch\", \"laptop\"';

  @override
  String get noProductsFound => 'No products found.';

  @override
  String couldNotSignOut(String error) {
    return 'Could not sign out: $error';
  }

  @override
  String get deleteAccountQ => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'Your profile, addresses, payout account, drafts and watchlist will be deleted. Finished orders are kept for the other party. This cannot be undone.';

  @override
  String get deleteWord => 'DELETE';

  @override
  String typeToConfirm(String word) {
    return 'Type $word to confirm';
  }

  @override
  String get accountDeleted => 'Your account was deleted.';

  @override
  String get wrongPasswordNothingDeleted => 'Wrong password. Nothing was deleted.';

  @override
  String get cancelledNothingDeleted => 'Cancelled. Nothing was deleted.';

  @override
  String get couldNotDeleteAccount => 'Could not delete the account.';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get liveAuctionsBlockDelete => 'You have live auctions with bids. Wait until they end.';

  @override
  String get highestBidder => 'Highest bidder';

  @override
  String yourMaxSuffix(String amount) {
    return '· your max $amount';
  }

  @override
  String get endedLabel => 'Ended';

  @override
  String finalAmount(String amount) {
    return 'Final $amount';
  }

  @override
  String get watching => 'Watching';

  @override
  String trendingSemantics(int rank, String title, String price, int count) {
    return 'Rank $rank, $title, $price, $count bids';
  }

  @override
  String recentBidsSemantics(int count) {
    return ', $count bids in the last hour';
  }

  @override
  String get unreadPrefix => 'Unread.';

  @override
  String avatarOf(String name) {
    return 'Avatar of $name';
  }

  @override
  String buyItNowSpace(String price) {
    return 'Buy It Now $price';
  }

  @override
  String get buyItNowPrefix => 'Buy It Now ·';

  @override
  String nBidsPrefix(int count) {
    return '$count bids ·';
  }

  @override
  String get adminsOnlyMsg => 'Admins only.';

  @override
  String get adminAllListings => 'Admin · All listings';

  @override
  String get noListings => 'No listings.';

  @override
  String get done => 'Done.';

  @override
  String get endListingNow => 'End listing now';

  @override
  String get deleteListing => 'Delete listing';

  @override
  String get noPermission => 'You don\'t have permission to do that.';

  @override
  String get cannotBuyOwn => 'You cannot buy your own item.';

  @override
  String get buyNowUnavailable => 'Buy It Now is no longer available.';

  @override
  String get cannotEndWithBids => 'Listings with bids cannot be ended early.';

  @override
  String get notSignedIn => 'Not signed in.';

  @override
  String get authInvalidEmail => 'That email address is not valid.';

  @override
  String get authDisabled => 'This account has been disabled.';

  @override
  String get authEmailInUse => 'An account already exists for that email.';

  @override
  String get authWeakPassword => 'Use at least 8 characters for the password.';

  @override
  String get authWrongCredentials => 'Wrong email or password.';

  @override
  String get authTooMany => 'Too many attempts. Try again later.';

  @override
  String get authGoogleCancelled => 'Google sign-in was cancelled.';

  @override
  String get authFailed => 'Authentication failed.';

  @override
  String somethingWrong(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String bidsWatchingPrefix(int bids, int watchers) {
    return '$bids bids · $watchers watching ·';
  }

  @override
  String get loading => 'loading';

  @override
  String labelLoading(String label) {
    return '$label, loading';
  }

  @override
  String get yourEmail => 'your email';

  @override
  String auctionCardSemantics(String title, String price, int count) {
    return '$title, $price, $count bids';
  }

  @override
  String get reminder1h => '1 hour left';

  @override
  String get reminder10m => '10 minutes left';

  @override
  String reminderBody(String title) {
    return '\"$title\" ends soon. Check the price and place your final bid.';
  }
}
