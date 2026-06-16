-- =====================================================
-- Database: prediksi_stok_db
-- Table: recipes (Resep Produk)
-- =====================================================

-- 1. TABLE: recipes
-- Menyimpan daftar resep/produk yang bisa dibuat
CREATE TABLE IF NOT EXISTS recipes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  recipe_name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY idx_recipe_name (recipe_name)
);

-- 2. TABLE: recipe_ingredients
-- Menyimpan detail ingredients untuk setiap resep
CREATE TABLE IF NOT EXISTS recipe_ingredients (
  id INT PRIMARY KEY AUTO_INCREMENT,
  recipe_id INT NOT NULL,
  product_name VARCHAR(100) NOT NULL,
  quantity_needed FLOAT NOT NULL,
  unit VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
  KEY idx_recipe_id (recipe_id),
  KEY idx_product_name (product_name)
);

-- 3. TABLE: products (Bahan/Produk)
-- Menyimpan data produk/bahan yang tersedia
CREATE TABLE IF NOT EXISTS products (
  id INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(100) NOT NULL UNIQUE,
  category VARCHAR(50) NOT NULL,
  price INT NOT NULL,
  current_stock DECIMAL(10,3) NOT NULL DEFAULT 0,
  unit VARCHAR(20) NOT NULL,
  min_stock DECIMAL(10,3) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY idx_product_name (product_name),
  KEY idx_category (category)
);

-- 4. TABLE: stock_usage_history
-- Menyimpan riwayat pemakaian stok saat produksi
CREATE TABLE IF NOT EXISTS stock_usage_history (
  id INT PRIMARY KEY AUTO_INCREMENT,
  recipe_name VARCHAR(100),
  production_quantity INT,
  product_id INT NOT NULL,
  product_name VARCHAR(100) NOT NULL,
  quantity_used FLOAT NOT NULL,
  unit VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  KEY idx_product_id (product_id),
  KEY idx_recipe_name (recipe_name)
);

-- Data master tidak di-seed otomatis.
-- Isi produk, resep, dan detail bahan dari aplikasi/backend agar data valid.

-- =====================================================
-- VIEW: Recipe Summary
-- =====================================================

CREATE OR REPLACE VIEW v_recipe_summary AS
SELECT
  r.id,
  r.recipe_name,
  r.description,
  COUNT(ri.id) as total_ingredients,
  GROUP_CONCAT(CONCAT(ri.product_name, ' (', ri.quantity_needed, ri.unit, ')') SEPARATOR ', ') as ingredients_list,
  r.created_at
FROM recipes r
LEFT JOIN recipe_ingredients ri ON r.id = ri.recipe_id
GROUP BY r.id, r.recipe_name, r.description, r.created_at;

-- =====================================================
-- VIEW: Stock Readiness (Kesiapan Stok untuk setiap resep)
-- =====================================================

CREATE OR REPLACE VIEW v_recipe_stock_readiness AS
SELECT
  r.recipe_name,
  ri.product_name,
  ri.quantity_needed,
  ri.unit,
  COALESCE(p.current_stock, 0) as current_stock,
  CASE
    WHEN COALESCE(p.current_stock, 0) >= ri.quantity_needed THEN 'Cukup (1x produksi)'
    WHEN COALESCE(p.current_stock, 0) > 0 THEN CONCAT('Kurang (dapat ', FLOOR(COALESCE(p.current_stock, 0) / ri.quantity_needed), 'x)')
    ELSE 'Kosong'
  END as status
FROM recipes r
JOIN recipe_ingredients ri ON r.id = ri.recipe_id
LEFT JOIN products p ON ri.product_name = p.product_name;

-- =====================================================
-- VERIFY DATA
-- =====================================================

-- Lihat semua resep
SELECT * FROM recipes;

-- Lihat ingredients per resep
SELECT
  r.recipe_name,
  ri.product_name,
  ri.quantity_needed,
  ri.unit
FROM recipes r
JOIN recipe_ingredients ri ON r.id = ri.recipe_id
ORDER BY r.recipe_name;

-- Lihat stok produk
SELECT * FROM products;
