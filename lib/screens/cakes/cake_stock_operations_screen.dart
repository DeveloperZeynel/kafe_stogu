import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/cakes/cake.dart';
import '../../services/cake_service.dart';
import 'cake_cabinet_screen.dart';

class CakeStockOperationsScreen extends StatefulWidget {
  final Cake cake;
  final CakeService cakeService;

  const CakeStockOperationsScreen({
    super.key,
    required this.cake,
    required this.cakeService,
  });

  @override
  State<CakeStockOperationsScreen> createState() =>
      _CakeStockOperationsScreenState();
}

class _CakeStockOperationsScreenState
    extends State<CakeStockOperationsScreen> {
  bool _isProcessing = false;

  // ===========================================================
  // BU EKRANDA STOK DEĞİŞİKLİĞİ YAPILDI MI?
  //
  // CakesScreen'e geri dönüldüğünde true gönderilirse
  // ana pasta listesi API'den tekrar yüklenir.
  // ===========================================================

  bool _hasChanges = false;

  // ===========================================================
  // GÜNCEL PASTA
  //
  // widget.cake ekran açıldığı andaki veridir.
  // Stok işlemlerinden sonra güncel veriyi burada tutuyoruz.
  // ===========================================================

  late Cake _cake;

  // ===========================================================
  // INIT
  // ===========================================================

  @override
  void initState() {
    super.initState();

    _cake = widget.cake;
  }

  // ===========================================================
  // PASTAYI YENİLE
  //
  // API'den güncel pasta bilgisini tekrar çeker.
  // Böylece mevcut stok ekran üzerinde anında güncellenir.
  // ===========================================================

  Future<void> _refreshCake() async {
    final updatedCake =
        await widget.cakeService.getById(
      _cake.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _cake = updatedCake;
    });
  }

  // ===========================================================
  // GERİ DÖN
  // ===========================================================

  void _goBack() {
    Navigator.of(context).pop(
      _hasChanges,
    );
  }

  // ===========================================================
  // STOK GİRİŞİ / DÜZELTME
  // ===========================================================

  Future<void> _stockAdjustment() async {
    final quantity =
        await _showQuantityDialog(
      title:
          'Stok Girişi / Düzeltme',
      description:
          'Pozitif değer stok ekler, negatif değer stoktan düşer.',
      allowNegative: true,
    );

    if (quantity == null || !mounted) {
      return;
    }

    await _execute(
      action: () =>
          widget.cakeService.adjustStock(
        id: _cake.id,
        quantity: quantity,
      ),
      message:
          'Stok işlemi başarıyla tamamlandı.',
    );
  }

  // ===========================================================
  // DOLABA KOY
  // ===========================================================

  Future<void> _putInCabinet() async {
    final quantity =
        await _showQuantityDialog(
      title:
          'Dolaba Koy',
      description:
          'Ana stoktan dolaba aktarılacak dilim sayısını girin.',
    );

    if (quantity == null || !mounted) {
      return;
    }

    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await widget.cakeService.putInCabinet(
        id: _cake.id,
        sliceQuantity: quantity,
      );

      // =======================================================
      // API işlemi tamamlandıktan sonra
      // güncel pasta stok bilgisini tekrar çek.
      //
      // Örnek:
      // 14 dilim
      // ↓
      // Dolaba 2 dilim
      // ↓
      // API'den tekrar çek
      // ↓
      // 12 dilim
      // =======================================================

      await _refreshCake();

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
        _hasChanges = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Pasta dolaba başarıyla aktarıldı.',
          ),
        ),
      );

      // Dolaba koyduktan sonra dolap ekranını aç.
      await _openCabinetScreen();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
      });

      _showError(e);
    }
  }

  // ===========================================================
  // DOLABA KONULAN PASTALAR
  // ===========================================================

  Future<void> _openCabinetScreen() async {
    if (_isProcessing) {
      return;
    }

    final result =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            CakeCabinetScreen(
          cake: _cake,
          cakeService:
              widget.cakeService,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      setState(() {
        _hasChanges = true;
      });
    }

    // Dolap ekranından geri dönüldüğünde de
    // ana stok bilgisini tekrar güncelle.
    try {
      await _refreshCake();
    } catch (_) {
      // Güncelleme başarısız olsa bile
      // dolap ekranından geri dönüşü engelleme.
    }
  }

  // ===========================================================
  // ANA STOK ZAYİ
  // ===========================================================

  Future<void> _createWaste() async {
    final quantity =
        await _showQuantityDialog(
      title:
          'Ana Stoktan Zayi',
      description:
          'Zayi olarak kaydedilecek dilim sayısını girin.',
    );

    if (quantity == null || !mounted) {
      return;
    }

    await _execute(
      action: () =>
          widget.cakeService.createWaste(
        id: _cake.id,
        sliceQuantity: quantity,
      ),
      message:
          'Zayi kaydı başarıyla oluşturuldu.',
    );
  }

  // ===========================================================
  // MİKTAR DİYALOĞU
  // ===========================================================

  Future<int?> _showQuantityDialog({
    required String title,
    required String description,
    bool allowNegative = false,
  }) {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return _QuantityDialog(
          title: title,
          description: description,
          allowNegative: allowNegative,
        );
      },
    );
  }

  // ===========================================================
  // API İŞLEMİ
  // ===========================================================

  Future<void> _execute({
    required Future<dynamic> Function() action,
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

      // =======================================================
      // İşlemden sonra güncel pasta bilgisini al.
      //
      // Stok düzeltme ve ana stoktan zayi işlemlerinde
      // mevcut stok ekran üzerinde anında değişir.
      // =======================================================

      await _refreshCake();

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;

        // API işlemi başarılı olduysa
        // CakesScreen'e geri dönüldüğünde liste yenilensin.
        _hasChanges = true;
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

      _showError(e);
    }
  }

  // ===========================================================
  // HATA
  // ===========================================================

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

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult:
          (
        didPop,
        result,
      ) {
        if (didPop) {
          return;
        }

        _goBack();
      },
      child: Scaffold(
        backgroundColor:
            AppColors.background,
        appBar: AppBar(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
          title: Text(
            '${_cake.name} - Stok İşlemleri',
          ),
          leading: IconButton(
            icon:
                const Icon(
              Icons.arrow_back,
            ),
            onPressed:
                _isProcessing
                    ? null
                    : _goBack,
          ),
        ),
        body: SafeArea(
          child: _isProcessing
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
                    _buildCakeSummary(),

                    const SizedBox(
                      height: 24,
                    ),

                    const Text(
                      'Stok İşlemleri',
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
                          Icons.add_box_outlined,
                      title:
                          'Stok Girişi / Düzeltme',
                      description:
                          'Ana stok miktarını artır veya azalt.',
                      onTap:
                          _stockAdjustment,
                    ),

                    _OperationCard(
                      icon:
                          Icons.storefront_outlined,
                      title:
                          'Dolaba Koy',
                      description:
                          'Ana stoktan dilimleri satış dolabına aktar.',
                      onTap:
                          _putInCabinet,
                    ),

                    _OperationCard(
                      icon:
                          Icons.kitchen_outlined,
                      title:
                          'Dolaba Konulan Pastalar',
                      description:
                          'Bu pastanın dolapta bulunan tüm girişlerini, tarihlerini ve kalan dilimlerini görüntüle.',
                      onTap:
                          _openCabinetScreen,
                    ),

                    _OperationCard(
                      icon:
                          Icons.delete_outline,
                      title:
                          'Ana Stoktan Zayi',
                      description:
                          'Ana stoktaki bozulmuş veya kullanılamaz dilimleri zayi olarak kaydet.',
                      danger: true,
                      onTap:
                          _createWaste,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Container(
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
                      child: const Row(
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
                            child: Text(
                              'Dolaptaki pastaların satışı ve dolap zayisi '
                              'dolaba konulan pastalar ekranından yönetilir.',
                              style: TextStyle(
                                color:
                                    AppColors.textPrimary,
                                fontSize: 13,
                              ),
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

  // ===========================================================
  // PASTA ÖZETİ
  // ===========================================================

  Widget _buildCakeSummary() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          18,
        ),
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
                  child: Text(
                    _cake.name,
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
                        'Mevcut Stok',
                    value:
                        '${_cake.currentSliceStock} dilim',
                  ),
                ),

                Expanded(
                  child:
                      _SummaryItem(
                    label:
                        'Dilim Satış',
                    value:
                        '${_cake.sliceSalePrice.toStringAsFixed(2)} ₺',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// MİKTAR DİYALOĞU
// =============================================================

class _QuantityDialog
    extends StatefulWidget {
  final String title;
  final String description;
  final bool allowNegative;

  const _QuantityDialog({
    required this.title,
    required this.description,
    required this.allowNegative,
  });

  @override
  State<_QuantityDialog> createState() =>
      _QuantityDialogState();
}

class _QuantityDialogState
    extends State<_QuantityDialog> {
  final TextEditingController
      _controller =
      TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value =
        _controller.text
            .trim()
            .replaceAll(
              ',',
              '.',
            );

    final quantity =
        int.tryParse(value);

    if (quantity == null) {
      setState(() {
        _errorMessage =
            'Geçerli bir tam sayı girin.';
      });
      return;
    }

    if (!widget.allowNegative &&
        quantity <= 0) {
      setState(() {
        _errorMessage =
            'Miktar 0\'dan büyük olmalıdır.';
      });
      return;
    }

    if (widget.allowNegative &&
        quantity == 0) {
      setState(() {
        _errorMessage =
            'Miktar 0 olamaz.';
      });
      return;
    }

    Navigator.of(context).pop(
      quantity,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title:
          Text(
        widget.title,
      ),
      content:
          Column(
        mainAxisSize:
            MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            widget.description,
          ),

          const SizedBox(
            height: 16,
          ),

          TextField(
            controller:
                _controller,
            keyboardType:
                const TextInputType.numberWithOptions(
              signed: true,
            ),
            autofocus: true,
            onSubmitted:
                (_) => _submit(),
            decoration:
                InputDecoration(
              labelText:
                  'Dilim Sayısı',
              border:
                  const OutlineInputBorder(),
              errorText:
                  _errorMessage,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              () {
            Navigator.of(
              context,
            ).pop();
          },
          child:
              const Text(
            'Vazgeç',
          ),
        ),

        FilledButton(
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
            fontSize: 13,
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
// İŞLEM KARTI
// =============================================================

class _OperationCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool danger;
  final VoidCallback onTap;

  const _OperationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final color =
        danger
            ? AppColors.danger
            : AppColors.primary;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        onTap: onTap,
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
                      color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
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
                      title,
                      style:
                          TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color: color,
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
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
