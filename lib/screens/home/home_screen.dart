import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/auth_storage.dart';
import '../../models/auth/login_response.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../services/report_service.dart';

import '../login/login_screen.dart';
import '../cakes/cakes_screen.dart';
import 'dashboard_screen.dart';
import '../categories/categories_screen.dart';
import '../products/products_screen.dart';
import '../reports/reports_screen.dart';
import '../employees/employees_screen.dart';

class HomeScreen extends StatelessWidget {
  final LoginResponse loginResponse;

  const HomeScreen({
    super.key,
    required this.loginResponse,
  });

  // =========================================================
  // ÇIKIŞ
  // =========================================================

  Future<void> _logout(
    BuildContext context,
  ) async {
    final storage = AuthStorage();

    await storage.clear();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // =========================================================
  // DASHBOARD
  // =========================================================

  void _openDashboard(
    BuildContext context,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
          loginResponse: loginResponse,
        ),
      ),
    );
  }

  // =========================================================
  // DİĞER STOKLAR
  // =========================================================

  void _openProducts(
    BuildContext context,
  ) {
    final authStorage = AuthStorage();

    final apiClient = ApiClient(
      authStorage: authStorage,
    );

    final productService = ProductService(
      apiClient: apiClient,
    );

    final categoryService = CategoryService(
      apiClient: apiClient,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductsScreen(
          productService: productService,
          categoryService: categoryService,
          isAdmin: loginResponse.isAdmin,
        ),
      ),
    );
  }

  // =========================================================
  // KATEGORİ YÖNETİMİ
  // =========================================================

  void _openCategories(
    BuildContext context,
  ) {
    final authStorage = AuthStorage();

    final apiClient = ApiClient(
      authStorage: authStorage,
    );

    final categoryService = CategoryService(
      apiClient: apiClient,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoriesScreen(
          categoryService: categoryService,
          isAdmin: loginResponse.isAdmin,
        ),
      ),
    );
  }

  // =========================================================
  // PASTALAR
  // =========================================================

  void _openCakes(
    BuildContext context,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CakesScreen(
          loginResponse: loginResponse,
        ),
      ),
    );
  }

  // =========================================================
  // RAPORLAR
  // =========================================================

  void _openReports(
    BuildContext context,
  ) {
    final authStorage = AuthStorage();

    final apiClient = ApiClient(
      authStorage: authStorage,
    );

    final reportService = ReportService(
      apiClient: apiClient,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportsScreen(
          reportService: reportService,
        ),
      ),
    );
  }

  // =========================================================
  // ÇALIŞAN YÖNETİMİ
  // =========================================================

  void _openEmployees(
    BuildContext context,
  ) {
    final authStorage = AuthStorage();

    final apiClient = ApiClient(
      authStorage: authStorage,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmployeesScreen(
          apiClient: apiClient,
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
    final bool isAdmin =
        loginResponse.isAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Kafe Stoğu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Çıkış yap',
            onPressed: () => _logout(
              context,
            ),
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(
          16,
        ),
        children: [
          // =====================================================
          // KULLANICI BİLGİ KARTI
          // =====================================================

          Card(
            elevation: 0,
            color: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        Colors.white24,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
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
                          style: TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          loginResponse.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          isAdmin
                              ? 'Yönetici'
                              : 'Çalışan',
                          style: const TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          const Text(
            'İşlemler',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // =====================================================
          // PASTALAR
          // =====================================================

          _MenuCard(
            icon: Icons.cake_outlined,
            title: 'Pastalar',
            subtitle:
                'Pasta stoğu, dolap, satış ve zayi işlemleri',
            onTap: () {
              _openCakes(
                context,
              );
            },
          ),

          // =====================================================
          // DİĞER STOKLAR
          // =====================================================

          _MenuCard(
            icon:
                Icons.inventory_2_outlined,
            title: 'Diğer Stoklar',
            subtitle:
                'Ürün stok giriş, çıkış ve düzeltme işlemleri',
            onTap: () {
              _openProducts(
                context,
              );
            },
          ),

          // =====================================================
          // ADMIN İŞLEMLERİ
          // =====================================================

          if (isAdmin) ...[
            const SizedBox(
              height: 12,
            ),

            const Text(
              'Yönetim',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // =================================================
            // DASHBOARD
            // =================================================

            _MenuCard(
              icon:
                  Icons.dashboard_outlined,
              title: 'Dashboard',
              subtitle:
                  'Genel stok ve performans özeti',
              onTap: () {
                _openDashboard(
                  context,
                );
              },
            ),

            // =================================================
            // ÇALIŞAN YÖNETİMİ
            // =================================================

            _MenuCard(
              icon:
                  Icons.people_outline,
              title: 'Çalışan Yönetimi',
              subtitle:
                  'Çalışan hesaplarını yönet',
              onTap: () {
                _openEmployees(
                  context,
                );
              },
            ),

            // =================================================
            // RAPORLAR
            // =================================================

            _MenuCard(
              icon:
                  Icons.bar_chart_outlined,
              title: 'Raporlar',
              subtitle:
                  'Zayi, stok ve satış raporları',
              onTap: () {
                _openReports(
                  context,
                );
              },
            ),

            // =================================================
            // KATEGORİ YÖNETİMİ
            // =================================================

            _MenuCard(
              icon:
                  Icons.category_outlined,
              title: 'Kategori Yönetimi',
              subtitle:
                  'Ürün kategorilerini yönet',
              onTap: () {
                _openCategories(
                  context,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================
// MENÜ KARTI
// =============================================================

class _MenuCard
    extends StatelessWidget {
  final IconData icon;

  final String title;

  final String subtitle;

  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      shape: RoundedRectangleBorder(
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
        onTap: onTap,
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
                child: Icon(
                  icon,
                  color:
                      AppColors.primary,
                  size: 28,
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
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color:
                            AppColors
                                .textPrimary,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color:
                            AppColors
                                .textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
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
}