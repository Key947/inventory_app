Aplikasi sistem Point of Sales (POS) sederhana namun fungsional yang dibangun menggunakan Flutter. Dirancang untuk membantu Usaha Kecil Menengah (UKM) dalam mengelola stok barang dan mencatat transaksi penjualan secara digital. Menggunakan database lokal (SQLite), aplikasi ini dapat berjalan sepenuhnya secara offline tanpa ketergantungan pada koneksi internet.

## Anggota Kelompok
- Revo Nagara Fisabilhaq (211080200174)
- Laverda Shafa Urnakara (221080200007)
- Achmad Isra Mujahidin (221080200070)

![WhatsApp Image 2026-01-12 at 11 44 28 AM](https://github.com/user-attachments/assets/2656a0e9-9bd1-4651-b41f-f925ffbef59a)

## 1. Deskripsi Singkat
Aplikasi ini adalah sistem Point of Sales (POS) sederhana namun fungsional yang dibangun menggunakan Flutter. Aplikasi ini dirancang untuk membantu Usaha Kecil Menengah (UKM) dalam mengelola stok barang dan mencatat transaksi penjualan secara digital. Menggunakan database lokal (SQLite), aplikasi ini dapat berjalan sepenuhnya secara offline tanpa ketergantungan pada koneksi internet.

## 2. Fitur Unggulan (Key Features)
Aplikasi ini membagi hak akses menjadi dua peran (Multi-Role User):

### A. Fitur Administrator (Pemilik Toko)
- **Manajemen Stok (CRUD)**: Admin dapat Menambah, Membaca, Mengubah, dan Menghapus data barang.
- **Upload Foto Produk**: Barang bisa dilengkapi dengan foto asli dari galeri HP, membuat tampilan lebih menarik.
- **Laporan Penjualan**: Admin dapat melihat riwayat transaksi yang terjadi (Omzet & Detail Barang Terjual).
- **Pencarian Barang**: Memudahkan admin mencari barang spesifik untuk diedit stok atau harganya.

### B. Fitur Kasir (Karyawan)
- **Tampilan Grid Visual**: Memilih barang lebih mudah dengan tampilan kartu bergambar.
- **Keranjang Belanja (Cart System)**: Menampung item sementara sebelum dibayar.
- **Fitur Pencarian Cepat**: Kasir bisa mencari nama barang secara real-time di kolom pencarian.
- **Fitur "Urungkan" (Undo/Reset)**:
  - Tombol (-) pada barang untuk mengurangi jumlah atau membatalkan pilihan.
  - Tombol Reset (Sampah) untuk menghapus seluruh keranjang jika pelanggan batal beli.
- **Checkout Otomatis**: Saat tombol "Bayar" ditekan, stok di database otomatis berkurang dan transaksi tercatat di riwayat.

## 3. Aspek Teknis (Tech Stack)
- **Framework**: Flutter (Dart Language) - untuk performa aplikasi native yang cepat di Android/iOS.
- **Database**: SQLite (menggunakan library sqflite) - Penyimpanan data relasional lokal yang ringan dan cepat.
- **State Management**: setState - Untuk manajemen perubahan tampilan yang responsif (real-time update pada keranjang dan list barang).

### Library Pendukung
- `image_picker`: Mengambil foto dari galeri.
- `intl`: Format mata uang Rupiah otomatis.
- `path_provider`: Mengelola lokasi penyimpanan file gambar di HP.

## 4. Keunggulan Desain (UI/UX)
- **Modern & Clean Interface**: Menggunakan kartu (Card) dengan sudut membulat (rounded) dan bayangan halus (shadow) agar terlihat elegan.
- **User Experience (UX) Friendly**:
  - Navigasi menggunakan Bottom Navigation Bar untuk Admin.
  - Pembedaan warna tombol yang kontras (Teks Putih pada tombol Gelap) untuk mencegah kesalahan klik.
  - Validasi Form (mencegah data kosong masuk ke sistem).
