-- =====================================================
-- Schema Laporan: bahan, stok_masuk, prediksi
-- Tujuan: mendukung fitur laporan realtime
-- =====================================================

-- 1) TABEL: bahan
-- Menyimpan stok bahan dengan stok minimum
CREATE TABLE IF NOT EXISTS bahan (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT NULL,
  nama_bahan VARCHAR(100) NOT NULL,
  stok DOUBLE NOT NULL DEFAULT 0,
  stok_minimum DOUBLE NOT NULL DEFAULT 0,
  unit VARCHAR(20) DEFAULT 'kg',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_bahan_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  KEY idx_bahan_nama (nama_bahan),
  KEY idx_bahan_product (product_id)
);

-- 2) TABEL: stok_masuk
-- Riwayat stok masuk bahan
CREATE TABLE IF NOT EXISTS stok_masuk (
  id INT PRIMARY KEY AUTO_INCREMENT,
  bahan_id INT NULL,
  product_id INT NULL,
  tanggal DATE NOT NULL,
  jumlah DOUBLE NOT NULL DEFAULT 0,
  unit VARCHAR(20) DEFAULT 'kg',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_stok_masuk_bahan
    FOREIGN KEY (bahan_id) REFERENCES bahan(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT fk_stok_masuk_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  KEY idx_stok_masuk_tanggal (tanggal),
  KEY idx_stok_masuk_bahan (bahan_id),
  KEY idx_stok_masuk_product (product_id)
);

-- 3) TABEL: prediksi
-- Menyimpan hasil prediksi permintaan
CREATE TABLE IF NOT EXISTS prediksi (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT NULL,
  nama_produk VARCHAR(100) NOT NULL,
  hasil_prediksi DOUBLE NOT NULL DEFAULT 0,
  estimasi_kebutuhan_bahan TEXT,
  tanggal_prediksi DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_prediksi_product
    FOREIGN KEY (product_id) REFERENCES products(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  KEY idx_prediksi_tanggal (tanggal_prediksi),
  KEY idx_prediksi_product (product_id)
);

-- =====================================================
-- Catatan:
-- - Jika tabel products sudah menyimpan stok (current_stock, min_stock),
--   endpoint laporan akan otomatis fallback ke tabel products.
-- - Pastikan data bahan/produk sinkron agar laporan tampil konsisten.
-- =====================================================
