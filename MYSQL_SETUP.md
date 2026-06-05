# MySQL Setup Guide - Prediksi Stok Bahan Kue

## Prerequisites

Anda harus memiliki:

- **MySQL Server** (versi 5.7 atau lebih baru)
- **Python 3.8+** dengan pip
- **Flask** (sudah di requirements.txt)

## Step 1: Install MySQL Server

### Windows

1. Download MySQL installer dari https://dev.mysql.com/downloads/mysql/
2. Run installer dan pilih "MySQL Server" component
3. Ikuti wizard hingga selesai
4. Default port: **3306**
5. Default user: **root** (password bisa dikosongkan atau set sesuai keinginan)

### Linux/Mac

```bash
# macOS (menggunakan Homebrew)
brew install mysql
brew services start mysql

# Linux (Ubuntu/Debian)
sudo apt-get install mysql-server
sudo systemctl start mysql
```

## Step 2: Verifikasi MySQL Installation

```bash
# Test MySQL connection
mysql -u root -p

# Jika password kosong, cukup tekan Enter
# Jika berhasil, Anda akan lihat MySQL prompt: mysql>
mysql> exit
```

## Step 3: Install Python Dependencies

```bash
cd c:\fluuter.u\permintaandanprediksi_stok_bahan_kue\finalproject\ml_model

# Install requirements
pip install -r requirements.txt
```

**Requirements.txt sekarang include:**

- flask==2.3.0
- flask-cors==4.0.0
- flask-sqlalchemy==3.0.0
- PyMySQL==1.1.0
- joblib==1.3.0
- pandas==2.0.0
- scikit-learn==1.2.0
- numpy==1.25.0

## Step 4: Setup Database

### Option A: Menggunakan Python Script (RECOMMENDED)

```bash
# Navigate ke ml_model folder
cd c:\fluuter.u\permintaandanprediksi_stok_bahan_kue\finalproject\ml_model

# Run database setup script
python database_setup.py
```

**Output yang diharapkan:**

```
============================================================
SETUP DATABASE MYSQL - PREDIKSI STOK BAHAN KUE
============================================================

Database Configuration:
  Host: localhost
  User: root
  Database: prediksi_stok_db

✅ Database 'prediksi_stok_db' created successfully
✅ Products table created successfully
✅ Transactions table created successfully
✅ Predictions table created successfully
✅ Inserted 8 default products
✅ Database setup completed successfully!
```

### Option B: Manual Setup (jika script gagal)

1. Buka MySQL CLI:

```bash
mysql -u root -p
```

2. Copy & paste semua commands di bawah:

```sql
-- Buat database
CREATE DATABASE IF NOT EXISTS prediksi_stok_db;
USE prediksi_stok_db;

-- Buat table products
CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price INT NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'tersedia',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Buat table transactions
CREATE TABLE IF NOT EXISTS transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    unit_price INT NOT NULL,
    total_price INT NOT NULL,
    transaction_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Buat table predictions
CREATE TABLE IF NOT EXISTS predictions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    unit_price INT NOT NULL,
    prediction_date DATE NOT NULL,
    predicted_quantity INT,
    raw_value DOUBLE,
    estimated_total_price INT,
    accuracy_r2 DOUBLE,
    error_mae DOUBLE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 8 default products
INSERT INTO products (name, category, price, stock, status) VALUES
('Tepung Terigu 1kg', 'Tepung', 15000, 45, 'tersedia'),
('Telur 1kg', 'Telur', 35000, 12, 'rendah'),
('Gula Pasir 1kg', 'Gula', 20000, 28, 'tersedia'),
('Susu Bubuk', 'Susu', 45000, 8, 'kritis'),
('Cokelat Bubuk 250gr', 'Cokelat', 35000, 22, 'tersedia'),
('Mentega 500gr', 'Mentega', 50000, 15, 'tersedia'),
('Keju Parut 250gr', 'Keju', 40000, 3, 'rendah'),
('Baking Powder', 'Bahan Tambahan', 12000, 60, 'tersedia');
```

## Step 5: Verify Database Setup

```bash
# Login ke MySQL
mysql -u root -p prediksi_stok_db

# Check tables
SHOW TABLES;

# Check products
SELECT * FROM products;

# Should show 8 products
```

## Step 6: Start Flask API

```bash
# From ml_model directory
python app.py
```

**Expected output:**

```
...
Starting Prediksi Stok API
================================================================================
Model: RandomForest
Accuracy (R²): 0.9964
Features: 10
Endpoints: /health, /metadata, /info, /prediksi, /batch-prediksi, /products, /transactions, /predictions
Access API at: http://localhost:5000
================================================================================
 * Running on http://0.0.0.0:5000
```

## Step 7: Test API Endpoints

### Test 1: Health Check

```bash
curl http://localhost:5000/health
```

### Test 2: Get Products

```bash
curl http://localhost:5000/products
```

Expected response:

```json
{
  "status": "success",
  "total": 8,
  "products": [
    {
      "id": 1,
      "name": "Tepung Terigu 1kg",
      "category": "Tepung",
      "price": 15000,
      "stock": 45,
      "status": "tersedia",
      "created_at": "2024-04-05T10:30:00",
      "updated_at": "2024-04-05T10:30:00"
    },
    ...
  ]
}
```

### Test 3: Save Transaction

```bash
curl -X POST http://localhost:5000/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "product_name": "Tepung Terigu 1kg",
    "category": "Tepung",
    "quantity": 5,
    "unit_price": 15000,
    "total_price": 75000,
    "transaction_date": "2024-04-05"
  }'
```

### Test 4: Get Transactions

```bash
curl http://localhost:5000/transactions
```

## Database Schema

### Products Table

```
+----------+-------------+----------+-------+--------+---------+
| Field    | Type        | Null    | Key   | Default | Extra   |
+----------+-------------+----------+-------+--------+---------+
| id       | INT         | NO      | PRI   | NULL   | AUTO    |
| name     | VARCHAR(255)| NO      |       | NULL   |         |
| category | VARCHAR(100)| NO      |       | NULL   |         |
| price    | INT         | NO      |       | NULL   |         |
| stock    | INT         | NO      |       | 0      |         |
| status   | VARCHAR(50) | NO      |       | tersedia|       |
+----------+-------------+----------+-------+--------+---------+
```

### Transactions Table

```
+------------------+-------------+----------+-------+--------+
| Field            | Type        | Null    | Key   | Default |
+------------------+-------------+----------+-------+--------+
| id               | INT         | NO      | PRI   | NULL    |
| product_name     | VARCHAR(255)| NO      |       | NULL    |
| category         | VARCHAR(100)| NO      |       | NULL    |
| quantity         | INT         | NO      |       | NULL    |
| unit_price       | INT         | NO      |       | NULL    |
| total_price      | INT         | NO      |       | NULL    |
| transaction_date | DATE        | NO      |       | NULL    |
| created_at       | TIMESTAMP   | NO      |       | NOW()   |
+------------------+-------------+----------+-------+--------+
```

### Predictions Table

```
+----------------------+----------+----------+-------+--------+
| Field                | Type     | Null    | Key   | Default |
+----------------------+----------+----------+-------+--------+
| id                   | INT      | NO      | PRI   | NULL    |
| product_name         | VARCHAR  | NO      |       | NULL    |
| category             | VARCHAR  | NO      |       | NULL    |
| unit_price           | INT      | NO      |       | NULL    |
| prediction_date      | DATE     | NO      |       | NULL    |
| predicted_quantity   | INT      | YES     |       | NULL    |
| raw_value            | DOUBLE   | YES     |       | NULL    |
| estimated_total_price| INT      | YES     |       | NULL    |
| accuracy_r2          | DOUBLE   | YES     |       | NULL    |
| error_mae            | DOUBLE   | YES     |       | NULL    |
| created_at           | TIMESTAMP| NO      |       | NOW()   |
+----------------------+----------+----------+-------+--------+
```

## Troubleshooting

### Error: "Access denied for user 'root'@'localhost'"

- **Solusi**: Jika MySQL meminta password, edit `app.py` dan `database_setup.py`:
  ```python
  DB_PASSWORD = 'your_mysql_password'  # Ganti dengan password Anda
  ```

### Error: "Can't connect to MySQL server"

- **Solusi**: Pastikan MySQL server sedang berjalan:

  ```bash
  # Windows
  mysql -u root -p

  # macOS
  brew services list  # Check if mysql is running

  # Linux
  sudo systemctl status mysql
  ```

### Error: "Database 'prediksi_stok_db' doesn't exist"

- **Solusi**: Jalankan `python database_setup.py` lagi

### Port 5000 Already in Use

- **Solusi**: Edit `app.py` di bagian akhir:
  ```python
  app.run(
      debug=False,
      host='0.0.0.0',
      port=5001,  # Ganti dengan port lain
      threaded=True
  )
  ```

## Security Notes

⚠️ **IMPORTANT untuk Production:**

1. Jangan gunakan `root` user tanpa password
2. Create dedicated database user:
   ```sql
   CREATE USER 'api_user'@'localhost' IDENTIFIED BY 'strong_password';
   GRANT ALL PRIVILEGES ON prediksi_stok_db.* TO 'api_user'@'localhost';
   FLUSH PRIVILEGES;
   ```
3. Update credentials di `app.py`
4. Setup firewall untuk restrict MySQL access
5. Use SSL/TLS untuk database connection

## Next Steps

1. ✅ Database setup selesai
2. ✅ API endpoints ready
3. 📱 Update Flutter app untuk call endpoints
4. 📊 Implement state management di Flutter
5. 💾 Add local caching untuk offline mode
