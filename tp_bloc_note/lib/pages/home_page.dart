// Importe le package Flutter pour les composants d'interface Material Design
import 'package:flutter/material.dart';

// Importe le modèle Note depuis le dossier models
import '../models/note.dart';

// Importe la page de création/modification de note
import 'create_page.dart';

// Importe la page de détail d'une note
import 'detail_page.dart';

// Déclare une page avec état pour la page d'accueil (liste des notes)
class HomePage extends StatefulWidget {
  // Constructeur par défaut
  const HomePage({super.key});

  // Crée l'état associé à ce widget
  @override
  State<HomePage> createState() => _HomePageState();
}

// Classe d'état privée pour HomePage
class _HomePageState extends State<HomePage> {
  // Liste des notes (état interne)
  List<Note> _notes = [];

  // Méthode de construction de l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    // Scaffold fournit la structure visuelle de base (AppBar, body, FAB, etc.)
    return Scaffold(
      // Barre d'applications en haut de l'écran
      appBar: AppBar(
        title: const Text('Mes Notes'), // Titre de l'app
        centerTitle: true, // Centrer le titre
      ),

      // Corps principal de la page
      body:
          _notes
              .isEmpty // Vérifie si la liste est vide
          // Si la liste est vide : affiche un message centré
          ? const Center(child: Text('Aucune note'))
          // Si la liste contient des notes : affiche une liste défilable
          : ListView.builder(
              // Nombre total d'éléments dans la liste
              itemCount: _notes.length,

              // Constructeur de chaque élément de la liste
              itemBuilder: (context, index) {
                // Récupère la note à l'index courant
                final note = _notes[index];

                // Retourne une carte (Card) pour chaque note
                return Card(
                  // Marge extérieure de la carte
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16, // Marge horizontale
                    vertical: 8, // Marge verticale
                  ),

                  // Container pour personnaliser l'apparence
                  child: Container(
                    // Décoration de la bordure
                    decoration: BoxDecoration(
                      // Bordure gauche uniquement
                      border: Border(
                        left: BorderSide(
                          // Couleur de la bordure = couleur de la note
                          color: Color(
                            int.parse(note.couleur.substring(1, 7), radix: 16),
                          ),
                          width: 6, // Épaisseur de la bordure
                        ),
                      ),
                    ),

                    // Élément de liste avec titre, sous-titre et action au clic
                    child: ListTile(
                      // Titre de la note (en gras)
                      title: Text(
                        note.titre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      // Sous-titre (contenu et date)
                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Alignement à gauche
                        children: [
                          // Affichage du contenu (tronqué à 30 caractères)
                          Text(
                            note.contenu.length > 30
                                ? '${note.contenu.substring(0, 30)}...' // Ajoute "..." si trop long
                                : note.contenu, // Affiche le texte complet
                          ),
                          const SizedBox(
                            height: 4,
                          ), // Espace vertical de 4 pixels
                          // Affichage de la date formatée
                          Text(
                            note.dateFormatee,
                            style: const TextStyle(
                              fontSize: 12, // Petite taille
                              color: Colors.grey, // Couleur grise
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
                          // Met à jour l'état pour rafraîchir l'interface
                          setState(() {
                            // Si le résultat est une Note (modification)
                            if (result is Note) {
                              // Trouve l'index de la note modifiée dans la liste
                              final index = _notes.indexWhere(
                                (n) => n.id == result.id, // Compare par ID
                              );
                              // Si la note existe dans la liste
                              if (index != -1) {
                                _notes[index] =
                                    result; // Remplace par la version modifiée
                              }
                            }
                            // Si le résultat est 'deleted' (suppression)
                            else if (result == 'deleted') {
                              // Supprime la note de la liste
                              _notes.removeWhere((n) => n.id == note.id);
                            }
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),

      // Bouton flottant d'action (FAB)
      floatingActionButton: FloatingActionButton(
        // Action au clic sur le bouton
        onPressed: () async {
          // Navigue vers la page de création de note
          final nouvelleNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNotePage()),
          );

          // Si une nouvelle note a été créée et retournée
          if (nouvelleNote != null && nouvelleNote is Note) {
            // Met à jour l'état pour ajouter la nouvelle note
            setState(() {
              _notes.add(nouvelleNote); // Ajoute la note à la liste
            });
          }
        },
        // Icône du bouton (+)
        child: const Icon(Icons.add),
      ),
    );
  }
}
