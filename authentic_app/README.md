# Imagi Auction

Aplikasi marketplace lelang online (MVP) berbasis **Flutter + Firebase**.
Tugas Pemrograman Mobile — Kelompok 5, Kelas C.

![Tampilan aplikasi](docs/screenshots/2026-11-16-app.png)

## Fitur

| Fitur | Implementasi |
|---|---|
| Autentikasi | Firebase Authentication (email & password) — `lib/ui/auth/` |
| Otorisasi | Role `user` / `admin`: guard di `lib/router.dart` + Firestore rules (`firestore.rules`) |
| Lelang | Proxy bidding otomatis, reserve price, buy now, seller end early — `lib/domain/bidding/` |
| Watchlist & aktivitas | Daftar lelang yang dipantau, riwayat bid, barang terjual/dimenangkan |
| Push notification | Firebase Cloud Messaging + `flutter_local_notifications` (outbid, menang, terjual) |
| REST API | [DummyJSON](https://dummyjson.com) untuk impor katalog produk, [Frankfurter](https://frankfurter.dev) untuk konversi kurs |
| State management | Riverpod — `lib/providers/providers.dart` |
| Backend terjadwal | Cloud Functions: kirim push & tutup lelang yang sudah berakhir — `functions/index.js` |

## Struktur folder

```
lib/
  core/          util & extension
  data/          API client, repository Firestore, service notifikasi
  domain/        model & logika bidding (proxy engine)
  providers/     provider Riverpod
  ui/            layar & widget
  router.dart    routing + guard login/admin
functions/       Cloud Functions (Node.js)
firestore.rules  aturan keamanan Firestore
test/            unit test proxy bidding
```

## Menjalankan

Kebutuhan: Flutter ≥ 3.44, Node.js 20, Firebase CLI (`npm i -g firebase-tools`).

```bash
flutter pub get

# (sekali saja) hubungkan ke project Firebase untuk platform yang dipakai
dart pub global activate flutterfire_cli
flutterfire configure --project=imagi-auction-k5c

flutter run            # pilih device: chrome / emulator Android / iOS
```

> Push notification hanya aktif di Android/iOS. Di web, notifikasi ditampilkan
> di dalam aplikasi (tab Notifications) saja.

### Deploy rules, index, dan Cloud Functions

```bash
firebase login
firebase deploy --only firestore          # rules + index
cd functions && npm install && cd ..
firebase deploy --only functions          # butuh paket Blaze
```

Tanpa Cloud Functions aplikasi tetap jalan: lelang ditutup saat ada yang membuka
halamannya setelah waktu habis, dan notifikasi tetap muncul selama aplikasi terbuka.

### Menjadikan user admin

Ubah field `role` pada dokumen `users/{uid}` menjadi `"admin"` lewat Firebase Console.

## Testing

```bash
flutter test
```

## Anggota Kelompok

1. Aysar Afdhillah Akbar (D121241015)
2. Cristiko Esteranto (D121241108)
3. Muhammad Rhiza Arrazi (D121241054)
