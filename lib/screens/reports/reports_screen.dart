import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/reports/report_dashboard.dart';
import '../../models/reports/report_summary.dart';
import '../../models/reports/top_selling_cake.dart';
import '../../services/report_service.dart';
import 'cake_analysis_screen.dart';

class ReportsScreen extends StatefulWidget {
  final ReportService reportService;

  const ReportsScreen({
    super.key,
    required this.reportService,
  });

  @override
  State<ReportsScreen> createState() =>
      _ReportsScreenState();
}

class _ReportsScreenState
    extends State<ReportsScreen> {
  ReportDashboard? _report;

  ReportSummary? _summary;

  bool _isLoading = true;

  bool _isSummaryLoading = false;

  String? _errorMessage;

  String? _summaryErrorMessage;

  _ReportPeriod _selectedPeriod =
      _ReportPeriod.thisMonth;

  DateTimeRange? _customDateRange;

  DateTime _summaryStartDate =
      DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  DateTime _summaryEndDate =
      DateTime.now();

  @override
  void initState() {
    super.initState();

    _loadReport();

    _loadInitialSummary();
  }

  // =========================================================
  // RAPOR YÜKLE
  // =========================================================

  Future<void> _loadReport() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final report =
          await widget.reportService
              .getDashboard();

      if (!mounted) {
        return;
      }

      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            _getErrorMessage(error);

        _isLoading = false;
      });
    }
  }

  // =========================================================
  // İLK ÖZET RAPOR
  // =========================================================

  Future<void> _loadInitialSummary() async {
    final range =
        _getDateRangeForPeriod(
      _selectedPeriod,
    );

    _summaryStartDate =
        range.start;

    _summaryEndDate =
        range.end;

    await _loadSummary();
  }

  // =========================================================
  // TARİH BAZLI ÖZET YÜKLE
  // =========================================================

  Future<void> _loadSummary() async {
    if (mounted) {
      setState(() {
        _isSummaryLoading = true;
        _summaryErrorMessage = null;
      });
    }

    try {
      final summary =
          await widget.reportService
              .getSummary(
        startDate:
            _summaryStartDate,
        endDate:
            _summaryEndDate,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _summary = summary;
        _isSummaryLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _summaryErrorMessage =
            _getErrorMessage(error);

        _isSummaryLoading = false;
      });
    }
  }

  // =========================================================
  // DÖNEM SEÇ
  // =========================================================

  Future<void> _selectPeriod(
    _ReportPeriod period,
  ) async {
    if (period ==
        _ReportPeriod.custom) {
      await _selectCustomDateRange();

      return;
    }

    final range =
        _getDateRangeForPeriod(
      period,
    );

    setState(() {
      _selectedPeriod = period;

      _summaryStartDate =
          range.start;

      _summaryEndDate =
          range.end;

      _customDateRange = null;
    });

    await _loadSummary();
  }

  // =========================================================
  // ÖZEL TARİH SEÇ
  // =========================================================

  Future<void>
      _selectCustomDateRange() async {
    final now =
        DateTime.now();

    final initialRange =
        _customDateRange ??
            DateTimeRange(
              start:
                  now.subtract(
                const Duration(
                  days: 6,
                ),
              ),
              end: now,
            );

    final selectedRange =
        await showDateRangePicker(
      context: context,
      firstDate: DateTime(
        2020,
      ),
      lastDate: DateTime(
        now.year + 5,
      ),
      initialDateRange:
          initialRange,
    );

    if (selectedRange == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedPeriod =
          _ReportPeriod.custom;

      _customDateRange =
          selectedRange;

      _summaryStartDate =
          selectedRange.start;

      _summaryEndDate =
          selectedRange.end;
    });

    await _loadSummary();
  }

  // =========================================================
  // DÖNEM TARİHİ
  // =========================================================

  DateTimeRange
      _getDateRangeForPeriod(
    _ReportPeriod period,
  ) {
    final now =
        DateTime.now();

    final today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    switch (period) {
      case _ReportPeriod.today:
        return DateTimeRange(
          start: today,
          end: today,
        );

      case _ReportPeriod.thisWeek:
        final weekday =
            today.weekday;

        final start =
            today.subtract(
          Duration(
            days: weekday - 1,
          ),
        );

        return DateTimeRange(
          start: start,
          end: today,
        );

      case _ReportPeriod.thisMonth:
        return DateTimeRange(
          start: DateTime(
            today.year,
            today.month,
            1,
          ),
          end: today,
        );

      case _ReportPeriod.custom:
        return _customDateRange ??
            DateTimeRange(
              start: today,
              end: today,
            );
    }
  }

  // =========================================================
  // YENİLE
  // =========================================================

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadReport(),
      _loadSummary(),
    ]);
  }

  // =========================================================
  // HATA MESAJI
  // =========================================================

  String _getErrorMessage(
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
  // TARİH FORMATLAMA
  // =========================================================

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day
            .toString()
            .padLeft(
              2,
              '0',
            );

    final month =
        date.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    final year =
        date.year.toString();

    return '$day.$month.$year';
  }

  String get _selectedDateRangeText {
    return '${_formatDate(_summaryStartDate)} - '
        '${_formatDate(_summaryEndDate)}';
  }

  // =========================================================
  // PASTA ANALİZİ SAYFASINI AÇ
  // =========================================================

  void _openCakeAnalysis() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const CakeAnalysisScreen(),
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
        title: const Text(
          'Raporlar',
        ),
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        actions: [
          IconButton(
            onPressed:
                _isLoading ||
                        _isSummaryLoading
                    ? null
                    : _refreshAll,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip:
                'Yenile',
          ),
        ],
      ),

      body: _buildBody(),
    );
  }

  // =========================================================
  // BODY
  // =========================================================

  Widget _buildBody() {
    if (_isLoading &&
        _report == null) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null &&
        _report == null) {
      return _buildDashboardError();
    }

    final report =
        _report;

    if (report == null) {
      return const Center(
        child: Text(
          'Rapor verisi bulunamadı.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:
          _refreshAll,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          16,
        ),
        children: [
          // ===============================================
          // DETAYLI ANALİZ
          // ===============================================

          const _SectionTitle(
            title:
                'Detaylı Analiz',
          ),

          const SizedBox(
            height: 12,
          ),

          _buildCakeAnalysisCard(),

          const SizedBox(
            height: 32,
          ),

          // ===============================================
          // TARİH BAZLI RAPOR
          // ===============================================

          _buildPeriodReportSection(),

          const SizedBox(
            height: 32,
          ),

          // ===============================================
          // GENEL ÖZET
          // ===============================================

          const _SectionTitle(
            title:
                'Genel Özet',
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons
                          .inventory_2_outlined,
                  title:
                      'Aktif Ürün',
                  value:
                      report
                          .totalProductCount
                          .toString(),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons
                          .warning_amber_outlined,
                  title:
                      'Düşük Stok',
                  value:
                      report
                          .lowStockProductCount
                          .toString(),
                  subtitle:
                      report
                          .lowStockRateText,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          // ===============================================
          // PASTA STOĞU
          // ===============================================

          const _SectionTitle(
            title:
                'Pasta Stoğu',
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons.cake_outlined,
                  title:
                      'Aktif Pasta',
                  value:
                      report
                          .totalCakeCount
                          .toString(),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons.layers_outlined,
                  title:
                      'Ana Stok',
                  value:
                      report
                          .totalCakeStockText,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          _WideReportCard(
            icon:
                Icons.inventory_outlined,
            title:
                'Toplam Kullanılabilir Stok',
            value:
                report
                    .totalAvailableSliceCountText,
          ),

          const SizedBox(
            height: 24,
          ),

          // ===============================================
          // DOLAP
          // ===============================================

          const _SectionTitle(
            title:
                'Dolap',
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons.kitchen_outlined,
                  title:
                      'Dolapta Kalan',
                  value:
                      report
                          .cabinetRemainingSliceCountText,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons.point_of_sale_outlined,
                  title:
                      'Satılan',
                  value:
                      report
                          .cabinetSoldSliceCountText,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons.delete_outline,
                  title:
                      'Dolap Zayi',
                  value:
                      report
                          .cabinetWastedSliceCountText,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons.percent_outlined,
                  title:
                      'Zayi Oranı',
                  value:
                      report.wasteRateText,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          // ===============================================
          // CİRO
          // ===============================================

          const _SectionTitle(
            title:
                'Ciro',
          ),

          const SizedBox(
            height: 12,
          ),

          _WideReportCard(
            icon:
                Icons.trending_up_outlined,
            title:
                'Potansiyel Ciro',
            value:
                report
                    .totalPotentialRevenueText,
          ),

          const SizedBox(
            height: 12,
          ),

          _WideReportCard(
            icon:
                Icons.payments_outlined,
            title:
                'Gerçekleşen Ciro',
            value:
                report
                    .totalRealizedRevenueText,
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons
                          .compare_arrows_outlined,
                  title:
                      'Ciro Farkı',
                  value:
                      report
                          .revenueDifferenceText,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons.percent_outlined,
                  title:
                      'Gerçekleşme',
                  value:
                      report
                          .revenueRealizationRateText,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          // ===============================================
          // ZAYİ ANALİZİ
          // ===============================================

          const _SectionTitle(
            title:
                'Zayi Analizi',
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons
                          .delete_forever_outlined,
                  title:
                      'Toplam Zayi',
                  value:
                      report
                          .totalWastedSliceCountText,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons
                          .money_off_csred_outlined,
                  title:
                      'Zayi Maliyeti',
                  value:
                      report
                          .totalWasteCostText,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons
                          .account_balance_wallet_outlined,
                  title:
                      'Zayi Sonrası Gelir',
                  value:
                      report
                          .netRevenueAfterWasteText,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    _ReportCard(
                  icon:
                      Icons.percent_outlined,
                  title:
                      'Zayi Maliyet Oranı',
                  value:
                      report
                          .wasteCostRateText,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PASTA ANALİZİ KARTI
  // =========================================================

  Widget _buildCakeAnalysisCard() {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        onTap:
            _openCakeAnalysis,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          child: Row(
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
                  Icons.analytics_outlined,
                  color:
                      AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(
                width: 16,
              ),

              const Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pasta Analizi',
                      style:
                          TextStyle(
                        color:
                            AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    SizedBox(
                      height: 4,
                    ),

                    Text(
                      'Günlük, haftalık ve aylık satış, ciro ve zayi analizlerini görüntüle',
                      style:
                          TextStyle(
                        color:
                            AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              const Icon(
                Icons.chevron_right,
                color:
                    AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // DÖNEM RAPORU
  // =========================================================

  Widget _buildPeriodReportSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title:
              'Tarih Bazlı Rapor',
        ),

        const SizedBox(
          height: 12,
        ),

        _buildPeriodSelector(),

        const SizedBox(
          height: 12,
        ),

        _buildDateRangeCard(),

        const SizedBox(
          height: 16,
        ),

        if (_isSummaryLoading)
          const Center(
            child:
                Padding(
              padding:
                  EdgeInsets.all(
                24,
              ),
              child:
                  CircularProgressIndicator(),
            ),
          )
        else if (_summaryErrorMessage !=
            null)
          _buildSummaryError()
        else if (_summary != null)
          _buildSummaryContent(
            _summary!,
          )
        else
          const _EmptyReportCard(
            message:
                'Bu tarih aralığı için rapor verisi bulunamadı.',
          ),
      ],
    );
  }

  // =========================================================
  // DÖNEM SEÇİCİ
  // =========================================================

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal,
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          _PeriodButton(
            label:
                'Bugün',
            isSelected:
                _selectedPeriod ==
                    _ReportPeriod.today,
            onPressed: () {
              _selectPeriod(
                _ReportPeriod.today,
              );
            },
          ),

          const SizedBox(
            width: 8,
          ),

          _PeriodButton(
            label:
                'Bu Hafta',
            isSelected:
                _selectedPeriod ==
                    _ReportPeriod.thisWeek,
            onPressed: () {
              _selectPeriod(
                _ReportPeriod.thisWeek,
              );
            },
          ),

          const SizedBox(
            width: 8,
          ),

          _PeriodButton(
            label:
                'Bu Ay',
            isSelected:
                _selectedPeriod ==
                    _ReportPeriod.thisMonth,
            onPressed: () {
              _selectPeriod(
                _ReportPeriod.thisMonth,
              );
            },
          ),

          const SizedBox(
            width: 8,
          ),

          _PeriodButton(
            label:
                'Özel Tarih',
            icon:
                Icons.date_range_outlined,
            isSelected:
                _selectedPeriod ==
                    _ReportPeriod.custom,
            onPressed:
                _selectCustomDateRange,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TARİH ARALIĞI KARTI
  // =========================================================

  Widget _buildDateRangeCard() {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
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
            Icons.calendar_month_outlined,
            color:
                AppColors.primary,
          ),
        ),
        title: const Text(
          'Seçilen Tarih Aralığı',
        ),
        subtitle: Text(
          _selectedDateRangeText,
        ),
        trailing: IconButton(
          onPressed:
              _isSummaryLoading
                  ? null
                  : _selectCustomDateRange,
          icon: const Icon(
            Icons.edit_calendar_outlined,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // SUMMARY CONTENT
  // =========================================================

  Widget _buildSummaryContent(
    ReportSummary summary,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child:
                  _ReportCard(
                icon:
                    Icons.point_of_sale_outlined,
                title:
                    'Satılan',
                value:
                    summary
                        .totalSoldSliceCountText,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child:
                  _ReportCard(
                icon:
                    Icons.payments_outlined,
                title:
                    'Ciro',
                value:
                    summary
                        .totalRealizedRevenueText,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        Row(
          children: [
            Expanded(
              child:
                  _ReportCard(
                icon:
                    Icons
                        .delete_forever_outlined,
                title:
                    'Zayi',
                value:
                    summary
                        .totalWastedSliceCountText,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child:
                  _ReportCard(
                icon:
                    Icons
                        .money_off_csred_outlined,
                title:
                    'Zayi Maliyeti',
                value:
                    summary
                        .totalWasteCostText,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        _WideReportCard(
          icon:
              Icons.kitchen_outlined,
          title:
              'Dolaba Konan Toplam',
          value:
              summary
                  .totalCabinetSliceCountText,
        ),

        const SizedBox(
          height: 24,
        ),

        _buildTopSellingCakes(
          summary,
        ),
      ],
    );
  }

  // =========================================================
  // EN ÇOK SATAN PASTALAR
  // =========================================================

  Widget _buildTopSellingCakes(
    ReportSummary summary,
  ) {
    if (summary
        .topSellingCakes
        .isEmpty) {
      return const _EmptyReportCard(
        message:
            'Bu tarih aralığında satış verisi bulunamadı.',
      );
    }

    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  color:
                      AppColors.primary,
                ),

                SizedBox(
                  width: 8,
                ),

                Text(
                  'En Çok Satan Pastalar',
                  style:
                      TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            ...List.generate(
              summary
                  .topSellingCakes
                  .length,
              (index) {
                final cake =
                    summary
                        .topSellingCakes[index];

                return _TopSellingCakeItem(
                  index:
                      index + 1,
                  cake:
                      cake,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DASHBOARD ERROR
  // =========================================================

  Widget _buildDashboardError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color:
                  Colors.red,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              _errorMessage ??
                  'Rapor yüklenirken bir hata oluştu.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed:
                  _loadReport,
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

  // =========================================================
  // SUMMARY ERROR
  // =========================================================

  Widget _buildSummaryError() {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color:
                  Colors.red,
              size: 36,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              _summaryErrorMessage ??
                  'Tarih bazlı rapor yüklenirken hata oluştu.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            ElevatedButton.icon(
              onPressed:
                  _loadSummary,
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

// ===========================================================
// RAPOR DÖNEMİ
// ===========================================================

enum _ReportPeriod {
  today,
  thisWeek,
  thisMonth,
  custom,
}

// ===========================================================
// BÖLÜM BAŞLIĞI
// ===========================================================

class _SectionTitle
    extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      title,
      style:
          const TextStyle(
        fontSize: 20,
        fontWeight:
            FontWeight.bold,
        color:
            AppColors.textPrimary,
      ),
    );
  }
}

// ===========================================================
// KÜÇÜK RAPOR KARTI
// ===========================================================

class _ReportCard
    extends StatelessWidget {
  final IconData icon;

  final String title;

  final String value;

  final String? subtitle;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color:
                  AppColors.primary,
              size: 28,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              value,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                fontSize: 20,
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
              title,
              style:
                  const TextStyle(
                fontSize: 13,
                color:
                    AppColors.textSecondary,
              ),
            ),

            if (subtitle != null) ...[
              const SizedBox(
                height: 4,
              ),

              Text(
                subtitle!,
                style:
                    const TextStyle(
                  fontSize: 12,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===========================================================
// GENİŞ RAPOR KARTI
// ===========================================================

class _WideReportCard
    extends StatelessWidget {
  final IconData icon;

  final String title;

  final String value;

  const _WideReportCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
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
              child: Icon(
                icon,
                color:
                    AppColors.primary,
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
                    title,
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
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          AppColors.textPrimary,
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
}

// ===========================================================
// DÖNEM BUTONU
// ===========================================================

class _PeriodButton
    extends StatelessWidget {
  final String label;

  final IconData? icon;

  final bool isSelected;

  final VoidCallback onPressed;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return OutlinedButton.icon(
      onPressed:
          onPressed,
      icon: icon == null
          ? const SizedBox.shrink()
          : Icon(
              icon,
              size: 18,
            ),
      label: Text(
        label,
      ),
      style:
          OutlinedButton.styleFrom(
        foregroundColor:
            isSelected
                ? Colors.white
                : AppColors.primary,
        backgroundColor:
            isSelected
                ? AppColors.primary
                : Colors.transparent,
        side:
            BorderSide(
          color:
              AppColors.primary,
        ),
        minimumSize:
            const Size(
          0,
          46,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
      ),
    );
  }
}

// ===========================================================
// BOŞ RAPOR KARTI
// ===========================================================

class _EmptyReportCard
    extends StatelessWidget {
  final String message;

  const _EmptyReportCard({
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child: Center(
          child: Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// EN ÇOK SATAN PASTA ITEM
// ===========================================================

class _TopSellingCakeItem
    extends StatelessWidget {
  final int index;

  final TopSellingCake cake;

  const _TopSellingCakeItem({
    required this.index,
    required this.cake,
  });

  String _formatRevenue(
    double value,
  ) {
    if (value ==
        value.truncateToDouble()) {
      return '${value.toInt()} ₺';
    }

    return '${value.toStringAsFixed(2)} ₺';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                AppColors.primary
                    .withValues(
              alpha: 0.10,
            ),
            child: Text(
              index.toString(),
              style:
                  const TextStyle(
                color:
                    AppColors.primary,
                fontWeight:
                    FontWeight.bold,
              ),
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
                  cake.cakeName,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  '${cake.soldSliceCount} dilim',
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

          Text(
            _formatRevenue(
              cake.revenue,
            ),
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
    );
  }
}