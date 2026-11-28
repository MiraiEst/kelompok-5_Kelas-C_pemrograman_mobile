// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get navHome => 'Beranda';

  @override
  String get navTrending => 'Trending';

  @override
  String get navYourBids => 'Tawaran saya';

  @override
  String get navAccount => 'Akun';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get seeAll => 'Lihat semua';

  @override
  String get cancel => 'Batal';

  @override
  String get back => 'Kembali';

  @override
  String get close => 'Tutup';

  @override
  String get save => 'Simpan';

  @override
  String get notifications => 'Notifikasi';

  @override
  String notificationsUnread(int count) {
    return 'Notifikasi, $count belum dibaca';
  }

  @override
  String get welcomeBack => 'Selamat datang kembali';

  @override
  String get signInSubtitle => 'Masuk untuk menawar, menjual, dan melacak pesanan';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata sandi';

  @override
  String get forgotPassword => 'Lupa kata sandi?';

  @override
  String get signIn => 'Masuk';

  @override
  String get or => 'atau';

  @override
  String get continueWithGoogle => 'Lanjut dengan Google';

  @override
  String get noAccount => 'Belum punya akun?';

  @override
  String get register => 'Daftar';

  @override
  String get showPassword => 'Tampilkan kata sandi';

  @override
  String get hidePassword => 'Sembunyikan kata sandi';

  @override
  String get enterValidEmail => 'Masukkan email yang valid';

  @override
  String get enterPassword => 'Masukkan kata sandi';

  @override
  String get enterEmailFirst => 'Masukkan email Anda dulu.';

  @override
  String get resetEmailSent => 'Email reset kata sandi terkirim.';

  @override
  String get createAccountTitle => 'Buat akun Anda';

  @override
  String get createAccountSubtitle => 'Satu akun untuk membeli dan menjual';

  @override
  String get username => 'Nama pengguna';

  @override
  String get usernameHint => 'Ditampilkan tersamar saat menawar (a***b)';

  @override
  String get atLeast3 => 'Minimal 3 karakter';

  @override
  String get atLeast8 => 'Minimal 8 karakter';

  @override
  String get phoneNumber => 'Nomor telepon';

  @override
  String get phoneInvalid => 'Gunakan nomor Indonesia yang diawali 08';

  @override
  String get agreePrefix => 'Saya setuju dengan ';

  @override
  String get termsOfService => 'Ketentuan Layanan';

  @override
  String get and => ' dan ';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get createAccount => 'Buat akun';

  @override
  String get verifyNote =>
      'Kami akan mengirim tautan verifikasi ke email Anda sebelum Anda bisa menawar.';

  @override
  String get backToSignIn => 'Kembali ke halaman masuk';

  @override
  String get verifyTitle => 'Verifikasi email Anda';

  @override
  String verifyBody(String email) {
    return 'Kami mengirim tautan ke $email. Buka tautan itu untuk mengaktifkan akun, lalu kembali dan ketuk \"Sudah verifikasi\".';
  }

  @override
  String get iveVerified => 'Sudah verifikasi';

  @override
  String get resendEmail => 'Kirim ulang email';

  @override
  String resendEmailIn(int seconds) {
    return 'Kirim ulang email ($seconds dtk)';
  }

  @override
  String get signOut => 'Keluar';

  @override
  String get checkSpam => 'Tidak ketemu? Periksa folder spam.';

  @override
  String get notVerifiedYet => 'Belum terverifikasi. Buka tautan di email dulu.';

  @override
  String get verificationSent => 'Email verifikasi terkirim.';

  @override
  String get searchAuctions => 'Cari lelang';

  @override
  String get all => 'Semua';

  @override
  String get endingSoon => 'Segera berakhir';

  @override
  String get catElectronics => 'Elektronik';

  @override
  String get catFashion => 'Fashion';

  @override
  String get catAntique => 'Antique';

  @override
  String get catHobbiesToys => 'Hobi dan Mainan';

  @override
  String get catHome => 'Rumah';

  @override
  String get catAutomotive => 'Otomotif';

  @override
  String get catOther => 'Lainnya';

  @override
  String get hotDeals => 'Penawaran panas';

  @override
  String get allAuctions => 'Semua lelang';

  @override
  String get noActiveAuctions => 'Belum ada lelang aktif';

  @override
  String get noEndingSoon => 'Tidak ada lelang yang segera berakhir.';

  @override
  String get sell => 'Jual';

  @override
  String get sellAnItem => 'Jual barang';

  @override
  String get endsIn => 'Berakhir dalam ';

  @override
  String get trendingSubtitle => 'Diperbarui langsung dari tawaran dan pemantau';

  @override
  String get mostBids => 'Tawaran terbanyak';

  @override
  String get mostWatched => 'Paling dipantau';

  @override
  String get newToday => 'Baru hari ini';

  @override
  String get hotCategories => 'Kategori populer';

  @override
  String get nothingNewToday => 'Belum ada yang baru dalam 24 jam terakhir.';

  @override
  String get noLiveCategories => 'Belum ada kategori aktif.';

  @override
  String liveCount(int count) {
    return '$count aktif';
  }

  @override
  String get bidding => 'Menawar';

  @override
  String biddingCount(int count) {
    return 'Menawar ($count)';
  }

  @override
  String get won => 'Menang';

  @override
  String wonCount(int count) {
    return 'Menang ($count)';
  }

  @override
  String get didntWin => 'Tidak menang';

  @override
  String get watchlist => 'Pantauan';

  @override
  String get winning => 'Memimpin';

  @override
  String get outbid => 'Kalah tawar';

  @override
  String get toPay => 'Belum dibayar';

  @override
  String get emptyBidding => 'Anda belum punya tawaran aktif';

  @override
  String get emptyWon => 'Barang yang Anda menangkan akan muncul di sini';

  @override
  String get emptyLost => 'Belum ada apa-apa di sini';

  @override
  String get emptyWatchlist => 'Ketuk ikon hati pada lelang untuk memantaunya';

  @override
  String get raiseMaxBid => 'Naikkan tawaran maks';

  @override
  String get placeMaxBid => 'Pasang tawaran maks';

  @override
  String get payNow => 'Bayar sekarang';

  @override
  String get trackOrder => 'Lacak pesanan';

  @override
  String get markAllRead => 'Tandai semua dibaca';

  @override
  String get today => 'Hari ini';

  @override
  String get yesterday => 'Kemarin';

  @override
  String get earlier => 'Sebelumnya';

  @override
  String get notificationsEmpty =>
      'Info kalah tawar, kemenangan, dan penjualan akan muncul di sini.';

  @override
  String get notificationDeleted => 'Notifikasi dihapus';

  @override
  String get undo => 'Urungkan';

  @override
  String get justNow => 'Baru saja';

  @override
  String minAgo(int n) {
    return '$n mnt lalu';
  }

  @override
  String hoursAgo(int n) {
    return '$n jam lalu';
  }

  @override
  String daysAgo(int n) {
    return '$n hari lalu';
  }

  @override
  String get selling => 'Dijual';

  @override
  String get sold => 'Terjual';

  @override
  String get purchases => 'Pembelian';

  @override
  String get buying => 'Pembelian';

  @override
  String get settings => 'Pengaturan';

  @override
  String get myListings => 'Barang saya';

  @override
  String activeCount(int count) {
    return '$count aktif';
  }

  @override
  String get ordersToShip => 'Pesanan untuk dikirim';

  @override
  String get payoutAccount => 'Rekening pencairan';

  @override
  String get notSet => 'Belum diisi';

  @override
  String get purchasesAndOrders => 'Pembelian & pesanan';

  @override
  String get addresses => 'Alamat';

  @override
  String get notificationSettings => 'Pengaturan notifikasi';

  @override
  String get adminPanel => 'Panel admin';

  @override
  String get adminsOnly => 'khusus admin';

  @override
  String get helpTermsPrivacy => 'Bantuan, ketentuan & privasi';

  @override
  String get deleteAccount => 'Hapus akun';

  @override
  String get editProfile => 'Ubah profil';

  @override
  String get verified => 'Pengguna terverifikasi';

  @override
  String memberSince(int year) {
    return 'Anggota sejak $year';
  }

  @override
  String get noRatingsYet => 'Belum ada penilaian';

  @override
  String ratingSummary(int pct, int count) {
    return '$pct% positif · $count penilaian';
  }

  @override
  String get statusAwaitingPayment => 'Menunggu pembayaran';

  @override
  String get statusPaid => 'Dibayar';

  @override
  String get statusShipped => 'Dikirim';

  @override
  String get statusInTransit => 'Dalam perjalanan';

  @override
  String get statusDelivered => 'Diterima';

  @override
  String get statusCompleted => 'Selesai';

  @override
  String get statusCancelled => 'Dibatalkan';

  @override
  String get listingActive => 'Aktif';

  @override
  String get listingSold => 'Terjual';

  @override
  String get listingUnsold => 'Tidak terjual';

  @override
  String get listingEnded => 'Dihentikan';

  @override
  String get conditionNew => 'Baru';

  @override
  String get conditionUsed => 'Bekas';

  @override
  String get conditionForParts => 'Untuk suku cadang';

  @override
  String get formatAuction => 'Lelang';

  @override
  String get formatBuyNow => 'Beli Sekarang';

  @override
  String get formatBoth => 'Keduanya';

  @override
  String get durationTest => '5 mnt (tes)';

  @override
  String durationDays(int n) {
    return '$n hr';
  }

  @override
  String get prefOutbid => 'Tawaran terlampaui';

  @override
  String get prefEndingSoon => 'Segera berakhir';

  @override
  String get prefWonLost => 'Menang / kalah';

  @override
  String get prefNewBid => 'Tawaran baru di barang saya';

  @override
  String get prefReserveMet => 'Harga cadangan tercapai';

  @override
  String get prefOrders => 'Pesanan & pengiriman';

  @override
  String get prefSecondChance => 'Kesempatan kedua';

  @override
  String get listingEndedSnack => 'Lelang dihentikan.';

  @override
  String get relistedSnack => 'Dilelang ulang selama 7 hari.';

  @override
  String get noListingsHere => 'Belum ada barang di sini.';

  @override
  String get endListing => 'Hentikan';

  @override
  String get relist => 'Lelang ulang';

  @override
  String bidsWatching(int bids, int watchers) {
    return '$bids tawaran · $watchers memantau';
  }

  @override
  String get nothingToShip => 'Belum ada yang perlu dikirim.';

  @override
  String get purchasesEmpty => 'Barang yang Anda beli akan muncul di sini.';

  @override
  String get payoutSaved => 'Rekening pencairan disimpan.';

  @override
  String get payoutIntro =>
      'Hasil penjualan dibayarkan ke rekening ini setelah pembeli mengonfirmasi barang diterima.';

  @override
  String get changeAccount => 'Ganti rekening';

  @override
  String get bank => 'Bank';

  @override
  String get chooseYourBank => 'Pilih bank Anda';

  @override
  String get chooseABank => 'Pilih bank';

  @override
  String get accountNumber => 'Nomor rekening';

  @override
  String get enterValidAccountNumber => 'Masukkan nomor rekening yang valid';

  @override
  String get accountHolderName => 'Nama pemilik rekening';

  @override
  String get enterAccountName => 'Masukkan nama sesuai rekening';

  @override
  String get push => 'Push';

  @override
  String get notifSettingsNote =>
      'Notifikasi dalam aplikasi selalu muncul di daftar Notifikasi. Tombol ini mengatur notifikasi push ke ponsel Anda.';

  @override
  String get faqProxyQ => 'Bagaimana cara kerja tawaran otomatis?';

  @override
  String get faqProxyA =>
      'Masukkan jumlah tertinggi yang mau Anda bayar. Kami menawar untuk Anda hanya sebesar yang diperlukan agar Anda tetap unggul, hingga batas maksimum itu. Tidak ada orang lain yang bisa melihat batas maksimum Anda.';

  @override
  String get faqReserveQ => 'Apa itu harga cadangan?';

  @override
  String get faqReserveA =>
      'Harga minimum tersembunyi yang ditetapkan penjual. Jika lelang berakhir di bawahnya, barang tidak terjual. Barang akan menampilkan \"Harga cadangan tercapai\" setelah ada tawaran yang mencapainya.';

  @override
  String get faqProtectionQ => 'Apa itu perlindungan pembeli?';

  @override
  String get faqProtectionA =>
      'Pembayaran Anda ditahan oleh Authentic dan baru diteruskan ke penjual setelah Anda mengonfirmasi barang diterima. Jika barang tidak sampai atau tidak sesuai deskripsi, gunakan \"Laporkan masalah\" pada pesanan.';

  @override
  String get faqCostQ => 'Berapa biayanya?';

  @override
  String faqCostA(int service, int fee) {
    return 'Pembeli membayar harga menang, ongkos kirim, dan biaya layanan $service% (maks. Rp 10.000). Penjual membayar biaya akhir $fee% dari harga jual.';
  }

  @override
  String get legalUpdated => 'Terakhir diperbarui: November 2026';

  @override
  String get changeProfilePhoto => 'Ganti foto profil';

  @override
  String get changePhoto => 'Ganti foto';

  @override
  String get shownMasked => 'Ditampilkan tersamar saat Anda menawar';

  @override
  String get emailCantChange => 'Email tidak dapat diubah di sini.';

  @override
  String get defaultLabel => 'Utama';

  @override
  String get deleteAddressQ => 'Hapus alamat ini?';

  @override
  String get delete => 'Hapus';

  @override
  String get chooseAddress => 'Pilih alamat';

  @override
  String get noAddresses => 'Belum ada alamat tersimpan.';

  @override
  String get addAddress => 'Tambah alamat';

  @override
  String get addressOptions => 'Opsi alamat';

  @override
  String get edit => 'Ubah';

  @override
  String get setAsDefault => 'Jadikan utama';

  @override
  String get required => 'Wajib diisi';

  @override
  String get editAddress => 'Ubah alamat';

  @override
  String get recipientName => 'Nama penerima';

  @override
  String get streetAddress => 'Alamat jalan';

  @override
  String get streetHint => 'Jalan, nomor, RT/RW, kecamatan';

  @override
  String get city => 'Kota/Kabupaten';

  @override
  String get province => 'Provinsi';

  @override
  String get postalCode => 'Kode pos';

  @override
  String get enter5Digits => 'Masukkan 5 angka';

  @override
  String get useAsDefaultAddress => 'Jadikan alamat utama';

  @override
  String get saveAddress => 'Simpan alamat';

  @override
  String get paymentExpired => 'Batas waktu pembayaran pesanan ini sudah lewat.';

  @override
  String get couldNotOpenPayment => 'Tidak dapat membuka halaman pembayaran.';

  @override
  String get noConnection => 'Tidak ada koneksi. Periksa internet Anda lalu coba lagi.';

  @override
  String get orderCantBePaid => 'Pesanan ini tidak dapat dibayar lagi.';

  @override
  String get paymentsNotSetUp => 'Pembayaran belum tersedia (Cloud Functions belum di-deploy).';

  @override
  String get paymentFailed => 'Pembayaran gagal. Silakan coba lagi.';

  @override
  String get checkout => 'Pembayaran';

  @override
  String get orderPreparing => 'Pesanan Anda sedang disiapkan. Coba lagi sebentar lagi.';

  @override
  String wonFor(String price) {
    return 'Dimenangkan seharga $price';
  }

  @override
  String get payWithin => 'Bayar dalam';

  @override
  String get shippingAddress => 'Alamat pengiriman';

  @override
  String get add => 'Tambah';

  @override
  String get change => 'Ganti';

  @override
  String get addShippingAddress => 'Tambah alamat pengiriman';

  @override
  String get courier => 'Kurir';

  @override
  String get free => 'Gratis';

  @override
  String etaDays(String range) {
    return '$range hari';
  }

  @override
  String get paymentMethod => 'Metode pembayaran';

  @override
  String get payVirtualAccount => 'Virtual account';

  @override
  String get payQris => 'QRIS';

  @override
  String get payQrisDetail => 'Pindai dengan aplikasi bank atau e-wallet apa pun';

  @override
  String get payEWallet => 'E-wallet';

  @override
  String get heldNote =>
      'Uang Anda ditahan oleh Authentic dan baru diteruskan ke penjual setelah Anda mengonfirmasi barang diterima.';

  @override
  String get winningPrice => 'Harga menang';

  @override
  String get shipping => 'Ongkos kirim';

  @override
  String get serviceFee => 'Biaya layanan';

  @override
  String get total => 'Total';

  @override
  String get payWithXendit => 'Bayar dengan Xendit';

  @override
  String get orderIsPaid => 'Pesanan ini sudah dibayar.';

  @override
  String get paymentReceived => 'Pembayaran diterima';

  @override
  String get paymentReceivedBody =>
      'Kami sudah memberi tahu penjual. Anda akan mendapat notifikasi saat barang dikirim.';

  @override
  String get youreHighestBidder => 'Anda penawar tertinggi';

  @override
  String outbidByMax(String price) {
    return 'Tawaran maksimum penawar lain lebih tinggi. Harga sekarang $price. Coba maksimum yang lebih tinggi.';
  }

  @override
  String couldNotPlaceBid(String error) {
    return 'Tawaran gagal: $error';
  }

  @override
  String enterMoreThanMax(String amount) {
    return 'Masukkan lebih dari maksimum Anda saat ini $amount';
  }

  @override
  String enterOrMore(String amount) {
    return 'Masukkan $amount atau lebih';
  }

  @override
  String currentPriceBids(String price, int count) {
    return 'Saat ini $price · $count tawaran ·';
  }

  @override
  String get timeLeftSuffix => 'lagi';

  @override
  String get raiseYourMaxBid => 'Naikkan tawaran maksimum Anda';

  @override
  String get placeYourMaxBid => 'Pasang tawaran maksimum Anda';

  @override
  String get yourMaxBid => 'Tawaran maksimum Anda';

  @override
  String get howItWorks => 'Cara kerjanya:';

  @override
  String get howItWorksBody =>
      'kami menawar untuk Anda hanya sebesar yang diperlukan agar Anda tetap unggul, hingga batas maksimum Anda. Orang lain tidak pernah melihat batas maksimum Anda.';

  @override
  String get agreeToBuy => 'Dengan mengonfirmasi, Anda setuju membeli jika menang.';

  @override
  String get bidsBinding => 'Tawaran bersifat mengikat.';

  @override
  String get auctionHasEnded => 'Lelang ini sudah berakhir';

  @override
  String get confirmBid => 'Konfirmasi tawaran';

  @override
  String confirmBidAmount(String amount) {
    return 'Konfirmasi tawaran · $amount';
  }

  @override
  String get rejectClosed => 'Lelang ini sudah berakhir.';

  @override
  String get rejectSeller => 'Penjual tidak dapat menawar barangnya sendiri.';

  @override
  String get rejectInvalid => 'Masukkan jumlah yang valid.';

  @override
  String rejectBelowMin(String amount) {
    return 'Tawaran maksimum Anda minimal $amount.';
  }

  @override
  String rejectCannotLower(String amount) {
    return 'Anda sudah unggul dengan maksimum $amount. Anda hanya bisa menaikkannya.';
  }

  @override
  String get countdownEnded => 'Berakhir';

  @override
  String get listingGone => 'Barang ini sudah tidak ada.';

  @override
  String shipsFrom(String place) {
    return 'Dikirim dari $place';
  }

  @override
  String get description => 'Deskripsi';

  @override
  String shareText(String title, String price) {
    return '$title · $price di Authentic';
  }

  @override
  String photoOf(int n, int total) {
    return 'Foto $n dari $total. Ketuk untuk memperbesar.';
  }

  @override
  String get share => 'Bagikan';

  @override
  String get removeFromWatchlist => 'Hapus dari pantauan';

  @override
  String get addToWatchlist => 'Tambah ke pantauan';

  @override
  String get newSeller => 'Penjual baru';

  @override
  String sellerSemantics(String name, String rating) {
    return 'Penjual $name, $rating';
  }

  @override
  String nameSeller(String name) {
    return '$name (penjual)';
  }

  @override
  String get youWonItem => 'Anda memenangkan barang ini!';

  @override
  String get youDidntWin => 'Anda tidak memenangkan barang ini.';

  @override
  String youreHighestMax(String amount) {
    return 'Anda penawar tertinggi · maksimum Anda $amount';
  }

  @override
  String get youveBeenOutbid =>
      'Tawaran Anda terlampaui. Naikkan maksimum Anda untuk kembali unggul.';

  @override
  String get buyNowPrice => 'Harga Beli Sekarang';

  @override
  String get currentPrice => 'Harga saat ini';

  @override
  String get finalPrice => 'Harga akhir';

  @override
  String nBids(int count) {
    return '$count tawaran';
  }

  @override
  String nBidders(int count) {
    return '$count penawar';
  }

  @override
  String nWatching(int count) {
    return '$count memantau';
  }

  @override
  String get reserveMet => 'Harga cadangan tercapai';

  @override
  String get reserveNotMet => 'Harga cadangan belum tercapai';

  @override
  String get endedNotSold => 'Berakhir · tidak terjual';

  @override
  String get endedBySeller => 'Dihentikan penjual';

  @override
  String get showLess => 'Lebih sedikit';

  @override
  String get readMore => 'Selengkapnya';

  @override
  String get freeCouriers => 'Gratis · JNE / SiCepat';

  @override
  String get handlingTime => 'Waktu proses';

  @override
  String shipsInDays(int n) {
    return 'Dikirim dalam $n hari';
  }

  @override
  String get returns => 'Pengembalian';

  @override
  String returnDaysProtection(int n) {
    return '$n hari · perlindungan pembeli';
  }

  @override
  String get noReturns => 'Tidak bisa dikembalikan';

  @override
  String get bidHistory => 'Riwayat tawaran';

  @override
  String get noBidsYet => 'Belum ada tawaran.';

  @override
  String allNBids(int count) {
    return 'Semua $count tawaran';
  }

  @override
  String seeAllNBids(int count) {
    return 'Lihat semua $count tawaran';
  }

  @override
  String get namesMasked => 'Nama disamarkan. Tawaran maksimum siapa pun tidak pernah ditampilkan.';

  @override
  String get endListingQ => 'Hentikan lelang ini?';

  @override
  String get endListingBody => 'Barang akan langsung dihapus dari pencarian.';

  @override
  String get endListingAction => 'Hentikan lelang';

  @override
  String get adminControls => 'Kontrol admin';

  @override
  String get relist7Days => 'Lelang ulang (7 hari)';

  @override
  String get buyItNow => 'Beli Sekarang';

  @override
  String buyNowConfirm(String title, String price) {
    return 'Beli \"$title\" seharga $price? Lelang akan berakhir.';
  }

  @override
  String get buy => 'Beli';

  @override
  String get youBoughtIt => 'Berhasil dibeli!';

  @override
  String buyItNowPrice(String price) {
    return 'Beli Sekarang · $price';
  }

  @override
  String get minimumBid => 'Tawaran minimum';

  @override
  String get order => 'Pesanan';

  @override
  String orderNumber(String number) {
    return 'Pesanan #$number';
  }

  @override
  String soldTo(String name) {
    return 'Dijual ke $name';
  }

  @override
  String boughtFrom(String name) {
    return 'Dibeli dari $name';
  }

  @override
  String get orderNotFound => 'Pesanan tidak ditemukan.';

  @override
  String amountPaid(String amount) {
    return '$amount dibayar';
  }

  @override
  String get problemReportedBanner =>
      'Ada masalah yang dilaporkan. Pembayaran ke penjual ditahan sampai masalah selesai.';

  @override
  String get orderCancelled => 'Pesanan ini dibatalkan.';

  @override
  String get markInTransit => 'Tandai dalam perjalanan';

  @override
  String get markedInTransit => 'Ditandai dalam perjalanan.';

  @override
  String get markDelivered => 'Tandai sudah sampai';

  @override
  String get markedDelivered => 'Ditandai sudah sampai.';

  @override
  String get shipTo => 'Kirim ke';

  @override
  String get iReceivedItem => 'Barang sudah saya terima';

  @override
  String get confirmReceivedQ => 'Konfirmasi barang sudah diterima?';

  @override
  String get confirmReceivedBody => 'Pesanan akan selesai dan pembayaran diteruskan ke penjual.';

  @override
  String get notYet => 'Belum';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get orderCompleted => 'Pesanan selesai.';

  @override
  String get reportProblem => 'Laporkan masalah';

  @override
  String get buyerProtectionNote =>
      'Barang tidak sampai atau tidak sesuai deskripsi? Anda dilindungi perlindungan pembeli.';

  @override
  String get waitingForPayment => 'Menunggu pembayaran';

  @override
  String get buyerHas => 'Sisa waktu pembeli';

  @override
  String get toPaySuffix => 'untuk membayar';

  @override
  String autoConfirmed(int days) {
    return 'Dikonfirmasi otomatis $days hari setelah sampai';
  }

  @override
  String get trackingCopied => 'Nomor resi disalin.';

  @override
  String get copyTracking => 'Salin nomor resi';

  @override
  String get stepDone => 'selesai';

  @override
  String get stepCurrent => 'sedang berlangsung';

  @override
  String get stepUpcoming => 'berikutnya';

  @override
  String get markedShipped => 'Ditandai sudah dikirim. Pembeli sudah diberi tahu.';

  @override
  String get shipThisOrder => 'Kirim pesanan ini';

  @override
  String shipWithinDays(int days) {
    return 'Kirim dalam $days hari setelah pembayaran.';
  }

  @override
  String get trackingNumber => 'Nomor resi';

  @override
  String get enterTracking => 'Masukkan nomor resi';

  @override
  String get markAsShipped => 'Tandai sudah dikirim';

  @override
  String get reasonNotReceived => 'Tidak diterima';

  @override
  String get reasonNotAsDescribed => 'Tidak sesuai deskripsi';

  @override
  String get reasonDamaged => 'Rusak';

  @override
  String get reasonOther => 'Lainnya';

  @override
  String get describeProblem => 'Jelaskan masalahnya dalam beberapa kata (minimal 10 karakter).';

  @override
  String get problemReported => 'Masalah dilaporkan. Kami akan menindaklanjutinya.';

  @override
  String get whatHappened => 'Apa yang terjadi?';

  @override
  String get whatHappenedHint => 'Ceritakan masalah pada barang atau pengirimannya';

  @override
  String get removePhoto => 'Hapus foto';

  @override
  String get addPhotoOptional => 'Tambah foto (opsional)';

  @override
  String get submitReport => 'Kirim laporan';

  @override
  String get ratingPositive => 'Positif';

  @override
  String get ratingNeutral => 'Netral';

  @override
  String get ratingNegative => 'Negatif';

  @override
  String get thanksFeedback => 'Terima kasih atas penilaian Anda!';

  @override
  String get rateSeller => 'Nilai penjual';

  @override
  String get rateBuyer => 'Nilai pembeli';

  @override
  String get ratedSeller => 'Anda sudah menilai penjual ini. Terima kasih!';

  @override
  String get ratedBuyer => 'Anda sudah menilai pembeli ini. Terima kasih!';

  @override
  String get comment => 'Komentar';

  @override
  String get sendRating => 'Kirim penilaian';

  @override
  String get buyerFallback => 'pembeli';

  @override
  String get sellerFallback => 'penjual';

  @override
  String get errNoPhotos => 'Tambahkan minimal 1 foto';

  @override
  String errTooManyPhotos(int max) {
    return 'Maksimal $max foto';
  }

  @override
  String get errPickCategory => 'Pilih kategori';

  @override
  String get errPriceTooLow => 'Minimal Rp 1.000';

  @override
  String get errNotAboveStart => 'Harus lebih tinggi dari harga awal';

  @override
  String get errNoBuyNow => 'Masukkan harga Beli Sekarang';

  @override
  String get errBelowReserve => 'Minimal sama dengan harga cadangan';

  @override
  String get continueDraftQ => 'Lanjutkan draf Anda?';

  @override
  String draftSavedAs(String title) {
    return '\"$title\" tersimpan sebagai draf.';
  }

  @override
  String get untitled => 'Tanpa judul';

  @override
  String get startNew => 'Mulai baru';

  @override
  String get continueLabel => 'Lanjutkan';

  @override
  String get draftSaved => 'Draf disimpan.';

  @override
  String couldNotSaveDraft(String error) {
    return 'Gagal menyimpan draf: $error';
  }

  @override
  String get takePhoto => 'Ambil foto';

  @override
  String get chooseFromGallery => 'Pilih dari galeri';

  @override
  String onlyNPhotos(int max) {
    return 'Maksimal $max foto.';
  }

  @override
  String get rateUnavailable => 'Kurs tidak tersedia. Masukkan harga awal sendiri.';

  @override
  String couldNotCreateListing(String error) {
    return 'Gagal membuat lelang: $error';
  }

  @override
  String get discardQ => 'Buang lelang ini?';

  @override
  String get discardBody => 'Perubahan Anda akan hilang. Ketuk \"Simpan draf\" untuk menyimpannya.';

  @override
  String get keepEditing => 'Lanjut mengedit';

  @override
  String get discard => 'Buang';

  @override
  String get saveDraft => 'Simpan draf';

  @override
  String get importFromCatalog => 'Impor dari katalog';

  @override
  String get title => 'Judul';

  @override
  String get titleHint => 'Merek, model, ukuran, warna';

  @override
  String get descriptionHint => 'Kondisi, kelengkapan, kekurangan';

  @override
  String get category => 'Kategori';

  @override
  String get chooseCategory => 'Pilih kategori';

  @override
  String get condition => 'Kondisi';

  @override
  String get format => 'Format';

  @override
  String get buyNowOnlyNote => 'Harga tetap, tanpa tawaran. Pembeli pertama yang mendapatkannya.';

  @override
  String get startingPrice => 'Harga awal';

  @override
  String get reservePrice => 'Harga cadangan';

  @override
  String get optionalHidden => '(opsional, tersembunyi)';

  @override
  String get reserveHelper => 'Barang tidak akan terjual di bawah harga ini';

  @override
  String get duration => 'Durasi';

  @override
  String endsOn(String date) {
    return 'Berakhir $date';
  }

  @override
  String get shippingAndReturns => 'Pengiriman & pengembalian';

  @override
  String get shippingCost => 'Ongkos kirim';

  @override
  String get zeroFree => '0 = gratis';

  @override
  String get shipsWithin => 'Dikirim dalam';

  @override
  String nDays(int n) {
    return '$n hari';
  }

  @override
  String get itemLocation => 'Lokasi barang';

  @override
  String get itemLocationHint => 'Kota, mis. Makassar';

  @override
  String get acceptReturns => 'Terima pengembalian';

  @override
  String get within7Days => 'Dalam 7 hari';

  @override
  String get listItem => 'Pasang lelang';

  @override
  String finalValueFee(int fee) {
    return 'Biaya akhir: $fee% dari harga jual';
  }

  @override
  String get photos => 'Foto';

  @override
  String get reorderHint => 'Tekan lama untuk mengurutkan. Foto pertama menjadi sampul.';

  @override
  String get addPhotos => 'Tambah foto';

  @override
  String get cover => 'Sampul';

  @override
  String uploadingPhoto(int n) {
    return 'Mengunggah foto $n';
  }

  @override
  String removePhotoN(int n) {
    return 'Hapus foto $n';
  }

  @override
  String get photo1Cover => 'Foto 1, sampul';

  @override
  String photoN(int n) {
    return 'Foto $n';
  }

  @override
  String get searchProductsHint => 'Cari produk, mis. \"watch\", \"laptop\"';

  @override
  String get noProductsFound => 'Produk tidak ditemukan.';

  @override
  String couldNotSignOut(String error) {
    return 'Gagal keluar: $error';
  }

  @override
  String get deleteAccountQ => 'Hapus akun Anda?';

  @override
  String get deleteAccountBody =>
      'Profil, alamat, rekening pencairan, draf, dan daftar pantauan Anda akan dihapus. Pesanan yang sudah selesai tetap disimpan untuk pihak lain. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get deleteWord => 'HAPUS';

  @override
  String typeToConfirm(String word) {
    return 'Ketik $word untuk konfirmasi';
  }

  @override
  String get accountDeleted => 'Akun Anda telah dihapus.';

  @override
  String get wrongPasswordNothingDeleted => 'Kata sandi salah. Tidak ada yang dihapus.';

  @override
  String get cancelledNothingDeleted => 'Dibatalkan. Tidak ada yang dihapus.';

  @override
  String get couldNotDeleteAccount => 'Gagal menghapus akun.';

  @override
  String get enterYourPassword => 'Masukkan kata sandi Anda';

  @override
  String get liveAuctionsBlockDelete =>
      'Anda masih punya lelang aktif yang sudah ada tawaran. Tunggu sampai lelang berakhir.';

  @override
  String get highestBidder => 'Penawar tertinggi';

  @override
  String yourMaxSuffix(String amount) {
    return '· maksimum Anda $amount';
  }

  @override
  String get endedLabel => 'Berakhir';

  @override
  String finalAmount(String amount) {
    return 'Akhir $amount';
  }

  @override
  String get watching => 'Dipantau';

  @override
  String trendingSemantics(int rank, String title, String price, int count) {
    return 'Peringkat $rank, $title, $price, $count tawaran';
  }

  @override
  String recentBidsSemantics(int count) {
    return ', $count tawaran dalam satu jam terakhir';
  }

  @override
  String get unreadPrefix => 'Belum dibaca.';

  @override
  String avatarOf(String name) {
    return 'Avatar $name';
  }

  @override
  String buyItNowSpace(String price) {
    return 'Beli Sekarang $price';
  }

  @override
  String get buyItNowPrefix => 'Beli Sekarang ·';

  @override
  String nBidsPrefix(int count) {
    return '$count tawaran ·';
  }

  @override
  String get adminsOnlyMsg => 'Khusus admin.';

  @override
  String get adminAllListings => 'Admin · Semua lelang';

  @override
  String get noListings => 'Belum ada lelang.';

  @override
  String get done => 'Selesai.';

  @override
  String get endListingNow => 'Hentikan lelang sekarang';

  @override
  String get deleteListing => 'Hapus lelang';

  @override
  String get noPermission => 'Anda tidak punya izin untuk melakukan itu.';

  @override
  String get cannotBuyOwn => 'Anda tidak dapat membeli barang sendiri.';

  @override
  String get buyNowUnavailable => 'Beli Sekarang sudah tidak tersedia.';

  @override
  String get cannotEndWithBids =>
      'Lelang yang sudah ada tawaran tidak dapat dihentikan lebih awal.';

  @override
  String get notSignedIn => 'Belum masuk.';

  @override
  String get authInvalidEmail => 'Alamat email tidak valid.';

  @override
  String get authDisabled => 'Akun ini telah dinonaktifkan.';

  @override
  String get authEmailInUse => 'Sudah ada akun dengan email tersebut.';

  @override
  String get authWeakPassword => 'Gunakan minimal 8 karakter untuk kata sandi.';

  @override
  String get authWrongCredentials => 'Email atau kata sandi salah.';

  @override
  String get authTooMany => 'Terlalu banyak percobaan. Coba lagi nanti.';

  @override
  String get authGoogleCancelled => 'Masuk dengan Google dibatalkan.';

  @override
  String get authFailed => 'Autentikasi gagal.';

  @override
  String somethingWrong(String error) {
    return 'Terjadi kesalahan: $error';
  }

  @override
  String bidsWatchingPrefix(int bids, int watchers) {
    return '$bids tawaran · $watchers memantau ·';
  }

  @override
  String get loading => 'memuat';

  @override
  String labelLoading(String label) {
    return '$label, memuat';
  }

  @override
  String get yourEmail => 'email Anda';

  @override
  String auctionCardSemantics(String title, String price, int count) {
    return '$title, $price, $count tawaran';
  }

  @override
  String get reminder1h => 'Tinggal 1 jam';

  @override
  String get reminder10m => 'Tinggal 10 menit';

  @override
  String reminderBody(String title) {
    return '\"$title\" segera berakhir. Cek harganya dan pasang tawaran terakhir Anda.';
  }
}
