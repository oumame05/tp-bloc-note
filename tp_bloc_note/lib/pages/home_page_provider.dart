// Importe le package Flutter pour les composants d'interface Material Design
import 'package:flutter/material.dart';
import 'dart:async'; // Pour StreamSubscription
import 'package:connectivity_plus/connectivity_plus.dart'; // Pour écouter le réseau en direct

// Importe le package provider pour la gestion d'état
import 'package:provider/provider.dart';

// Importe le service de gestion des notes
import '../services/note_service.dart';

// Importe le modèle Note
import '../models/note.dart';

// Importe la page de création/modification de note
import 'create_page.dart';

// Importe la page de détail d'une note
import 'detail_page.dart';

// Importe la page des notes de l'API
import 'api_notes_page.dart';

// Importe l'utilitaire de connectivité
import '../utils/connectivity.dart';

// Déclare une page avec état utilisant Provider pour la gestion d'état
class HomePageProvider extends StatefulWidget {
  // Constructeur par défaut
  const HomePageProvider({super.key});

  // Crée l'état associé à ce widget
  @override
  State<HomePageProvider> createState() => _HomePageProviderState();
}

// Classe d'état privée pour HomePageProvider
class _HomePageProviderState extends State<HomePageProvider> {
  // Stocke la requête de recherche tapée par l'utilisateur
  String _query = '';

  // État de la connexion (vrai par défaut en attendant la vérification)
  bool _isConnected = true;
  
  // Abonnement pour écouter les changements de connexion en direct
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity(); // Vérification initiale

    // Abonnement aux changements d'état du réseau
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool isNowConnected = true;
      // Logique similaire à notre isConnected() utilitaire
      if (results.contains(ConnectivityResult.none) && results.length == 1) {
        isNowConnected = false;
      } else if (results.isEmpty || results.first == ConnectivityResult.none) {
        isNowConnected = false;
      }
      
      // Met à jour l'interface seulement si l'état a changé
      if (mounted && _isConnected != isNowConnected) {
        setState(() {
          _isConnected = isNowConnected;
        });
      }
    });
  }

  @override
  void dispose() {
    // Il est très important d'annuler l'abonnement quand la page est détruite
    // pour éviter les fuites de mémoire (memory leaks)
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Vérifie la connexion internet et met à jour l'interface
  Future<void> _checkConnectivity() async {
    final connected = await isConnected();
    if (mounted) {
      setState(() {
        _isConnected = connected;
      });
    }
  }

  // Méthode de construction de l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    // Récupère l'instance du service de notes via Provider
    final noteService = Provider.of<NoteService>(context);

    // Applique le filtre de recherche aux notes
    final notesFiltrees = noteService.search(_query);

    // Scaffold fournit la structure visuelle de base
    return Scaffold(
      // Barre d'applications en haut de l'écran
      appBar: AppBar(
        title: const Text('Mes Notes'), // Titre de l'app
        centerTitle: true, // Centrer le titre
        // Actions dans l'AppBar (icônes à droite)
        actions: [
          // Icône d'état de la connexion réseau
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              _isConnected ? Icons.wifi : Icons.wifi_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
          ),
          
          // Bouton pour accéder à la page API (synchronisation)
          IconButton(
            icon: const Icon(Icons.cloud),
            onPressed: () {
              if (_isConnected) {
                // Si connecté, on navigue vers la page API
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApiNotesPage()),
                );
              } else {
                // Si hors ligne, on affiche un message d'erreur
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pas de connexion — mode hors ligne'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
          // Compteur de notes avec Consumer (reconstruction ciblée uniquement sur ce widget)
          Consumer<NoteService>(
            builder: (context, service, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16), // Marge à droite
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ), // Padding interne
                decoration: BoxDecoration(
                  color: Colors.white, // Fond blanc
                  borderRadius: BorderRadius.circular(20), // Coins arrondis
                ),
                child: Center(
                  child: Text(
                    '${service.count}', // Affiche le nombre total de notes
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // Texte bleu
                    ),
                  ),
                ),
              );
            },
          ),

          // Menu déroulant pour le tri
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort), // Icône de tri
            onSelected: (value) {
              // Action quand une option est sélectionnée
              noteService.setSortCritere(
                value,
              ); // Change le critère de tri dans le service
            },
            // Construction des éléments du menu
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date_desc',
                child: Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 8),
                    Text('Date (récent → ancien)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'date_asc',
                child: Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 8),
                    Text('Date (ancien → récent)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'titre_asc',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('Titre (A → Z)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'titre_desc',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('Titre (Z → A)'),
                  ],
                ),
              ),
            ],
          ),
        ],

        // Barre inférieure de l'AppBar (contient la barre de recherche)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60), // Hauteur fixe de 60 pixels
          child: Padding(
            padding: const EdgeInsets.all(8), // Marge interne
            child: TextField(
              onChanged: (value) {
                // Appelé à chaque changement de texte
                setState(() {
                  _query = value; // Met à jour la requête de recherche
                });
              },
              decoration: const InputDecoration(
                hintText: 'Rechercher...', // Texte indicatif
                prefixIcon: Icon(Icons.search), // Icône loupe à gauche
                border: OutlineInputBorder(
                  // Bordure avec contour
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true, // Fond rempli
                fillColor: Colors.white, // Fond blanc
              ),
            ),
          ),
        ),
      ),

      // Corps principal de la page
      body: notesFiltrees.isEmpty
          // Si aucun résultat : affiche un message avec icône
          ? const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centrage vertical
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey,
                  ), // Icône loupe barrée
                  SizedBox(height: 16), // Espace vertical
                  Text(
                    'Aucun résultat',
                    style: TextStyle(color: Colors.grey),
                  ), // Message
                ],
              ),
            )
          // Si des résultats existent : affiche une liste défilable
          : ListView.builder(
              itemCount: notesFiltrees.length, // Nombre d'éléments
              itemBuilder: (context, index) {
                // Construction de chaque élément
                final note = notesFiltrees[index]; // Récupère la note à l'index

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ), // Marge extérieure
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          // Bordure gauche colorée selon la note
                          color: Color(
                            int.parse(note.couleur.substring(1, 7), radix: 16),
                          ),
                          width: 6, // Épaisseur de la bordure
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        note.titre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ), // Titre en gras
                      ),
                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Alignement à gauche
                        children: [
                          // Affiche le début du contenu (tronqué à 30 caractères)
                          Text(
                            note.contenu.length > 30
                                ? '${note.contenu.substring(0, 30)}...'
                                : note.contenu,
                          ),
                          const SizedBox(height: 4), // Espace vertical
                          // Affiche la date formatée
                          Text(
                            note.dateFormatee,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      // Action au clic sur la carte
                      onTap: () async {
                        // Navigue vers la page de détail
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(note: note),
                          ),
                        );

                        // Traite le résultat retourné (modification ou suppression)
                        if (result != null) {
                          if (result is Note) {
                            noteService.updateNote(
                              result,
                            ); // Met à jour la note dans le service
                          } else if (result == 'deleted') {
                            noteService.deleteNote(
                              note.id,
                            ); // Supprime la note du service
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),

      // Bouton flottant d'action (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigue vers la page de création de note
          final nouvelleNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNotePage()),
          );

          // Si une nouvelle note a été créée
          if (nouvelleNote != null && nouvelleNote is Note) {
            noteService.addNote(nouvelleNote); // Ajoute la note au service
          }
        },
        child: const Icon(Icons.add), // Icône +
      ),
    );
  }
}
