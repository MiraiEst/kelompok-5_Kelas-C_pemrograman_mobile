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
  String get verified => 'Terverifikasi';

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
}
