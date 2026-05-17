"""
Flask API untuk Prediksi Permintaan Stok Bahan
Menggunakan Random Forest Model
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import pandas as pd
import numpy as np
import logging
import math
from datetime import datetime
import mysql.connector
from mysql.connector import Error

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# ============================================================================
# DATABASE CONFIGURATION
# ============================================================================
DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = ''  # Ganti dengan password MySQL Anda jika ada
DB_NAME = 'prediksi_stok_db'

# Table names (use backticks for names with spaces)
TRANSACTIONS_TABLE = "`Stock In`"

def get_db_connection():
    """Get MySQL database connection"""
    try:
        connection = mysql.connector.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        return connection
    except Error as e:
        logger.error(f"Database connection error: {e}")
        return None

def table_exists(connection, table_name: str) -> bool:
    try:
        cursor = connection.cursor()
        cursor.execute("SHOW TABLES LIKE %s", (table_name,))
        exists = cursor.fetchone() is not None
        cursor.close()
        return exists
    except Error:
        return False

def get_product_name_column(connection) -> str:
    cursor = connection.cursor()
    cursor.execute("SHOW COLUMNS FROM products LIKE 'name'")
    has_name = cursor.fetchone() is not None
    cursor.close()
    return 'name' if has_name else 'product_name'

def has_product_unit_column(connection) -> bool:
    cursor = connection.cursor()
    cursor.execute("SHOW COLUMNS FROM products LIKE 'unit'")
    has_unit = cursor.fetchone() is not None
    cursor.close()
    return has_unit

def escape_table_name(table_name: str) -> str:
    return f"`{table_name}`"

def get_existing_table(connection, candidates: list[str]) -> str | None:
    for table_name in candidates:
        if table_exists(connection, table_name):
            return table_name
    return None

def get_existing_column(connection, table_name: str, candidates: list[str]) -> str | None:
    cursor = connection.cursor()
    try:
        for column in candidates:
            cursor.execute(f"SHOW COLUMNS FROM {escape_table_name(table_name)} LIKE %s", (column,))
            if cursor.fetchone() is not None:
                return column
    finally:
        cursor.close()
    return None

def build_report_response(success: bool, message: str, data: list | None = None, status_code: int = 200):
    return jsonify({
        'status': success,
        'message': message,
        'data': data or []
    }), status_code

def ensure_prediction_needs_column(connection, table_name: str = 'predictions') -> str | None:
    needs_col = get_existing_column(
        connection,
        table_name,
        ['estimated_needs', 'estimasi_kebutuhan_bahan']
    )
    if needs_col:
        return needs_col

    if not table_exists(connection, table_name):
        return None

    cursor = connection.cursor()
    try:
        cursor.execute(
            f"ALTER TABLE {escape_table_name(table_name)} ADD COLUMN estimated_needs TEXT"
        )
        connection.commit()
        return 'estimated_needs'
    except Error as e:
        logger.warning(f"Could not add estimated_needs column: {e}")
        return None
    finally:
        cursor.close()

def ensure_stock_usage_tables(connection):
    cursor = connection.cursor()
    try:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS stock_usage_history (
                id INT AUTO_INCREMENT PRIMARY KEY,
                recipe_name VARCHAR(255),
                production_quantity INT,
                product_id INT,
                product_name VARCHAR(255) NOT NULL,
                quantity_used FLOAT NOT NULL,
                unit VARCHAR(50),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS stok_keluar (
                id INT AUTO_INCREMENT PRIMARY KEY,
                bahan_id INT,
                jumlah_keluar FLOAT NOT NULL,
                satuan VARCHAR(50) DEFAULT 'kg',
                tanggal_keluar DATE NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        """)
        connection.commit()
    finally:
        cursor.close()

def compute_stock_status(stok: float, stok_minimum: float) -> str:
    if stok > stok_minimum:
        return 'Aman'
    if stok == stok_minimum:
        return 'Rendah'
    return 'Kritis'

def fetch_stock_report(connection):
    # Prioritaskan tabel products agar stok kritis mengikuti data produk aktif.
    table_name = get_existing_table(connection, ['products', 'bahan'])
    if not table_name:
        return None, 'Tabel bahan atau products tidak ditemukan'

    name_col = get_existing_column(connection, table_name, ['nama_bahan', 'product_name', 'name'])
    stock_col = get_existing_column(connection, table_name, ['stok', 'current_stock', 'stock'])
    min_col = get_existing_column(connection, table_name, ['stok_minimum', 'min_stock', 'minimum_stock'])
    unit_col = get_existing_column(connection, table_name, ['unit'])

    if not name_col or not stock_col:
        return None, 'Kolom bahan/stok tidak ditemukan'

    select_min = min_col if min_col else '0'
    select_unit = unit_col if unit_col else "''"

    cursor = connection.cursor(dictionary=True)
    cursor.execute(
        f"""
        SELECT {name_col} AS nama_bahan,
               {stock_col} AS stok,
               {select_min} AS stok_minimum,
               {select_unit} AS unit
        FROM {escape_table_name(table_name)}
        ORDER BY {name_col}
        """
    )
    rows = cursor.fetchall()
    cursor.close()

    data = []
    for row in rows:
        stok = float(row.get('stok') or 0)
        stok_minimum = float(row.get('stok_minimum') or 0)
        status = compute_stock_status(stok, stok_minimum)
        data.append({
            'nama_bahan': row.get('nama_bahan'),
            'stok': stok,
            'stok_minimum': stok_minimum,
            'status': status,
            'unit': row.get('unit') or 'kg'
        })

    return data, None


def fetch_penggunaan_bahan(connection):
    table_name = get_existing_table(connection, ['stok_keluar', 'stock_usage_history'])
    if not table_name:
        return []

    cursor = connection.cursor(dictionary=True)

    if table_name == 'stock_usage_history':
        cursor.execute(
            f"""
            SELECT product_name AS nama_bahan,
                   COALESCE(SUM(quantity_used), 0) AS total_digunakan,
                   COALESCE(unit, 'kg') AS satuan
            FROM {escape_table_name(table_name)}
            GROUP BY product_name, unit
            ORDER BY total_digunakan DESC
            LIMIT 5
            """
        )
    else:
        name_col = get_existing_column(connection, table_name, ['nama_bahan'])
        qty_col = get_existing_column(connection, table_name, ['jumlah_keluar', 'quantity_used', 'jumlah'])
        unit_col = get_existing_column(connection, table_name, ['satuan', 'unit'])
        bahan_id_col = get_existing_column(connection, table_name, ['bahan_id', 'product_id'])

        if name_col and qty_col:
            unit_select = unit_col if unit_col else "'kg'"
            cursor.execute(
                f"""
                SELECT {name_col} AS nama_bahan,
                       COALESCE(SUM({qty_col}), 0) AS total_digunakan,
                       {unit_select} AS satuan
                FROM {escape_table_name(table_name)}
                GROUP BY {name_col}, {unit_select}
                ORDER BY total_digunakan DESC
                LIMIT 5
                """
            )
        elif bahan_id_col and qty_col:
            bahan_table = get_existing_table(connection, ['bahan', 'products'])
            if not bahan_table:
                cursor.close()
                return []

            bahan_name_col = get_existing_column(connection, bahan_table, ['nama_bahan', 'product_name', 'name'])
            bahan_unit_col = get_existing_column(connection, bahan_table, ['satuan', 'unit'])
            if not bahan_name_col:
                cursor.close()
                return []

            unit_select = f"b.{bahan_unit_col}" if bahan_unit_col else "'kg'"
            cursor.execute(
                f"""
                SELECT b.{bahan_name_col} AS nama_bahan,
                       COALESCE(SUM(k.{qty_col}), 0) AS total_digunakan,
                       {unit_select} AS satuan
                FROM {escape_table_name(table_name)} k
                JOIN {escape_table_name(bahan_table)} b ON b.id = k.{bahan_id_col}
                GROUP BY b.{bahan_name_col}, {unit_select}
                ORDER BY total_digunakan DESC
                LIMIT 5
                """
            )
        else:
            cursor.close()
            return []

    rows = cursor.fetchall()
    cursor.close()

    data = []
    for row in rows:
        data.append({
            'nama_bahan': row.get('nama_bahan'),
            'total_digunakan': float(row.get('total_digunakan') or 0),
            'satuan': row.get('satuan') or 'kg'
        })

    return data


def getBahanDigunakanHariIni(connection):
    """Total bahan keluar hari ini dari stok_keluar, fallback ke stock_usage_history."""
    table_name = get_existing_table(connection, ['stok_keluar'])
    totalBahanDigunakanHariIni = 0

    if table_name:
        qty_col = get_existing_column(connection, table_name, ['jumlah_keluar'])
        date_col = get_existing_column(connection, table_name, ['tanggal_keluar'])
        created_col = get_existing_column(connection, table_name, ['created_at'])

        if qty_col:
            table_sql = escape_table_name(table_name)
            cursor = connection.cursor()

            if date_col and created_col:
                cursor.execute(
                    f"""
                    SELECT COALESCE(SUM({qty_col}), 0)
                    FROM {table_sql}
                    WHERE (
                        {date_col} >= CURDATE()
                        AND {date_col} < DATE_ADD(CURDATE(), INTERVAL 1 DAY)
                    )
                    OR (
                        {date_col} IS NULL
                        AND {created_col} >= CURDATE()
                        AND {created_col} < DATE_ADD(CURDATE(), INTERVAL 1 DAY)
                    )
                    """
                )
            elif date_col:
                cursor.execute(
                    f"""
                    SELECT COALESCE(SUM({qty_col}), 0)
                    FROM {table_sql}
                    WHERE {date_col} >= CURDATE()
                      AND {date_col} < DATE_ADD(CURDATE(), INTERVAL 1 DAY)
                    """
                )
            elif created_col:
                cursor.execute(
                    f"""
                    SELECT COALESCE(SUM({qty_col}), 0)
                    FROM {table_sql}
                    WHERE {created_col} >= CURDATE()
                      AND {created_col} < DATE_ADD(CURDATE(), INTERVAL 1 DAY)
                    """
                )
            else:
                cursor.close()
                cursor = None

            if cursor:
                totalBahanDigunakanHariIni = cursor.fetchone()[0] or 0
                cursor.close()

    if float(totalBahanDigunakanHariIni or 0) == 0 and table_exists(connection, 'stock_usage_history'):
        cursor = connection.cursor(dictionary=True)
        cursor.execute(
            """
            SELECT quantity_used, unit
            FROM stock_usage_history
            WHERE created_at >= CURDATE()
              AND created_at < DATE_ADD(CURDATE(), INTERVAL 1 DAY)
            """
        )
        rows = cursor.fetchall()
        cursor.close()
        totalBahanDigunakanHariIni = sum(
            convert_stock_quantity(
                float(row.get('quantity_used') or 0),
                row.get('unit') or 'kg',
                'kg'
            )
            for row in rows
        )

    total = float(totalBahanDigunakanHariIni)

    return {
        'total': int(total) if total.is_integer() else total,
        'satuan': 'kg',
        'keterangan': 'total penggunaan hari ini'
    }

def grams_to_kg_rounded(grams: float) -> float:
    """
    Convert grams to kilograms with rounding rules:
    - <= 500g -> 0.5kg
    - 500g < g <= 1000g -> 1kg
    - > 1000g -> round up to nearest 0.5kg
    """
    if grams <= 0:
        raise ValueError("grams must be greater than 0")
    if grams <= 500:
        return 0.5
    if grams <= 1000:
        return 1.0
    return math.ceil(grams / 500.0) * 0.5

def normalize_stock_unit(unit: str | None) -> str:
    normalized = (unit or '').strip().lower()
    if normalized in ['g', 'gr', 'gram', 'grams']:
        return 'gr'
    if normalized in ['kg', 'kilogram', 'kilograms']:
        return 'kg'
    if normalized in ['ml', 'mili', 'mililiter', 'milliliter']:
        return 'ml'
    if normalized in ['l', 'lt', 'ltr', 'liter', 'litre']:
        return 'l'
    if normalized in ['butir', 'pcs', 'piece', 'pieces']:
        return 'butir'
    return normalized

def convert_stock_quantity(quantity: float, from_unit: str, to_unit: str) -> float:
    unit = normalize_stock_unit(from_unit)
    stock_unit = normalize_stock_unit(to_unit)

    if unit == stock_unit or not unit or not stock_unit:
        return quantity
    if unit == 'gr' and stock_unit == 'kg':
        return quantity / 1000
    if unit == 'kg' and stock_unit == 'gr':
        return quantity * 1000
    if unit == 'ml' and stock_unit == 'kg':
        return quantity / 1000
    if unit == 'l' and stock_unit == 'kg':
        return quantity
    if unit == 'kg' and stock_unit == 'ml':
        return quantity * 1000
    if unit == 'kg' and stock_unit == 'l':
        return quantity
    if unit == 'ml' and stock_unit == 'gr':
        return quantity
    if unit == 'gr' and stock_unit == 'ml':
        return quantity
    if unit == 'l' and stock_unit == 'ml':
        return quantity * 1000
    if unit == 'ml' and stock_unit == 'l':
        return quantity / 1000

    return quantity

# ============================================================================
# LOAD MODELS AT STARTUP
# ============================================================================
try:
    model = joblib.load('model_prediksi.pkl')
    encoders = joblib.load('encoders.pkl')
    feature_columns = joblib.load('feature_columns.pkl')
    metadata = joblib.load('model_metadata.pkl')
    logger.info("Models loaded successfully")
    logger.info(f"Model Type: {metadata['model_type']}")
    logger.info(f"R² Score: {metadata['r2_score']:.4f}")
except Exception as e:
    logger.error(f"Failed to load models: {e}")
    raise

# ============================================================================
# ROUTES
# ============================================================================

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'model_type': metadata['model_type'],
        'r2_score': round(metadata['r2_score'], 4),
        'timestamp': datetime.now().isoformat()
    }), 200


@app.route('/metadata', methods=['GET'])
def get_metadata():
    """Get model metadata"""
    return jsonify({
        'status': 'success',
        'model_info': {
            'type': metadata['model_type'],
            'r2_score': round(metadata['r2_score'], 4),
            'mae': round(metadata['mae'], 4),
            'rmse': round(metadata['rmse'], 4),
            'features': feature_columns,
            'target': metadata['target_column'],
            'total_samples': metadata['total_samples']
        }
    }), 200


@app.route('/prediksi', methods=['POST'])
def prediksi():
    """
    Predict stock demand

    Body: {
        "tahun": 2024,
        "bulan": 4,
        "hari": 4,
        "hari_dalam_minggu": 3,
        "harga_satuan_update": 50000,
        "total_harga_update": 250000,
        "produk_encoded": 2,
        "nama_produk_encoded": 2,
        "kategori_produk_encoded": 1,
        "hari_minggu": 3
    }
    """
    try:
        data = request.json

        # Validate required fields
        required_fields = feature_columns
        missing_fields = [f for f in required_fields if f not in data]

        if missing_fields:
            return jsonify({
                'status': 'error',
                'message': f'Missing fields: {", ".join(missing_fields)}',
                'required_fields': required_fields
            }), 400

        # Create feature array
        X_pred = np.array([[data[f] for f in feature_columns]])

        # Predict
        prediksi_raw = model.predict(X_pred)[0]
        prediksi = max(1, round(prediksi_raw))

        # Return result
        return jsonify({
            'status': 'success',
            'input': data,
            'prediksi': {
                'jumlah_unit': prediksi,
                'nilai_raw': round(prediksi_raw, 2)
            },
            'model_accuracy': {
                'r2_score': round(metadata['r2_score'], 4),
                'mae': round(metadata['mae'], 4),
                'rmse': round(metadata['rmse'], 4)
            }
        }), 200

    except Exception as e:
        logger.error(f"Prediction error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': f'Prediction failed: {str(e)}'
        }), 500


@app.route('/batch-prediksi', methods=['POST'])
def batch_prediksi():
    """
    Batch prediction for multiple items

    Body: {
        "items": [
            {"tahun": 2024, "bulan": 4, ...},
            {"tahun": 2024, "bulan": 5, ...}
        ]
    }
    """
    try:
        data = request.json

        if 'items' not in data or not isinstance(data['items'], list):
            return jsonify({
                'status': 'error',
                'message': 'Body harus berisi "items" array'
            }), 400

        results = []

        for i, item in enumerate(data['items']):
            try:
                # Check required fields
                missing_fields = [f for f in feature_columns if f not in item]

                if missing_fields:
                    results.append({
                        'index': i,
                        'status': 'error',
                        'message': f'Missing fields: {", ".join(missing_fields)}'
                    })
                    continue

                # Create feature array
                X_pred = np.array([[item[f] for f in feature_columns]])

                # Predict
                prediksi_raw = model.predict(X_pred)[0]
                prediksi = max(1, round(prediksi_raw))

                results.append({
                    'index': i,
                    'status': 'success',
                    'prediksi': prediksi,
                    'nilai_raw': round(prediksi_raw, 2)
                })

            except Exception as e:
                results.append({
                    'index': i,
                    'status': 'error',
                    'message': str(e)
                })

        return jsonify({
            'status': 'success',
            'total_items': len(data['items']),
            'results': results
        }), 200

    except Exception as e:
        logger.error(f"Batch prediction error: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': f'Batch prediction failed: {str(e)}'
        }), 500


@app.route('/info', methods=['GET'])
def info():
    """Get API information"""
    return jsonify({
        'api_name': 'Prediksi Permintaan Stok Bahan',
        'version': '2.0',
        'model': metadata['model_type'],
        'endpoints': {
            'GET /health': 'API health check',
            'GET /metadata': 'Get model metadata',
            'GET /info': 'Get API info',
            'POST /prediksi': 'Single prediction',
            'POST /batch-prediksi': 'Batch prediction',
            'GET /products': 'Get all products',
            'POST /transactions': 'Save transaction (legacy)',
            'GET /transactions': 'Get transaction history',
            'POST /transaksi': 'Save transaction and update stock automatically',
            'POST /stock/consume': 'Consume stock after production'
        },
        'required_features': feature_columns
    }), 200


# ============================================================================
# DATABASE ENDPOINTS - PRODUCTS & TRANSACTIONS
# ============================================================================

@app.route('/products', methods=['GET'])
def get_products():
    """Get all products from database"""
    try:
        connection = get_db_connection()
        if not connection:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM products ORDER BY name")
        products = cursor.fetchall()
        cursor.close()
        connection.close()

        return jsonify({
            'status': 'success',
            'total': len(products),
            'products': products
        }), 200

    except Exception as e:
        logger.error(f"Get products error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Get specific product by ID"""
    try:
        connection = get_db_connection()
        if not connection:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM products WHERE id = %s", (product_id,))
        product = cursor.fetchone()
        cursor.close()
        connection.close()

        if not product:
            return jsonify({'status': 'error', 'message': 'Product not found'}), 404

        return jsonify({
            'status': 'success',
            'product': product
        }), 200

    except Exception as e:
        logger.error(f"Get product error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/products', methods=['POST'])
def create_product():
    """
    Create new product in database
    Body: {
        "name": "Tepung Terigu 1kg",
        "category": "Tepung",
        "price": 15000,
        "current_stock": 50,
        "unit": "kg",
        "product_type": "Bahan"
    }
    """
    try:
        data = request.json

        # Validate required fields
        required_fields = ['name', 'category', 'price', 'current_stock']
        missing_fields = [f for f in required_fields if f not in data]

        if missing_fields:
            return jsonify({
                'status': 'error',
                'message': f'Missing fields: {", ".join(missing_fields)}',
                'required_fields': required_fields
            }), 400

        connection = get_db_connection()
        if not connection:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        cursor = connection.cursor()

        # Optional columns compatibility (works for old/new schemas)
        cursor.execute("SHOW COLUMNS FROM products LIKE 'unit'")
        has_unit_column = cursor.fetchone() is not None
        cursor.execute("SHOW COLUMNS FROM products LIKE 'product_type'")
        has_product_type_column = cursor.fetchone() is not None

        unit_value = data.get('unit')
        product_type_value = data.get('product_type')

        # Check for duplicate product name
        cursor.execute("SELECT id FROM products WHERE name = %s", (data['name'],))
        if cursor.fetchone():
            cursor.close()
            connection.close()
            return jsonify({
                'status': 'error',
                'message': f'Product "{data["name"]}" already exists'
            }), 409

        # Insert new product
        if has_unit_column and has_product_type_column:
            cursor.execute("""
                INSERT INTO products
                (name, category, price, current_stock, unit, product_type)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (
                data['name'],
                data['category'],
                data['price'],
                data['current_stock'],
                unit_value,
                product_type_value
            ))
        elif has_unit_column:
            cursor.execute("""
                INSERT INTO products
                (name, category, price, current_stock, unit)
                VALUES (%s, %s, %s, %s, %s)
            """, (
                data['name'],
                data['category'],
                data['price'],
                data['current_stock'],
                unit_value
            ))
        elif has_product_type_column:
            cursor.execute("""
                INSERT INTO products
                (name, category, price, current_stock, product_type)
                VALUES (%s, %s, %s, %s, %s)
            """, (
                data['name'],
                data['category'],
                data['price'],
                data['current_stock'],
                product_type_value
            ))
        else:
            cursor.execute("""
                INSERT INTO products
                (name, category, price, current_stock)
                VALUES (%s, %s, %s, %s)
            """, (
                data['name'],
                data['category'],
                data['price'],
                data['current_stock']
            ))
        connection.commit()

        product_id = cursor.lastrowid
        cursor.close()
        connection.close()

        return jsonify({
            'status': 'success',
            'product_id': product_id,
            'message': 'Product created successfully'
        }), 201

    except Exception as e:
        logger.error(f"Create product error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/stock/consume', methods=['POST'])
def consume_stock():
    """
    Consume stock after production.
    Body: {
        "recipe_name": "Donat",
        "production_quantity": 10,
        "items": [
            {"product_id": 1, "product_name": "Tepung Terigu 1kg", "quantity": 1, "unit": "kg"}
        ],
        "allow_partial": false
    }
    """
    print("FLASK TERBARU AKTIF")
    print("REQUEST RECEIVED")
    connection = None
    cursor = None
    started_transaction = False
    try:
        data = request.json or {}
        print("REQUEST DATA:", data)
        items = data.get('items', [])
        allow_partial = bool(data.get('allow_partial', False))

        if not isinstance(items, list) or not items:
            return jsonify({
                'status': 'error',
                'message': 'Items wajib diisi'
            }), 400

        connection = get_db_connection()
        if not connection:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        ensure_stock_usage_tables(connection)

        name_column = get_product_name_column(connection)
        unit_column_exists = has_product_unit_column(connection)
        history_enabled = table_exists(connection, 'stock_usage_history')
        stock_out_enabled = table_exists(connection, 'stok_keluar')
        stock_out_product_col = None
        stock_out_qty_col = None
        stock_out_unit_col = None
        stock_out_date_col = None
        if stock_out_enabled:
            stock_out_product_col = get_existing_column(connection, 'stok_keluar', ['bahan_id', 'product_id'])
            stock_out_qty_col = get_existing_column(connection, 'stok_keluar', ['jumlah_keluar'])
            stock_out_unit_col = get_existing_column(connection, 'stok_keluar', ['satuan', 'unit'])
            stock_out_date_col = get_existing_column(connection, 'stok_keluar', ['tanggal_keluar'])
            stock_out_enabled = bool(stock_out_product_col and stock_out_qty_col)

        cursor = connection.cursor(dictionary=True)
        started_transaction = True

        errors = []
        valid_items = []

        for item in items:
            product_id = item.get('product_id')
            product_name = item.get('product_name')
            quantity = item.get('quantity')
            unit = (item.get('unit') or '').strip().lower()

            if not isinstance(quantity, (int, float)) or quantity <= 0:
                errors.append({
                    'item': item,
                    'message': 'Quantity harus lebih dari 0'
                })
                continue

            if unit_column_exists:
                select_fields = f"id, {name_column} as name, current_stock, unit"
            else:
                select_fields = f"id, {name_column} as name, current_stock"

            if product_id:
                cursor.execute(
                    f"SELECT {select_fields} FROM products WHERE id = %s",
                    (product_id,)
                )
            else:
                cursor.execute(
                    f"SELECT {select_fields} FROM products WHERE {name_column} = %s",
                    (product_name,)
                )

            product = cursor.fetchone()
            if not product:
                errors.append({
                    'item': item,
                    'message': 'Produk tidak ditemukan'
                })
                continue

            product_unit = (product.get('unit') or '').strip().lower()
            effective_unit = normalize_stock_unit(product_unit or unit)
            effective_quantity = convert_stock_quantity(
                float(quantity),
                unit or effective_unit,
                effective_unit
            )

            logger.info(
                f"[stock/consume] Using quantity: {quantity} {unit or effective_unit} -> {effective_quantity} {effective_unit} (product_id={product.get('id')})"
            )

            if product['current_stock'] < effective_quantity:
                errors.append({
                    'item': item,
                    'message': 'Stok tidak cukup',
                    'available': product['current_stock']
                })
                continue

            valid_items.append({
                'product': product,
                'quantity': effective_quantity,
                'unit': effective_unit or product.get('unit'),
                'input_quantity': quantity,
                'input_unit': unit or product.get('unit')
            })

        if errors and not allow_partial:
            connection.rollback()
            return jsonify({
                'status': 'error',
                'message': 'Ada item gagal diproses',
                'errors': errors
            }), 400

        print("UPDATING STOCK")
        results = []
        for entry in valid_items:
            product = entry['product']
            quantity = entry['quantity']
            cursor.execute(
                "UPDATE products SET current_stock = current_stock - %s WHERE id = %s",
                (quantity, product['id'])
            )

            if history_enabled:
                cursor.execute(
                    """
                    INSERT INTO stock_usage_history
                    (recipe_name, production_quantity, product_id, product_name, quantity_used, unit)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    (
                        data.get('recipe_name'),
                        data.get('production_quantity'),
                        product['id'],
                        product['name'],
                        quantity,
                        entry['unit']
                    )
                )

            if stock_out_enabled:
                columns = [stock_out_product_col, stock_out_qty_col]
                values = [product['id'], quantity]

                if stock_out_unit_col:
                    columns.append(stock_out_unit_col)
                    values.append(entry['unit'])
                if stock_out_date_col:
                    columns.append(stock_out_date_col)
                    values.append(datetime.now().date())

                column_sql = ', '.join(columns)
                placeholders = ', '.join(['%s'] * len(columns))
                cursor.execute(
                    f"INSERT INTO stok_keluar ({column_sql}) VALUES ({placeholders})",
                    tuple(values)
                )

            results.append({
                'product_id': product['id'],
                'product_name': product['name'],
                'quantity_used': quantity,
                'deducted_amount': quantity,
                'unit': entry['unit'],
                'quantity_input': entry.get('input_quantity'),
                'unit_input': entry.get('input_unit')
            })

        connection.commit()

        return jsonify({
            'status': 'success',
            'processed': len(results),
            'results': results,
            'errors': errors if allow_partial else []
        }), 200

    except Exception as e:
        if connection and started_transaction:
            try:
                connection.rollback()
            except Exception:
                logger.exception("[stock/consume] Failed to rollback transaction")
        logger.error(f"Consume stock error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500
    finally:
        if cursor is not None:
            try:
                cursor.close()
            except Exception:
                logger.exception("[stock/consume] Failed to close cursor")
        if connection is not None:
            try:
                connection.close()
            except Exception:
                logger.exception("[stock/consume] Failed to close connection")
        print("REQUEST FINISHED")


@app.route('/transactions', methods=['POST'])
def save_transaction():
    """
    Save transaction to database
    Body: {
        "product_name": "Tepung Terigu 1kg",
        "category": "Tepung",
        "quantity": 5,
        "unit_price": 15000,
        "total_price": 75000,
        "transaction_date": "2024-04-05"
    }
    """
    try:
        data = request.json

        # Validate required fields
        required_fields = ['product_name', 'category', 'quantity', 'unit_price', 'total_price', 'transaction_date']
        missing_fields = [f for f in required_fields if f not in data]

        if missing_fields:
            return jsonify({
                'status': 'error',
                'message': f'Missing fields: {", ".join(missing_fields)}',
                'required_fields': required_fields
            }), 400

        connection = get_db_connection()
        if not connection:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        cursor = connection.cursor()
        cursor.execute(f"""
            INSERT INTO {TRANSACTIONS_TABLE}
            (product_name, category, quantity, unit_price, total_price, transaction_date)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            data['product_name'],
            data['category'],
            data['quantity'],
            data['unit_price'],
            data['total_price'],
            data['transaction_date']
        ))
        connection.commit()

        transaction_id = cursor.lastrowid
        cursor.close()
        connection.close()

        logger.info(f"Transaction saved: ID={transaction_id}")

        return jsonify({
            'status': 'success',
            'message': 'Transaction saved successfully',
            'transaction_id': transaction_id
        }), 201

    except Exception as e:
        logger.error(f"Save transaction error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/transaksi', methods=['POST'])
def add_transaction_with_stock_update():
    """
    Add transaction AND update stock automatically
    Body: {
        "produk_id": 1,
        "jumlah": 5,
        "unit_price": 15000,
        "total_price": 75000,
        "transaction_date": "2024-04-05"
    }
    """
    try:
        data = request.json

        # Validate required fields
        required_fields = ['produk_id', 'jumlah', 'unit_price', 'total_price', 'transaction_date']
        missing_fields = [f for f in required_fields if f not in data]

        if missing_fields:
            return jsonify({
                'status': 'error',
                'message': f'Missing fields: {", ".join(missing_fields)}',
                'required_fields': required_fields
            }), 400

        connection = get_db_connection()
        if not connection:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        cursor = connection.cursor(dictionary=True)

        # 1. Get product info
        cursor.execute("SELECT id, name, category FROM products WHERE id = %s", (data['produk_id'],))
        product = cursor.fetchone()

        if not product:
            cursor.close()
            connection.close()
            return jsonify({
                'status': 'error',
                'message': f'Product ID {data["produk_id"]} not found'
            }), 404

        # 2. Save transaction
        cursor.execute(f"""
            INSERT INTO {TRANSACTIONS_TABLE}
            (product_name, category, quantity, unit_price, total_price, transaction_date)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            product['name'],
            product['category'],
            data['jumlah'],
            data['unit_price'],
            data['total_price'],
            data['transaction_date']
        ))
        connection.commit()
        transaction_id = cursor.lastrowid

        # 3. Update product stock (add quantity)
        cursor.execute("""
            UPDATE products
            SET current_stock = current_stock + %s
            WHERE id = %s
        """, (data['jumlah'], data['produk_id']))
        connection.commit()

        cursor.close()
        connection.close()

        logger.info(f"Transaction saved: ID={transaction_id}, Stock updated for product ID={data['produk_id']} (+{data['jumlah']})")

        return jsonify({
            'status': 'success',
            'message': 'Stok berhasil ditambahkan',
            'transaction_id': transaction_id,
            'product_id': data['produk_id'],
            'product_name': product['name'],
            'quantity_added': data['jumlah']
        }), 201

    except Exception as e:
        logger.error(f"Add transaction with stock update error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500



@app.route('/transactions', methods=['GET'])
def get_transactions():
    """Get transaction history"""
    try:
        # Get optional query parameters
        limit = request.args.get('limit', 100, type=int)
        offset = request.args.get('offset', 0, type=int)
        product_name = request.args.get('product_name', None)

        connection = get_db_connection()
        if not connection:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        cursor = connection.cursor(dictionary=True)

        # Build query
        query = f"SELECT * FROM {TRANSACTIONS_TABLE} WHERE 1=1"
        params = []

        if product_name:
            query += " AND product_name LIKE %s"
            params.append(f"%{product_name}%")

        query += " ORDER BY created_at DESC LIMIT %s OFFSET %s"
        params.extend([limit, offset])

        cursor.execute(query, params)
        transactions = cursor.fetchall()

        # Get total count
        cursor.execute(f"SELECT COUNT(*) as total FROM {TRANSACTIONS_TABLE}" +
                      (" WHERE product_name LIKE %s" if product_name else ""),
                      ([f"%{product_name}%"] if product_name else []))
        total = cursor.fetchone()['total']

        cursor.close()
        connection.close()

        return jsonify({
            'status': 'success',
            'total': total,
            'limit': limit,
            'offset': offset,
            'transactions': transactions
        }), 200

    except Exception as e:
        logger.error(f"Get transactions error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/predictions', methods=['POST'])
def save_prediction():
    """
    Save prediction result to database
    Body: {
        "product_name": "Tepung Terigu 1kg",
        "category": "Tepung",
        "unit_price": 15000,
        "prediction_date": "2024-04-05",
        "predicted_quantity": 45,
        "raw_value": 44.8,
        "estimated_total_price": 672000,
        "accuracy_r2": 0.9964,
        "error_mae": 2.51
    }
    """
    try:
        data = request.json

        required_fields = ['product_name', 'category', 'unit_price', 'prediction_date', 'predicted_quantity']
        missing_fields = [f for f in required_fields if f not in data]

        if missing_fields:
            return jsonify({
                'status': 'error',
                'message': f'Missing fields: {", ".join(missing_fields)}'
            }), 400

        connection = get_db_connection()
        if not connection:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        table_name = 'predictions'
        needs_col = ensure_prediction_needs_column(connection, table_name)

        columns = [
            'product_name',
            'category',
            'unit_price',
            'prediction_date',
            'predicted_quantity',
            'raw_value',
            'estimated_total_price',
            'accuracy_r2',
            'error_mae'
        ]
        values = [
            data['product_name'],
            data['category'],
            data['unit_price'],
            data['prediction_date'],
            data['predicted_quantity'],
            data.get('raw_value'),
            data.get('estimated_total_price'),
            data.get('accuracy_r2'),
            data.get('error_mae')
        ]

        if needs_col:
            columns.append(needs_col)
            values.append(data.get('estimated_needs') or data.get('estimasi_kebutuhan_bahan'))

        cursor = connection.cursor()
        placeholders = ', '.join(['%s'] * len(columns))
        column_sql = ', '.join(columns)
        cursor.execute(
            f"INSERT INTO predictions ({column_sql}) VALUES ({placeholders})",
            tuple(values)
        )
        connection.commit()

        prediction_id = cursor.lastrowid
        cursor.close()
        connection.close()

        logger.info(f"Prediction saved: ID={prediction_id}")

        return jsonify({
            'status': 'success',
            'message': 'Prediction saved successfully',
            'prediction_id': prediction_id
        }), 201

    except Exception as e:
        logger.error(f"Save prediction error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


# ============================================================================
# REPORT ENDPOINTS - LAPORAN
# ============================================================================

@app.route('/laporan/stok', methods=['GET'])
def laporan_stok():
    """Laporan stok bahan dari tabel bahan/products."""
    try:
        connection = get_db_connection()
        if not connection:
            return build_report_response(False, 'Database connection failed', [], 500)

        data, error_message = fetch_stock_report(connection)
        connection.close()

        if error_message:
            return build_report_response(False, error_message, [], 404)

        return build_report_response(True, 'Data berhasil diambil', data, 200)
    except Exception as e:
        logger.error(f"Laporan stok error: {str(e)}")
        return build_report_response(False, f'Gagal mengambil data: {str(e)}', [], 500)


@app.route('/laporan/bahan-kritis', methods=['GET'])
def laporan_bahan_kritis():
    """Laporan bahan kritis/ rendah berdasarkan stok minimum."""
    try:
        connection = get_db_connection()
        if not connection:
            return build_report_response(False, 'Database connection failed', [], 500)

        data, error_message = fetch_stock_report(connection)
        connection.close()

        if error_message:
            return build_report_response(False, error_message, [], 404)

        critical_items = [
            item for item in data
            if item['status'] in ['Rendah', 'Kritis']
        ]

        return build_report_response(True, 'Data berhasil diambil', critical_items, 200)
    except Exception as e:
        logger.error(f"Laporan bahan kritis error: {str(e)}")
        return build_report_response(False, f'Gagal mengambil data: {str(e)}', [], 500)


@app.route('/laporan/stok-masuk', methods=['GET'])
def laporan_stok_masuk():
    """Laporan riwayat stok masuk dari tabel stok_masuk/Stock In/transactions."""
    try:
        connection = get_db_connection()
        if not connection:
            return build_report_response(False, 'Database connection failed', [], 500)

        table_name = get_existing_table(connection, ['stok_masuk', 'Stock In', 'transactions'])
        if not table_name:
            connection.close()
            return build_report_response(False, 'Tabel stok_masuk/transactions tidak ditemukan', [], 404)

        name_col = get_existing_column(connection, table_name, ['nama_bahan', 'product_name', 'name'])
        qty_col = get_existing_column(connection, table_name, ['jumlah', 'quantity'])
        date_col = get_existing_column(connection, table_name, ['tanggal', 'transaction_date', 'created_at'])
        unit_col = get_existing_column(connection, table_name, ['unit'])
        product_id_col = get_existing_column(connection, table_name, ['product_id', 'produk_id', 'bahan_id'])

        if not qty_col or not date_col:
            connection.close()
            return build_report_response(False, 'Kolom stok masuk tidak lengkap', [], 500)

        cursor = connection.cursor(dictionary=True)
        table_sql = escape_table_name(table_name)

        if not name_col and product_id_col:
            product_table = get_existing_table(connection, ['products', 'bahan'])
            if product_table:
                product_name_col = get_existing_column(connection, product_table, ['nama_bahan', 'product_name', 'name'])
                product_unit_col = get_existing_column(connection, product_table, ['unit'])
                if product_name_col:
                    cursor.execute(
                        f"""
                        SELECT p.{product_name_col} AS nama_bahan,
                               sm.{qty_col} AS jumlah,
                               sm.{date_col} AS tanggal,
                               p.{product_unit_col} AS unit
                        FROM {table_sql} sm
                        JOIN {escape_table_name(product_table)} p ON p.id = sm.{product_id_col}
                        ORDER BY sm.{date_col} DESC
                        """
                    )
                else:
                    cursor.execute(
                        f"""
                        SELECT sm.{qty_col} AS jumlah,
                               sm.{date_col} AS tanggal
                        FROM {table_sql} sm
                        ORDER BY sm.{date_col} DESC
                        """
                    )
            else:
                cursor.execute(
                    f"""
                    SELECT sm.{qty_col} AS jumlah,
                           sm.{date_col} AS tanggal
                    FROM {table_sql} sm
                    ORDER BY sm.{date_col} DESC
                    """
                )
        else:
            unit_select = unit_col if unit_col else "''"
            cursor.execute(
                f"""
                SELECT {name_col} AS nama_bahan,
                       {qty_col} AS jumlah,
                       {date_col} AS tanggal,
                       {unit_select} AS unit
                FROM {table_sql}
                ORDER BY {date_col} DESC
                """
            )

        rows = cursor.fetchall()
        cursor.close()
        connection.close()

        data = []
        for row in rows:
            tanggal = row.get('tanggal')
            data.append({
                'nama_bahan': row.get('nama_bahan'),
                'jumlah': float(row.get('jumlah') or 0),
                'tanggal': tanggal.isoformat() if hasattr(tanggal, 'isoformat') else tanggal,
                'unit': row.get('unit') or 'kg'
            })

        return build_report_response(True, 'Data berhasil diambil', data, 200)
    except Exception as e:
        logger.error(f"Laporan stok masuk error: {str(e)}")
        return build_report_response(False, f'Gagal mengambil data: {str(e)}', [], 500)


@app.route('/laporan/prediksi', methods=['GET'])
def laporan_prediksi():
    """Laporan prediksi permintaan dari tabel prediksi/predictions."""
    try:
        connection = get_db_connection()
        if not connection:
            return build_report_response(False, 'Database connection failed', [], 500)

        table_name = get_existing_table(connection, ['prediksi', 'predictions'])
        if not table_name:
            connection.close()
            return build_report_response(False, 'Tabel prediksi/predictions tidak ditemukan', [], 404)

        name_col = get_existing_column(connection, table_name, ['nama_produk', 'product_name', 'name'])
        result_col = get_existing_column(connection, table_name, ['hasil_prediksi', 'predicted_quantity'])
        estimate_col = get_existing_column(connection, table_name, ['estimasi_kebutuhan_bahan', 'estimated_needs', 'raw_value'])
        date_col = get_existing_column(connection, table_name, ['tanggal_prediksi', 'prediction_date', 'created_at'])

        if not result_col or not date_col:
            connection.close()
            return build_report_response(False, 'Kolom prediksi tidak lengkap', [], 500)

        cursor = connection.cursor(dictionary=True)
        table_sql = escape_table_name(table_name)
        estimate_select = estimate_col if estimate_col else 'NULL'
        name_select = name_col if name_col else "''"

        cursor.execute(
            f"""
            SELECT {name_select} AS nama_produk,
                   {result_col} AS hasil_prediksi,
                   {estimate_select} AS estimasi_kebutuhan_bahan,
                   {date_col} AS tanggal_prediksi
            FROM {table_sql}
            ORDER BY {date_col} DESC
            """
        )

        rows = cursor.fetchall()
        cursor.close()
        connection.close()

        data = []
        for row in rows:
            tanggal_prediksi = row.get('tanggal_prediksi')
            data.append({
                'nama_produk': row.get('nama_produk'),
                'hasil_prediksi': float(row.get('hasil_prediksi') or 0),
                'estimasi_kebutuhan_bahan': row.get('estimasi_kebutuhan_bahan'),
                'tanggal_prediksi': tanggal_prediksi.isoformat() if hasattr(tanggal_prediksi, 'isoformat') else tanggal_prediksi
            })

        return build_report_response(True, 'Data berhasil diambil', data, 200)
    except Exception as e:
        logger.error(f"Laporan prediksi error: {str(e)}")
        return build_report_response(False, f'Gagal mengambil data: {str(e)}', [], 500)


# ============================================================================
# DASHBOARD ENDPOINTS
# ============================================================================

@app.route('/api/dashboard/bahan-digunakan-hari-ini', methods=['GET'])
def bahanDigunakanHariIni():
    """Total bahan keluar hari ini dari stok_keluar."""
    connection = None
    try:
        connection = get_db_connection()
        if not connection:
            return jsonify({
                'status': False,
                'message': 'Database connection failed',
                'total': 0,
                'satuan': 'kg',
                'keterangan': 'total penggunaan hari ini'
            }), 500

        data = getBahanDigunakanHariIni(connection)
        return jsonify(data), 200
    except Exception as e:
        logger.error(f"Bahan digunakan hari ini error: {str(e)}")
        return jsonify({
            'status': False,
            'message': f'Gagal mengambil data: {str(e)}',
            'total': 0,
            'satuan': 'kg',
            'keterangan': 'total penggunaan hari ini'
        }), 500
    finally:
        if connection:
            connection.close()

@app.route('/api/dashboard/summary', methods=['GET'])
def dashboard_summary():
    """Ringkasan dashboard untuk grafik penggunaan bahan."""
    try:
        connection = get_db_connection()
        if not connection:
            return jsonify({
                'status': False,
                'message': 'Database connection failed',
                'penggunaan_bahan': []
            }), 500

        penggunaan = fetch_penggunaan_bahan(connection)
        connection.close()

        return jsonify({
            'status': True,
            'penggunaan_bahan': penggunaan
        }), 200
    except Exception as e:
        logger.error(f"Dashboard summary error: {str(e)}")
        return jsonify({
            'status': False,
            'message': f'Gagal mengambil data: {str(e)}',
            'penggunaan_bahan': []
        }), 500


# ============================================================================
# RECIPES ENDPOINTS
# ============================================================================

@app.route('/recipes', methods=['GET'])
def get_recipes():
    """Get all recipes with their ingredients"""
    try:
        connection = get_db_connection()
        if not connection:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        cursor = connection.cursor(dictionary=True)

        # Get all recipes
        cursor.execute("SELECT id, recipe_name, description FROM recipes ORDER BY recipe_name")
        recipes = cursor.fetchall()

        # Get ingredients for each recipe
        for recipe in recipes:
            cursor.execute("""
                SELECT product_name, quantity_needed, unit
                FROM recipe_ingredients
                WHERE recipe_id = %s
                ORDER BY product_name
            """, (recipe['id'],))
            recipe['ingredients'] = cursor.fetchall()

        cursor.close()
        connection.close()

        return jsonify({
            'status': 'success',
            'total': len(recipes),
            'recipes': recipes
        }), 200

    except Exception as e:
        logger.error(f"Get recipes error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/recipes/<int:recipe_id>', methods=['GET'])
def get_recipe(recipe_id):
    """Get specific recipe with ingredients"""
    try:
        connection = get_db_connection()
        if not connection:
            return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

        cursor = connection.cursor(dictionary=True)

        # Get recipe
        cursor.execute("SELECT id, recipe_name, description FROM recipes WHERE id = %s", (recipe_id,))
        recipe = cursor.fetchone()

        if not recipe:
            cursor.close()
            connection.close()
            return jsonify({'status': 'error', 'message': 'Recipe not found'}), 404

        # Get ingredients
        cursor.execute("""
            SELECT product_name, quantity_needed, unit
            FROM recipe_ingredients
            WHERE recipe_id = %s
            ORDER BY product_name
        """, (recipe_id,))
        recipe['ingredients'] = cursor.fetchall()

        cursor.close()
        connection.close()

        return jsonify({
            'status': 'success',
            'recipe': recipe
        }), 200

    except Exception as e:
        logger.error(f"Get recipe error: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.errorhandler(404)
def not_found(error):
    return jsonify({'status': 'error', 'message': 'Endpoint tidak ditemukan'}), 404


@app.errorhandler(500)
def internal_error(error):
    return jsonify({'status': 'error', 'message': 'Internal server error'}), 500


@app.route('/test')
def test():
    return {"message": "FLASK BARU AKTIF"}


# ============================================================================
# MAIN
# ============================================================================
if __name__ == '__main__':
    logger.info("=" * 80)
    logger.info("Starting Prediksi Stok API")
    logger.info("=" * 80)
    logger.info(f"Model: {metadata['model_type']}")
    logger.info(f"Accuracy (R²): {metadata['r2_score']:.4f}")
    logger.info(f"Features: {len(feature_columns)}")
    logger.info("Endpoints: /health, /metadata, /info, /prediksi, /batch-prediksi, /products, /transactions, /predictions, /recipes")
    logger.info("Access API at: http://localhost:5000")
    logger.info("=" * 80)

    app.run(
        debug=False,
        host='0.0.0.0',
        port=5000,
        threaded=True
    )
