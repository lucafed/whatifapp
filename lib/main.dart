
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'src/state/app_state.dart';
import 'src/ui/shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WhatfApp());
}

class WhatfApp extends StatelessWidget {
  const WhatfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          final theme = ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: state.isDark ? Brightness.dark : Brightness.light,
              seedColor: const Color(0xFF6D28D9),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              state.isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
            ),
            useMaterial3: true,
          );
          return MaterialApp(
            title: 'What?f',
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: const NavShell(),
          );
        },
      ),
    );
  }
}
