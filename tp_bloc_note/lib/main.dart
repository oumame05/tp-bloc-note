import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/home_page.dart';

void main() async {
  // Initialiser les locales pour le français
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc-Notes',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
