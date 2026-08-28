import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/products/product.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import 'product_form_screen.dart';
import 'product_stock_movements_screen.dart';
import 'product_stock_operations_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final ProductService productService;
  final CategoryService categoryService;
  final bool isAdmin;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.productService,
    required this.categoryService,
    required this.isAdmin,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  late Product _product;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _product = widget.product;
  }

  // =========================================================
  // ÜRÜNÜ YENİLE
  // =========================================================

  Future<void> _refreshProduct() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product =
          await widget.productService.getById(
        _product.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showError(e);
    }
  }

  // =========================================================
  // ÜRÜN DÜZENLE
  // =========================================================

  Future<void> _openEditForm() async {
    if (!widget.isAdmin) {
      return;
    }

    final result =
        await Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        builder: (_) =>
            ProductFormScreen(
          productService:
              widget.productService,
          categoryService:
              widget.categoryService,
          product: _product,
        ),
      ),
    );

    if (result == true &&
        mounted) {
      await _refreshProduct();
    }
  }

  // =========================================================
  // ÜRÜN SİL
  // =========================================================

  Future<void> _deleteProduct() async {
    if (!widget.isAdmin ||
        _isLoading) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Ürünü Sil',
          ),
          content: Text(
            '"${_product.name}" ürününü silmek istediğinize emin misiniz?\n\n'
            'Ürün pasifleştirilecek ve stok geçmişi korunacaktır.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Vazgeç',
              ),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    AppColors.danger,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Sil',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.productService.delete(
        _product.id,
      );

      if (!mounted) {
        return;
      }

      // ProductsScreen tarafındaki
      // result == true kontrolünün
      // listeyi yenilemesini sağlıyoruz.
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      _showError(e);
    }
  }

  // =========================================================
  // STOK İŞLEMLERİ
  // =========================================================

  Future<void>
      _openStockOperations() async {
    final result =
        await Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        builder: (_) =>
            ProductStockOperationsScreen(
          product: _product,
          productService:
              widget.productService,
        ),
      ),
    );

    if (result == true &&
        mounted) {
      await _refreshProduct();
    }
  }

  // =========================================================
  // STOK HAREKETLERİ
  // =========================================================

  Future<void>
      _openStockMovements() async {
    await Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        builder: (_) =>
            ProductStockMovementsScreen(
          product: _product,
          productService:
              widget.productService,
        ),
      ),
    );
  }

  // =========================================================
  // HATA
  // =========================================================

  void _showError(
    Object error,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        backgroundColor:
            AppColors.danger,
        content: Text(
          _cleanError(error),
        ),
      ),
    );
  }

  String _cleanError(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
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
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,

        title: Text(
          _product.name,
        ),

        actions: [
          // ===================================================
          // ADMIN ÜRÜN İŞLEMLERİ
          // ===================================================

          if (widget.isAdmin)
            PopupMenuButton<String>(
              tooltip:
                  'Ürün işlemleri',
              enabled:
                  !_isLoading,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _openEditForm();
                    break;

                  case 'delete':
                    _deleteProduct();
                    break;
                }
              },
              itemBuilder:
                  (context) {
                return const [
                  PopupMenuItem<String>(
                    value:
                        'edit',
                    child:
                        ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      leading:
                          Icon(
                        Icons
                            .edit_outlined,
                      ),
                      title:
                          Text(
                        'Düzenle',
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value:
                        'delete',
                    child:
                        ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      leading:
                          Icon(
                        Icons
                            .delete_outline,
                        color:
                            AppColors
                                .danger,
                      ),
                      title:
                          Text(
                        'Ürünü Sil',
                        style:
                            TextStyle(
                          color:
                              AppColors
                                  .danger,
                        ),
                      ),
                    ),
                  ),
                ];
              },
            ),

          // ===================================================
          // YENİLE
          // ===================================================

          IconButton(
            tooltip:
                'Yenile',
            onPressed:
                _isLoading
                    ? null
                    : _refreshProduct,
            icon:
                _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.refresh,
                      ),
          ),
        ],
      ),

      // =======================================================
      // BODY
      // =======================================================

      body: SafeArea(
        child:
            RefreshIndicator(
          color:
              AppColors.primary,
          onRefresh:
              _refreshProduct,

          child:
              ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),

            padding:
                const EdgeInsets.all(
              16,
            ),

            children: [
              _buildProductHeader(),

              const SizedBox(
                height: 20,
              ),

              _buildStockSummary(),

              const SizedBox(
                height: 24,
              ),

              const Text(
                'İşlemler',
                style:
                    TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              _OperationCard(
                icon:
                    Icons
                        .swap_vert_circle_outlined,
                title:
                    'Stok İşlemleri',
                description:
                    'Stok girişi, stok çıkışı ve stok düzeltme işlemlerini yap.',
                onTap:
                    _openStockOperations,
              ),

              _OperationCard(
                icon:
                    Icons.history,
                title:
                    'Stok Hareketleri',
                description:
                    'Bu ürüne ait tüm stok giriş, çıkış ve düzeltme kayıtlarını görüntüle.',
                onTap:
                    _openStockMovements,
              ),

              const SizedBox(
                height: 20,
              ),

              _buildProductInfo(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ÜRÜN BAŞLIĞI
  // =========================================================

  Widget _buildProductHeader() {
    final isLowStock =
        _product.isLowStock;

    return Card(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child:
            Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child:
                  const Icon(
                Icons
                    .inventory_2_outlined,
                color:
                    AppColors.primary,
                size: 32,
              ),
            ),

            const SizedBox(
              width: 16,
            ),

            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    _product.name,
                    style:
                        const TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors
                              .textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    _product.categoryName,
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          AppColors
                              .textSecondary,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          (isLowStock
                                  ? AppColors
                                      .danger
                                  : AppColors
                                      .success)
                              .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        8,
                      ),
                    ),
                    child:
                        Text(
                      _product
                          .statusText,
                      style:
                          TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight
                                .w600,
                        color:
                            isLowStock
                                ? AppColors
                                    .danger
                                : AppColors
                                    .success,
                      ),
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
  // STOK ÖZETİ
  // =========================================================

  Widget _buildStockSummary() {
    final isLowStock =
        _product.isLowStock;

    return Row(
      children: [
        Expanded(
          child:
              _StockCard(
            icon:
                Icons
                    .inventory_2_outlined,
            title:
                'Mevcut Stok',
            value:
                _product.stockText,
            color:
                isLowStock
                    ? AppColors
                        .danger
                    : AppColors
                        .primary,
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child:
              _StockCard(
            icon:
                Icons
                    .warning_amber_outlined,
            title:
                'Minimum Stok',
            value:
                _product
                    .minimumStockText,
            color:
                AppColors
                    .textPrimary,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ÜRÜN BİLGİLERİ
  // =========================================================

  Widget _buildProductInfo() {
    return Card(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Ürün Bilgileri',
              style:
                  TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
                color:
                    AppColors
                        .textPrimary,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _InfoRow(
              label:
                  'Ürün Adı',
              value:
                  _product.name,
            ),

            _InfoRow(
              label:
                  'Kategori',
              value:
                  _product.categoryName,
            ),

            _InfoRow(
              label:
                  'Birim',
              value:
                  _product.unitText,
            ),

            _InfoRow(
              label:
                  'Mevcut Stok',
              value:
                  _product.stockText,
            ),

            _InfoRow(
              label:
                  'Minimum Stok',
              value:
                  _product
                      .minimumStockText,
            ),

            _InfoRow(
              label:
                  'Durum',
              value:
                  _product.statusText,
              valueColor:
                  _product.isLowStock
                      ? AppColors
                          .danger
                      : AppColors
                          .success,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// İŞLEM KARTI
// =============================================================

class _OperationCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _OperationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child:
          InkWell(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        onTap:
            onTap,
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child:
              Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.primary
                          .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),
                child:
                    Icon(
                  icon,
                  color:
                      AppColors
                          .primary,
                  size: 25,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            AppColors
                                .textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      description,
                      style:
                          const TextStyle(
                        fontSize: 13,
                        color:
                            AppColors
                                .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .chevron_right,
                color:
                    AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// STOK KARTI
// =============================================================

class _StockCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StockCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color:
                  color,
              size: 25,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 11,
                color:
                    AppColors
                        .textSecondary,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              value,
              style:
                  TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
                color:
                    color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// BİLGİ SATIRI
// =============================================================

class _InfoRow
    extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          SizedBox(
            width: 125,
            child:
                Text(
              label,
              style:
                  const TextStyle(
                fontSize: 13,
                color:
                    AppColors
                        .textSecondary,
              ),
            ),
          ),

          Expanded(
            child:
                Text(
              value,
              style:
                  TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
                color:
                    valueColor ??
                        AppColors
                            .textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}