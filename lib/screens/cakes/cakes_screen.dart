import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/auth_storage.dart';
import '../../models/auth/login_response.dart';
import '../../models/cakes/cake.dart';
import '../../services/cake_service.dart';
import 'cake_form_screen.dart';
import 'cake_stock_operations_screen.dart';

class CakesScreen extends StatefulWidget {
  final LoginResponse loginResponse;

  const CakesScreen({
    super.key,
    required this.loginResponse,
  });

  @override
  State<CakesScreen> createState() =>
      _CakesScreenState();
}

class _CakesScreenState
    extends State<CakesScreen> {
  late final CakeService _cakeService;

  List<Cake> _cakes = [];

  // =========================================================
  // ARAMA İÇİN FİLTRELENMİŞ PASTALAR
  // =========================================================

  List<Cake> _filteredCakes = [];

  final TextEditingController _searchController =
      TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  bool get _isAdmin =>
      widget.loginResponse.isAdmin;

  @override
  void initState() {
    super.initState();

    _cakeService = CakeService(
      apiClient: ApiClient(
        authStorage: AuthStorage(),
      ),
    );

    _searchController.addListener(
      _filterCakes,
    );

    _loadCakes();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // =========================================================
  // PASTALARI GETİR
  // =========================================================

  Future<void> _loadCakes() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final cakes =
          await _cakeService.getAll();

      if (!mounted) {
        return;
      }

      setState(() {
        _cakes = cakes;

        _isLoading = false;
      });

      _filterCakes();
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
  // PASTALARI ARA / FİLTRELE
  // =========================================================

  void _filterCakes() {
    final searchText =
        _searchController.text
            .trim()
            .toLowerCase();

    if (!mounted) {
      return;
    }

    setState(() {
      if (searchText.isEmpty) {
        _filteredCakes =
            List<Cake>.from(
          _cakes,
        );
      } else {
        _filteredCakes =
            _cakes.where(
          (cake) {
            return cake.name
                .toLowerCase()
                .contains(
                  searchText,
                );
          },
        ).toList();
      }
    });
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
  // PASTA EKLE
  // =========================================================

  Future<void> _openCreateForm() async {
    final result =
        await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CakeFormScreen(
          cakeService:
              _cakeService,
        ),
      ),
    );

    if (result == true) {
      await _loadCakes();
    }
  }

  // =========================================================
  // PASTA DÜZENLE
  // =========================================================

  Future<void> _openEditForm(
    Cake cake,
  ) async {
    final result =
        await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CakeFormScreen(
          cakeService:
              _cakeService,
          cake: cake,
        ),
      ),
    );

    if (result == true) {
      await _loadCakes();
    }
  }

  // =========================================================
  // STOK İŞLEMLERİ
  // =========================================================

  Future<void> _openStockOperations(
    Cake cake,
  ) async {
    final result =
        await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CakeStockOperationsScreen(
          cake: cake,
          cakeService:
              _cakeService,
        ),
      ),
    );

    if (result == true) {
      await _loadCakes();
    }
  }

  // =========================================================
  // PASTA SİL
  // =========================================================

  Future<void> _deleteCake(
    Cake cake,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            'Pastayı Sil',
          ),
          content: Text(
            '"${cake.name}" pastasını '
            'silmek istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(
                context,
              ).pop(false),
              child:
                  const Text(
                'Vazgeç',
              ),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    AppColors.danger,
              ),
              onPressed: () =>
                  Navigator.of(
                context,
              ).pop(true),
              child:
                  const Text(
                'Sil',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _cakeService.delete(
        cake.id,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Pasta başarıyla silindi.',
          ),
        ),
      );

      await _loadCakes();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(
        _cleanError(e),
      );
    }
  }

  // =========================================================
  // HATA MESAJI
  // =========================================================

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        backgroundColor:
            AppColors.danger,
        content: Text(
          message,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      // =====================================================
      // APPBAR
      // MEVCUT HALİNE DOKUNULMADI
      // =====================================================

      appBar: AppBar(
        title:
            const Text(
          'Pastalar',
        ),
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        actions: [
          IconButton(
            tooltip:
                'Yenile',
            onPressed:
                _loadCakes,
            icon:
                const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      // =======================================================
      // SADECE ADMIN PASTA EKLEYEBİLİR
      // =======================================================

      floatingActionButton:
          _isAdmin
              ? FloatingActionButton.extended(
                  onPressed:
                      _openCreateForm,
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor:
                      Colors.white,
                  icon:
                      const Icon(
                    Icons.add,
                  ),
                  label:
                      const Text(
                    'Pasta Ekle',
                  ),
                )
              : null,

      body: Column(
        children: [
          // =================================================
          // AYRI ARAMA NAVİGASYON ALANI
          //
          // APPBAR'IN HEMEN ALTINDA
          // BEYAZ ARKA PLAN
          // PRIMARY RENK YAZI VE İKON
          // =================================================

          Container(
            width:
                double.infinity,
            color:
                Colors.white,
            padding:
                const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12,
            ),
            child: TextField(
              controller:
                  _searchController,
              style:
                  const TextStyle(
                color:
                    AppColors.primary,
              ),
              cursorColor:
                  AppColors.primary,
              decoration:
                  InputDecoration(
                hintText:
                    'Pasta ara...',
                hintStyle:
                    TextStyle(
                  color:
                      AppColors.primary
                          .withValues(
                    alpha: 0.65,
                  ),
                ),
                prefixIcon:
                    const Icon(
                  Icons.search,
                  color:
                      AppColors.primary,
                ),
                suffixIcon:
                    _searchController
                            .text
                            .isNotEmpty
                        ? IconButton(
                            tooltip:
                                'Temizle',
                            onPressed: () {
                              _searchController
                                  .clear();
                            },
                            icon:
                                const Icon(
                              Icons.close,
                              color:
                                  AppColors.primary,
                            ),
                          )
                        : null,
                filled:
                    true,
                fillColor:
                    Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(
                  vertical:
                      14,
                ),
                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                  borderSide:
                      BorderSide(
                    color:
                        AppColors.primary
                            .withValues(
                      alpha: 0.45,
                    ),
                  ),
                ),
                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                  borderSide:
                      const BorderSide(
                    color:
                        AppColors.primary,
                    width:
                        2,
                  ),
                ),
              ),
            ),
          ),

          // =================================================
          // PASTA LİSTESİ
          // =================================================

          Expanded(
            child:
                RefreshIndicator(
              color:
                  AppColors.primary,
              onRefresh:
                  _loadCakes,
              child:
                  _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // =========================================================
    // YÜKLENİYOR
    // =========================================================

    if (_isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(
          color:
              AppColors.primary,
        ),
      );
    }

    // =========================================================
    // HATA
    // =========================================================

    if (_errorMessage != null) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(
            height: 120,
          ),
          const Icon(
            Icons.error_outline,
            size: 56,
            color:
                AppColors.danger,
          ),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Text(
              _errorMessage!,
              textAlign:
                  TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Center(
            child:
                ElevatedButton.icon(
              onPressed:
                  _loadCakes,
              icon:
                  const Icon(
                Icons.refresh,
              ),
              label:
                  const Text(
                'Tekrar Dene',
              ),
            ),
          ),
        ],
      );
    }

    // =========================================================
    // BOŞ LİSTE
    // =========================================================

    if (_cakes.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(
            height: 140,
          ),
          const Icon(
            Icons.cake_outlined,
            size: 64,
            color:
                AppColors.textSecondary,
          ),
          const SizedBox(
            height: 16,
          ),
          const Center(
            child: Text(
              'Henüz pasta bulunmuyor.',
              style:
                  TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ),
          if (_isAdmin) ...[
            const SizedBox(
              height: 8,
            ),
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Text(
                'Yeni pasta eklemek için '
                'sağ alttaki butonu kullanabilirsiniz.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      );
    }

    // =========================================================
    // ARAMA SONUCU BULUNAMADI
    // =========================================================

    if (_filteredCakes.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(
            height: 140,
          ),
          const Icon(
            Icons.search_off_outlined,
            size: 64,
            color:
                AppColors.textSecondary,
          ),
          const SizedBox(
            height: 16,
          ),
          const Center(
            child: Text(
              'Pasta bulunamadı.',
              style:
                  TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          const Center(
            child: Text(
              'Farklı bir isimle tekrar arayabilirsiniz.',
              style:
                  TextStyle(
                color:
                    AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    // =========================================================
    // PASTA LİSTESİ
    // =========================================================

    return ListView.builder(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ),
      itemCount:
          _filteredCakes.length,
      itemBuilder:
          (context, index) {
        final cake =
            _filteredCakes[index];

        return _CakeCard(
          cake: cake,
          isAdmin:
              _isAdmin,
          onEdit: () =>
              _openEditForm(
            cake,
          ),
          onDelete: () =>
              _deleteCake(
            cake,
          ),
          onStockOperations: () =>
              _openStockOperations(
            cake,
          ),
        );
      },
    );
  }
}

// =============================================================
// PASTA KARTI
// =============================================================

class _CakeCard
    extends StatelessWidget {
  final Cake cake;
  final bool isAdmin;

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStockOperations;

  const _CakeCard({
    required this.cake,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
    required this.onStockOperations,
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
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
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
                  child:
                      const Icon(
                    Icons.cake,
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
                        cake.name,
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
                        height: 4,
                      ),
                      Text(
                        'Satış fiyatı: '
                        '${cake.sliceSalePrice.toStringAsFixed(2)} ₺',
                        style:
                            const TextStyle(
                          color:
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin)
                  PopupMenuButton<String>(
                    onSelected:
                        (value) {
                      if (value ==
                          'edit') {
                        onEdit();
                      } else if (value ==
                          'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder:
                        (context) => [
                      const PopupMenuItem(
                        value:
                            'edit',
                        child:
                            Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Düzenle',
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value:
                            'delete',
                        child:
                            Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color:
                                  AppColors.danger,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Sil',
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    label:
                        'Mevcut Stok',
                    value:
                        '${cake.currentSliceStock}',
                    icon:
                        Icons.inventory_2_outlined,
                  ),
                ),
                Expanded(
                  child:
                      _StockInfo(
                    label:
                        'Dilim / Kutu',
                    value:
                        '${cake.slicesPerBox}',
                    icon:
                        Icons.grid_view_outlined,
                  ),
                ),
                Expanded(
                  child:
                      _StockInfo(
                    label:
                        'Kutu Fiyatı',
                    value:
                        '${cake.boxPurchasePrice.toStringAsFixed(2)} ₺',
                    icon:
                        Icons.payments_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width:
                  double.infinity,
              child:
                  OutlinedButton.icon(
                onPressed:
                    onStockOperations,
                icon:
                    const Icon(
                  Icons.tune,
                ),
                label:
                    const Text(
                  'Stok İşlemleri',
                ),
              ),
            ),
          ],
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
  final String label;
  final String value;
  final IconData icon;

  const _StockInfo({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 21,
          color:
              AppColors.primary,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          value,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
            color:
                AppColors.textPrimary,
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        Text(
          label,
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            fontSize: 11,
            color:
                AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
