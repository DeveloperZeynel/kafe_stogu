import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/products/product.dart';
import '../../services/product_service.dart';

class ProductStockOperationsScreen
    extends StatefulWidget {
  final Product product;
  final ProductService productService;

  const ProductStockOperationsScreen({
    super.key,
    required this.product,
    required this.productService,
  });

  @override
  State<ProductStockOperationsScreen>
      createState() =>
          _ProductStockOperationsScreenState();
}

class _ProductStockOperationsScreenState
    extends State<ProductStockOperationsScreen> {
  bool _isProcessing = false;

  // =========================================================
  // STOK GİRİŞİ
  // =========================================================

  Future<void> _stockIn() async {
    final result =
        await _showOperationDialog(
      title: 'Stok Girişi',
      description:
          'Depoya gelen ürün miktarını girin.',
      operation:
          _StockOperation.stockIn,
    );

    if (result == null ||
        !mounted) {
      return;
    }

    await _executeStockOperation(
      operation:
          _StockOperation.stockIn,
      quantity:
          result.quantity,
      note:
          result.note,
    );
  }

  // =========================================================
  // STOK ÇIKIŞI
  // =========================================================

  Future<void> _stockOut() async {
    final result =
        await _showOperationDialog(
      title: 'Stok Çıkışı',
      description:
          'Stoktan çıkacak ürün miktarını girin.',
      operation:
          _StockOperation.stockOut,
    );

    if (result == null ||
        !mounted) {
      return;
    }

    await _executeStockOperation(
      operation:
          _StockOperation.stockOut,
      quantity:
          result.quantity,
      note:
          result.note,
    );
  }

  // =========================================================
  // STOK DÜZELTME
  // =========================================================

  Future<void> _adjustStock() async {
    final result =
        await _showOperationDialog(
      title: 'Stok Düzeltme',
      description:
          'Stok miktarını artırmak veya azaltmak için fark miktarını girin.',
      operation:
          _StockOperation.adjustment,
    );

    if (result == null ||
        !mounted) {
      return;
    }

    await _executeStockOperation(
      operation:
          _StockOperation.adjustment,
      quantity:
          result.quantity,
      note:
          result.note,
    );
  }

  // =========================================================
  // API İŞLEMİ
  // =========================================================

  Future<void> _executeStockOperation({
    required _StockOperation operation,
    required double quantity,
    required String? note,
  }) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      switch (operation) {
        case _StockOperation.stockIn:
          await widget.productService.stockIn(
            id: widget.product.id,
            quantity: quantity,
            note: note,
          );
          break;

        case _StockOperation.stockOut:
          await widget.productService.stockOut(
            id: widget.product.id,
            quantity: quantity,
            note: note,
          );
          break;

        case _StockOperation.adjustment:
          await widget.productService.adjustStock(
            id: widget.product.id,
            quantity: quantity,
            note: note,
          );
          break;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            _successMessage(
              operation,
            ),
          ),
        ),
      );

      Navigator.of(
        context,
      ).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      _showError(
        e,
      );
    }
  }

  // =========================================================
  // DİYALOG
  // =========================================================

  Future<_StockOperationResult?>
      _showOperationDialog({
    required String title,
    required String description,
    required _StockOperation operation,
  }) {
    return showDialog<
        _StockOperationResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          _StockOperationDialog(
        title: title,
        description: description,
        operation: operation,
        unitText:
            widget.product.unitText,
        currentStock:
            widget.product.currentStock,
      ),
    );
  }

  // =========================================================
  // BAŞARI MESAJI
  // =========================================================

  String _successMessage(
    _StockOperation operation,
  ) {
    switch (operation) {
      case _StockOperation.stockIn:
        return 'Stok girişi başarıyla kaydedildi.';

      case _StockOperation.stockOut:
        return 'Stok çıkışı başarıyla kaydedildi.';

      case _StockOperation.adjustment:
        return 'Stok düzeltmesi başarıyla kaydedildi.';
    }
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
          _cleanError(
            error,
          ),
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
        title:
            const Text(
          'Stok İşlemleri',
        ),
      ),

      body: SafeArea(
        child:
            _isProcessing
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          AppColors.primary,
                    ),
                  )
                : ListView(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    children: [
                      _buildProductSummary(),

                      const SizedBox(
                        height: 24,
                      ),

                      const Text(
                        'İşlem Seç',
                        style:
                            TextStyle(
                          fontSize: 21,
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
                            Icons.add_circle_outline,
                        title:
                            'Stok Girişi',
                        description:
                            'Ürüne yeni stok ekle.',
                        color:
                            AppColors.success,
                        onTap:
                            _stockIn,
                      ),

                      _OperationCard(
                        icon:
                            Icons.remove_circle_outline,
                        title:
                            'Stok Çıkışı',
                        description:
                            'Üründen stok düş.',
                        color:
                            AppColors.danger,
                        onTap:
                            _stockOut,
                      ),

                      _OperationCard(
                        icon:
                            Icons.tune,
                        title:
                            'Stok Düzeltme',
                        description:
                            'Sayım farkını stok miktarına uygula.',
                        color:
                            AppColors.primary,
                        onTap:
                            _adjustStock,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildInfoBox(),
                    ],
                  ),
      ),
    );
  }

  // =========================================================
  // ÜRÜN ÖZETİ
  // =========================================================

  Widget _buildProductSummary() {
    final isLowStock =
        widget.product.isLowStock;

    return Card(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
        child:
            Row(
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
              child:
                  const Icon(
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
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
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
                    widget.product.categoryName,
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

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                const Text(
                  'Mevcut',
                  style:
                      TextStyle(
                    fontSize: 11,
                    color:
                        AppColors.textSecondary,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  widget.product.stockText,
                  style:
                      TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        isLowStock
                            ? AppColors.danger
                            : AppColors.primary,
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
  // BİLGİ
  // =========================================================

  Widget _buildInfoBox() {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            AppColors.primary
                .withValues(
          alpha: 0.07,
        ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child:
          const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color:
                AppColors.primary,
          ),

          SizedBox(
            width: 10,
          ),

          Expanded(
            child:
                Text(
              'Stok düzeltmede pozitif değer stok ekler, '
              'negatif değer stoktan düşer. '
              'Stok girişi ve çıkışında ise yalnızca '
              'pozitif miktar girilmelidir.',
              style:
                  TextStyle(
                fontSize: 13,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// İŞLEM TİPİ
// =============================================================

enum _StockOperation {
  stockIn,
  stockOut,
  adjustment,
}

// =============================================================
// İŞLEM SONUCU
// =============================================================

class _StockOperationResult {
  final double quantity;
  final String? note;

  const _StockOperationResult({
    required this.quantity,
    required this.note,
  });
}

// =============================================================
// İŞLEM DİYALOĞU
// =============================================================

class _StockOperationDialog
    extends StatefulWidget {
  final String title;
  final String description;
  final _StockOperation operation;
  final String unitText;
  final double currentStock;

  const _StockOperationDialog({
    required this.title,
    required this.description,
    required this.operation,
    required this.unitText,
    required this.currentStock,
  });

  @override
  State<_StockOperationDialog>
      createState() =>
          _StockOperationDialogState();
}

class _StockOperationDialogState
    extends State<_StockOperationDialog> {
  late final TextEditingController
      _quantityController;

  late final TextEditingController
      _noteController;

  String? _quantityError;

  @override
  void initState() {
    super.initState();

    _quantityController =
        TextEditingController();

    _noteController =
        TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  // =========================================================
  // SUBMIT
  // =========================================================

  void _submit() {
    final rawQuantity =
        _quantityController.text
            .trim();

    final quantity =
        double.tryParse(
      rawQuantity.replaceAll(
        ',',
        '.',
      ),
    );

    if (quantity == null) {
      setState(() {
        _quantityError =
            'Geçerli bir miktar girin.';
      });
      return;
    }

    if (widget.operation !=
            _StockOperation.adjustment &&
        quantity <= 0) {
      setState(() {
        _quantityError =
            'Miktar 0\'dan büyük olmalıdır.';
      });
      return;
    }

    if (widget.operation ==
            _StockOperation.adjustment &&
        quantity == 0) {
      setState(() {
        _quantityError =
            'Düzeltme miktarı 0 olamaz.';
      });
      return;
    }

    final note =
        _noteController.text.trim();

    Navigator.of(
      context,
    ).pop(
      _StockOperationResult(
        quantity: quantity,
        note:
            note.isEmpty
                ? null
                : note,
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final isAdjustment =
        widget.operation ==
            _StockOperation.adjustment;

    final isStockOut =
        widget.operation ==
            _StockOperation.stockOut;

    return AlertDialog(
      title:
          Text(widget.title),

      content:
          SingleChildScrollView(
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.description,
              style:
                  const TextStyle(
                fontSize: 13,
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.07,
                ),
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child:
                  Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color:
                        AppColors.primary,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  const Text(
                    'Mevcut stok:',
                    style:
                        TextStyle(
                      fontSize: 12,
                      color:
                          AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  Text(
                    _formatNumber(
                      widget.currentStock,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(
                    width: 4,
                  ),

                  Text(
                    widget.unitText,
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

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  _quantityController,
              autofocus:
                  true,
              keyboardType:
                  TextInputType.numberWithOptions(
                decimal: true,
                signed:
                    isAdjustment,
              ),
              decoration:
                  InputDecoration(
                labelText:
                    isAdjustment
                        ? 'Düzeltme miktarı'
                        : 'Miktar',
                hintText:
                    isAdjustment
                        ? 'Örn. +5 veya -3'
                        : 'Miktar girin',
                suffixText:
                    widget.unitText,
                errorText:
                    _quantityError,
              ),
              onChanged: (_) {
                if (_quantityError !=
                    null) {
                  setState(() {
                    _quantityError =
                        null;
                  });
                }
              },
              onSubmitted:
                  (_) => _submit(),
            ),

            const SizedBox(
              height: 14,
            ),

            TextField(
              controller:
                  _noteController,
              maxLines: 3,
              textCapitalization:
                  TextCapitalization.sentences,
              decoration:
                  const InputDecoration(
                labelText:
                    'Not',
                hintText:
                    'İsterseniz işlem için not ekleyin...',
                alignLabelWithHint:
                    true,
              ),
            ),

            if (isStockOut) ...[
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Stok çıkışı mevcut stoktan düşülecektir.',
                style:
                    TextStyle(
                  fontSize: 11,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],

            if (isAdjustment) ...[
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Pozitif değer stok ekler, negatif değer stoktan düşer.',
                style:
                    TextStyle(
                  fontSize: 11,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
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
              const Text(
            'Kaydet',
          ),
        ),
      ],
    );
  }

  // =========================================================
  // SAYI FORMAT
  // =========================================================

  String _formatNumber(
    double value,
  ) {
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
}

// =============================================================
// İŞLEM KARTI
// =============================================================

class _OperationCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _OperationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
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
                      color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child:
                    Icon(
                  icon,
                  color:
                      color,
                  size: 26,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                      description,
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

              Icon(
                Icons.chevron_right,
                color:
                    color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
