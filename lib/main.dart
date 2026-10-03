import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/energy_provider.dart';
import 'widgets/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred portrait orientations for mobile devices, while allowing landscape on tablets
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EnergyProvider()),
      ],
      child: const EnergyWatchApp(),
    ),
  );
}

/// Root Application Widget for EnergyWatch.
class EnergyWatchApp extends StatelessWidget {
  const EnergyWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final energy = context.watch<EnergyProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: energy.themeMode,
      home: const AppShell(),
    );
  }
}
