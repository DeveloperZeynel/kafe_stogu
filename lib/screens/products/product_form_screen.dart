import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/products/category.dart';
import '../../models/products/product.dart';
import '../../models/products/product_unit_type.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductService productService;
  final CategoryService categoryService;

  final Product? product;

  const ProductFormScreen({
    super.key,
    required this.productService,
    required this.categoryService,
    this.product,
  });

  bool get isEditMode => product != null;

  @override
  State<ProductFormScreen> createState() =>
      _ProductFormScreenState();
}

class _ProductFormScreenState
    extends State<ProductFormScreen> {
  late final TextEditingController
      _nameController;

  late final TextEditingController
      _initialStockController;

  late final TextEditingController
      _minimumStockController;

  List<Category> _categories = [];

  Category? _selectedCategory;

  ProductUnitType _selectedUnitType =
      ProductUnitType.piece;

  bool _isLoadingCategories = true;
  bool _isSaving = false;

  String? _categoryError;
  String? _nameError;
  String? _initialStockError;
  String? _minimumStockError;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController =
        TextEditingController(
      text: product?.name ?? '',
    );

    _initialStockController =
        TextEditingController(
      text: product == null
          ? ''
          : _formatNumber(
              product.currentStock,
            ),
    );

    _minimumStockController =
        TextEditingController(
      text: product == null
          ? ''
          : _formatNumber(
              product.minimumStock,
            ),
    );

    if (product != null) {
      _selectedUnitType =
          product.unitType;
    }

    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialStockController.dispose();
    _minimumStockController.dispose();

    super.dispose();
  }

  // =========================================================
  // KATEGORİLER
  // =========================================================

  Future<void> _loadCategories() async {
    try {
      final categories =
          await widget.categoryService
              .getAll();

      if (!mounted) {
        return;
      }

      Category? selected;

      if (widget.product != null) {
        for (final category
            in categories) {
          if (category.id ==
              widget.product!.categoryId) {
            selected = category;
            break;
          }
        }
      }

      setState(() {
        _categories = categories;
        _selectedCategory = selected;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingCategories = false;
      });

      _showError(e);
    }
  }

  // =========================================================
  // KAYDET
  // =========================================================

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    if (!_validate()) {
      return;
    }

    final name =
        _nameController.text.trim();

    final categoryId =
        _selectedCategory!.id;

    final minimumStock =
        _parseNumber(
      _minimumStockController.text,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.isEditMode) {
        await widget.productService.update(
          id: widget.product!.id,
          name: name,
          categoryId: categoryId,
          unitType:
              _selectedUnitType.value,
          minimumStock:
              minimumStock,
        );
      } else {
        final initialStock =
            _parseNumber(
          _initialStockController.text,
        );

        await widget.productService.create(
          name: name,
          categoryId: categoryId,
          unitType:
              _selectedUnitType.value,
          initialStock:
              initialStock,
          minimumStock:
              minimumStock,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      _showError(e);
    }
  }

  // =========================================================
  // VALIDASYON
  // =========================================================

  bool _validate() {
    bool valid = true;

    setState(() {
      _nameError = null;
      _categoryError = null;
      _initialStockError = null;
      _minimumStockError = null;
    });

    if (_nameController.text.trim().isEmpty) {
      _nameError =
          'Ürün adı zorunludur.';
      valid = false;
    }

    if (_selectedCategory == null) {
      _categoryError =
          'Kategori seçiniz.';
      valid = false;
    }

    if (!widget.isEditMode) {
      final text =
          _initialStockController.text
              .trim();

      if (text.isEmpty) {
        _initialStockError =
            'İlk stok zorunludur.';
        valid = false;
      } else {
        final value =
            _parseNumber(text);

        if (value < 0) {
          _initialStockError =
              'Stok negatif olamaz.';
          valid = false;
        }
      }
    }

    final minimumText =
        _minimumStockController.text
            .trim();

    if (minimumText.isEmpty) {
      _minimumStockError =
          'Minimum stok zorunludur.';
      valid = false;
    } else {
      final value =
          _parseNumber(minimumText);

      if (value < 0) {
        _minimumStockError =
            'Minimum stok negatif olamaz.';
        valid = false;
      }
    }

    if (!valid) {
      setState(() {});
    }

    return valid;
  }

  // =========================================================
  // HATA
  // =========================================================

  void _showError(Object error) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        backgroundColor:
            AppColors.danger,
        content: Text(
          _cleanError(error),
        ),
      ),
    );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }

  // =========================================================
  // SAYI
  // =========================================================

  double _parseNumber(String value) {
    return double.tryParse(
          value
              .trim()
              .replaceAll(',', '.'),
        ) ??
        0;
  }

  String _formatNumber(double value) {
    if (value ==
        value.truncateToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceFirst(
          RegExp(r'\.?0+$'),
          '',
        );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final isEdit =
        widget.isEditMode;

    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        title: Text(
          isEdit
              ? 'Ürünü Düzenle'
              : 'Yeni Ürün',
        ),
      ),

      body: SafeArea(
        child: _isLoadingCategories
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      AppColors.primary,
                ),
              )
            : _buildForm(),
      ),
    );
  }

  // =========================================================
  // FORM
  // =========================================================

  Widget _buildForm() {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        32,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(
            height: 18,
          ),

          _buildNameField(),

          const SizedBox(
            height: 14,
          ),

          _buildCategoryField(),

          const SizedBox(
            height: 14,
          ),

          _buildUnitTypeField(),

          const SizedBox(
            height: 14,
          ),

          if (!widget.isEditMode) ...[
            _buildInitialStockField(),

            const SizedBox(
              height: 14,
            ),
          ],

          _buildMinimumStockField(),

          const SizedBox(
            height: 26,
          ),

          _buildSaveButton(),
        ],
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Card(
      elevation: 0,
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color:
                    AppColors.primary,
                size: 28,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEditMode
                        ? 'Ürün Bilgilerini Düzenle'
                        : 'Yeni Ürün Oluştur',
                    style:
                        const TextStyle(
                      color:
                          AppColors.textPrimary,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    widget.isEditMode
                        ? 'Ürün bilgilerini güncelleyebilirsiniz.'
                        : 'Stoğa yeni bir ürün ekleyin.',
                    style:
                        const TextStyle(
                      color:
                          AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ÜRÜN ADI
  // =========================================================

  Widget _buildNameField() {
    return TextField(
      controller:
          _nameController,
      textCapitalization:
          TextCapitalization.sentences,
      enabled: !_isSaving,
      decoration:
          InputDecoration(
        labelText:
            'Ürün adı',
        hintText:
            'Örn. Espresso Kahve',
        prefixIcon:
            const Icon(
          Icons.inventory_2_outlined,
        ),
        errorText:
            _nameError,
      ),
      onChanged: (_) {
        if (_nameError != null) {
          setState(() {
            _nameError = null;
          });
        }
      },
    );
  }

  // =========================================================
  // KATEGORİ
  // =========================================================

  Widget _buildCategoryField() {
    return DropdownButtonFormField<int>(
      initialValue:
          _selectedCategory?.id,
      isExpanded: true,
      decoration:
          InputDecoration(
        labelText:
            'Kategori',
        prefixIcon:
            const Icon(
          Icons.category_outlined,
        ),
        errorText:
            _categoryError,
      ),
      items:
          _categories.map(
        (category) {
          return DropdownMenuItem<int>(
            value:
                category.id,
            child:
                Text(
              category.name,
              overflow:
                  TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged:
          _isSaving
              ? null
              : (value) {
                  if (value == null) {
                    return;
                  }

                  Category? category;

                  for (final item
                      in _categories) {
                    if (item.id ==
                        value) {
                      category = item;
                      break;
                    }
                  }

                  setState(() {
                    _selectedCategory =
                        category;
                    _categoryError =
                        null;
                  });
                },
    );
  }

  // =========================================================
  // BİRİM TİPİ
  // =========================================================

  Widget _buildUnitTypeField() {
    return Card(
      elevation: 0,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Birim tipi',
              style:
                  TextStyle(
                color:
                    AppColors.textPrimary,
                fontSize: 15,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      _UnitTypeOption(
                    type:
                        ProductUnitType
                            .piece,
                    selected:
                        _selectedUnitType ==
                            ProductUnitType
                                .piece,
                    enabled:
                        !_isSaving,
                    onTap: () {
                      setState(() {
                        _selectedUnitType =
                            ProductUnitType
                                .piece;
                      });
                    },
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child:
                      _UnitTypeOption(
                    type:
                        ProductUnitType
                            .box,
                    selected:
                        _selectedUnitType ==
                            ProductUnitType
                                .box,
                    enabled:
                        !_isSaving,
                    onTap: () {
                      setState(() {
                        _selectedUnitType =
                            ProductUnitType
                                .box;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // İLK STOK
  // =========================================================

  Widget _buildInitialStockField() {
    return TextField(
      controller:
          _initialStockController,
      enabled: !_isSaving,
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration:
          InputDecoration(
        labelText:
            'İlk stok',
        hintText:
            'Örn. 10',
        prefixIcon:
            const Icon(
          Icons.add_box_outlined,
        ),
        suffixText:
            _selectedUnitType.label,
        errorText:
            _initialStockError,
      ),
      onChanged: (_) {
        if (_initialStockError !=
            null) {
          setState(() {
            _initialStockError =
                null;
          });
        }
      },
    );
  }

  // =========================================================
  // MİNİMUM STOK
  // =========================================================

  Widget _buildMinimumStockField() {
    return TextField(
      controller:
          _minimumStockController,
      enabled: !_isSaving,
      keyboardType:
          const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration:
          InputDecoration(
        labelText:
            'Minimum stok',
        hintText:
            'Örn. 5',
        prefixIcon:
            const Icon(
          Icons.warning_amber_outlined,
        ),
        suffixText:
            _selectedUnitType.label,
        errorText:
            _minimumStockError,
      ),
      onChanged: (_) {
        if (_minimumStockError !=
            null) {
          setState(() {
            _minimumStockError =
                null;
          });
        }
      },
    );
  }

  // =========================================================
  // KAYDET BUTONU
  // =========================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child:
          FilledButton.icon(
        style:
            FilledButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
        ),
        onPressed:
            _isSaving
                ? null
                : _save,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                      Colors.white,
                ),
              )
            : Icon(
                widget.isEditMode
                    ? Icons.save_outlined
                    : Icons.add,
              ),
        label:
            Text(
          _isSaving
              ? 'Kaydediliyor...'
              : widget.isEditMode
                  ? 'Değişiklikleri Kaydet'
                  : 'Ürünü Ekle',
        ),
      ),
    );
  }
}

// =============================================================
// BİRİM TİPİ SEÇENEĞİ
// =============================================================

class _UnitTypeOption
    extends StatelessWidget {
  final ProductUnitType type;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _UnitTypeOption({
    required this.type,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(14),
      onTap:
          enabled
              ? onTap
              : null,
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),
        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? AppColors.primary
                  .withValues(
                alpha: 0.10,
              )
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          border:
              Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey.shade300,
            width:
                selected
                    ? 1.5
                    : 1,
          ),
        ),
        child:
            Row(
          children: [
            Icon(
              type ==
                      ProductUnitType
                          .piece
                  ? Icons
                      .format_list_numbered
                  : Icons
                      .inventory_2_outlined,
              color:
                  selected
                      ? AppColors.primary
                      : AppColors
                          .textSecondary,
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child:
                  Text(
                type.label,
                style:
                    TextStyle(
                  color: selected
                      ? AppColors
                          .primary
                      : AppColors
                          .textPrimary,
                  fontWeight:
                      selected
                          ? FontWeight
                              .w700
                          : FontWeight
                              .w500,
                ),
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle,
                color:
                    AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}