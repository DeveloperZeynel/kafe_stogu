import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/auth_storage.dart';
import '../../models/auth/login_response.dart';
import '../../models/cakes/cake_summary.dart';
import '../../services/cake_service.dart';

class DashboardScreen
    extends StatefulWidget {
  final LoginResponse loginResponse;

  const DashboardScreen({
    super.key,
    required this.loginResponse,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  late final CakeService _cakeService;

  bool _isLoading = true;

  String? _errorMessage;

  List<CakeSummary> _cakes = [];

  @override
  void initState() {
    super.initState();

    final storage =
        AuthStorage();

    final apiClient =
        ApiClient(
      authStorage: storage,
    );

    _cakeService =
        CakeService(
      apiClient: apiClient,
    );

    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final cakes =
          await _cakeService
              .getSummary();

      if (!mounted) {
        return;
      }

      setState(() {
        _cakes = cakes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                );
      });
    }
  }

  int get _totalCakeStock {
    return _cakes.fold(
      0,
      (sum, cake) =>
          sum +
          cake.currentSliceStock,
    );
  }

  int get _totalCabinetSlices {
    return _cakes.fold(
      0,
      (sum, cake) =>
          sum +
          cake.totalCabinetSlices,
    );
  }

  int get _totalWasteSlices {
    return _cakes.fold(
      0,
      (sum, cake) =>
          sum +
          cake.totalWasteSlices,
    );
  }

  double get _totalWasteCost {
    return _cakes.fold(
      0,
      (sum, cake) =>
          sum +
          cake.totalWasteCost,
    );
  }

  double get _potentialRevenue {
    return _cakes.fold(
      0,
      (sum, cake) =>
          sum +
          cake.potentialRevenue,
    );
  }

  String _money(
    double value,
  ) {
    return '${value.toStringAsFixed(2)} ₺';
  }

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
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: RefreshIndicator(
        color:
            AppColors.primary,
        onRefresh:
            _loadDashboard,
        child:
            _buildBody(),
      ),
    );
  }

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
              style:
                  const TextStyle(
                color:
                    AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Center(
            child:
                ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    Colors.white,
              ),
              onPressed:
                  _loadDashboard,
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

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(16),
      children: [
        _buildWelcomeCard(),

        const SizedBox(
          height: 20,
        ),

        const Text(
          'Pasta Özeti',
          style: TextStyle(
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

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio:
              1.45,
          children: [
            _StatCard(
              icon:
                  Icons.cake_outlined,
              title:
                  'Pasta Çeşidi',
              value:
                  '${_cakes.length}',
            ),
            _StatCard(
              icon:
                  Icons.inventory_2_outlined,
              title:
                  'Mevcut Dilim',
              value:
                  '$_totalCakeStock',
            ),
            _StatCard(
              icon:
                  Icons.storefront_outlined,
              title:
                  'Dolaptaki Dilim',
              value:
                  '$_totalCabinetSlices',
            ),
            _StatCard(
              icon:
                  Icons.delete_outline,
              title:
                  'Zayi Dilimi',
              value:
                  '$_totalWasteSlices',
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        _MoneyCard(
          icon:
              Icons.warning_amber_outlined,
          title:
              'Toplam Zayi Maliyeti',
          value:
              _money(
                _totalWasteCost,
              ),
        ),

        const SizedBox(
          height: 12,
        ),

        _MoneyCard(
          icon:
              Icons.payments_outlined,
          title:
              'Potansiyel Satış Geliri',
          value:
              _money(
                _potentialRevenue,
              ),
        ),

        const SizedBox(
          height: 24,
        ),

        const Text(
          'Pastalar',
          style: TextStyle(
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

        if (_cakes.isEmpty)
          _buildEmptyState()
        else
          ..._cakes.map(
            _buildCakeCard,
          ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 0,
      color:
          AppColors.primary,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor:
                  Colors.white24,
              child: Icon(
                Icons.person,
                color:
                    Colors.white,
                size: 32,
              ),
            ),

            const SizedBox(
              width: 16,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hoş geldin',
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    widget.loginResponse
                        .username,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  const Text(
                    'Yönetici Paneli',
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
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

  Widget _buildCakeCard(
    CakeSummary cake,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
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
                    Icons.cake,
                    color:
                        AppColors.primary,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                      Text(
                    cake.name,
                    style:
                        const TextStyle(
                      fontSize: 17,
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
              height: 16,
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                _SmallInfo(
                  label:
                      'Stok',
                  value:
                      '${cake.currentSliceStock}',
                ),
                _SmallInfo(
                  label:
                      'Dolap',
                  value:
                      '${cake.totalCabinetSlices}',
                ),
                _SmallInfo(
                  label:
                      'Zayi',
                  value:
                      '${cake.totalWasteSlices}',
                ),
                _SmallInfo(
                  label:
                      'Potansiyel',
                  value:
                      _money(
                    cake.potentialRevenue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.cake_outlined,
              size: 52,
              color:
                  AppColors.textSecondary,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'Henüz pasta bulunmuyor.',
              style:
                  TextStyle(
                fontWeight:
                    FontWeight.bold,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  AppColors.primary,
              size: 28,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              title,
              style:
                  const TextStyle(
                color:
                    AppColors.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            Text(
              value,
              style:
                  const TextStyle(
                color:
                    AppColors.textPrimary,
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MoneyCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading:
            CircleAvatar(
          backgroundColor:
              AppColors.primary
                  .withValues(
            alpha: 0.10,
          ),
          child:
              Icon(
            icon,
            color:
                AppColors.primary,
          ),
        ),
        title:
            Text(
          title,
          style:
              const TextStyle(
            color:
                AppColors.textSecondary,
          ),
        ),
        trailing:
            Text(
          value,
          style:
              const TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
            color:
                AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SmallInfo
    extends StatelessWidget {
  final String label;
  final String value;

  const _SmallInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
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
          style:
              const TextStyle(
            fontSize: 12,
            color:
                AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}