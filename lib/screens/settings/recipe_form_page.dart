import 'package:finalproject/services/ml_service.dart';
import 'package:finalproject/theme/colors.dart';
import 'package:finalproject/theme/text_styles.dart';
import 'package:flutter/material.dart';

class RecipeFormPage extends StatefulWidget {
  const RecipeFormPage({super.key});

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipeNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _ingredients = [];
  List<Map<String, dynamic>> _availableProducts = [];
  bool _isLoadingProducts = true;
  bool _isSaving = false;
  int? _editingRecipeId;

  @override
  void initState() {
    super.initState();
    _loadAvailableProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    if (rawArgs is Map && _editingRecipeId == null) {
      final args = Map<String, dynamic>.from(rawArgs);
      _editingRecipeId = args['id'] as int?;
      _recipeNameController.text = args['recipe_name']?.toString() ?? '';
      _descriptionController.text = args['description']?.toString() ?? '';

      final rawIngredients = args['ingredients'] as List? ?? [];
      _ingredients = rawIngredients.map((item) {
        if (item is Map) {
          final itemMap = Map<String, dynamic>.from(item);
          return <String, dynamic>{
            'product_name': itemMap['product_name']?.toString() ?? '',
            'quantity_needed': (itemMap['quantity_needed'] as num?)?.toDouble() ?? 0.0,
            'unit': itemMap['unit']?.toString() ?? 'gr',
          };
        }
        return <String, dynamic>{
          'product_name': '',
          'quantity_needed': 0.0,
          'unit': 'gr',
        };
      }).toList();
    }
  }

  Future<void> _loadAvailableProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final fetchedProducts = await MLService.getProducts();
      setState(() {
        _availableProducts = fetchedProducts;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      _showMessage('Gagal memuat bahan baku: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.statusError : AppColors.primaryBrown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addIngredientRow() {
    setState(() {
      _ingredients.add(<String, dynamic>{
        'product_name': '',
        'quantity_needed': 0.0,
        'unit': 'gr',
      });
    });
  }

  void _removeIngredientRow(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_ingredients.isEmpty) {
      _showMessage('Resep harus memiliki minimal 1 bahan baku', isError: true);
      return;
    }

    // Validate that all ingredients have selected product names and positive quantities
    for (int i = 0; i < _ingredients.length; i++) {
      final name = _ingredients[i]['product_name']?.toString() ?? '';
      final qty = _ingredients[i]['quantity_needed'] as double?;

      if (name.isEmpty) {
        _showMessage('Harap pilih produk/bahan untuk baris ke-${i + 1}', isError: true);
        return;
      }

      if (qty == null || qty <= 0) {
        _showMessage('Jumlah kuantitas untuk $name harus lebih besar dari 0', isError: true);
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    final recipeName = _recipeNameController.text.trim();
    final description = _descriptionController.text.trim();

    try {
      Map<String, dynamic> result;
      if (_editingRecipeId != null) {
        // Edit Mode
        result = await MLService.updateRecipe(
          recipeId: _editingRecipeId!,
          recipeName: recipeName,
          description: description,
          ingredients: _ingredients,
        );
      } else {
        // Create Mode
        result = await MLService.createRecipe(
          recipeName: recipeName,
          description: description,
          ingredients: _ingredients,
        );
      }

      setState(() {
        _isSaving = false;
      });

      if (result['status'] == 'success') {
        _showMessage('Resep berhasil disimpan');
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showMessage(result['message'] ?? 'Gagal menyimpan resep', isError: true);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showMessage('Terjadi kesalahan: $e', isError: true);
    }
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = _editingRecipeId != null;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBrown,
        elevation: 0,
        title: Text(
          isEditMode ? 'Ubah Resep' : 'Tambah Resep',
          style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
        ),
      ),
      body: _isLoadingProducts
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBrown,
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildGeneralInfoCard(),
                  const SizedBox(height: 24),
                  _buildIngredientsHeader(),
                  const SizedBox(height: 12),
                  _buildIngredientsList(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _buildGeneralInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.white,
      shadowColor: AppColors.grey200,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Umum Resep',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipeNameController,
              decoration: InputDecoration(
                labelText: 'Nama Kue / Resep',
                hintText: 'Masukkan nama kue (misal: Kue Tart Keju)',
                labelStyle: const TextStyle(color: AppColors.primaryBrown),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBrown, width: 2),
                ),
                prefixIcon: const Icon(Icons.cookie, color: AppColors.primaryBrown),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama kue tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Deskripsi / Keterangan',
                hintText: 'Keterangan resep singkat...',
                labelStyle: const TextStyle(color: AppColors.primaryBrown),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBrown, width: 2),
                ),
                prefixIcon: const Icon(Icons.description_outlined, color: AppColors.primaryBrown),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Komposisi Bahan Kue',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: _addIngredientRow,
          icon: const Icon(Icons.add, color: AppColors.primaryBrown),
          label: const Text(
            'Tambah Bahan',
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsList() {
    if (_ingredients.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          children: [
            Icon(Icons.layers_clear_outlined, size: 48, color: AppColors.grey400),
            const SizedBox(height: 12),
            Text(
              'Belum ada bahan ditambahkan',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Ketuk "Tambah Bahan" untuk menentukan komposisi kue.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = _ingredients[index];
        final selectedProductName = ingredient['product_name']?.toString() ?? '';
        final qty = ingredient['quantity_needed'];
        final unit = ingredient['unit']?.toString() ?? 'gr';

        return Card(
          key: ValueKey('ing_$index'),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.grey200),
          ),
          elevation: 0,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedProductName.isNotEmpty ? selectedProductName : null,
                    decoration: InputDecoration(
                      labelText: 'Pilih Bahan',
                      labelStyle: const TextStyle(fontSize: 12, color: AppColors.primaryBrown),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _availableProducts.map((prod) {
                      final name = prod['name']?.toString() ?? '';
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      // Find the selected product unit
                      final matchingProduct = _availableProducts.firstWhere(
                        (prod) => prod['name'] == val,
                        orElse: () => <String, dynamic>{},
                      );
                      final prodUnit = matchingProduct['unit']?.toString() ?? 'gr';

                      setState(() {
                        _ingredients[index]['product_name'] = val;
                        _ingredients[index]['unit'] = prodUnit;
                      });
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Pilih bahan';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: qty > 0.0 ? (qty % 1 == 0 ? qty.toInt().toString() : qty.toString()) : '',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Jumlah',
                      suffixText: unit,
                      suffixStyle: const TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.bold),
                      labelStyle: const TextStyle(fontSize: 12, color: AppColors.primaryBrown),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) {
                      final parsedQty = double.tryParse(val) ?? 0.0;
                      _ingredients[index]['quantity_needed'] = parsedQty;
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Jumlah';
                      }
                      final parsed = double.tryParse(val);
                      if (parsed == null || parsed <= 0) {
                        return '> 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.statusError),
                  onPressed: () => _removeIngredientRow(index),
                  tooltip: 'Hapus baris bahan',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveRecipe,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBrown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Simpan Resep',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
