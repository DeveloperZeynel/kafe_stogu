import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/products/category.dart';
import '../../services/category_service.dart';

class CategoriesScreen extends StatefulWidget {
  final CategoryService categoryService;

  final bool isAdmin;

  const CategoriesScreen({
    super.key,
    required this.categoryService,
    required this.isAdmin,
  });

  @override
  State<CategoriesScreen> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState
    extends State<CategoriesScreen> {
  List<Category> _categories = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadCategories();
  }

  // =========================================================
  // KATEGORİLERİ GETİR
  // =========================================================

  Future<void> _loadCategories() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories =
          await widget.categoryService.getAll();

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _cleanError(e);
      });
    }
  }

  // =========================================================
  // KATEGORİ EKLE
  // SADECE ADMIN
  // =========================================================

  Future<void> _createCategory() async {
    if (!widget.isAdmin) {
      return;
    }

    final name =
        await _showCategoryDialog(
      title: 'Yeni Kategori',
      buttonText: 'Ekle',
    );

    if (name == null ||
        name.trim().isEmpty ||
        !mounted) {
      return;
    }

    try {
      await widget.categoryService.create(
        name: name.trim(),
      );

      if (!mounted) {
        return;
      }

      _showSuccess(
        'Kategori başarıyla eklendi.',
      );

      await _loadCategories();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(e);
    }
  }

  // =========================================================
  // KATEGORİ GÜNCELLE
  // SADECE ADMIN
  // =========================================================

  Future<void> _updateCategory(
    Category category,
  ) async {
    if (!widget.isAdmin) {
      return;
    }

    final name =
        await _showCategoryDialog(
      title: 'Kategori Düzenle',
      buttonText: 'Kaydet',
      initialName: category.name,
    );

    if (name == null ||
        name.trim().isEmpty ||
        !mounted) {
      return;
    }

    try {
      await widget.categoryService.update(
        id: category.id,
        name: name.trim(),
      );

      if (!mounted) {
        return;
      }

      _showSuccess(
        'Kategori başarıyla güncellendi.',
      );

      await _loadCategories();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(e);
    }
  }

  // =========================================================
  // KATEGORİ SİL
  // SADECE ADMIN
  // =========================================================

  Future<void> _deleteCategory(
    Category category,
  ) async {
    if (!widget.isAdmin) {
      return;
    }

    final confirmed =
        await _showDeleteConfirmation(
      category,
    );

    if (!confirmed || !mounted) {
      return;
    }

    try {
      await widget.categoryService.delete(
        category.id,
      );

      if (!mounted) {
        return;
      }

      _showSuccess(
        'Kategori başarıyla silindi.',
      );

      await _loadCategories();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showError(e);
    }
  }

  // =========================================================
  // KATEGORİ DİYALOĞU
  // =========================================================

  Future<String?> _showCategoryDialog({
    required String title,
    required String buttonText,
    String initialName = '',
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => _CategoryDialog(
        title: title,
        buttonText: buttonText,
        initialName: initialName,
      ),
    );
  }

  // =========================================================
  // SİLME ONAYI
  // =========================================================

  Future<bool> _showDeleteConfirmation(
    Category category,
  ) async {
    final productCount =
        category.productCount;

    final message =
        productCount > 0
            ? '“${category.name}” kategorisine bağlı '
                '$productCount aktif ürün bulunuyor. '
                'Kategori silindiğinde bağlı aktif ürünler '
                'de pasif hale getirilecektir.'
            : '“${category.name}” kategorisi silinecek. '
                'Bu işlem geri alınamaz.';

    final result =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Kategoriyi Sil',
          ),
          content: Text(
            message,
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(false),
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
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(true),
              child: const Text(
                'Sil',
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // =========================================================
  // BAŞARI
  // =========================================================

  void _showSuccess(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
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
        title: const Text(
          'Kategori Yönetimi',
        ),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed:
                _isLoading
                    ? null
                    : _loadCategories,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

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
                          : _createCategory,
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text(
                    'Kategori Ekle',
                  ),
                )
              : null,

      body: SafeArea(
        child: _buildBody(),
      ),
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

    if (_categories.isEmpty) {
      return RefreshIndicator(
        color:
            AppColors.primary,
        onRefresh:
            _loadCategories,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:
                  MediaQuery.of(context)
                          .size
                          .height *
                      0.30,
            ),
            _buildEmptyState(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color:
          AppColors.primary,
      onRefresh:
          _loadCategories,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          100,
        ),
        children: [
          _buildHeader(),

          const SizedBox(
            height: 16,
          ),

          ..._categories.map(
            (category) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              child: _CategoryCard(
                category: category,
                isAdmin:
                    widget.isAdmin,
                onEdit: () =>
                    _updateCategory(
                  category,
                ),
                onDelete: () =>
                    _deleteCategory(
                  category,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    final totalProducts =
        _categories.fold<int>(
      0,
      (
        total,
        category,
      ) =>
          total +
          category.productCount,
    );

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
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
                Icons.category_outlined,
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
                  const Text(
                    'Kategoriler',
                    style:
                        TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors
                              .textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    '${_categories.length} aktif kategori • '
                    '$totalProducts aktif ürün',
                    style:
                        const TextStyle(
                      fontSize: 12,
                      color:
                          AppColors
                              .textSecondary,
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
  // BOŞ
  // =========================================================

  Widget _buildEmptyState() {
    return Padding(
      padding:
          const EdgeInsets.all(
        32,
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
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
            child: const Icon(
              Icons.category_outlined,
              size: 36,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            widget.isAdmin
                ? 'Henüz kategori yok'
                : 'Kategori bulunamadı',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
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
            widget.isAdmin
                ? 'Ürünlerinizi düzenlemek için ilk kategoriyi oluşturabilirsiniz.'
                : 'Aktif kategori bulunmuyor.',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 13,
              color:
                  AppColors.textSecondary,
            ),
          ),

          if (widget.isAdmin) ...[
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
                  _createCategory,
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'İlk Kategoriyi Ekle',
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // HATA
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
              'Kategoriler yüklenemedi',
              textAlign:
                  TextAlign.center,
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
                    AppColors
                        .textSecondary,
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
                  _loadCategories,
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
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
// KATEGORİ KARTI
// =============================================================

class _CategoryCard
    extends StatelessWidget {
  final Category category;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Row(
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
              child: const Icon(
                Icons.category_outlined,
                color:
                    AppColors.primary,
                size: 25,
              ),
            ),

            const SizedBox(
              width: 13,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 16,
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

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .inventory_2_outlined,
                        size: 14,
                        color:
                            AppColors
                                .textSecondary,
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Text(
                        '${category.productCount} aktif ürün',
                        style:
                            const TextStyle(
                          fontSize: 11,
                          color:
                              AppColors
                                  .textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (isAdmin) ...[
              IconButton(
                tooltip:
                    'Düzenle',
                onPressed:
                    onEdit,
                icon:
                    const Icon(
                  Icons
                      .edit_outlined,
                  color:
                      AppColors
                          .primary,
                ),
              ),

              IconButton(
                tooltip:
                    'Sil',
                onPressed:
                    onDelete,
                icon:
                    const Icon(
                  Icons
                      .delete_outline,
                  color:
                      AppColors
                          .danger,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================
// KATEGORİ DİYALOĞU
// =============================================================

class _CategoryDialog
    extends StatefulWidget {
  final String title;
  final String buttonText;
  final String initialName;

  const _CategoryDialog({
    required this.title,
    required this.buttonText,
    required this.initialName,
  });

  @override
  State<_CategoryDialog> createState() =>
      _CategoryDialogState();
}

class _CategoryDialogState
    extends State<_CategoryDialog> {
  late final TextEditingController
      _controller;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _controller =
        TextEditingController(
      text: widget.initialName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _submit() {
    final name =
        _controller.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage =
            'Kategori adı zorunludur.';
      });
      return;
    }

    Navigator.of(
      context,
    ).pop(name);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title:
          Text(widget.title),

      content:
          TextField(
        controller:
            _controller,
        autofocus:
            true,
        textCapitalization:
            TextCapitalization.sentences,
        maxLength:
            100,
        decoration:
            InputDecoration(
          labelText:
              'Kategori adı',
          hintText:
              'Örn. Kahveler',
          errorText:
              _errorMessage,
        ),
        onChanged: (_) {
          if (_errorMessage !=
              null) {
            setState(() {
              _errorMessage =
                  null;
            });
          }
        },
        onSubmitted:
            (_) => _submit(),
      ),

      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(
            context,
          ).pop(),
          child:
              const Text(
            'Vazgeç',
          ),
        ),

        FilledButton(
          style:
              FilledButton.styleFrom(
            backgroundColor:
                AppColors.primary,
          ),
          onPressed:
              _submit,
          child:
              Text(
            widget.buttonText,
          ),
        ),
      ],
    );
  }
}