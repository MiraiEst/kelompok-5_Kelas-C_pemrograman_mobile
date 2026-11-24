import 'package:flutter/material.dart';

import '../../core/config.dart';
import '../../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// Which legal page to show. Opened at /legal/terms and /legal/privacy,
/// which also work while signed out (linked from the register screen).
enum LegalDoc {
  terms,
  privacy;

  static LegalDoc parse(String? s) => s == 'privacy' ? privacy : terms;
}

/// Terms of Service / Privacy Policy, built into the app (English and
/// Indonesian, following the device language).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final id = l10n.localeName.startsWith('id');
    final sections = switch (doc) {
      LegalDoc.terms => id ? _termsId : _termsEn,
      LegalDoc.privacy => id ? _privacyId : _privacyEn,
    };
    return Scaffold(
      appBar: AppBar(title: Text(doc == LegalDoc.terms ? l10n.termsOfService : l10n.privacyPolicy)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(l10n.legalUpdated, style: AppText.caption),
          const SizedBox(height: 8),
          for (final (title, body) in sections) ...[
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 6),
            Text(body, style: AppText.body),
          ],
        ],
      ),
    );
  }
}

const _fee = AppConfig.finalValueFeePercent;
const _service = AppConfig.serviceFeePercent;
const _payDays = AppConfig.payWithinDays;
const _confirmDays = AppConfig.autoConfirmDays;

const _termsEn = [
  (
    '1. About Authentic',
    'Authentic is an online auction marketplace where registered users can list items for '
        'auction and bid on items listed by others. By creating an account you agree to these terms.',
  ),
  (
    '2. Your account',
    'You must give accurate information, keep your password secret and verify your email before '
        'bidding. You are responsible for everything done with your account. One person, one account.',
  ),
  (
    '3. Bidding',
    'Every bid is binding. When you enter a maximum bid, we bid for you automatically up to that '
        'amount. If you win, you must pay within $_payDays days after the auction ends. Repeatedly '
        'not paying for won items can get your account suspended.',
  ),
  (
    '4. Selling',
    'Only list items you own and are allowed to sell, and describe them honestly with your own '
        'photos. You must ship the item to the winner after payment. Sellers pay a final value fee '
        'of $_fee% of the sale price. Prohibited items (illegal goods, weapons, counterfeits, '
        'animals protected by law and the like) will be removed.',
  ),
  (
    '5. Payment and buyer protection',
    'Buyers pay the winning price, shipping and a service fee of $_service% (max Rp 10.000). '
        'The payment is held until the buyer confirms delivery, or automatically $_confirmDays days '
        'after delivery, and is then paid out to the seller. If an item does not arrive or is not as '
        'described, the buyer can report a problem on the order.',
  ),
  (
    '6. Fair use',
    'Do not bid on your own items, manipulate prices, harass other users or try to trade outside '
        'the app to avoid fees. We may remove listings and suspend accounts that break these terms.',
  ),
  (
    '7. Liability',
    'Authentic is a platform connecting buyers and sellers; the item itself is the seller\'s '
        'responsibility. The app is provided as is, as part of a student project, and may be '
        'unavailable at times.',
  ),
  (
    '8. Changes',
    'We may update these terms. The date at the top shows the latest version. Continuing to use '
        'the app after a change means you accept the new terms.',
  ),
];

const _termsId = [
  (
    '1. Tentang Authentic',
    'Authentic adalah marketplace lelang online tempat pengguna terdaftar dapat melelang barang '
        'dan menawar barang milik pengguna lain. Dengan membuat akun, Anda menyetujui ketentuan ini.',
  ),
  (
    '2. Akun Anda',
    'Anda wajib memberikan data yang benar, menjaga kerahasiaan kata sandi, dan memverifikasi email '
        'sebelum menawar. Anda bertanggung jawab atas semua aktivitas di akun Anda. Satu orang, satu akun.',
  ),
  (
    '3. Menawar',
    'Setiap tawaran bersifat mengikat. Saat Anda memasukkan tawaran maksimum, kami menawar otomatis '
        'untuk Anda hingga jumlah tersebut. Jika menang, Anda wajib membayar dalam $_payDays hari '
        'setelah lelang berakhir. Berulang kali tidak membayar barang yang dimenangkan dapat membuat '
        'akun Anda ditangguhkan.',
  ),
  (
    '4. Menjual',
    'Hanya lelang barang milik Anda yang boleh dijual, dan jelaskan dengan jujur menggunakan foto '
        'Anda sendiri. Anda wajib mengirim barang ke pemenang setelah pembayaran. Penjual dikenakan '
        'biaya akhir $_fee% dari harga jual. Barang terlarang (barang ilegal, senjata, barang palsu, '
        'satwa dilindungi, dan sejenisnya) akan dihapus.',
  ),
  (
    '5. Pembayaran dan perlindungan pembeli',
    'Pembeli membayar harga menang, ongkos kirim, dan biaya layanan $_service% (maks. Rp 10.000). '
        'Pembayaran ditahan sampai pembeli mengonfirmasi barang diterima, atau otomatis $_confirmDays '
        'hari setelah terkirim, lalu dicairkan ke penjual. Jika barang tidak sampai atau tidak sesuai '
        'deskripsi, pembeli dapat melaporkan masalah pada pesanan.',
  ),
  (
    '6. Penggunaan yang wajar',
    'Jangan menawar barang sendiri, memanipulasi harga, melecehkan pengguna lain, atau bertransaksi '
        'di luar aplikasi untuk menghindari biaya. Kami dapat menghapus barang dan menangguhkan akun '
        'yang melanggar ketentuan ini.',
  ),
  (
    '7. Tanggung jawab',
    'Authentic adalah platform yang mempertemukan pembeli dan penjual; barang itu sendiri '
        'menjadi tanggung jawab penjual. Aplikasi disediakan apa adanya sebagai bagian dari proyek '
        'mahasiswa dan sewaktu-waktu bisa tidak tersedia.',
  ),
  (
    '8. Perubahan',
    'Kami dapat memperbarui ketentuan ini. Tanggal di atas menunjukkan versi terbaru. Tetap '
        'menggunakan aplikasi setelah perubahan berarti Anda menyetujui ketentuan yang baru.',
  ),
];

const _privacyEn = [
  (
    'What we collect',
    'Account details (name, username, email, phone number), shipping addresses, payout account, '
        'the photos and listings you post, your bids, orders, ratings and messages about orders, '
        'and a device token used to send push notifications.',
  ),
  (
    'How we use it',
    'To run auctions and orders: showing your listings, placing your bids, delivering items to the '
        'right address, paying out sellers, sending notifications you switched on and preventing abuse.',
  ),
  (
    'What others see',
    'Other users see your username and rating. When you bid, your username is shown masked '
        '(e.g. a***b). Your maximum bid, email, phone number and address are never shown publicly. '
        'The seller of an item you win gets your shipping address and phone number to send it.',
  ),
  (
    'Where it is stored',
    'Account data is stored with Google Firebase and photos with Supabase Storage. Photos you '
        'upload are publicly accessible to anyone who has their link.',
  ),
  (
    'Your choices',
    'You can edit your profile and addresses, switch notifications off in Notification settings '
        'and sign out at any time. To delete your account and data, contact the Authentic team.',
  ),
];

const _privacyId = [
  (
    'Data yang kami kumpulkan',
    'Data akun (nama, username, email, nomor telepon), alamat pengiriman, rekening pencairan, foto '
        'dan barang yang Anda lelang, tawaran, pesanan, rating, dan pesan terkait pesanan, serta token '
        'perangkat untuk mengirim notifikasi push.',
  ),
  (
    'Cara kami menggunakannya',
    'Untuk menjalankan lelang dan pesanan: menampilkan barang Anda, memproses tawaran, mengirim '
        'barang ke alamat yang benar, mencairkan dana ke penjual, mengirim notifikasi yang Anda '
        'aktifkan, dan mencegah penyalahgunaan.',
  ),
  (
    'Yang dilihat pengguna lain',
    'Pengguna lain melihat username dan rating Anda. Saat menawar, username Anda ditampilkan '
        'tersamar (mis. a***b). Tawaran maksimum, email, nomor telepon, dan alamat Anda tidak pernah '
        'ditampilkan publik. Penjual barang yang Anda menangkan menerima alamat dan nomor telepon Anda '
        'untuk pengiriman.',
  ),
  (
    'Tempat penyimpanan',
    'Data akun disimpan di Google Firebase dan foto di Supabase Storage. Foto yang Anda unggah '
        'dapat diakses publik oleh siapa pun yang memiliki tautannya.',
  ),
  (
    'Pilihan Anda',
    'Anda dapat mengubah profil dan alamat, mematikan notifikasi di Pengaturan notifikasi, dan '
        'keluar kapan saja. Untuk menghapus akun dan data Anda, hubungi tim Authentic.',
  ),
];
