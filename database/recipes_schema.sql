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

-- =====================================================
-- INSERT DATA: RESEP
-- =====================================================

-- 1. Donat
INSERT INTO recipes (recipe_name, description) VALUES
('Donat', 'Donat klasik dengan topping gula');

-- 2. Roti Putih
INSERT INTO recipes (recipe_name, description) VALUES
('Roti Putih', 'Roti putih lembut untuk sarapan');

-- 3. Kue Brownies
INSERT INTO recipes (recipe_name, description) VALUES
('Kue Brownies', 'Brownies cokelat yang lembut dan nikmat');

-- 4. Kue Tart
INSERT INTO recipes (recipe_name, description) VALUES
('Kue Tart', 'Kue tart creamy dengan topping keju');

-- =====================================================
-- INSERT DATA: RECIPE INGREDIENTS
-- =====================================================

-- 1. DONAT (per unit = 1 pcs)
-- Donat membutuhkan per pcs: Tepung 500gr, Telur 2, Gula 100gr, Mentega 50gr, Baking Powder 5gr
INSERT INTO recipe_ingredients (recipe_id, product_name, quantity_needed, unit) VALUES
((SELECT id FROM recipes WHERE recipe_name = 'Donat'), 'Tepung Terigu 1kg', 500, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Donat'), 'Telur 1kg', 2, 'butir'),
((SELECT id FROM recipes WHERE recipe_name = 'Donat'), 'Gula Pasir 1kg', 100, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Donat'), 'Mentega 500gr', 50, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Donat'), 'Baking Powder', 5, 'gr');

-- 2. ROTI PUTIH (per unit = 1 pcs)
-- Roti membutuhkan per pcs: Tepung 800gr, Telur 3, Gula 80gr, Mentega 80gr, Susu 50gr, Baking Powder 8gr
INSERT INTO recipe_ingredients (recipe_id, product_name, quantity_needed, unit) VALUES
((SELECT id FROM recipes WHERE recipe_name = 'Roti Putih'), 'Tepung Terigu 1kg', 800, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Roti Putih'), 'Telur 1kg', 3, 'butir'),
((SELECT id FROM recipes WHERE recipe_name = 'Roti Putih'), 'Gula Pasir 1kg', 80, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Roti Putih'), 'Mentega 500gr', 80, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Roti Putih'), 'Susu Bubuk', 50, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Roti Putih'), 'Baking Powder', 8, 'gr');

-- 3. KUE BROWNIES (per unit = 1 pcs)
-- Brownies membutuhkan per pcs: Tepung 300gr, Cokelat 100gr, Telur 4, Gula 200gr, Mentega 150gr, Baking Powder 5gr
INSERT INTO recipe_ingredients (recipe_id, product_name, quantity_needed, unit) VALUES
((SELECT id FROM recipes WHERE recipe_name = 'Kue Brownies'), 'Tepung Terigu 1kg', 300, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Kue Brownies'), 'Cokelat Bubuk 250gr', 100, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Kue Brownies'), 'Telur 1kg', 4, 'butir'),
((SELECT id FROM recipes WHERE recipe_name = 'Kue Brownies'), 'Gula Pasir 1kg', 200, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Kue Brownies'), 'Mentega 500gr', 150, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Kue Brownies'), 'Baking Powder', 5, 'gr');

-- 4. KUE TART (per unit = 1 pcs)
-- Tart membutuhkan per pcs: Tepung 400gr, Telur 5, Gula 150gr, Mentega 200gr, Keju 100gr, Susu 80gr
INSERT INTO recipe_ingredients (recipe_id, product_name, quantity_needed, unit) VALUES
((SELECT id FROM recipes WHERE recipe_name = 'Kue Tart'), 'Tepung Terigu 1kg', 400, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Kue Tart'), 'Telur 1kg', 5, 'butir'),
((SELECT id FROM recipes WHERE recipe_name = 'Kue Tart'), 'Gula Pasir 1kg', 150, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Kue Tart'), 'Mentega 500gr', 200, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Kue Tart'), 'Keju Parut 250gr', 100, 'gr'),
((SELECT id FROM recipes WHERE recipe_name = 'Kue Tart'), 'Susu Bubuk', 80, 'gr');

-- =====================================================
-- INSERT DATA: PRODUCTS (BAHAN)
-- =====================================================

INSERT INTO products (product_name, category, price, current_stock, unit, min_stock) VALUES
('Tepung Terigu 1kg', 'Tepung', 15000, 45000, 'gr', 5000),
('Telur 1kg', 'Telur', 35000, 12, 'butir', 2),
('Gula Pasir 1kg', 'Gula', 20000, 28000, 'gr', 5000),
('Susu Bubuk', 'Susu', 45000, 8000, 'gr', 1000),
('Cokelat Bubuk 250gr', 'Cokelat', 35000, 22000, 'gr', 2000),
('Mentega 500gr', 'Mentega', 50000, 15000, 'gr', 3000),
('Keju Parut 250gr', 'Keju', 40000, 3000, 'gr', 500),
('Baking Powder', 'Bahan Tambahan', 12000, 60000, 'gr', 5000);

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
