import 'package:flutter/material.dart';

import 'prediction_controller.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  late final PredictionController _controller;
  final TextEditingController _productionController = TextEditingController();
  bool _showAcademicDetails = false;

  @override
  void initState() {
    super.initState();
    _controller = PredictionController();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final error = await _controller.loadRecipes();
    if (!mounted || error == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _refreshRecipes() {
    return _loadRecipes();
  }

  Future<void> _submitProduction() async {
    if (_controller.isSubmitting) return;
    final result = await _controller.submitProduction();
    if (!mounted) return;

    if (result['status'] == 'success') {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Produksi Berhasil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Stok bahan sudah diperbarui sesuai produksi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA89080),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sukses',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      await _controller.refreshStock();
      _controller.reset();
      _productionController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal submit')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final selectedRecipe = _controller.selectedRecipe;
        final displayIngredients =
            selectedRecipe == null
                ? <String, Map<String, dynamic>>{}
                : (_controller.recipeIngredients[selectedRecipe] ??
                    <String, Map<String, dynamic>>{});
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(200),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFA89080),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prediksi Kebutuhan Bahan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Kalkulasi bahan berdasarkan rencana produksi',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              tooltip: 'Refresh',
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _refreshRecipes,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.calculate,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sistem Kalkulasi Otomatis',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Pilih produk dan jumlah untuk lihat kebutuhan bahan',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _refreshRecipes,
            color: const Color(0xFFA89080),
            child:
                _controller.isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Memuat resep...'),
                        ],
                      ),
                    )
                    : _controller.recipes.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(height: 16),
                          const Text('Gagal memuat resep'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadRecipes,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                    : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Rencana Produksi',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Pilih Produk',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(0xFFE5E7EB),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value:
                                                    _controller.selectedRecipe,
                                                hint: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                                  child: Text(
                                                    '-- Pilih Produk --',
                                                    style: TextStyle(
                                                      color: Color(0xFF9CA3AF),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                isExpanded: true,
                                                icon: const Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 12,
                                                  ),
                                                  child: Icon(
                                                    Icons.expand_more,
                                                    color: Color(0xFF9CA3AF),
                                                  ),
                                                ),
                                                items:
                                                    _controller.recipes
                                                        .map(
                                                          (
                                                            recipe,
                                                          ) => DropdownMenuItem<
                                                            String
                                                          >(
                                                            value:
                                                                recipe['recipe_name']
                                                                    as String,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                  ),
                                                              child: Text(
                                                                recipe['recipe_name']
                                                                    as String,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                onChanged:
                                                    _controller
                                                        .setSelectedRecipe,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Jumlah Produksi Manual (opsional)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextField(
                                            controller: _productionController,
                                            keyboardType: TextInputType.number,
                                            onChanged:
                                                _controller
                                                    .setProductionQuantity,
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              hintStyle: const TextStyle(
                                                color: Color(0xFF9CA3AF),
                                              ),
                                              suffixText: 'pcs',
                                              suffixStyle: const TextStyle(
                                                color: Color(0xFF9CA3AF),
                                                fontSize: 12,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFE5E7EB),
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFE5E7EB),
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 12,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'Kosongkan untuk memakai hasil prediksi Random Forest.',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed:
                                                  _controller.canCalculate
                                                      ? () async {
                                                        final error =
                                                            await _controller
                                                                .calculate();
                                                        _productionController
                                                            .text = _controller
                                                                .productionQuantity
                                                                .toString();
                                                        if (!context.mounted ||
                                                            error == null) {
                                                          return;
                                                        }

                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              error,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      : null,
                                              icon:
                                                  _controller.isPredicting
                                                      ? const SizedBox(
                                                        width: 18,
                                                        height: 18,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                        ),
                                                      )
                                                      : const Icon(
                                                        Icons.auto_graph,
                                                        size: 18,
                                                      ),
                                              label: Text(
                                                _controller.isPredicting
                                                    ? 'Memprediksi...'
                                                    : 'Prediksi Random Forest',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFA89080,
                                                ),
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          OutlinedButton(
                                            onPressed: () {
                                              _controller.reset();
                                              _productionController.clear();
                                            },
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: const Text(
                                              'Reset',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1F2937),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (_controller.isCalculated) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFA89080,
                                      ).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFA89080,
                                        ).withOpacity(0.25),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFA89080,
                                                ).withOpacity(0.18),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.auto_graph,
                                                color: Color(0xFFA89080),
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Hasil Prediksi Random Forest',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF1F2937),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Bahan acuan: ${_controller.cleanIngredientName(_controller.predictionModelProduct ?? '-')}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _PredictionMetric(
                                                label: 'Permintaan',
                                                value:
                                                    '${_controller.predictedDemand ?? 0}',
                                                infoTitle: 'Permintaan (Prediksi)',
                                                infoText:
                                                    'Perkiraan jumlah produk yang akan dibeli pelanggan berdasarkan riwayat penjualan toko.',
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _PredictionMetric(
                                                label: 'Produksi',
                                                value:
                                                    '${_controller.productionQuantity} pcs',
                                                infoTitle: 'Jumlah Produksi',
                                                infoText:
                                                    'Banyaknya produk yang akan Anda buat. Jumlah ini bisa disesuaikan secara manual di bagian atas.',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _PredictionMetric(
                                                label: 'R2',
                                                value:
                                                    _controller.predictionR2 ==
                                                            null
                                                        ? '-'
                                                        : _controller
                                                            .predictionR2!
                                                            .toStringAsFixed(4),
                                                infoTitle: 'Akurasi Model (R²)',
                                                infoText:
                                                    'Mengukur seberapa pintar model membaca pola penjualan Anda.\n\n'
                                                    '• Semakin mendekati 1, tebakan model semakin tepat.\n'
                                                    '• Nilai rendah/negatif berarti pola penjualan sangat fluktuatif.\n\n'
                                                    'Standar Acuan Prediksi Baik:\n'
                                                    '• Sangat Baik: 0.70 s/d 1.00\n'
                                                    '• Cukup Baik: 0.50 s/d 0.69\n'
                                                    '• Kurang Baik: Di bawah 0.50',
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: _PredictionMetric(
                                                label: 'MAE',
                                                value:
                                                    _controller.predictionMae ==
                                                            null
                                                        ? '-'
                                                        : _controller
                                                            .predictionMae!
                                                            .toStringAsFixed(2),
                                                infoTitle: 'Potensi Meleset (MAE)',
                                                infoText:
                                                    'Rata-rata selisih antara hasil prediksi dengan kenyataan penjualan.\n\n'
                                                    '• Menunjukkan rata-rata seberapa jauh tebakan model bisa meleset.\n'
                                                    '• Semakin kecil nilai MAE, tebakan model semakin akurat.\n\n'
                                                    'Standar Acuan Prediksi Baik:\n'
                                                    '• Semakin dekat ke 0 semakin akurat.\n'
                                                    '• Baik/Akurat jika MAE ≤ 2.0 unit (atau di bawah 20% dari rata-rata penjualan).',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Builder(
                                          builder: (context) {
                                            final r2 = _controller.predictionR2;
                                            final mae = _controller.predictionMae;

                                            String statusTitle = 'Belum Dihitung';
                                            String description = 'Silakan pilih resep dan lakukan perhitungan prediksi terlebih dahulu.';
                                            Color badgeColor = Colors.grey;
                                            IconData statusIcon = Icons.info_outline;

                                            if (r2 != null && mae != null) {
                                              if (r2 >= 0.70) {
                                                statusTitle = 'Tinggi (Sangat Akurat) ✨';
                                                description = 'Pola penjualan kue ini sangat stabil dan konsisten. Prediksi ini sangat aman untuk diikuti sepenuhnya dalam merencanakan stok produksi Anda.';
                                                badgeColor = const Color(0xFF4CAF50); // statusSuccess / green
                                                statusIcon = Icons.check_circle_outline;
                                              } else if (r2 >= 0.50) {
                                                statusTitle = 'Sedang (Cukup Akurat) 👍';
                                                description = 'Pola penjualan cukup stabil. Prediksi ini cukup aman diikuti, dengan perkiraan tebakan bisa meleset sedikit sekitar ±${mae.toStringAsFixed(1)} unit.';
                                                badgeColor = const Color(0xFF2196F3); // secondaryBlue / blue
                                                statusIcon = Icons.info_outline_rounded;
                                              } else {
                                                statusTitle = 'Perlu Hati-Hati ⚠️';
                                                description = 'Pola penjualan bahan ini naik-turun secara drastis (tidak menentu). Jadikan prediksi ini acuan kasar saja, dan sesuaikan produksi dengan rata-rata penjualan harian atau kondisi nyata toko.';
                                                badgeColor = const Color(0xFFFF9800); // statusWarning / orange
                                                statusIcon = Icons.warning_amber_rounded;
                                              }
                                            }

                                            return Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.65),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: const Color(0xFFA89080).withValues(alpha: 0.2),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Title row
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        statusIcon,
                                                        size: 16,
                                                        color: badgeColor,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      const Expanded(
                                                        child: Text(
                                                          'Tingkat Kepercayaan Prediksi:',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w700,
                                                            color: Color(0xFF2C1810), // textPrimary
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  // Status Badge
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: badgeColor.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      statusTitle,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: badgeColor,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Description
                                                  Text(
                                                    description,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFF4B5563),
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  const Divider(height: 1, color: Color(0xFFE8DDD5)), // grey200
                                                  const SizedBox(height: 8),
                                                  // Accordion toggle button
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _showAcademicDetails = !_showAcademicDetails;
                                                      });
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        const Text(
                                                          'Lihat Detail Parameter Akademis (Dosen)',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w600,
                                                            color: Color(0xFF8B6E58), // primaryBrown
                                                            decoration: TextDecoration.underline,
                                                          ),
                                                        ),
                                                        Icon(
                                                          _showAcademicDetails
                                                              ? Icons.keyboard_arrow_up
                                                              : Icons.keyboard_arrow_down,
                                                          size: 14,
                                                          color: const Color(0xFF8B6E58), // primaryBrown
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (_showAcademicDetails) ...[
                                                    const SizedBox(height: 8),
                                                    Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF5EFE8).withValues(alpha: 0.5), // grey100
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        '• Akurasi Model (R²): ${r2 == null ? '-' : r2.toStringAsFixed(4)} (${r2 == null ? 'Belum dihitung' : r2 >= 0.7 ? 'Sangat Baik, target ≥ 0.50' : r2 >= 0.5 ? 'Cukup Baik, target ≥ 0.50' : 'Kurang Baik, target ≥ 0.50'})\n'
                                                        '• Potensi Meleset (MAE): ${mae == null ? '-' : '±${mae.toStringAsFixed(1)} unit'} (${mae == null ? 'Belum dihitung' : mae <= 2.0 ? 'Sangat Akurat, target ≤ 2.0' : 'Kurang Akurat, target ≤ 2.0'})',
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Color(0xFF6B5040), // textSecondary
                                                          height: 1.4,
                                                          fontFamily: 'monospace',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color:
                                          _controller.isStockSufficient
                                              ? const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.1)
                                              : const Color(
                                                0xFFDC2626,
                                              ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color:
                                            _controller.isStockSufficient
                                                ? const Color(
                                                  0xFF10B981,
                                                ).withOpacity(0.3)
                                                : const Color(
                                                  0xFFDC2626,
                                                ).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color:
                                                _controller.isStockSufficient
                                                    ? const Color(
                                                      0xFF10B981,
                                                    ).withOpacity(0.2)
                                                    : const Color(
                                                      0xFFDC2626,
                                                    ).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            _controller.isStockSufficient
                                                ? Icons.check_circle
                                                : Icons.warning_amber,
                                            color:
                                                _controller.isStockSufficient
                                                    ? const Color(0xFF10B981)
                                                    : const Color(0xFFDC2626),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _controller.isStockSufficient
                                                    ? 'Stok Cukup'
                                                    : 'Stok Belum Cukup',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      _controller
                                                              .isStockSufficient
                                                          ? const Color(
                                                            0xFF10B981,
                                                          )
                                                          : const Color(
                                                            0xFFDC2626,
                                                          ),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _controller.isStockSufficient
                                                    ? 'Semua bahan tersedia untuk produksi'
                                                    : 'Ada bahan yang perlu ditambah',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Kebutuhan Bahan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (displayIngredients.isEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'Belum ada bahan untuk produk ini.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children:
                                            displayIngredients.entries.toList().asMap().entries.map((
                                              entry,
                                            ) {
                                              final isLast =
                                                  entry.key ==
                                                  displayIngredients.length - 1;
                                              final ingredient =
                                                  entry.value.key;
                                              final details = entry.value.value;
                                              final isSelected = _controller
                                                  .isIngredientSelected(
                                                    ingredient,
                                                  );
                                              final quantityPerUnit =
                                                  (details['quantity'] as num)
                                                      .toDouble();
                                              final neededAmount =
                                                  isSelected
                                                      ? quantityPerUnit *
                                                          _controller
                                                              .productionQuantity
                                                      : 0.0;
                                              final currentStockValue =
                                                  _controller
                                                      .getCurrentStock(
                                                        ingredient,
                                                      );
                                              final requiredInStockUnit =
                                                  _controller
                                                      .getRequiredInStockUnit(
                                                        ingredient,
                                                      );
                                              final isSufficient =
                                                  currentStockValue >=
                                                  requiredInStockUnit;
                                              final statusColor =
                                                  isSelected
                                                      ? (isSufficient
                                                          ? const Color(
                                                            0xFF10B981,
                                                          )
                                                          : const Color(
                                                            0xFFDC2626,
                                                          ))
                                                      : const Color(0xFF9CA3AF);
                                              final statusLabel =
                                                  isSelected
                                                      ? (isSufficient
                                                          ? 'Aman'
                                                          : 'Kurang')
                                                      : 'Diabaikan';

                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          14,
                                                        ),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Checkbox(
                                                              value: isSelected,
                                                              onChanged: (
                                                                value,
                                                              ) {
                                                                _controller
                                                                    .setIngredientSelection(
                                                                      ingredient,
                                                                      value ??
                                                                          false,
                                                                    );
                                                              },
                                                              activeColor:
                                                                  const Color(
                                                                    0xFFA89080,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    _controller
                                                                        .cleanIngredientName(
                                                                          ingredient,
                                                                        ),
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Color(
                                                                        0xFF1F2937,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 6,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            const Text(
                                                                              'Kebutuhan',
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    11,
                                                                                color: Color(
                                                                                  0xFF9CA3AF,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              isSelected
                                                                                  ? _controller.formatRequiredQuantity(
                                                                                    ingredient,
                                                                                    neededAmount,
                                                                                  )
                                                                                  : '-',
                                                                              style: const TextStyle(
                                                                                fontSize:
                                                                                    12,
                                                                                fontWeight:
                                                                                    FontWeight.w700,
                                                                                color: Color(
                                                                                  0xFF1F2937,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            const Text(
                                                                              'Stok Saat Ini',
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    11,
                                                                                color: Color(
                                                                                  0xFF9CA3AF,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              _controller.formatStockQuantity(
                                                                                ingredient,
                                                                                currentStockValue,
                                                                              ),
                                                                              style: const TextStyle(
                                                                                fontSize:
                                                                                    12,
                                                                                fontWeight:
                                                                                    FontWeight.w700,
                                                                                color: Color(
                                                                                  0xFF1F2937,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical: 6,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: statusColor
                                                                    .withOpacity(
                                                                      0.15,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                                border: Border.all(
                                                                  color: statusColor
                                                                      .withOpacity(
                                                                        0.3,
                                                                      ),
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              child: Text(
                                                                statusLabel,
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color:
                                                                      statusColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (!isLast)
                                                    Container(
                                                      height: 1,
                                                      color: const Color(
                                                        0xFFF3F4F6,
                                                      ),
                                                    ),
                                                ],
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  if (_controller.stockUsage.isNotEmpty) ...[
                                    const Text(
                                      'Ringkasan Pengurangan Stok',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children:
                                            _controller.stockUsage.entries.map((
                                              entry,
                                            ) {
                                              final ingredient = entry.key;
                                              final amount = entry.value;
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _controller
                                                            .cleanIngredientName(
                                                              ingredient,
                                                            ),
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                            0xFF1F2937,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '-${_controller.formatStockQuantity(ingredient, amount)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Color(
                                                          0xFFDC2626,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            _controller.isSubmitting
                                                ? null
                                                : _submitProduction,
                                        icon:
                                            _controller.isSubmitting
                                                ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                                : const Icon(
                                                  Icons.check_circle,
                                                ),
                                        label: Text(
                                          _controller.isSubmitting
                                              ? 'Memproses...'
                                              : 'Submit Produksi',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF10B981,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  if (!_controller.isStockSufficient) ...[
                                    const Text(
                                      'Rekomendasi Penambahan Stok',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFDC2626,
                                        ).withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(
                                            0xFFDC2626,
                                          ).withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            _controller.insufficientStock.entries.map((
                                              entry,
                                            ) {
                                              final ingredient = entry.key;
                                              final deficitAmount = entry.value;
                                              final unit = _controller
                                                  .getStockUnit(ingredient);

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _controller
                                                            .cleanIngredientName(
                                                              ingredient,
                                                            ),
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Color(
                                                            0xFF1F2937,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFDC2626,
                                                        ).withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '+${_controller.formatQuantity(deficitAmount)} $unit',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                            0xFFDC2626,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ],
                                ] else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Column(
                                      children: [
                                        _EmptyCalcIcon(),
                                        SizedBox(height: 16),
                                        Text(
                                          'Belum Ada Kalkulasi',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Pilih produk dan masukkan jumlah produksi untuk melihat kebutuhan bahan',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF9CA3AF),
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 3,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.popUntil(context, (route) => route.isFirst);
                  break;
                case 1:
                  Navigator.pushNamed(context, '/products');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/transaction');
                  break;
                case 4:
                  Navigator.pushNamed(context, '/reports');
                  break;
                case 5:
                  Navigator.pushNamed(context, '/settings');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                label: 'Produk',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                label: 'Stok Masuk',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.trending_up_outlined),
                label: 'Prediksi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined),
                label: 'Laporan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: 'Pengaturan',
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _productionController.dispose();
    _controller.dispose();
    super.dispose();
  }
}

class _PredictionMetric extends StatelessWidget {
  const _PredictionMetric({
    required this.label,
    required this.value,
    this.infoTitle,
    this.infoText,
  });

  final String label;
  final String value;
  final String? infoTitle;
  final String? infoText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
              if (infoText != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA89080).withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.info_outline_rounded,
                                        color: Color(0xFFA89080),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        infoTitle ?? label,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  infoText!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4B5563),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFA89080),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text(
                                      'Mengerti',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 6, bottom: 4, top: 4),
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 13,
                      color: Color(0xFFA89080),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCalcIcon extends StatelessWidget {
  const _EmptyCalcIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF9CA3AF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.calculate, color: Color(0xFF9CA3AF), size: 32),
      ),
    );
  }
}
