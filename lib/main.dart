import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/shell/adaptive_shell.dart';
import 'app/theme/aarogya_theme.dart';
import 'features/auth/auth_screen.dart';
import 'firebase_options.dart';
import 'shared/state/aarogya_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const ProviderScope(child: AarogyaApp()));
}

class AarogyaApp extends ConsumerWidget {
  const AarogyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return MaterialApp(
      title: 'Aarogya • Next-Gen Hospital & Healthcare Platform',
      debugShowCheckedModeBanner: false,
      theme: AarogyaTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: isAuthenticated ? const AdaptiveShell() : const AuthScreen(),
    );
  }
}
