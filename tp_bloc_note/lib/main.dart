// Importe le package Flutter pour les composants d'interface Material Design
import 'package:flutter/material.dart';

// Importe le package intl pour la gestion des dates et locales (français)
import 'package:intl/date_symbol_data_local.dart';

// Importe les packages pour la gestion d'état et le stockage local
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importe le service et la page d'accueil avec Provider
import 'services/note_service.dart';
import 'pages/home_page_provider.dart';

// Fonction principale, point d'entrée de l'application (async car initialisation asynchrone)
void main() async {
  // Initialise les liaisons entre Flutter et le moteur de rendu natif
  // Obligatoire avant d'utiliser certaines fonctions asynchrones
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise le formatage des dates pour la locale française (France)
  await initializeDateFormatting('fr_FR', null);

  // Initialise SharedPreferences avant le lancement de l'application
  final prefs = await SharedPreferences.getInstance();

  // Lance l'application enveloppée dans un ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => NoteService(prefs),
      child: const MyApp(),
    ),
  );
}

// Classe principale de l'application (Stateless car la configuration ne change pas)
class MyApp extends StatelessWidget {
  // Constructeur avec clé optionnelle
  const MyApp({super.key});

  // Méthode de construction de l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    // MaterialApp : widget racine qui fournit la configuration Material Design
    return MaterialApp(
      // Titre de l'application (apparaît dans le gestionnaire de tâches)
      title: 'Bloc-Notes',

      // Thème de l'application
      theme: ThemeData(
        primarySwatch: Colors.blue, // Couleur primaire (bleue)
        useMaterial3: true, // Active Material Design 3 (la dernière version)
      ),

      // Page d'accueil avec Provider affichée au démarrage
      home: const HomePageProvider(),

      // Désactive la bannière "DEBUG" en haut à droite de l'application
      debugShowCheckedModeBanner: false,
    );
  }
}
