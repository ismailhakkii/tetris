import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'presentation/views/game_screen.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  // Hive başlatma
  await Hive.initFlutter();
  await Hive.openBox('scoreBox');
  
  runApp(const ProviderScope(child: SudokuApp()));
}

class SudokuApp extends ConsumerWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Sudoku Oyunu',
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode,
      home: const GameScreen(),
    );
  }
}