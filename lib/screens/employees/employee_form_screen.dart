import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../models/employees/employee.dart';
import '../../services/employee_service.dart';

class EmployeeFormScreen extends StatefulWidget {
  final ApiClient apiClient;

  final Employee? employee;

  const EmployeeFormScreen({
    super.key,
    required this.apiClient,
    this.employee,
  });

  @override
  State<EmployeeFormScreen> createState() =>
      _EmployeeFormScreenState();
}

class _EmployeeFormScreenState
    extends State<EmployeeFormScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late final EmployeeService _employeeService;

  late final TextEditingController _usernameController;

  late final TextEditingController _passwordController;

  late final TextEditingController _confirmPasswordController;

  bool _isSaving = false;

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;

  bool get _isEditMode =>
      widget.employee != null;

  @override
  void initState() {
    super.initState();

    _employeeService =
        EmployeeService(
      apiClient: widget.apiClient,
    );

    _usernameController =
        TextEditingController(
      text:
          widget.employee?.username ?? '',
    );

    _passwordController =
        TextEditingController();

    _confirmPasswordController =
        TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();

    _passwordController.dispose();

    _confirmPasswordController.dispose();

    super.dispose();
  }

  // =========================================================
  // KAYDET
  // =========================================================

  Future<void> _save() async {
    final isValid =
        _formKey.currentState?.validate() ??
            false;

    if (!isValid) {
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditMode) {
        await _employeeService.update(
          id:
              widget.employee!.id,
          username:
              _usernameController.text
                  .trim(),
        );
      } else {
        await _employeeService.create(
          username:
              _usernameController.text
                  .trim(),
          password:
              _passwordController.text,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showErrorMessage(
        _getErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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

        final errors =
            data['errors'];

        if (errors is Map) {
          final messages =
              <String>[];

          for (final value
              in errors.values) {
            if (value is List) {
              messages.addAll(
                value.map(
                  (item) =>
                      item.toString(),
                ),
              );
            } else if (value != null) {
              messages.add(
                value.toString(),
              );
            }
          }

          if (messages.isNotEmpty) {
            return messages.join(
              '\n',
            );
          }
        }
      }

      if (error.response?.statusCode ==
          400) {
        return 'Gönderilen bilgiler geçersiz.';
      }

      if (error.response?.statusCode ==
          401) {
        return 'Bu işlem için oturumunuz geçerli değil.';
      }

      if (error.response?.statusCode ==
          403) {
        return 'Bu işlem için yetkiniz bulunmuyor.';
      }

      if (error.response?.statusCode ==
          409) {
        return 'Bu kullanıcı adı zaten kullanılıyor.';
      }

      return error.message ??
          'Sunucuyla bağlantı kurulurken bir hata oluştu.';
    }

    return 'Beklenmeyen bir hata oluştu.';
  }

  // =========================================================
  // SNACKBAR
  // =========================================================

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
      appBar: AppBar(
        title: Text(
          _isEditMode
              ? 'Çalışanı Düzenle'
              : 'Yeni Çalışan',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets.all(
              16,
            ),
            children: [
              _buildInfoCard(),

              const SizedBox(
                height: 24,
              ),

              _buildUsernameField(),

              if (!_isEditMode) ...[
                const SizedBox(
                  height: 16,
                ),

                _buildPasswordField(),

                const SizedBox(
                  height: 16,
                ),

                _buildConfirmPasswordField(),
              ],

              const SizedBox(
                height: 32,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 50,
                child:
                    ElevatedButton(
                  onPressed:
                      _isSaving
                          ? null
                          : _save,
                  child:
                      _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )
                          : Text(
                              _isEditMode
                                  ? 'Değişiklikleri Kaydet'
                                  : 'Çalışan Oluştur',
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BİLGİ KARTI
  // =========================================================

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              _isEditMode
                  ? Icons
                      .edit_outlined
                  : Icons
                      .person_add_alt_1,
              size: 30,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditMode
                        ? 'Çalışan Bilgilerini Düzenle'
                        : 'Yeni Çalışan Oluştur',
                    style:
                        Theme.of(context)
                            .textTheme
                            .titleMedium,
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    _isEditMode
                        ? 'Bu ekrandan çalışanın kullanıcı adını değiştirebilirsiniz. Şifre değişikliği çalışan listesindeki işlem menüsünden yapılır.'
                        : 'Yeni çalışanın giriş yapabilmesi için kullanıcı adı ve şifre belirleyin.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // KULLANICI ADI
  // =========================================================

  Widget _buildUsernameField() {
    return TextFormField(
      controller:
          _usernameController,
      enabled:
          !_isSaving,
      textInputAction:
          _isEditMode
              ? TextInputAction.done
              : TextInputAction.next,
      onFieldSubmitted:
          _isEditMode
              ? (_) {
                  _save();
                }
              : null,
      decoration:
          const InputDecoration(
        labelText:
            'Kullanıcı Adı',
        hintText:
            'Örneğin: ahmet.yilmaz',
        prefixIcon:
            Icon(
          Icons.person_outline,
        ),
        border:
            OutlineInputBorder(),
      ),
      validator:
          (value) {
        final username =
            value?.trim() ?? '';

        if (username.isEmpty) {
          return 'Kullanıcı adı zorunludur.';
        }

        if (username.length < 3) {
          return 'Kullanıcı adı en az 3 karakter olmalıdır.';
        }

        if (username.length > 50) {
          return 'Kullanıcı adı en fazla 50 karakter olabilir.';
        }

        return null;
      },
    );
  }

  // =========================================================
  // ŞİFRE
  // =========================================================

  Widget _buildPasswordField() {
    return TextFormField(
      controller:
          _passwordController,
      enabled:
          !_isSaving,
      obscureText:
          _obscurePassword,
      textInputAction:
          TextInputAction.next,
      decoration:
          InputDecoration(
        labelText:
            'Şifre',
        hintText:
            'Çalışanın giriş şifresi',
        prefixIcon:
            const Icon(
          Icons.lock_outline,
        ),
        border:
            const OutlineInputBorder(),
        suffixIcon:
            IconButton(
          onPressed:
              _isSaving
                  ? null
                  : () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },
          icon: Icon(
            _obscurePassword
                ? Icons
                    .visibility_off
                : Icons.visibility,
          ),
        ),
      ),
      validator:
          (value) {
        final password =
            value ?? '';

        if (password.isEmpty) {
          return 'Şifre zorunludur.';
        }

        if (password.length < 4) {
          return 'Şifre en az 4 karakter olmalıdır.';
        }

        return null;
      },
    );
  }

  // =========================================================
  // ŞİFRE TEKRAR
  // =========================================================

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller:
          _confirmPasswordController,
      enabled:
          !_isSaving,
      obscureText:
          _obscureConfirmPassword,
      textInputAction:
          TextInputAction.done,
      onFieldSubmitted:
          (_) {
        _save();
      },
      decoration:
          InputDecoration(
        labelText:
            'Şifre Tekrar',
        hintText:
            'Şifreyi tekrar girin',
        prefixIcon:
            const Icon(
          Icons.lock_outline,
        ),
        border:
            const OutlineInputBorder(),
        suffixIcon:
            IconButton(
          onPressed:
              _isSaving
                  ? null
                  : () {
                      setState(() {
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                      });
                    },
          icon: Icon(
            _obscureConfirmPassword
                ? Icons
                    .visibility_off
                : Icons.visibility,
          ),
        ),
      ),
      validator:
          (value) {
        final confirmPassword =
            value ?? '';

        if (confirmPassword.isEmpty) {
          return 'Şifre tekrarı zorunludur.';
        }

        if (confirmPassword !=
            _passwordController.text) {
          return 'Şifreler birbiriyle eşleşmiyor.';
        }

        return null;
      },
    );
  }
}