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

-- Data master tidak di-seed otomatis.
-- Isi produk, resep, akun, stok masuk, dan prediksi dari aplikasi/backend
-- agar data yang tampil bukan data dummy.

-- Verify tables created
SELECT 'Tables created successfully!' as status;
SELECT COUNT(*) as total_products FROM products;
SELECT COUNT(*) as total_recipes FROM recipes;
