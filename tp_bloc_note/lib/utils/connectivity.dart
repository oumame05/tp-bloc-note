import 'package:connectivity_plus/connectivity_plus.dart';

// Fonction utilitaire pour vérifier si l'appareil est connecté à internet
Future<bool> isConnected() async {
  try {
    // Vérifie l'état de la connectivité réseau
    final List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    
    // À partir de connectivity_plus 6.0.0, checkConnectivity retourne une List<ConnectivityResult>
    // Si la liste contient uniquement 'none', alors on n'est pas connecté
    if (results.contains(ConnectivityResult.none) && results.length == 1) {
      return false;
    }
    
    // S'il n'y a aucun résultat ou que 'none' est le seul résultat, pas de connexion
    if (results.isEmpty || results.first == ConnectivityResult.none) {
      return false;
    }
    
    // Sinon on est connecté (wifi, mobile, ethernet, etc.)
    return true;
  } catch (e) {
    // En cas d'erreur (ex: permissions manquantes sur certaines plateformes),
    // on peut par défaut retourner false ou true selon la politique souhaitée.
    print('Erreur de vérification de connectivité : $e');
    return false;
  }
}
