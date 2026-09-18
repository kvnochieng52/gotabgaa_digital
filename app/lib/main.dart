import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/root_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  runApp(const GotabgaaApp());
}

class GotabgaaApp extends StatelessWidget {
  const GotabgaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gotabgaa Digital',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const RootShell(),
    );
  }
}
