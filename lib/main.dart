import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'screens/login/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const KafeStoguApp(),
  );
}

class KafeStoguApp extends StatelessWidget {
  const KafeStoguApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      title: 'Kafe Stoğu',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        // =====================================================
        // ANA RENK
        // #503315
        // =====================================================

        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              AppColors.primary,
          brightness:
              Brightness.light,
        ),

        scaffoldBackgroundColor:
            AppColors.background,

        // =====================================================
        // APP BAR
        // =====================================================

        appBarTheme:
            const AppBarTheme(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
          elevation: 0,
          centerTitle: false,
        ),

        // =====================================================
        // ELEVATED BUTTON
        // =====================================================

        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                AppColors.primary,
            foregroundColor:
                Colors.white,
            minimumSize:
                const Size(
              double.infinity,
              52,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
          ),
        ),

        // =====================================================
        // OUTLINED BUTTON
        // =====================================================

        outlinedButtonTheme:
            OutlinedButtonThemeData(
          style:
              OutlinedButton.styleFrom(
            foregroundColor:
                AppColors.primary,
            side:
                const BorderSide(
              color:
                  AppColors.primary,
            ),
            minimumSize:
                const Size(
              double.infinity,
              50,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
          ),
        ),

        // =====================================================
        // TEXT BUTTON
        // =====================================================

        textButtonTheme:
            TextButtonThemeData(
          style:
              TextButton.styleFrom(
            foregroundColor:
                AppColors.primary,
          ),
        ),

        // =====================================================
        // INPUT
        // =====================================================

        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor:
              Colors.white,

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                BorderSide(
              color:
                  AppColors.primary
                      .withValues(
                alpha: 0.20,
              ),
            ),
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                BorderSide(
              color:
                  AppColors.primary
                      .withValues(
                alpha: 0.20,
              ),
            ),
          ),

          focusedBorder:
              const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(
              Radius.circular(
                12,
              ),
            ),
            borderSide:
                BorderSide(
              color:
                  AppColors.primary,
              width: 2,
            ),
          ),

          errorBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.danger,
            ),
          ),

          focusedErrorBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.danger,
              width: 2,
            ),
          ),

          prefixIconColor:
              AppColors.primary,

          suffixIconColor:
              AppColors.primary,

          labelStyle:
              const TextStyle(
            color:
                AppColors.textSecondary,
          ),

          floatingLabelStyle:
              const TextStyle(
            color:
                AppColors.primary,
          ),
        ),

        // =====================================================
        // CARD
        // =====================================================

        cardTheme:
            CardThemeData(
          color:
              AppColors.card,
          elevation: 1,
          margin:
              EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
        ),

        // =====================================================
        // ICON
        // =====================================================

        iconTheme:
            const IconThemeData(
          color:
              AppColors.primary,
        ),

        // =====================================================
        // PROGRESS INDICATOR
        // =====================================================

        progressIndicatorTheme:
            const ProgressIndicatorThemeData(
          color:
              AppColors.primary,
        ),

        // =====================================================
        // FLOATING ACTION BUTTON
        // =====================================================

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
        ),

        // =====================================================
        // DIVIDER
        // =====================================================

        dividerTheme:
            DividerThemeData(
          color:
              AppColors.primary
                  .withValues(
            alpha: 0.10,
          ),
        ),
      ),

      home:
          const LoginScreen(),
    );
  }
}