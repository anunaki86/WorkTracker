import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';

import 'providers/auth_provider.dart';
import 'providers/rounds_provider.dart';
import 'providers/work_provider.dart';
import 'screens/home_page.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Konfiguracja systemu logowania
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    Logger.root.info('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });
  
  // Utwórz domyślne konto administratora, jeśli potrzeba
  final authService = AuthService();
  await authService.createDefaultAdminIfNeeded();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => RoundsProvider()),
        ChangeNotifierProvider(create: (context) => WorkProvider()),
      ],
      child: WorkTimeTrackerApp(),
    ),
  );
}

class WorkTimeTrackerApp extends StatelessWidget {
  const WorkTimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return MaterialApp(
      title: 'Śledzenie czasu pracy',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pl', 'PL'),
      ],
      themeMode: ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: authProvider.isInitialized
          ? (authProvider.isLoggedIn ? HomePage(onLogout: () => authProvider.logout()) : LoginScreen(onLoginSuccess: () => authProvider.login()))
          : const Scaffold(
              body: Center(
                child: SpinKitDoubleBounce(
                  color: Colors.blue,
                  size: 50.0,
                ),
              ),
            ),
    );
  }
}
