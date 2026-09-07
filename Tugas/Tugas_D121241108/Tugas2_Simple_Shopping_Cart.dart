int hitungSubtotal(List<Map<String, dynamic>> items) {
  int total = 0;
  for (var item in items) {
    int harga = item['harga'] as int;
    int jumlah = item['jumlah'] as int;
    total += harga * jumlah;
  }
  return total;
}

double tentukanPersenDiskon(int subtotal) {
  if (subtotal >= 100000) {
    return 10.0;
  } else if (subtotal >= 50000) {
    return 5.0;
  } else {
    return 0.0;
  }
}

int hitungNominalDiskon(int subtotal, double persenDiskon) {
  return (subtotal * (persenDiskon / 100)).round();
}

void main() {
  List<Map<String, dynamic>> keranjangBelanja = [
    {'nama': 'Buku Tulis', 'harga': 5000, 'jumlah': 4},
    {'nama': 'Pulpen Gel', 'harga': 3500, 'jumlah': 6},
    {'nama': 'Kalkulator Ilmiah', 'harga': 75000, 'jumlah': 1},
    {'nama': 'Penghapus', 'harga': 2000, 'jumlah': 2},
  ];

  print('Daftar Produk:');

  for (int i = 0; i < keranjangBelanja.length; i++) {
    var produk = keranjangBelanja[i];
    String nama = produk['nama'] as String;
    int harga = produk['harga'] as int;
    int jumlah = produk['jumlah'] as int;
    int subtotalItem = harga * jumlah;

    print('${i + 1}. $nama');
    print('   $jumlah x Rp$harga = Rp$subtotalItem');
  }

  int subtotalKeseluruhan = hitungSubtotal(keranjangBelanja);
  double persenDiskon = tentukanPersenDiskon(subtotalKeseluruhan);
  int nominalDiskon = hitungNominalDiskon(subtotalKeseluruhan, persenDiskon);
  int totalPembayaran = subtotalKeseluruhan - nominalDiskon;

  print('----------------------------------------------------');
  print('RINGKASAN PEMBAYARAN:');
  print('Subtotal            : Rp$subtotalKeseluruhan');
  print('Diskon ($persenDiskon%)       : -Rp$nominalDiskon');
  print('----------------------------------------------------');
  print('TOTAL AKHIR         : Rp$totalPembayaran');
  print('====================================================');
}
