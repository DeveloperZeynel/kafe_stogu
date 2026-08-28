
import 'package:flutter/material.dart';
import '../../models/products/product_stock_movement_type.dart';
import '../../core/constants/app_colors.dart';
import '../../models/products/product.dart';
import '../../models/products/product_stock_movement.dart';
import '../../services/product_service.dart';

class ProductStockMovementsScreen
    extends StatefulWidget {
  final Product product;
  final ProductService productService;

  const ProductStockMovementsScreen({
    super.key,
    required this.product,
    required this.productService,
  });

  @override
  State<ProductStockMovementsScreen>
      createState() =>
          _ProductStockMovementsScreenState();
}

class _ProductStockMovementsScreenState
    extends State<ProductStockMovementsScreen> {
  List<ProductStockMovement>
      _movements = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadMovements();
  }

  // =========================================================
  // HAREKETLERİ GETİR
  // =========================================================

  Future<void> _loadMovements() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final movements =
          await widget.productService
              .getStockMovements(
        widget.product.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _movements = movements;
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
        title:
            const Text(
          'Stok Hareketleri',
        ),
        actions: [
          IconButton(
            tooltip:
                'Yenile',
            onPressed:
                _isLoading
                    ? null
                    : _loadMovements,
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
      return _buildError();
    }

    return RefreshIndicator(
      color:
          AppColors.primary,
      onRefresh:
          _loadMovements,
      child:
          CustomScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child:
                _buildHeader(),
          ),

          if (_movements.isEmpty)
            SliverFillRemaining(
              hasScrollBody:
                  false,
              child:
                  _buildEmpty(),
            )
          else
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                4,
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
                    final movement =
                        _movements[index];

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child:
                          _MovementCard(
                        movement:
                            movement,
                        unitText:
                            widget.product
                                .unitText,
                      ),
                    );
                  },
                  childCount:
                      _movements.length,
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
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        14,
      ),
      child:
          Card(
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
                  Icons.history,
                  color:
                      AppColors.primary,
                  size: 27,
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
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
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
                      '${_movements.length} stok hareketi',
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
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BOŞ
  // =========================================================

  Widget _buildEmpty() {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          32,
        ),
        child:
            Column(
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
                Icons.history,
                size: 34,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Henüz stok hareketi yok',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            const Text(
              'Bu ürün üzerinde henüz bir stok işlemi gerçekleştirilmemiş.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
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
  // HATA
  // =========================================================

  Widget _buildError() {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child:
            Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 54,
              color:
                  AppColors.danger,
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Stok hareketleri yüklenemedi',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 18,
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
                  _loadMovements,
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
// HAREKET KARTI
// =============================================================

class _MovementCard
    extends StatelessWidget {
  final ProductStockMovement movement;
  final String unitText;

  const _MovementCard({
    required this.movement,
    required this.unitText,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final type =
        movement.movementType;

    final color =
        _movementColor(type);

    final icon =
        _movementIcon(type);

    final title =
        _movementTitle(type);

    return Card(
      margin:
          EdgeInsets.zero,
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
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration:
                      BoxDecoration(
                    color:
                        color.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      11,
                    ),
                  ),
                  child:
                      Icon(
                    icon,
                    color:
                        color,
                    size: 23,
                  ),
                ),

                const SizedBox(
                  width: 12,
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
                          fontSize: 15,
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
                        _formatDate(
                          movement.createdAt,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 11,
                          color:
                              AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  _quantityText(
                    movement.quantity,
                    type,
                  ),
                  style:
                      TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        color,
                  ),
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
                      _StockValue(
                    label:
                        'Önceki',
                    value:
                        _formatStock(
                      movement.previousStock,
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color:
                      AppColors.textSecondary,
                ),

                Expanded(
                  child:
                      _StockValue(
                    label:
                        'Yeni',
                    value:
                        _formatStock(
                      movement.newStock,
                    ),
                    alignEnd:
                        true,
                  ),
                ),
              ],
            ),

            if (movement.note !=
                    null &&
                movement.note!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(
                height: 14,
              ),

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  11,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.background,
                  borderRadius:
                      BorderRadius.circular(
                    9,
                  ),
                ),
                child:
                    Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons
                          .notes_outlined,
                      size: 17,
                      color:
                          AppColors.textSecondary,
                    ),

                    const SizedBox(
                      width: 7,
                    ),

                    Expanded(
                      child:
                          Text(
                        movement.note!,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // İŞLEM RENGİ
  // =========================================================

  Color _movementColor(
    ProductStockMovementType type,
  ) {
    switch (type) {
      case ProductStockMovementType.initialEntry:
        return AppColors.primary;

      case ProductStockMovementType.stockIn:
        return AppColors.success;

      case ProductStockMovementType.stockOut:
        return AppColors.danger;

      case ProductStockMovementType.adjustment:
        return AppColors.warning;
    }
  }

  // =========================================================
  // İŞLEM İKONU
  // =========================================================

  IconData _movementIcon(
    ProductStockMovementType type,
  ) {
    switch (type) {
      case ProductStockMovementType.initialEntry:
        return Icons.flag_outlined;

      case ProductStockMovementType.stockIn:
        return Icons.add_circle_outline;

      case ProductStockMovementType.stockOut:
        return Icons.remove_circle_outline;

      case ProductStockMovementType.adjustment:
        return Icons.tune;
    }
  }

  // =========================================================
  // İŞLEM ADI
  // =========================================================

  String _movementTitle(
    ProductStockMovementType type,
  ) {
    switch (type) {
      case ProductStockMovementType.initialEntry:
        return 'İlk Stok';

      case ProductStockMovementType.stockIn:
        return 'Stok Girişi';

      case ProductStockMovementType.stockOut:
        return 'Stok Çıkışı';

      case ProductStockMovementType.adjustment:
        return 'Stok Düzeltme';
    }
  }

  // =========================================================
  // MİKTAR
  // =========================================================

  String _quantityText(
    double quantity,
    ProductStockMovementType type,
  ) {
    final formatted =
        _formatStock(quantity);

    switch (type) {
      case ProductStockMovementType.stockOut:
        return '-$formatted $unitText';

      case ProductStockMovementType.stockIn:
        return '+$formatted $unitText';

      case ProductStockMovementType.adjustment:
        if (quantity > 0) {
          return '+$formatted $unitText';
        }

        return '$formatted $unitText';

      case ProductStockMovementType.initialEntry:
        return '$formatted $unitText';
    }
  }

  // =========================================================
  // STOK FORMAT
  // =========================================================

  String _formatStock(
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

  // =========================================================
  // TARİH FORMAT
  // =========================================================

  String _formatDate(
    DateTime date,
  ) {
    final local =
        date.toLocal();

    final day =
        local.day
            .toString()
            .padLeft(
          2,
          '0',
        );

    final month =
        local.month
            .toString()
            .padLeft(
          2,
          '0',
        );

    final year =
        local.year
            .toString();

    final hour =
        local.hour
            .toString()
            .padLeft(
          2,
          '0',
        );

    final minute =
        local.minute
            .toString()
            .padLeft(
          2,
          '0',
        );

    return '$day.$month.$year • '
        '$hour:$minute';
  }
}

// =============================================================
// STOK DEĞERİ
// =============================================================

class _StockValue
    extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _StockValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment:
          alignEnd
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(
            fontSize: 10,
            color:
                AppColors.textSecondary,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          value,
          style:
              const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.bold,
            color:
                AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
