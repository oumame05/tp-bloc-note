// Importe le package Flutter pour les composants d'interface Material Design
import 'package:flutter/material.dart';

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
