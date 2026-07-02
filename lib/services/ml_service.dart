import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class MLService {
  // API URL Railway Flask backend.
  static const String baseUrl = 'http://127.0.0.1:5000';
  //http://127.0.0.1:5000
  //https://web-production-c3c06.up.railway.app
  static const int timeoutSeconds = 30;

  static dynamic _tryDecodeJsonBody(String body) {
    final trimmed = body.trimLeft();
    if (trimmed.isEmpty) return null;
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _decodeJsonMap(String body) {
    final decoded = _tryDecodeJsonBody(body);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return null;
  }

  /// Login using account data from MySQL login table.
  static Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': usernameOrEmail,
              'username': usernameOrEmail,
              'password': password,
            }),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      final body = _decodeJsonMap(response.body);
      if (body == null) {
        return {
          'status': 'error',
          'message':
              'Server mengembalikan respons bukan JSON. Cek baseUrl API.',
        };
      }
      if (response.statusCode == 200) {
        return body;
      }

      return {'status': 'error', 'message': body['message'] ?? 'Login gagal'};
    } on TimeoutException {
      return {
        'status': 'error',
        'message':
            'Server tidak merespons. Pastikan Flask aktif dan IP/port API sudah benar.',
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> sendForgotPasswordOtp({
    required String usernameOrEmail,
  }) async {
    return _postJson('/api/forgot-password/send-otp', {
      'email': usernameOrEmail,
      'username': usernameOrEmail,
    }, fallbackMessage: 'Gagal membuat OTP');
  }

  static Future<Map<String, dynamic>> verifyForgotPasswordOtp({
    required String usernameOrEmail,
    required String otp,
  }) async {
    return _postJson('/api/forgot-password/verify-otp', {
      'email': usernameOrEmail,
      'username': usernameOrEmail,
      'otp': otp,
    }, fallbackMessage: 'Gagal verifikasi OTP');
  }

  static Future<Map<String, dynamic>> resetPasswordWithOtp({
    required String usernameOrEmail,
    required String otp,
    required String newPassword,
  }) async {
    return _postJson('/api/forgot-password/reset', {
      'email': usernameOrEmail,
      'username': usernameOrEmail,
      'otp': otp,
      'new_password': newPassword,
    }, fallbackMessage: 'Gagal reset password');
  }

  static Future<Map<String, dynamic>> changePassword({
    required String usernameOrEmail,
    required String currentPassword,
    required String newPassword,
  }) async {
    return _postJson('/api/change-password', {
      'email': usernameOrEmail,
      'username': usernameOrEmail,
      'current_password': currentPassword,
      'new_password': newPassword,
    }, fallbackMessage: 'Gagal mengubah password');
  }

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload, {
    required String fallbackMessage,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      final body = _decodeJsonMap(response.body);
      if (body == null) {
        return {
          'status': 'error',
          'message':
              'Server mengembalikan respons bukan JSON. Cek baseUrl API.',
        };
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {'status': 'error', 'message': body['message'] ?? fallbackMessage};
    } on TimeoutException {
      return {
        'status': 'error',
        'message':
            'Server tidak merespons. Pastikan Flask aktif dan IP/port API sudah benar.',
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Tidak dapat terhubung ke server: $e',
      };
    }
  }

  /// Convert grams to kilograms with rounding rules:
  /// - <= 500g -> 0.5kg
  /// - 500g < g <= 1000g -> 1kg
  /// - > 1000g -> round up to nearest 0.5kg
  static double gramsToKgRounded(num grams) {
    if (grams <= 0) {
      throw ArgumentError('grams must be greater than 0');
    }
    if (grams <= 500) return 0.5;
    if (grams <= 1000) return 1.0;
    return (grams / 500).ceilToDouble() * 0.5;
  }

  /// Health Check - Test if API is running
  static Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

  /// Get Metadata - Retrieve model information
  static Future<Map<String, dynamic>> getMetadata() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/metadata'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return _decodeJsonMap(response.body) ??
            {'status': 'error', 'message': 'Respons metadata tidak valid'};
      } else {
        return {'status': 'error', 'message': 'Failed to get metadata'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Simplified Prediction - For UI use
  static Future<Map<String, dynamic>> simplePrediksi({
    required String productName,
    required String category,
    required int unitPrice,
    int plannedQuantity = 1,
    DateTime? predictionDate,
  }) async {
    try {
      final date = predictionDate ?? DateTime.now();

      final response = await http
          .post(
            Uri.parse('$baseUrl/prediksi'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'product_name': productName,
              'category': category,
              'unit_price': unitPrice,
              'planned_quantity': plannedQuantity,
              'prediction_date': date.toIso8601String().split('T').first,
            }),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return _decodeJsonMap(response.body) ??
            {'status': 'error', 'message': 'Respons prediksi tidak valid'};
      }

      return {
        'status': 'error',
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Single Prediction - Predict stock demand
  static Future<Map<String, dynamic>> prediksiStok({
    required int tahun,
    required int bulan,
    required int hari,
    required int hariDalamMinggu,
    required int hariMinggu,
    required int hargaSatuanUpdate,
    required int totalHargaUpdate,
    required int produkEncoded,
    required int namaProdukEncoded,
    required int kategoriProdukEncoded,
  }) async {
    try {
      final data = {
        'tahun': tahun,
        'bulan': bulan,
        'hari': hari,
        'hari_dalam_minggu': hariDalamMinggu,
        'hari_minggu': hariMinggu,
        'harga_satuan_update': hargaSatuanUpdate,
        'total_harga_update': totalHargaUpdate,
        'produk_encoded': produkEncoded,
        'nama_produk_encoded': namaProdukEncoded,
        'kategori_produk_encoded': kategoriProdukEncoded,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/prediksi'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return _decodeJsonMap(response.body) ??
            {'status': 'error', 'message': 'Respons prediksi tidak valid'};
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Batch Prediction - Predict multiple items
  static Future<Map<String, dynamic>> batchPrediksi(
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final data = {'items': items};

      final response = await http
          .post(
            Uri.parse('$baseUrl/batch-prediksi'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return _decodeJsonMap(response.body) ??
            {
              'status': 'error',
              'message': 'Respons batch prediksi tidak valid',
            };
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Get API Info
  static Future<Map<String, dynamic>> getInfo() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/info'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return _decodeJsonMap(response.body) ??
            {'status': 'error', 'message': 'Respons info tidak valid'};
      } else {
        return {'status': 'error', 'message': 'Failed to get info'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  // ========================================================================
  // DASHBOARD ENDPOINTS
  // ========================================================================

  /// Ringkasan dashboard: penggunaan bahan
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/dashboard/summary'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return _decodeJsonMap(response.body) ??
            {
              'status': false,
              'message': 'Respons dashboard tidak valid',
              'penggunaan_bahan': [],
            };
      }

      return {
        'status': false,
        'message': 'Server error: ${response.statusCode}',
        'penggunaan_bahan': [],
      };
    } catch (e) {
      return {
        'status': false,
        'message': 'Connection error: $e',
        'penggunaan_bahan': [],
      };
    }
  }

  /// Total bahan keluar yang digunakan hari ini.
  static Future<Map<String, dynamic>> getBahanDigunakanHariIni() async {
    const fallback = {
      'total': 0,
      'satuan': 'kg',
      'keterangan': 'total penggunaan hari ini',
    };

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/dashboard/bahan-digunakan-hari-ini'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = _decodeJsonMap(response.body);
        return data is Map<String, dynamic> ? data : fallback;
      }

      return {
        ...fallback,
        'status': false,
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      return {...fallback, 'status': false, 'message': 'Connection error: $e'};
    }
  }

  // ========================================================================
  // REPORT ENDPOINTS - LAPORAN
  // ========================================================================

  /// Helper GET untuk endpoint laporan (response: {status, message, data})
  static Future<Map<String, dynamic>> _getReport(String path) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$path'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        return _decodeJsonMap(response.body) ??
            {
              'status': false,
              'message': 'Respons laporan tidak valid',
              'data': [],
            };
      }

      print('Report request failed [$path]: ${response.statusCode}');
      return {
        'status': false,
        'message': 'Server error: ${response.statusCode}',
        'data': [],
      };
    } catch (e) {
      print('Report request error [$path]: $e');
      return {'status': false, 'message': 'Connection error: $e', 'data': []};
    }
  }

  /// Laporan stok bahan
  static Future<Map<String, dynamic>> getReportStock() async {
    return _getReport('/laporan/stok');
  }

  /// Riwayat stok masuk
  static Future<Map<String, dynamic>> getReportStockIn() async {
    return _getReport('/laporan/stok-masuk');
  }

  /// Laporan prediksi permintaan
  static Future<Map<String, dynamic>> getReportPredictions() async {
    return _getReport('/laporan/prediksi');
  }

  /// Laporan prediksi hari/tanggal dan bulan ke depan.
  static Future<Map<String, dynamic>> getReportPredictionForecast({
    int days = 7,
    int months = 3,
    int limit = 8,
    DateTime? startDate,
    String? productName,
  }) async {
    final queryParameters = <String, String>{
      'days': days.toString(),
      'months': months.toString(),
      'limit': limit.toString(),
      if (startDate != null)
        'start_date': startDate.toIso8601String().split('T').first,
      if (productName != null && productName.trim().isNotEmpty)
        'product_name': productName.trim(),
    };
    final path =
        Uri(
          path: '/laporan/prediksi-forecast',
          queryParameters: queryParameters,
        ).toString();

    return _getReport(path);
  }

  /// Laporan bahan kritis
  static Future<Map<String, dynamic>> getReportCritical() async {
    return _getReport('/laporan/bahan-kritis');
  }

  // ========================================================================
  // DATABASE ENDPOINTS - PRODUCTS & TRANSACTIONS
  // ========================================================================

  /// Consume stock (batch) after production
  static Future<Map<String, dynamic>> consumeStock({
    required List<Map<String, dynamic>> items,
    String? recipeName,
    int? productionQuantity,
  }) async {
    try {
      final data = {
        'items': items,
        if (recipeName != null) 'recipe_name': recipeName,
        if (productionQuantity != null)
          'production_quantity': productionQuantity,
      };

      print('[consumeStock] Request payload: ${jsonEncode(data)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/stock/consume'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      print('[consumeStock] Response status: ${response.statusCode}');
      print('[consumeStock] Response body: ${response.body}');

      final parsedBody = _decodeJsonMap(response.body);

      if (response.statusCode == 200) {
        return parsedBody is Map<String, dynamic>
            ? parsedBody
            : {'status': 'success'};
      }

      if (parsedBody is Map<String, dynamic>) {
        return parsedBody;
      }

      return {
        'status': 'error',
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      print('Consume stock error: $e');
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Get all products from database
  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = _decodeJsonMap(response.body);
        if (data != null && data['status'] == 'success') {
          final products = data['products'];
          if (products is List) {
            return products
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          }
        }
      }
      print(
        'Get products unexpected response: ${response.statusCode} ${response.body}',
      );
      return [];
    } catch (e) {
      print('Get products error: $e');
      return [];
    }
  }

  /// Create new product in database
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String category,
    required int price,
    required int currentStock,
    double? minStock,
    String? unit,
    String? productType,
  }) async {
    try {
      final data = {
        'name': name,
        'category': category,
        'price': price,
        'current_stock': currentStock,
        if (minStock != null) 'min_stock': minStock,
        if (unit != null) 'unit': unit,
        if (productType != null) 'product_type': productType,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/products'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        return _decodeJsonMap(response.body) ??
            {'status': 'success', 'message': 'Produk berhasil ditambahkan'};
      } else if (response.statusCode == 409) {
        return _decodeJsonMap(response.body) ??
            {'status': 'error', 'message': 'Produk sudah ada'};
      } else if (response.statusCode == 400) {
        final result = _decodeJsonMap(response.body);
        return {
          'status': 'error',
          'message': result?['message'] ?? 'Bad request',
        };
      } else {
        print('Create product error - Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Create product exception: $e');
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Get specific product by ID
  static Future<Map<String, dynamic>?> getProduct(int productId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products/$productId'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = _decodeJsonMap(response.body);
        if (data != null && data['status'] == 'success') {
          return data['product'];
        }
      }
      return null;
    } catch (e) {
      print('Get product error: $e');
      return null;
    }
  }

  /// Update product in database
  static Future<Map<String, dynamic>> updateProduct({
    required int productId,
    String? name,
    String? category,
    int? price,
    double? currentStock,
    double? minStock,
    String? unit,
  }) async {
    try {
      final data = {
        if (name != null) 'name': name,
        if (category != null) 'category': category,
        if (price != null) 'price': price,
        if (currentStock != null) 'current_stock': currentStock,
        if (minStock != null) 'min_stock': minStock,
        if (unit != null) 'unit': unit,
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/products/$productId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      final body = _decodeJsonMap(response.body) ?? <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      return {
        'status': 'error',
        'message': body['message'] ?? 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      print('Update product error: $e');
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Save transaction and update stock automatically
  static Future<Map<String, dynamic>> addTransactionWithStockUpdate({
    required int productId,
    required int quantity,
    required int unitPrice,
    required int totalPrice,
    required String transactionDate, // Format: 'YYYY-MM-DD'
  }) async {
    try {
      final data = {
        'produk_id': productId,
        'jumlah': quantity,
        'unit_price': unitPrice,
        'total_price': totalPrice,
        'transaction_date': transactionDate,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/transaksi'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        final result = _decodeJsonMap(response.body);
        return result ?? {'status': 'success'};
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Add transaction with stock update error: $e');
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Save transaction to database (legacy - without stock update)
  static Future<bool> saveTransaction({
    required String productName,
    required String category,
    required int quantity,
    required int unitPrice,
    required int totalPrice,
    required String transactionDate, // Format: 'YYYY-MM-DD'
  }) async {
    try {
      final data = {
        'product_name': productName,
        'category': category,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': totalPrice,
        'transaction_date': transactionDate,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/transactions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        final result = _decodeJsonMap(response.body);
        return result?['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Save transaction error: $e');
      return false;
    }
  }

  /// Get transaction history from database
  static Future<List<Map<String, dynamic>>> getTransactions({
    int limit = 100,
    int offset = 0,
    String? productName,
  }) async {
    try {
      var url = '$baseUrl/transactions?limit=$limit&offset=$offset';
      if (productName != null && productName.isNotEmpty) {
        url += '&product_name=$productName';
      }

      final response = await http
          .get(Uri.parse(url))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = _decodeJsonMap(response.body);
        if (data != null && data['status'] == 'success') {
          final transactions = data['transactions'];
          if (transactions is List) {
            return transactions
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Get transactions error: $e');
      return [];
    }
  }

  /// Save prediction result to database
  static Future<bool> savePrediction({
    required String productName,
    required String category,
    required int unitPrice,
    required String predictionDate, // Format: 'YYYY-MM-DD'
    required int predictedQuantity,
    double? rawValue,
    int? estimatedTotalPrice,
    String? estimatedNeeds,
    double? accuracyR2,
    double? errorMae,
  }) async {
    try {
      final data = {
        'product_name': productName,
        'category': category,
        'unit_price': unitPrice,
        'prediction_date': predictionDate,
        'predicted_quantity': predictedQuantity,
        if (rawValue != null) 'raw_value': rawValue,
        if (estimatedTotalPrice != null)
          'estimated_total_price': estimatedTotalPrice,
        if (estimatedNeeds != null) 'estimated_needs': estimatedNeeds,
        if (accuracyR2 != null) 'accuracy_r2': accuracyR2,
        if (errorMae != null) 'error_mae': errorMae,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/predictions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 201) {
        final result = _decodeJsonMap(response.body);
        return result?['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Save prediction error: $e');
      return false;
    }
  }

  // ========================================================================
  // RECIPES ENDPOINTS
  // ========================================================================

  /// Get all recipes with ingredients
  static Future<List<Map<String, dynamic>>> getRecipes() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/recipes'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = _decodeJsonMap(response.body);
        if (data != null && data['status'] == 'success') {
          final recipes = data['recipes'];
          if (recipes is List) {
            return recipes
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Get recipes error: $e');
      return [];
    }
  }

  /// Get specific recipe by ID with ingredients
  static Future<Map<String, dynamic>?> getRecipe(int recipeId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/recipes/$recipeId'))
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = _decodeJsonMap(response.body);
        if (data != null && data['status'] == 'success') {
          return data['recipe'];
        }
      }
      return null;
    } catch (e) {
      print('Get recipe error: $e');
      return null;
    }
  }

  /// Create new recipe with ingredients
  static Future<Map<String, dynamic>> createRecipe({
    required String recipeName,
    required String description,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    try {
      final data = {
        'recipe_name': recipeName,
        'description': description,
        'ingredients': ingredients,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/recipes'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      final body = _decodeJsonMap(response.body);
      if (body == null) {
        return {
          'status': 'error',
          'message': 'Server mengembalikan respons bukan JSON.',
        };
      }

      if (response.statusCode == 201) {
        return body;
      }
      return {
        'status': 'error',
        'message': body['message'] ?? 'Gagal membuat resep',
      };
    } catch (e) {
      print('Create resep error: $e');
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Update existing recipe with ingredients
  static Future<Map<String, dynamic>> updateRecipe({
    required int recipeId,
    required String recipeName,
    required String description,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    try {
      final data = {
        'recipe_name': recipeName,
        'description': description,
        'ingredients': ingredients,
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/recipes/$recipeId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: timeoutSeconds));

      final body = _decodeJsonMap(response.body);
      if (body == null) {
        return {
          'status': 'error',
          'message': 'Server mengembalikan respons bukan JSON.',
        };
      }

      if (response.statusCode == 200) {
        return body;
      }
      return {
        'status': 'error',
        'message': body['message'] ?? 'Gagal memperbarui resep',
      };
    } catch (e) {
      print('Update resep error: $e');
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }

  /// Delete recipe
  static Future<Map<String, dynamic>> deleteRecipe(int recipeId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/recipes/$recipeId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: timeoutSeconds));

      final body = _decodeJsonMap(response.body);
      if (body == null) {
        return {
          'status': 'error',
          'message': 'Server mengembalikan respons bukan JSON.',
        };
      }

      if (response.statusCode == 200) {
        return body;
      }
      return {
        'status': 'error',
        'message': body['message'] ?? 'Gagal menghapus resep',
      };
    } catch (e) {
      print('Delete resep error: $e');
      return {'status': 'error', 'message': 'Connection error: $e'};
    }
  }
}
