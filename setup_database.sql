-- Create Database and Tables for Prediksi Stok Bahan Kue
-- Run this in MySQL to setup the database

-- Create Database
CREATE DATABASE IF NOT EXISTS prediksi_stok_db;
USE prediksi_stok_db;

-- Create Products Table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    category VARCHAR(100) NOT NULL,
    product_type VARCHAR(20) DEFAULT 'Bahan',
    unit VARCHAR(20) DEFAULT 'kg',
    price INT NOT NULL,
    current_stock INT NOT NULL DEFAULT 0,
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
    accuracy_r2 FLOAT,
    error_mae FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
INSERT INTO products (name, category, product_type, unit, price, current_stock) VALUES
('Tepung Terigu 1kg', 'Tepung', 'Bahan', 'kg', 15000, 50),
('Telur 1kg', 'Telur', 'Bahan', 'kg', 25000, 30),
('Gula Pasir 1kg', 'Gula', 'Bahan', 'kg', 12000, 40),
('Susu Bubuk', 'Susu', 'Bahan', 'kg', 20000, 20),
('Cokelat Bubuk 250gr', 'Cokelat', 'Bahan', 'kg', 18000, 15),
('Mentega 500gr', 'Mentega', 'Bahan', 'kg', 22000, 25),
('Keju Parut 250gr', 'Keju', 'Bahan', 'kg', 28000, 10),
('Baking Powder', 'Bahan Tambahan', 'Bahan', 'kg', 8000, 35);

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
