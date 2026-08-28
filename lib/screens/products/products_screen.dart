import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/products/category.dart';
import '../../models/products/product.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  final ProductService productService;
  final CategoryService categoryService;

  // Admin ise ürün ekleme/düzenleme işlemleri
  // gösterilebilir.
  final bool isAdmin;

  const ProductsScreen({
    super.key,
    required this.productService,
    required this.categoryService,
    required this.isAdmin,
  });

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState
    extends State<ProductsScreen> {
  List<Product> _products = [];
  List<Category> _categories = [];

  bool _isLoading = true;
  String? _errorMessage;

  String _searchText = '';
  int? _selectedCategoryId;
  bool _onlyLowStock = false;

  final TextEditingController
      _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // =========================================================
  // VERİLERİ GETİR
  // =========================================================

  Future<void> _loadData() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results =
          await Future.wait([
        widget.productService.getAll(),
        widget.categoryService.getAll(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _products =
            results[0] as List<Product>;

        _categories =
            results[1] as List<Category>;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            _cleanError(e);
      });
    }
  }

  // =========================================================
  // FİLTRELENMİŞ ÜRÜNLER
  // =========================================================

  List<Product>
      get _filteredProducts {
    final search =
        _searchText
            .trim()
            .toLowerCase();

    return _products.where(
      (product) {
        if (search.isNotEmpty) {
          final matchesName =
              product.name
                  .toLowerCase()
                  .contains(search);

          final matchesCategory =
              product.categoryName
                  .toLowerCase()
                  .contains(search);

          if (!matchesName &&
              !matchesCategory) {
            return false;
          }
        }

        if (_selectedCategoryId !=
            null) {
          if (product.categoryId !=
              _selectedCategoryId) {
            return false;
          }
        }

        if (_onlyLowStock &&
            !product.isLowStock) {
          return false;
        }

        return true;
      },
    ).toList();
  }

  // =========================================================
  // ARAMA
  // =========================================================

  void _onSearchChanged(
    String value,
  ) {
    setState(() {
      _searchText = value;
    });
  }

  // =========================================================
  // KATEGORİ FİLTRESİ
  // =========================================================

  void _selectCategory(
    int? categoryId,
  ) {
    setState(() {
      _selectedCategoryId =
          categoryId;
    });
  }

  // =========================================================
  // DÜŞÜK STOK FİLTRESİ
  // =========================================================

  void _toggleLowStock() {
    setState(() {
      _onlyLowStock =
          !_onlyLowStock;
    });
  }

  // =========================================================
  // ÜRÜN EKLE
  // =========================================================

  Future<void> _openProductForm() async {
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
        ),
      ),
    );

    if (result == true &&
        mounted) {
      await _loadData();
    }
  }

  // =========================================================
  // ÜRÜN DETAYI
  // =========================================================

  Future<void>
      _openProductDetail(
    Product product,
  ) async {
    final result =
        await Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        builder: (_) =>
            ProductDetailScreen(
              product: product,
              productService:
                  widget.productService,
              categoryService:
                  widget.categoryService,
              isAdmin:
                  widget.isAdmin,
            ),
      ),
    );

    if (result == true &&
        mounted) {
      await _loadData();
    }
  }

  // =========================================================
  // HATA
  // =========================================================

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
        title: const Text(
          'Diğer Stoklar',
        ),
        actions: [
          IconButton(
            tooltip:
                'Yenile',
            onPressed:
                _isLoading
                    ? null
                    : _loadData,
            icon:
                const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child:
            _buildBody(),
      ),

      // =====================================================
      // ADMIN ÜRÜN EKLE BUTONU
      // =====================================================

      floatingActionButton:
          widget.isAdmin
              ? FloatingActionButton.extended(
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor:
                      Colors.white,
                  onPressed:
                      _isLoading
                          ? null
                          : _openProductForm,
                  icon:
                      const Icon(
                    Icons.add,
                  ),
                  label:
                      const Text(
                    'Ürün Ekle',
                  ),
                )
              : null,
    );
  }

  // =========================================================
  // BODY
  // =========================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(
          color:
              AppColors.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color:
          AppColors.primary,
      onRefresh:
          _loadData,
      child:
          CustomScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child:
                _buildHeader(),
          ),

          SliverToBoxAdapter(
            child:
                _buildSearch(),
          ),

          SliverToBoxAdapter(
            child:
                _buildFilters(),
          ),

          SliverToBoxAdapter(
            child:
                _buildResultHeader(),
          ),

          _buildProductList(),
        ],
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    final lowStockCount =
        _products
            .where(
              (product) =>
                  product.isLowStock,
            )
            .length;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stok Yönetimi',
                  style:
                      TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  '${_products.length} ürün'
                  '${lowStockCount > 0 ? ' • $lowStockCount düşük stok' : ''}',
                  style:
                      const TextStyle(
                    fontSize: 13,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          if (lowStockCount > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.danger
                        .withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child:
                  const Icon(
                Icons.warning_amber_rounded,
                color:
                    AppColors.danger,
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================
  // ARAMA
  // =========================================================

  Widget _buildSearch() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        12,
      ),
      child: TextField(
        controller:
            _searchController,
        onChanged:
            _onSearchChanged,
        decoration:
            InputDecoration(
          hintText:
              'Ürün veya kategori ara...',
          prefixIcon:
              const Icon(
            Icons.search,
          ),
          suffixIcon:
              _searchText.isEmpty
                  ? null
                  : IconButton(
                      tooltip:
                          'Temizle',
                      onPressed: () {
                        _searchController
                            .clear();

                        _onSearchChanged(
                          '',
                        );
                      },
                      icon:
                          const Icon(
                        Icons.clear,
                      ),
                    ),
        ),
      ),
    );
  }

  // =========================================================
  // FİLTRELER
  // =========================================================

  Widget _buildFilters() {
    return SizedBox(
      height: 48,
      child:
          ListView(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        children: [
          _FilterChip(
            label:
                'Tümü',
            selected:
                _selectedCategoryId ==
                    null &&
                !_onlyLowStock,
            onTap: () {
              setState(() {
                _selectedCategoryId =
                    null;
                _onlyLowStock =
                    false;
              });
            },
          ),

          const SizedBox(
            width: 8,
          ),

          _FilterChip(
            label:
                'Düşük Stok',
            selected:
                _onlyLowStock,
            danger: true,
            onTap:
                _toggleLowStock,
          ),

          ..._categories.map(
            (
              category,
            ) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  left: 8,
                ),
                child:
                    _FilterChip(
                  label:
                      category.name,
                  selected:
                      _selectedCategoryId ==
                          category.id,
                  onTap: () =>
                      _selectCategory(
                    category.id,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SONUÇ BAŞLIĞI
  // =========================================================

  Widget _buildResultHeader() {
    final products =
        _filteredProducts;

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        10,
      ),
      child: Row(
        children: [
          const Text(
            'Ürünler',
            style:
                TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const Spacer(),

          Text(
            '${products.length} sonuç',
            style:
                const TextStyle(
              fontSize: 12,
              color:
                  AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ÜRÜN LİSTESİ
  // =========================================================

  Widget _buildProductList() {
    final products =
        _filteredProducts;

    if (products.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody:
            false,
        child:
            _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        24,
      ),
      sliver:
          SliverList(
        delegate:
            SliverChildBuilderDelegate(
          (
            context,
            index,
          ) {
            final product =
                products[index];

            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              child:
                  _ProductCard(
                product:
                    product,
                onTap: () =>
                    _openProductDetail(
                  product,
                ),
              ),
            );
          },
          childCount:
              products.length,
        ),
      ),
    );
  }

  // =========================================================
  // BOŞ LİSTE
  // =========================================================

  Widget _buildEmptyState() {
    String title;
    String subtitle;

    if (_searchText
            .trim()
            .isNotEmpty ||
        _selectedCategoryId !=
            null ||
        _onlyLowStock) {
      title =
          'Ürün bulunamadı';

      subtitle =
          'Seçtiğiniz filtrelere uygun ürün bulunmuyor.';
    } else {
      title =
          'Henüz ürün yok';

      subtitle =
          'Bu bölümde kayıtlı aktif ürün bulunmuyor.';
    }

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          32,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.10,
                ),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.inventory_2_outlined,
                size: 34,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              subtitle,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 13,
                color:
                    AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HATA EKRANI
  // =========================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color:
                  AppColors.danger,
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Stoklar yüklenemedi',
              style:
                  TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              _errorMessage ??
                  'Bilinmeyen bir hata oluştu.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 13,
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            FilledButton.icon(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
              ),
              onPressed:
                  _loadData,
              icon:
                  const Icon(
                Icons.refresh,
              ),
              label:
                  const Text(
                'Tekrar Dene',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// ÜRÜN KARTI
// =============================================================

class _ProductCard
    extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isLowStock =
        product.isLowStock;

    final statusColor =
        isLowStock
            ? AppColors.danger
            : AppColors.success;

    return Card(
      margin:
          EdgeInsets.zero,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        onTap:
            onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.primary
                              .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child:
                        const Icon(
                      Icons.inventory_2_outlined,
                      color:
                          AppColors.primary,
                      size: 26,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          product.categoryName,
                          style:
                              const TextStyle(
                            fontSize: 12,
                            color:
                                AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right,
                    color:
                        AppColors.textSecondary,
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        _StockInfo(
                      title:
                          'Mevcut Stok',
                      value:
                          product.stockText,
                      color:
                          statusColor,
                    ),
                  ),

                  Expanded(
                    child:
                        _StockInfo(
                      title:
                          'Minimum',
                      value:
                          product.minimumStockText,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                children: [
                  Icon(
                    isLowStock
                        ? Icons
                            .warning_amber_rounded
                        : Icons
                            .check_circle_outline,
                    size: 17,
                    color:
                        statusColor,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    product.statusText,
                    style:
                        TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          statusColor,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    product.unitText,
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// STOK BİLGİSİ
// =============================================================

class _StockInfo
    extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StockInfo({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 11,
            color:
                AppColors.textSecondary,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          value,
          style:
              TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.bold,
            color:
                color,
          ),
        ),
      ],
    );
  }
}

// =============================================================
// FİLTRE CHIP
// =============================================================

class _FilterChip
    extends StatelessWidget {
  final String label;
  final bool selected;
  final bool danger;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final baseColor =
        danger
            ? AppColors.danger
            : AppColors.primary;

    return Material(
      color:
          selected
              ? baseColor
              : Colors.white,
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        onTap:
            onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            border:
                Border.all(
              color:
                  selected
                      ? baseColor
                      : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style:
                TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color:
                  selected
                      ? Colors.white
                      : baseColor,
            ),
          ),
        ),
      ),
    );
  }
}