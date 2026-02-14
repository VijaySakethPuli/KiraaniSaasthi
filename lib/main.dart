import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop_agent/core/theme/app_theme.dart';
import 'package:shop_agent/features/dashboard/screens/dashboard_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(const ShopAgentApp());
}

class ShopAgentApp extends StatelessWidget {
  const ShopAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // TODO: Add providers here later (e.g., InventoryProvider)
        Provider(create: (_) => Object()), 
      ],
      child: MaterialApp(
        title: 'Shop Agent',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const DashboardScreen(),
      ),
    );
  }
}
