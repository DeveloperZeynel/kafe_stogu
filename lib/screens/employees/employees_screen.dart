import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../models/employees/employee.dart';
import '../../services/employee_service.dart';
import 'employee_form_screen.dart';

class EmployeesScreen extends StatefulWidget {
  final ApiClient apiClient;

  const EmployeesScreen({
    super.key,
    required this.apiClient,
  });

  @override
  State<EmployeesScreen> createState() =>
      _EmployeesScreenState();
}

class _EmployeesScreenState
    extends State<EmployeesScreen> {
  late final EmployeeService _employeeService;

  final TextEditingController _searchController =
      TextEditingController();

  bool _isLoading = true;

  String? _errorMessage;

  List<Employee> _employees = [];

  @override
  void initState() {
    super.initState();

    _employeeService =
        EmployeeService(
      apiClient: widget.apiClient,
    );

    _searchController.addListener(
      _onSearchChanged,
    );

    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController
        .removeListener(
      _onSearchChanged,
    );

    _searchController.dispose();

    super.dispose();
  }

  // =========================================================
  // ÇALIŞANLARI YÜKLE
  // =========================================================

  Future<void> _loadEmployees() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final employees =
          await _employeeService.getAll();

      if (!mounted) {
        return;
      }

      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            _getErrorMessage(error);
      });
    }
  }

  // =========================================================
  // ARAMA
  // =========================================================

  void _onSearchChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  List<Employee> get _filteredEmployees {
    final query =
        _searchController.text
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      return List<Employee>.from(
        _employees,
      );
    }

    return _employees
        .where(
          (employee) =>
              employee.username
                  .toLowerCase()
                  .contains(
                    query,
                  ) ||
              employee.role
                  .toLowerCase()
                  .contains(
                    query,
                  ),
        )
        .toList();
  }

  List<Employee> get _activeEmployees {
    return _filteredEmployees
        .where(
          (employee) =>
              employee.isActive,
        )
        .toList();
  }

  List<Employee> get _inactiveEmployees {
    return _filteredEmployees
        .where(
          (employee) =>
              !employee.isActive,
        )
        .toList();
  }

  // =========================================================
  // ÇALIŞAN AKTİF / PASİF
  // =========================================================

  Future<void> _toggleEmployeeStatus(
    Employee employee,
  ) async {
    final shouldActivate =
        !employee.isActive;

    final actionText =
        shouldActivate
            ? 'aktifleştirmek'
            : 'pasifleştirmek';

    final confirmed =
        await _showConfirmationDialog(
      title: shouldActivate
          ? 'Çalışanı Aktifleştir'
          : 'Çalışanı Pasifleştir',
      content:
          '${employee.username} adlı çalışanı $actionText istediğinize emin misiniz?',
      confirmText: shouldActivate
          ? 'Aktifleştir'
          : 'Pasifleştir',
    );

    if (confirmed != true) {
      return;
    }

    try {
      if (shouldActivate) {
        await _employeeService.activate(
          employee.id,
        );
      } else {
        await _employeeService.deactivate(
          employee.id,
        );
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        shouldActivate
            ? 'Çalışan aktifleştirildi.'
            : 'Çalışan pasifleştirildi.',
      );

      await _loadEmployees();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showErrorMessage(
        _getErrorMessage(error),
      );
    }
  }

  // =========================================================
  // YENİ ÇALIŞAN
  // =========================================================

  Future<void> _openCreateEmployee() async {
    final result =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            EmployeeFormScreen(
          apiClient:
              widget.apiClient,
        ),
      ),
    );

    if (result == true) {
      await _loadEmployees();
    }
  }

  // =========================================================
  // ÇALIŞAN DÜZENLE
  // =========================================================

  Future<void> _openEditEmployee(
    Employee employee,
  ) async {
    final result =
        await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            EmployeeFormScreen(
          apiClient:
              widget.apiClient,
          employee:
              employee,
        ),
      ),
    );

    if (result == true) {
      await _loadEmployees();
    }
  }

  // =========================================================
  // ŞİFRE DEĞİŞTİR
  // =========================================================

  Future<void> _openChangePasswordDialog(
    Employee employee,
  ) async {
    final passwordController =
        TextEditingController();

    final confirmPasswordController =
        TextEditingController();

    bool obscurePassword = true;

    final result =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Şifre Değiştir',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${employee.username} adlı çalışan için yeni şifre belirleyin.',
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextField(
                      controller:
                          passwordController,
                      obscureText:
                          obscurePassword,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Yeni Şifre',
                        border:
                            const OutlineInputBorder(),
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setDialogState(
                              () {
                                obscurePassword =
                                    !obscurePassword;
                              },
                            );
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons
                                    .visibility_off
                                : Icons
                                    .visibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextField(
                      controller:
                          confirmPasswordController,
                      obscureText:
                          obscurePassword,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Yeni Şifre Tekrar',
                        border:
                            OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(
                      false,
                    );
                  },
                  child: const Text(
                    'İptal',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final password =
                        passwordController.text
                            .trim();

                    final confirmPassword =
                        confirmPasswordController
                            .text
                            .trim();

                    if (password.isEmpty) {
                      _showDialogError(
                        dialogContext,
                        'Yeni şifre boş bırakılamaz.',
                      );
                      return;
                    }

                    if (password.length < 4) {
                      _showDialogError(
                        dialogContext,
                        'Şifre en az 4 karakter olmalıdır.',
                      );
                      return;
                    }

                    if (password !=
                        confirmPassword) {
                      _showDialogError(
                        dialogContext,
                        'Şifreler birbiriyle eşleşmiyor.',
                      );
                      return;
                    }

                    Navigator.of(
                      dialogContext,
                    ).pop(
                      true,
                    );
                  },
                  child: const Text(
                    'Kaydet',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    final newPassword =
        passwordController.text
            .trim();

    passwordController.dispose();
    confirmPasswordController.dispose();

    if (result != true ||
        newPassword.isEmpty) {
      return;
    }

    try {
      await _employeeService
          .changePassword(
        id: employee.id,
        newPassword:
            newPassword,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Çalışanın şifresi başarıyla değiştirildi.',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showErrorMessage(
        _getErrorMessage(error),
      );
    }
  }

  // =========================================================
  // İŞLEM MENÜSÜ
  // =========================================================

  void _showEmployeeActions(
    Employee employee,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                ),
                title: const Text(
                  'Kullanıcı Adını Düzenle',
                ),
                onTap: () {
                  Navigator.of(
                    sheetContext,
                  ).pop();

                  _openEditEmployee(
                    employee,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.lock_outline,
                ),
                title: const Text(
                  'Şifre Değiştir',
                ),
                onTap: () {
                  Navigator.of(
                    sheetContext,
                  ).pop();

                  _openChangePasswordDialog(
                    employee,
                  );
                },
              ),
              const Divider(
                height: 1,
              ),
              ListTile(
                leading: Icon(
                  employee.isActive
                      ? Icons
                          .person_off_outlined
                      : Icons
                          .person_add_alt_1_outlined,
                ),
                title: Text(
                  employee.isActive
                      ? 'Pasifleştir'
                      : 'Aktifleştir',
                ),
                onTap: () {
                  Navigator.of(
                    sheetContext,
                  ).pop();

                  _toggleEmployeeStatus(
                    employee,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // ONAY DIALOG
  // =========================================================

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            title,
          ),
          content: Text(
            content,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  false,
                );
              },
              child: const Text(
                'İptal',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  true,
                );
              },
              child: Text(
                confirmText,
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // DIALOG HATA
  // =========================================================

  void _showDialogError(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }

  // =========================================================
  // HATA MESAJI
  // =========================================================

  String _getErrorMessage(
    Object error,
  ) {
    if (error is DioException) {
      final data =
          error.response?.data;

      if (data is Map) {
        final message =
            data['message'];

        if (message != null &&
            message
                .toString()
                .trim()
                .isNotEmpty) {
          return message
              .toString();
        }

        final title =
            data['title'];

        if (title != null &&
            title
                .toString()
                .trim()
                .isNotEmpty) {
          return title
              .toString();
        }
      }

      return error.message ??
          'Sunucuyla bağlantı kurulurken bir hata oluştu.';
    }

    return 'Beklenmeyen bir hata oluştu.';
  }

  // =========================================================
  // MESAJ
  // =========================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }

  void _showErrorMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
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
      appBar: AppBar(
        title: const Text(
          'Çalışan Yönetimi',
        ),
        actions: [
          IconButton(
            onPressed:
                _isLoading
                    ? null
                    : _loadEmployees,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed:
            _openCreateEmployee,
        icon: const Icon(
          Icons.person_add_alt_1,
        ),
        label: const Text(
          'Çalışan Ekle',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading &&
        _employees.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null &&
        _employees.isEmpty) {
      return _buildErrorView();
    }

    return RefreshIndicator(
      onRefresh:
          _loadEmployees,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),
        children: [
          _buildSearchField(),

          const SizedBox(
            height: 16,
          ),

          _buildSummary(),

          const SizedBox(
            height: 24,
          ),

          if (_activeEmployees.isNotEmpty)
            _buildSection(
              title:
                  'Aktif Çalışanlar',
              employees:
                  _activeEmployees,
            ),

          if (_inactiveEmployees.isNotEmpty)
            const SizedBox(
              height: 24,
            ),

          if (_inactiveEmployees.isNotEmpty)
            _buildSection(
              title:
                  'Pasif Çalışanlar',
              employees:
                  _inactiveEmployees,
            ),

          if (_filteredEmployees.isEmpty)
            _buildEmptyView(),
        ],
      ),
    );
  }

  // =========================================================
  // ARAMA ALANI
  // =========================================================

  Widget _buildSearchField() {
    return TextField(
      controller:
          _searchController,
      decoration:
          InputDecoration(
        labelText:
            'Çalışan Ara',
        hintText:
            'Kullanıcı adı ile ara',
        prefixIcon:
            const Icon(
          Icons.search,
        ),
        border:
            const OutlineInputBorder(),
        suffixIcon:
            _searchController
                    .text
                    .isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController
                          .clear();
                    },
                    icon: const Icon(
                      Icons.clear,
                    ),
                  ),
      ),
    );
  }

  // =========================================================
  // ÖZET
  // =========================================================

  Widget _buildSummary() {
    final activeCount =
        _employees
            .where(
              (employee) =>
                  employee.isActive,
            )
            .length;

    final inactiveCount =
        _employees.length -
            activeCount;

    return Row(
      children: [
        Expanded(
          child:
              _buildSummaryCard(
            icon:
                Icons.people_outline,
            title:
                'Toplam',
            value:
                _employees.length
                    .toString(),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child:
              _buildSummaryCard(
            icon:
                Icons.check_circle_outline,
            title:
                'Aktif',
            value:
                activeCount
                    .toString(),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child:
              _buildSummaryCard(
            icon:
                Icons.pause_circle_outline,
            title:
                'Pasif',
            value:
                inactiveCount
                    .toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          12,
        ),
        child: Column(
          children: [
            Icon(
              icon,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              value,
              style:
                  Theme.of(context)
                      .textTheme
                      .titleLarge,
            ),
            Text(
              title,
              style:
                  Theme.of(context)
                      .textTheme
                      .bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ÇALIŞAN BÖLÜMÜ
  // =========================================================

  Widget _buildSection({
    required String title,
    required List<Employee> employees,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              Theme.of(context)
                  .textTheme
                  .titleMedium,
        ),
        const SizedBox(
          height: 8,
        ),
        ...employees.map(
          _buildEmployeeCard,
        ),
      ],
    );
  }

  // =========================================================
  // ÇALIŞAN KARTI
  // =========================================================

  Widget _buildEmployeeCard(
    Employee employee,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: ListTile(
        leading:
            CircleAvatar(
          child: Icon(
            employee.isAdmin
                ? Icons.admin_panel_settings
                : Icons.person_outline,
          ),
        ),
        title: Text(
          employee.username,
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 4,
            ),
            Text(
              employee.roleText,
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              'Oluşturulma: ${employee.createdAtText}',
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              employee.isActive
                  ? Icons.check_circle
                  : Icons.pause_circle,
            ),
            IconButton(
              onPressed: () {
                _showEmployeeActions(
                  employee,
                );
              },
              icon: const Icon(
                Icons.more_vert,
              ),
            ),
          ],
        ),
        onTap: () {
          _showEmployeeActions(
            employee,
          );
        },
      ),
    );
  }

  // =========================================================
  // BOŞ DURUM
  // =========================================================

  Widget _buildEmptyView() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 48,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.people_outline,
              size: 56,
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              'Çalışan bulunamadı.',
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HATA
  // =========================================================

  Widget _buildErrorView() {
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
              size: 56,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              _errorMessage ??
                  'Bir hata oluştu.',
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              onPressed:
                  _loadEmployees,
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