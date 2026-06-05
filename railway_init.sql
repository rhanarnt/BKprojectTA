-- Railway MySQL initialization script for BKprojectTA backend
-- Run this inside the Railway MySQL Database console.
-- This script uses the currently selected Railway database.

-- Create Database and Tables for Prediksi Stok Bahan Kue
-- Run this in MySQL to setup the database

-- Create Database

-- Create Products Table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    category VARCHAR(100) NOT NULL,
    product_type VARCHAR(20) DEFAULT 'Bahan',
    unit VARCHAR(20) DEFAULT 'kg',
    price INT NOT NULL,
    current_stock DECIMAL(10,3) NOT NULL DEFAULT 0,
    min_stock DECIMAL(10,3) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Transactions Table
CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    unit_price INT NOT NULL,
    total_price INT NOT NULL,
    transaction_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Stock Usage History Table
CREATE TABLE IF NOT EXISTS stock_usage_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_name VARCHAR(255),
    production_quantity INT,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity_used FLOAT NOT NULL,
    unit VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Predictions Table
CREATE TABLE IF NOT EXISTS predictions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    unit_price INT NOT NULL,
    prediction_date DATE NOT NULL,
    predicted_quantity INT NOT NULL,
    raw_value FLOAT,
    estimated_total_price INT,
    estimated_needs TEXT,
    accuracy_r2 FLOAT,
    error_mae FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Login Table
CREATE TABLE IF NOT EXISTS login (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Password Reset OTP Table
CREATE TABLE IF NOT EXISTS password_reset_otps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    login_id INT NOT NULL,
    email VARCHAR(100) NOT NULL,
    otp_code VARCHAR(10) NOT NULL,
    expires_at DATETIME NOT NULL,
    is_used TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (login_id) REFERENCES login(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Recipes Table
CREATE TABLE IF NOT EXISTS recipes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Recipe Ingredients Table
CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    quantity_needed FLOAT NOT NULL,
    unit VARCHAR(50) NOT NULL,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert Initial Products (8 items)
INSERT INTO products (name, category, product_type, unit, price, current_stock, min_stock) VALUES
('Tepung Terigu 1kg', 'Tepung', 'Bahan', 'kg', 15000, 50, 10),
('Telur 1kg', 'Telur', 'Bahan', 'kg', 25000, 30, 5),
('Gula Pasir 1kg', 'Gula', 'Bahan', 'kg', 12000, 40, 8),
('Susu Bubuk', 'Susu', 'Bahan', 'kg', 20000, 20, 4),
('Cokelat Bubuk 250gr', 'Cokelat', 'Bahan', 'kg', 18000, 15, 3),
('Mentega 500gr', 'Mentega', 'Bahan', 'kg', 22000, 25, 5),
('Keju Parut 250gr', 'Keju', 'Bahan', 'kg', 28000, 10, 2),
('Baking Powder', 'Bahan Tambahan', 'Bahan', 'kg', 8000, 35, 2);

-- Insert Default Login Account
INSERT INTO login (name, email, username, password) VALUES
('Ibu Sulastri', 'sulastri.aritanto10@gmail.com', 'admin', 'password')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    email = VALUES(email),
    username = VALUES(username);

-- Insert Sample Recipes
INSERT INTO recipes (recipe_name, description) VALUES
('Donat', 'Resep donat lezat'),
('Roti Putih', 'Resep roti putih'),
('Kue Brownies', 'Resep brownies cokelat'),
('Kue Tart', 'Resep kue tart');

-- Insert Recipe Ingredients
-- Donat
INSERT INTO recipe_ingredients (recipe_id, product_name, quantity_needed, unit) VALUES
(1, 'Tepung Terigu 1kg', 0.5, 'kg'),
(1, 'Telur 1kg', 2, 'butir'),
(1, 'Gula Pasir 1kg', 0.1, 'kg'),
(1, 'Mentega 500gr', 0.05, 'kg'),
(1, 'Baking Powder', 0.005, 'kg');

-- Roti Putih
INSERT INTO recipe_ingredients (recipe_id, product_name, quantity_needed, unit) VALUES
(2, 'Tepung Terigu 1kg', 0.8, 'kg'),
(2, 'Telur 1kg', 3, 'butir'),
(2, 'Gula Pasir 1kg', 0.08, 'kg'),
(2, 'Mentega 500gr', 0.08, 'kg'),
(2, 'Susu Bubuk', 0.05, 'kg'),
(2, 'Baking Powder', 0.008, 'kg');

-- Kue Brownies
INSERT INTO recipe_ingredients (recipe_id, product_name, quantity_needed, unit) VALUES
(3, 'Tepung Terigu 1kg', 0.3, 'kg'),
(3, 'Cokelat Bubuk 250gr', 0.1, 'kg'),
(3, 'Telur 1kg', 4, 'butir'),
(3, 'Gula Pasir 1kg', 0.2, 'kg'),
(3, 'Mentega 500gr', 0.15, 'kg'),
(3, 'Baking Powder', 0.005, 'kg');

-- Kue Tart
INSERT INTO recipe_ingredients (recipe_id, product_name, quantity_needed, unit) VALUES
(4, 'Tepung Terigu 1kg', 0.4, 'kg'),
(4, 'Telur 1kg', 5, 'butir'),
(4, 'Gula Pasir 1kg', 0.15, 'kg'),
(4, 'Mentega 500gr', 0.2, 'kg'),
(4, 'Keju Parut 250gr', 0.1, 'kg'),
(4, 'Susu Bubuk', 0.08, 'kg');

-- Verify tables created
SELECT 'Tables created successfully!' as status;
SELECT COUNT(*) as total_products FROM products;
SELECT COUNT(*) as total_recipes FROM recipes;

-- Extra report tables
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
