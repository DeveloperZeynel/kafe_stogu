import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/auth_storage.dart';
import '../../models/reports/cake_analysis.dart';
import '../../services/report_service.dart';

class CakeAnalysisScreen extends StatefulWidget {
  const CakeAnalysisScreen({
    super.key,
  });

  @override
  State<CakeAnalysisScreen> createState() =>
      _CakeAnalysisScreenState();
}

class _CakeAnalysisScreenState
    extends State<CakeAnalysisScreen> {
  late final ReportService _reportService;

  String _selectedPeriod = 'day';

  Future<CakeAnalysis>? _analysisFuture;

  @override
  void initState() {
    super.initState();

    final authStorage =
        AuthStorage();

    _reportService =
        ReportService(
      apiClient: ApiClient(
        authStorage:
            authStorage,
      ),
    );

    _loadAnalysis();
  }

  void _loadAnalysis() {
    setState(
      () {
        _analysisFuture =
            _reportService.getCakeAnalysis(
          period:
              _selectedPeriod,
        );
      },
    );
  }

  Future<void> _refresh() async {
    _analysisFuture =
        _reportService.getCakeAnalysis(
      period:
          _selectedPeriod,
    );

    setState(
      () {},
    );

    await _analysisFuture;
  }

  void _changePeriod(
    String period,
  ) {
    if (_selectedPeriod ==
        period) {
      return;
    }

    setState(
      () {
        _selectedPeriod =
            period;

        _analysisFuture =
            _reportService.getCakeAnalysis(
          period:
              period,
        );
      },
    );
  }

  String _getPeriodLabel(
    String period,
  ) {
    switch (period) {
      case 'week':
        return 'Hafta';

      case 'month':
        return 'Ay';

      case 'day':
      default:
        return 'Gün';
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Pasta Analizi',
        ),
      ),
      body:
          FutureBuilder<CakeAnalysis>(
        future:
            _analysisFuture,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildError(
              snapshot.error,
            );
          }

          final analysis =
              snapshot.data;

          if (analysis == null) {
            return _buildEmpty(
              'Rapor verisi bulunamadı.',
            );
          }

          return RefreshIndicator(
            onRefresh:
                _refresh,
            child:
                ListView(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              children: [
                _buildPeriodSelector(),

                const SizedBox(
                  height:
                      20,
                ),

                _buildDateRange(
                  analysis,
                ),

                const SizedBox(
                  height:
                      20,
                ),

                _buildSummaryCards(
                  analysis,
                ),

                const SizedBox(
                  height:
                      28,
                ),

                _buildSectionTitle(
                  'En Çok Satılan Pastalar',
                  Icons
                      .local_fire_department_outlined,
                ),

                const SizedBox(
                  height:
                      12,
                ),

                _buildTopSellingCakes(
                  analysis,
                ),

                const SizedBox(
                  height:
                      28,
                ),

                _buildSectionTitle(
                  'En Çok Zayi Veren Pastalar',
                  Icons
                      .delete_outline,
                ),

                const SizedBox(
                  height:
                      12,
                ),

                _buildTopWastedCakes(
                  analysis,
                ),

                const SizedBox(
                  height:
                      28,
                ),

                _buildSectionTitle(
                  'Tüm Pasta Performansı',
                  Icons
                      .analytics_outlined,
                ),

                const SizedBox(
                  height:
                      12,
                ),

                _buildAllCakes(
                  analysis,
                ),

                const SizedBox(
                  height:
                      32,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<String>(
      segments:
          const [
        ButtonSegment<String>(
          value:
              'day',
          label:
              Text(
            'Gün',
          ),
          icon:
              Icon(
            Icons
                .today_outlined,
          ),
        ),
        ButtonSegment<String>(
          value:
              'week',
          label:
              Text(
            'Hafta',
          ),
          icon:
              Icon(
            Icons
                .date_range_outlined,
          ),
        ),
        ButtonSegment<String>(
          value:
              'month',
          label:
              Text(
            'Ay',
          ),
          icon:
              Icon(
            Icons
                .calendar_month_outlined,
          ),
        ),
      ],
      selected: {
        _selectedPeriod,
      },
      onSelectionChanged: (
        Set<String> selected,
      ) {
        if (selected.isEmpty) {
          return;
        }

        _changePeriod(
          selected.first,
        );
      },
    );
  }

  Widget _buildDateRange(
    CakeAnalysis analysis,
  ) {
    return Card(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child:
            Row(
          children: [
            const Icon(
              Icons
                  .calendar_today_outlined,
            ),

            const SizedBox(
              width:
                  12,
            ),

            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getPeriodLabel(_selectedPeriod)} Raporu',
                    style:
                        Theme.of(
                      context,
                    )
                            .textTheme
                            .titleMedium,
                  ),

                  const SizedBox(
                    height:
                        4,
                  ),

                  Text(
                    '${_formatDate(analysis.startDate)} - ${_formatDate(analysis.endDate)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    CakeAnalysis analysis,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child:
                  _buildSummaryCard(
                title:
                    'Satış',
                value:
                    '${analysis.totalSoldSliceCount} dilim',
                icon:
                    Icons
                        .shopping_cart_outlined,
              ),
            ),

            const SizedBox(
              width:
                  12,
            ),

            Expanded(
              child:
                  _buildSummaryCard(
                title:
                    'Ciro',
                value:
                    _formatCurrency(
                  analysis
                      .totalRealizedRevenue,
                ),
                icon:
                    Icons
                        .payments_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(
          height:
              12,
        ),

        Row(
          children: [
            Expanded(
              child:
                  _buildSummaryCard(
                title:
                    'Zayi',
                value:
                    '${analysis.totalWastedSliceCount} dilim',
                icon:
                    Icons
                        .delete_outline,
              ),
            ),

            const SizedBox(
              width:
                  12,
            ),

            Expanded(
              child:
                  _buildSummaryCard(
                title:
                    'Zayi Maliyeti',
                value:
                    _formatCurrency(
                  analysis
                      .totalWasteCost,
                ),
                icon:
                    Icons
                        .money_off_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
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
            ),

            const SizedBox(
              height:
                  12,
            ),

            Text(
              title,
            ),

            const SizedBox(
              height:
                  6,
            ),

            Text(
              value,
              maxLines:
                  1,
              overflow:
                  TextOverflow
                      .ellipsis,
              style:
                  Theme.of(
                context,
              )
                      .textTheme
                      .titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
        ),

        const SizedBox(
          width:
              8,
        ),

        Text(
          title,
          style:
              Theme.of(
            context,
          )
                  .textTheme
                  .titleLarge,
        ),
      ],
    );
  }

  Widget _buildTopSellingCakes(
    CakeAnalysis analysis,
  ) {
    final cakes =
        analysis.topSellingCakes
            .take(
              5,
            )
            .toList();

    if (cakes.isEmpty) {
      return _buildEmpty(
        'Bu dönemde satış bulunmuyor.',
      );
    }

    return Card(
      child:
          Column(
        children:
            List.generate(
          cakes.length,
          (
            index,
          ) {
            final cake =
                cakes[index];

            return Column(
              children: [
                ListTile(
                  leading:
                      CircleAvatar(
                    child:
                        Text(
                      '${index + 1}',
                    ),
                  ),
                  title:
                      Text(
                    cake.cakeName,
                  ),
                  subtitle:
                      Text(
                    'Ciro: ${_formatCurrency(cake.realizedRevenue)}',
                  ),
                  trailing:
                      Text(
                    '${cake.soldSliceCount} dilim',
                    style:
                        Theme.of(
                      context,
                    )
                            .textTheme
                            .titleSmall,
                  ),
                ),

                if (index !=
                    cakes.length -
                        1)
                  const Divider(
                    height:
                        1,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopWastedCakes(
    CakeAnalysis analysis,
  ) {
    final cakes =
        analysis.topWastedCakes
            .take(
              5,
            )
            .toList();

    if (cakes.isEmpty) {
      return _buildEmpty(
        'Bu dönemde zayi kaydı bulunmuyor.',
      );
    }

    return Card(
      child:
          Column(
        children:
            List.generate(
          cakes.length,
          (
            index,
          ) {
            final cake =
                cakes[index];

            return Column(
              children: [
                ListTile(
                  leading:
                      CircleAvatar(
                    child:
                        Text(
                      '${index + 1}',
                    ),
                  ),
                  title:
                      Text(
                    cake.cakeName,
                  ),
                  subtitle:
                      Text(
                    'Zayi maliyeti: ${_formatCurrency(cake.wasteCost)}',
                  ),
                  trailing:
                      Text(
                    '${cake.wastedSliceCount} dilim',
                    style:
                        Theme.of(
                      context,
                    )
                            .textTheme
                            .titleSmall,
                  ),
                ),

                if (index !=
                    cakes.length -
                        1)
                  const Divider(
                    height:
                        1,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAllCakes(
    CakeAnalysis analysis,
  ) {
    if (analysis
        .cakes
        .isEmpty) {
      return _buildEmpty(
        'Bu dönem için pasta verisi bulunamadı.',
      );
    }

    return Column(
      children:
          analysis.cakes
              .map(
        (
          cake,
        ) {
          return Padding(
            padding:
                const EdgeInsets.only(
              bottom:
                  12,
            ),
            child:
                Card(
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
                    Text(
                      cake.cakeName,
                      style:
                          Theme.of(
                        context,
                      )
                              .textTheme
                              .titleMedium,
                    ),

                    const SizedBox(
                      height:
                          16,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child:
                              _buildMetric(
                            'Satış',
                            '${cake.soldSliceCount} dilim',
                          ),
                        ),

                        Expanded(
                          child:
                              _buildMetric(
                            'Ciro',
                            _formatCurrency(
                              cake
                                  .realizedRevenue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height:
                          16,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child:
                              _buildMetric(
                            'Zayi',
                            '${cake.wastedSliceCount} dilim',
                          ),
                        ),

                        Expanded(
                          child:
                              _buildMetric(
                            'Zayi Maliyeti',
                            _formatCurrency(
                              cake
                                  .wasteCost,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildMetric(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              Theme.of(
            context,
          )
                  .textTheme
                  .bodySmall,
        ),

        const SizedBox(
          height:
              4,
        ),

        Text(
          value,
          style:
              Theme.of(
            context,
          )
                  .textTheme
                  .titleSmall,
        ),
      ],
    );
  }

  Widget _buildEmpty(
    String message,
  ) {
    return Card(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child:
            Center(
          child:
              Text(
            message,
            textAlign:
                TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildError(
    Object? error,
  ) {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline,
              size:
                  48,
            ),

            const SizedBox(
              height:
                  16,
            ),

            const Text(
              'Rapor verileri yüklenirken bir hata oluştu.',
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height:
                  16,
            ),

            ElevatedButton.icon(
              onPressed:
                  _loadAnalysis,
              icon:
                  const Icon(
                Icons
                    .refresh,
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

    return '$day.$month.${date.year}';
  }

  String _formatCurrency(
    double value,
  ) {
    if (value ==
        value.truncateToDouble()) {
      return '${value.toInt()} ₺';
    }

    return '${value.toStringAsFixed(2)} ₺';
  }
}