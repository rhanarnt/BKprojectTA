"""
Setup MySQL Database untuk Prediksi Stok Bahan Kue
"""

import mysql.connector
from mysql.connector import Error
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database Configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'prediksi_stok_db'
}

# Products list
PRODUCTS = [
    {'name': 'Tepung Terigu 1kg', 'category': 'Tepung'},
    {'name': 'Telur 1kg', 'category': 'Telur'},
    {'name': 'Gula Pasir 1kg', 'category': 'Gula'},
    {'name': 'Susu Bubuk', 'category': 'Susu'},
    {'name': 'Cokelat Bubuk 250gr', 'category': 'Cokelat'},
    {'name': 'Mentega 500gr', 'category': 'Mentega'},
    {'name': 'Keju Parut 250gr', 'category': 'Keju'},
    {'name': 'Baking Powder', 'category': 'Bahan Tambahan'},
]

def create_database():
    """Create database if not exists"""
    try:
        connection = mysql.connector.connect(
            host=DB_CONFIG['host'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password']
        )
        cursor = connection.cursor()
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_CONFIG['database']}")
        logger.info(f"✅ Database '{DB_CONFIG['database']}' created successfully")
        cursor.close()
        connection.close()
        return True
    except Error as err:
        print(f"❌ Error creating database: {err}")
        return False

def create_tables():
    """Create tables in database"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()

        # Products table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id INT PRIMARY KEY AUTO_INCREMENT,
            name VARCHAR(100) NOT NULL UNIQUE,
            category VARCHAR(50) NOT NULL,
            price DECIMAL(10, 2) DEFAULT 0,
            stock INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """)
        logger.info("✅ Products table created successfully")

        # Transactions table
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS transactions (
            id INT PRIMARY KEY AUTO_INCREMENT,
            product_name VARCHAR(100) NOT NULL,
            category VARCHAR(50) NOT NULL,
            quantity INT NOT NULL,
            unit_price DECIMAL(10, 2) NOT NULL,
            total_price DECIMAL(10, 2) NOT NULL,
            transaction_date DATETIME NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_name) REFERENCES products(name)
        )
        """)
        logger.info("✅ Transactions table created successfully")

        # Predictions table (FIXED SCHEMA)
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS predictions (
            id INT PRIMARY KEY AUTO_INCREMENT,
            product_name VARCHAR(100) NOT NULL,
            category VARCHAR(50) NOT NULL,
            unit_price DECIMAL(10, 2),
            prediction_date DATETIME NOT NULL,
            predicted_quantity DECIMAL(10, 2),
            raw_value DECIMAL(10, 2),
            estimated_total_price DECIMAL(10, 2),
            accuracy_r2 DECIMAL(5, 4),
            error_mae DECIMAL(5, 4),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_name) REFERENCES products(name)
        )
        """)
        logger.info("✅ Predictions table created successfully")

        connection.commit()
        cursor.close()
        connection.close()
        return True
    except Error as err:
        print(f"❌ Error creating tables: {err}")
        return False

def insert_default_products():
    """Insert default products"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()

        for product in PRODUCTS:
            try:
                cursor.execute(
                    "INSERT INTO products (name, category) VALUES (%s, %s)",
                    (product['name'], product['category'])
                )
            except:
                pass

        connection.commit()
        cursor.execute("SELECT COUNT(*) FROM products")
        count = cursor.fetchone()[0]
        logger.info(f"✅ Inserted {count} default products")
        cursor.close()
        connection.close()
        return True
    except Error as err:
        print(f"❌ Error inserting products: {err}")
        return False

def verify_connection():
    """Verify database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor()
        cursor.execute("SELECT COUNT(*) FROM products")
        count = cursor.fetchone()[0]
        logger.info(f"✅ Database connected! Found {count} products")
        cursor.close()
        connection.close()
        return True
    except Error as err:
        print(f"❌ Connection error: {err}")
        return False

def main():
    print("=" * 60)
    print("SETUP DATABASE MYSQL - PREDIKSI STOK BAHAN KUE")
    print("=" * 60)
    print()
    print("Database Configuration:")
    print(f"  Host: {DB_CONFIG['host']}")
    print(f"  User: {DB_CONFIG['user']}")
    print(f"  Database: {DB_CONFIG['database']}")
    print()

    if not create_database():
        return

    if not create_tables():
        return

    if not insert_default_products():
        return

    verify_connection()

    print()
    print("=" * 60)
    print("✅ Database setup completed successfully!")
    print("=" * 60)

if __name__ == "__main__":
    main()
