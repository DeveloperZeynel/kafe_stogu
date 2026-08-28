import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/cakes/cake.dart';
import '../../models/cakes/cake_cabinet.dart';
import '../../services/cake_service.dart';

class CakeCabinetScreen extends StatefulWidget {
  final Cake cake;
  final CakeService cakeService;

  const CakeCabinetScreen({
    super.key,
    required this.cake,
    required this.cakeService,
  });

  @override
  State<CakeCabinetScreen> createState() =>
      _CakeCabinetScreenState();
}

class _CakeCabinetScreenState
    extends State<CakeCabinetScreen> {
  List<CakeCabinet> _records = [];

  bool _isLoading = true;
  bool _isProcessing = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadCabinet();
  }

  // =========================================================
  // DOLAP KAYITLARINI GETİR
  // =========================================================

  Future<void> _loadCabinet() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final records =
          await widget.cakeService
              .getCabinetRecords(
        widget.cake.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _records = records;
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
  // TOPLAM DOLAP STOĞU
  // =========================================================

  int get _totalCabinetSlices {
    return _records.fold<int>(
      0,
      (
        total,
        record,
      ) =>
          total +
          record.remainingQuantity,
    );
  }

  // =========================================================
  // TARİH FORMATLAMA
  // =========================================================

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final local =
        dateTime.toLocal();

    final day =
        local.day
            .toString()
            .padLeft(2, '0');

    final month =
        local.month
            .toString()
            .padLeft(2, '0');

    final year =
        local.year.toString();

    final hour =
        local.hour
            .toString()
            .padLeft(2, '0');

    final minute =
        local.minute
            .toString()
            .padLeft(2, '0');

    return '$day.$month.$year '
        '$hour:$minute';
  }

  // =========================================================
  // SATIŞ
  // =========================================================

  Future<void> _createSale(
    CakeCabinet cabinet,
  ) async {
    if (cabinet.id <= 0) {
      _showError(
        'Dolap kaydı bulunamadı.',
      );
      return;
    }

    if (cabinet.remainingQuantity <= 0) {
      _showError(
        'Bu partide satılabilir dilim kalmadı.',
      );
      return;
    }

    final quantity =
        await _showQuantityDialog(
      title: 'Pasta Satışı',
      description:
          '${cabinet.cakeName} partisinden '
          'satılan dilim miktarını girin.',
      maxQuantity:
          cabinet.remainingQuantity,
      actionText:
          'Satışı Kaydet',
    );

    if (quantity == null) {
      return;
    }

    await _execute(
      action: () =>
          widget.cakeService
              .createCabinetSale(
        cabinetId:
            cabinet.id,
        sliceQuantity:
            quantity,
      ),
      message:
          '$quantity dilim satış başarıyla kaydedildi.',
    );
  }

  // =========================================================
  // ZAYİ
  // =========================================================

  Future<void> _createWaste(
    CakeCabinet cabinet,
  ) async {
    if (cabinet.id <= 0) {
      _showError(
        'Dolap kaydı bulunamadı.',
      );
      return;
    }

    if (cabinet.remainingQuantity <= 0) {
      _showError(
        'Bu partide zayi edilecek dilim kalmadı.',
      );
      return;
    }

    final quantity =
        await _showQuantityDialog(
      title: 'Pasta Zayii',
      description:
          '${cabinet.cakeName} partisinden '
          'zayi olan dilim miktarını girin.',
      maxQuantity:
          cabinet.remainingQuantity,
      actionText:
          'Zayii Kaydet',
    );

    if (quantity == null) {
      return;
    }

    await _execute(
      action: () =>
          widget.cakeService
              .createCabinetWaste(
        cabinetId:
            cabinet.id,
        sliceQuantity:
            quantity,
      ),
      message:
          '$quantity dilim zayi olarak kaydedildi.',
    );
  }

  // =========================================================
  // MİKTAR DİYALOĞU
  // =========================================================

  Future<int?> _showQuantityDialog({
    required String title,
    required String description,
    required int maxQuantity,
    required String actionText,
  }) {
    return showDialog<int>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return _CabinetQuantityDialog(
          title: title,
          description: description,
          maxQuantity: maxQuantity,
          actionText: actionText,
        );
      },
    );
  }

  // =========================================================
  // API İŞLEMİ
  // =========================================================

  Future<void> _execute({
    required Future<dynamic>
        Function() action,
    required String message,
  }) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await action();

      if (!mounted) {
        return;
      }

      await _loadCabinet();

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
            message,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

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
          message,
        ),
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
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        title: Text(
          '${widget.cake.name} - Dolap',
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed:
                _isProcessing
                    ? null
                    : _loadCabinet,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      AppColors.primary,
                ),
              )
            : _buildBody(),
      ),
    );
  }

  // =========================================================
  // BODY
  // =========================================================

  Widget _buildBody() {
    if (_errorMessage != null) {
      return RefreshIndicator(
        color:
            AppColors.primary,
        onRefresh:
            _loadCabinet,
        child: ListView(
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
                    _loadCabinet,
                icon: const Icon(
                  Icons.refresh,
                ),
                label:
                    const Text(
                  'Tekrar Dene',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color:
          AppColors.primary,
      onRefresh:
          _loadCabinet,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          30,
        ),
        children: [
          _buildSummary(),

          const SizedBox(
            height: 24,
          ),

          const Text(
            'Dolaba Konulan Pastalar',
            style: TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'Her dolap girişi ayrı bir parti olarak '
            'tarih ve gün bilgisiyle gösterilir.',
            style: TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          if (_records.isEmpty)
            _buildEmptyState()
          else
            ..._records.map(
              (
                cabinet,
              ) =>
                  _CabinetRecordCard(
                cabinet:
                    cabinet,
                formattedDate:
                    _formatDateTime(
                  cabinet.createdAt,
                ),
                onSale: () =>
                    _createSale(
                  cabinet,
                ),
                onWaste: () =>
                    _createWaste(
                  cabinet,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================
  // ÖZET
  // =========================================================

  Widget _buildSummary() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
                    Icons.storefront,
                    color:
                        AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(
                  width: 14,
                ),
                Expanded(
                  child: Text(
                    widget.cake.name,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      _SummaryItem(
                    label:
                        'Ana Stok',
                    value:
                        '${widget.cake.currentSliceStock} dilim',
                  ),
                ),
                Expanded(
                  child:
                      _SummaryItem(
                    label:
                        'Dolap',
                    value:
                        '$_totalCabinetSlices dilim',
                  ),
                ),
                Expanded(
                  child:
                      _SummaryItem(
                    label:
                        'Dilim Fiyatı',
                    value:
                        '${widget.cake.sliceSalePrice.toStringAsFixed(2)} ₺',
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
  // BOŞ DOLAP
  // =========================================================

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 50,
          horizontal: 24,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.storefront_outlined,
              size: 60,
              color:
                  AppColors.textSecondary,
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Dolapta pasta bulunmuyor.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.textPrimary,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Stok İşlemleri bölümünden '
              'pastayı dolaba aktarabilirsiniz.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// DOLAP PARTİ KARTI
// =============================================================

class _CabinetRecordCard
    extends StatelessWidget {
  final CakeCabinet cabinet;
  final String formattedDate;
  final VoidCallback onSale;
  final VoidCallback onWaste;

  const _CabinetRecordCard({
    required this.cabinet,
    required this.formattedDate,
    required this.onSale,
    required this.onWaste,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final isEmpty =
        cabinet.remainingQuantity <= 0;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // -------------------------------------------------
            // TARİH + GÜN
            // -------------------------------------------------

            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(9),
                  decoration:
                      BoxDecoration(
                    color:
                        AppColors.primary.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dolaba Konulma Tarihi',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

    // -------------------------------------------------
    // SADECE KALAN PASTA VARSA GÜN BİLGİSİ
    // -------------------------------------------------

    if (cabinet.remainingQuantity > 0)
      Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration:
            BoxDecoration(
          color:
              AppColors.primary,
          borderRadius:
              BorderRadius.circular(
            10,
          ),
        ),
        child: Text(
          cabinet.cabinetDurationText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
  ],
),


            // -------------------------------------------------
            // PARTİ BİLGİSİ
            // -------------------------------------------------

            Container(
              padding:
                  const EdgeInsets.all(14),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.background,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child:
                        _RecordValue(
                      label:
                          'İlk Miktar',
                      value:
                          '${cabinet.sliceQuantity}',
                    ),
                  ),
                  Expanded(
                    child:
                        _RecordValue(
                      label:
                          'Satılan',
                      value:
                          '${cabinet.soldQuantity}',
                    ),
                  ),
                  Expanded(
                    child:
                        _RecordValue(
                      label:
                          'Zayi',
                      value:
                          '${cabinet.wastedQuantity}',
                    ),
                  ),
                  Expanded(
                    child:
                        _RecordValue(
                      label:
                          'Kalan',
                      value:
                          '${cabinet.remainingQuantity}',
                      highlighted:
                          true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // -------------------------------------------------
            // FİYAT
            // -------------------------------------------------

            Row(
              children: [
                const Icon(
                  Icons.sell_outlined,
                  size: 18,
                  color:
                      AppColors.textSecondary,
                ),
                const SizedBox(
                  width: 7,
                ),
                const Text(
                  'Dilim satış fiyatı: ',
                  style:
                      TextStyle(
                    color:
                        AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${cabinet.sliceSalePrice.toStringAsFixed(2)} ₺',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            // -------------------------------------------------
            // SATIŞ + ZAYİ
            // -------------------------------------------------

            if (!isEmpty) ...[
              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          onSale,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary,
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                      icon:
                          const Icon(
                        Icons.point_of_sale,
                      ),
                      label:
                          const Text(
                        'Satış Yap',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          onWaste,
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            AppColors.danger,
                        side:
                            const BorderSide(
                          color:
                              AppColors.danger,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                      icon:
                          const Icon(
                        Icons.delete_outline,
                      ),
                      label:
                          const Text(
                        'Zayi',
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(
                height: 14,
              ),

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 12,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.textSecondary
                          .withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color:
                          AppColors.textSecondary,
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                      'Bu partide kalan pasta yok.',
                      style:
                          TextStyle(
                        color:
                            AppColors.textSecondary,
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
}

// =============================================================
// KAYIT İÇİ DEĞER
// =============================================================

class _RecordValue
    extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  const _RecordValue({
    required this.label,
    required this.value,
    this.highlighted = false,
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
          label,
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
            color: highlighted
                ? AppColors.primary
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =============================================================
// ÖZET BİLGİ
// =============================================================

class _SummaryItem
    extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({
    required this.label,
    required this.value,
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
          label,
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
              const TextStyle(
            fontSize: 16,
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

// =============================================================
// MİKTAR DİYALOĞU
// =============================================================

class _CabinetQuantityDialog
    extends StatefulWidget {
  final String title;
  final String description;
  final int maxQuantity;
  final String actionText;

  const _CabinetQuantityDialog({
    required this.title,
    required this.description,
    required this.maxQuantity,
    required this.actionText,
  });

  @override
  State<_CabinetQuantityDialog>
      createState() =>
          _CabinetQuantityDialogState();
}

class _CabinetQuantityDialogState
    extends State<
        _CabinetQuantityDialog> {
  late final TextEditingController
      _controller;

  String? _error;

  @override
  void initState() {
    super.initState();

    _controller =
        TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value =
        int.tryParse(
      _controller.text.trim(),
    );

    if (value == null) {
      setState(() {
        _error =
            'Geçerli bir miktar girin.';
      });
      return;
    }

    if (value <= 0) {
      setState(() {
        _error =
            'Miktar 0\'dan büyük olmalıdır.';
      });
      return;
    }

    if (value > widget.maxQuantity) {
      setState(() {
        _error =
            'En fazla ${widget.maxQuantity} '
            'dilim girebilirsiniz.';
      });
      return;
    }

    Navigator.of(
      context,
    ).pop(value);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title: Text(
        widget.title,
      ),
      content:
          SingleChildScrollView(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.description,
              style:
                  const TextStyle(
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Mevcut: '
              '${widget.maxQuantity} dilim',
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  _controller,
              autofocus: true,
              keyboardType:
                  TextInputType.number,
              decoration:
                  InputDecoration(
                labelText:
                    'Dilim miktarı',
                suffixText:
                    'dilim',
                errorText:
                    _error,
              ),
              onSubmitted:
                  (_) => _submit(),
            ),
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
          child: Text(
            widget.actionText,
          ),
        ),
      ],
    );
  }
}
