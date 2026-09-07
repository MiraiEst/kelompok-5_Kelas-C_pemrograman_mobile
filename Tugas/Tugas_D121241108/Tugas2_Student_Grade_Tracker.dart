String hitungGrade(double nilai) {
  if (nilai >= 85) {
    return 'A';
  } else if (nilai >= 75) {
    return 'B';
  } else if (nilai >= 65) {
    return 'C';
  } else if (nilai >= 50) {
    return 'D';
  } else {
    return 'E';
  }
}

String cekKelulusan(double nilai, double kehadiran) {
  if (nilai >= 65 && kehadiran >= 75.0) {
    return 'Lulus';
  } else {
    return 'Tidak Lulus';
  }
}

void main() {
  List<Map<String, dynamic>> daftarMahasiswa = [
    {'nama': 'Ahmad Fauzi', 'nilai': 88.5, 'kehadiran': 90.0},
    {'nama': 'Bunga Lestari', 'nilai': 72.0, 'kehadiran': 80.0},
    {'nama': 'Citra Dewi', 'nilai': 68.0,'kehadiran': 70.0},
    {'nama': 'Doni Prasetyo', 'nilai': 45.0, 'kehadiran': 85.0},
  ];

  for (var mhs in daftarMahasiswa) {
    String nama = mhs['nama'] as String;
    double nilai = mhs['nilai'] as double;
    double kehadiran = mhs['kehadiran'] as double;

    String grade = hitungGrade(nilai);
    String status = cekKelulusan(nilai, kehadiran);

    print('Nama Mahasiswa : $nama');
    print('Nilai Akhir    : $nilai');
    print('Kehadiran      : $kehadiran%');
    print('Grade          : $grade');
    print('Status         : $status');
    print('---------------------------------------------------------------');
  }
}
