import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.anonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const GreenOrchardApp(),
    ),
  );
}

class GreenOrchardApp extends StatelessWidget {
  const GreenOrchardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Orchard Market',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Supabase keeps the session on the device, so a logged-in user
      // goes straight to the shell next time they open the app (FR1).
      home: Consumer<AuthProvider>(
        builder: (_, auth, __) =>
            auth.isLoggedIn ? const MainShell() : const LoginScreen(),
      ),
    );
  }
}
