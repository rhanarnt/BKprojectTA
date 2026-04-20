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
            'POST /transactions': 'Save transaction',
            'GET /transactions': 'Get transaction history'
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
        "current_stock": 50
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
        cursor.execute("""
            INSERT INTO transactions
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
        query = "SELECT * FROM transactions WHERE 1=1"
        params = []

        if product_name:
            query += " AND product_name LIKE %s"
            params.append(f"%{product_name}%")

        query += " ORDER BY created_at DESC LIMIT %s OFFSET %s"
        params.extend([limit, offset])

        cursor.execute(query, params)
        transactions = cursor.fetchall()

        # Get total count
        cursor.execute("SELECT COUNT(*) as total FROM transactions" +
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

        cursor = connection.cursor()
        cursor.execute("""
            INSERT INTO predictions
            (product_name, category, unit_price, prediction_date, predicted_quantity,
             raw_value, estimated_total_price, accuracy_r2, error_mae)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            data['product_name'],
            data['category'],
            data['unit_price'],
            data['prediction_date'],
            data['predicted_quantity'],
            data.get('raw_value'),
            data.get('estimated_total_price'),
            data.get('accuracy_r2'),
            data.get('error_mae')
        ))
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
