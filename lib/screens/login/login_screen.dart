import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/auth_storage.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final _usernameController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _formKey =
      GlobalKey<FormState>();

  late final AuthStorage _authStorage;
  late final AuthService _authService;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _authStorage =
        AuthStorage();

    final apiClient =
        ApiClient(
      authStorage: _authStorage,
    );

    _authService =
        AuthService(
      apiClient: apiClient,
      authStorage: _authStorage,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await _authService.login(
        username:
            _usernameController.text.trim(),
        password:
            _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => HomeScreen(
            loginResponse: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message =
          e.toString()
              .replaceFirst(
                'Exception: ',
                '',
              );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 420,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.coffee,
                      size: 72,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Text(
                      'KAFE STOĞU',
                      textAlign:
                          TextAlign.center,
                      style:
                          Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Stok yönetim sistemine giriş yapın',
                      textAlign:
                          TextAlign.center,
                      style:
                          Theme.of(context)
                              .textTheme
                              .bodyMedium,
                    ),

                    const SizedBox(
                      height: 40,
                    ),

                    TextFormField(
                      controller:
                          _usernameController,
                      textInputAction:
                          TextInputAction.next,
                      autocorrect: false,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Kullanıcı adı',
                        prefixIcon:
                            Icon(
                          Icons.person_outline,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Kullanıcı adı zorunludur.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller:
                          _passwordController,
                      obscureText:
                          _obscurePassword,
                      textInputAction:
                          TextInputAction.done,
                      onFieldSubmitted:
                          (_) => _login(),
                      decoration:
                          InputDecoration(
                        labelText:
                            'Şifre',
                        prefixIcon:
                            const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon:
                            IconButton(
                          onPressed:
                              () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          icon:
                              Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        border:
                            const OutlineInputBorder(),
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Şifre zorunludur.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    SizedBox(
                      height: 52,
                      child:
                          ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _login,
                        child:
                            _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2.5,
                                    ),
                                  )
                                : const Text(
                                    'GİRİŞ YAP',
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}