import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spot/l10n/l10n.dart';
import 'package:spot/pages/splash_page.dart';
import 'package:spot/repositories/repository.dart';
import 'package:supabase/supabase.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const _supabaseannonKey = String.fromEnvironment('SUPABASE_ANNON_KEY');
    final supabaseClient = SupabaseClient(_supabaseUrl, _supabaseannonKey);
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Repository>(
          create: (context) => Repository(supabaseClient: supabaseClient),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(
          primaryColor: const Color(0xFFFFFFFF),
          accentColor: const Color(0xFFFFFFFF),
          appBarTheme: const AppBarTheme(
            color: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Color(0xFFFFFFFF)),
            ),
            isDense: true,
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(primary: const Color(0xFFFFFFFF)),
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFFFFFFFF).withOpacity(0.7),
            elevation: 10,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashPage(),
      ),
    );
  }
}
