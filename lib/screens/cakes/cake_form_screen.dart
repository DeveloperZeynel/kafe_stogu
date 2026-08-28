import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/cakes/cake.dart';
import '../../services/cake_service.dart';

class CakeFormScreen
    extends StatefulWidget {
  final CakeService cakeService;
  final Cake? cake;

  const CakeFormScreen({
    super.key,
    required this.cakeService,
    this.cake,
  });

  bool get isEdit =>
      cake != null;

  @override
  State<CakeFormScreen> createState() =>
      _CakeFormScreenState();
}

class _CakeFormScreenState
    extends State<CakeFormScreen> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _nameController;

  late final TextEditingController
      _sliceCountController;

  late final TextEditingController
      _slicesPerBoxController;

  late final TextEditingController
      _boxPurchasePriceController;

  late final TextEditingController
      _sliceSalePriceController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final cake = widget.cake;

    _nameController =
        TextEditingController(
      text: cake?.name ?? '',
    );

    _sliceCountController =
        TextEditingController(
      text: cake == null
          ? ''
          : cake.initialSliceCount
              .toString(),
    );

    _slicesPerBoxController =
        TextEditingController(
      text: cake == null
          ? ''
          : cake.slicesPerBox
              .toString(),
    );

    _boxPurchasePriceController =
        TextEditingController(
      text: cake == null
          ? ''
          : cake.boxPurchasePrice
              .toString(),
    );

    _sliceSalePriceController =
        TextEditingController(
      text: cake == null
          ? ''
          : cake.sliceSalePrice
              .toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sliceCountController.dispose();
    _slicesPerBoxController.dispose();
    _boxPurchasePriceController
        .dispose();
    _sliceSalePriceController
        .dispose();

    super.dispose();
  }

  String? _required(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Bu alan zorunludur.';
    }

    return null;
  }

  String? _positiveInteger(
    String? value,
  ) {
    final required =
        _required(value);

    if (required != null) {
      return required;
    }

    final number =
        int.tryParse(
      value!.trim(),
    );

    if (number == null ||
        number <= 0) {
      return '0\'dan büyük bir tam sayı girin.';
    }

    return null;
  }

  String? _positiveDecimal(
    String? value,
  ) {
    final required =
        _required(value);

    if (required != null) {
      return required;
    }

    final normalized =
        value!.trim().replaceAll(
              ',',
              '.',
            );

    final number =
        double.tryParse(
      normalized,
    );

    if (number == null ||
        number <= 0) {
      return 'Geçerli bir fiyat girin.';
    }

    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final name =
          _nameController.text.trim();

      final slicesPerBox =
          int.parse(
        _slicesPerBoxController
            .text
            .trim(),
      );

      final boxPurchasePrice =
          double.parse(
        _boxPurchasePriceController
            .text
            .trim()
            .replaceAll(
              ',',
              '.',
            ),
      );

      final sliceSalePrice =
          double.parse(
        _sliceSalePriceController
            .text
            .trim()
            .replaceAll(
              ',',
              '.',
            ),
      );

      if (widget.isEdit) {
        await widget.cakeService
            .update(
          id: widget.cake!.id,
          name: name,
          slicesPerBox:
              slicesPerBox,
          boxPurchasePrice:
              boxPurchasePrice,
          sliceSalePrice:
              sliceSalePrice,
        );
      } else {
        final sliceCount =
            int.parse(
          _sliceCountController
              .text
              .trim(),
        );

        await widget.cakeService
            .create(
          name: name,
          sliceCount:
              sliceCount,
          slicesPerBox:
              slicesPerBox,
          boxPurchasePrice:
              boxPurchasePrice,
          sliceSalePrice:
              sliceSalePrice,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Pasta başarıyla güncellendi.'
                : 'Pasta başarıyla eklendi.',
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
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          backgroundColor:
              AppColors.danger,
          content: Text(
            e.toString()
                .replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final isEdit =
        widget.isEdit;

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
              ? 'Pasta Düzenle'
              : 'Pasta Ekle',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.all(16),
          children: [
            _buildSectionTitle(
              isEdit
                  ? 'Pasta Bilgilerini Düzenle'
                  : 'Yeni Pasta',
            ),

            const SizedBox(
              height: 16,
            ),

            TextFormField(
              controller:
                  _nameController,
              textInputAction:
                  TextInputAction.next,
              decoration:
                  const InputDecoration(
                labelText:
                    'Pasta adı',
                prefixIcon:
                    Icon(
                  Icons.cake_outlined,
                ),
              ),
              validator:
                  _required,
            ),

            if (!isEdit) ...[
              const SizedBox(
                height: 14,
              ),
              TextFormField(
                controller:
                    _sliceCountController,
                keyboardType:
                    TextInputType.number,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'İlk dilim sayısı',
                  prefixIcon:
                      Icon(
                    Icons
                        .format_list_numbered,
                  ),
                  helperText:
                      'Pasta ilk kaydedildiğinde '
                      'stoğa eklenecek dilim sayısı.',
                ),
                validator:
                    _positiveInteger,
              ),
            ],

            const SizedBox(
              height: 14,
            ),

            TextFormField(
              controller:
                  _slicesPerBoxController,
              keyboardType:
                  TextInputType.number,
              textInputAction:
                  TextInputAction.next,
              decoration:
                  const InputDecoration(
                labelText:
                    'Kutu başına dilim',
                prefixIcon:
                    Icon(
                  Icons
                      .view_module_outlined,
                ),
              ),
              validator:
                  _positiveInteger,
            ),

            const SizedBox(
              height: 14,
            ),

            TextFormField(
              controller:
                  _boxPurchasePriceController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              textInputAction:
                  TextInputAction.next,
              decoration:
                  const InputDecoration(
                labelText:
                    'Kutu alış fiyatı',
                prefixIcon:
                    Icon(
                  Icons
                      .shopping_bag_outlined,
                ),
                suffixText:
                    '₺',
              ),
              validator:
                  _positiveDecimal,
            ),

            const SizedBox(
              height: 14,
            ),

            TextFormField(
              controller:
                  _sliceSalePriceController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              textInputAction:
                  TextInputAction.done,
              onFieldSubmitted:
                  (_) => _save(),
              decoration:
                  const InputDecoration(
                labelText:
                    'Dilim satış fiyatı',
                prefixIcon:
                    Icon(
                  Icons
                      .sell_outlined,
                ),
                suffixText:
                    '₺',
              ),
              validator:
                  _positiveDecimal,
            ),

            if (isEdit) ...[
              const SizedBox(
                height: 20,
              ),

              Container(
                padding:
                    const EdgeInsets.all(
                  14,
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
                    12,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color:
                          AppColors.primary,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child:
                          Text(
                        'Mevcut stok bu ekrandan '
                        'değiştirilmez. Stok değişikliği '
                        'Stok İşlemleri bölümünden yapılır.',
                        style:
                            const TextStyle(
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

            const SizedBox(
              height: 28,
            ),

            SizedBox(
              height: 52,
              child:
                  ElevatedButton.icon(
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
                          strokeWidth:
                              2,
                          color:
                              Colors.white,
                        ),
                      )
                    : Icon(
                        isEdit
                            ? Icons.save_outlined
                            : Icons.add,
                      ),
                label: Text(
                  _isSaving
                      ? 'Kaydediliyor...'
                      : isEdit
                          ? 'Değişiklikleri Kaydet'
                          : 'Pastayı Ekle',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style:
          const TextStyle(
        fontSize: 21,
        fontWeight:
            FontWeight.bold,
        color:
            AppColors.textPrimary,
      ),
    );
  }
}