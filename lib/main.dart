import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/shell/adaptive_shell.dart';
import 'app/theme/aarogya_theme.dart';
import 'shared/state/aarogya_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AarogyaApp(),
    ),
  );
}

class AarogyaApp extends ConsumerWidget {
  const AarogyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Aarogya • Next-Gen Hospital & Healthcare Platform',
      debugShowCheckedModeBanner: false,
      theme: AarogyaTheme.lightTheme,
      darkTheme: AarogyaTheme.darkTheme,
      themeMode: themeMode,
      home: const AdaptiveShell(),
    );
  }
}
