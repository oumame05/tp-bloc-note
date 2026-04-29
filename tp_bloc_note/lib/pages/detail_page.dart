// Importe le package Flutter pour les composants d'interface Material Design
import 'package:flutter/material.dart';

// Importe le modèle Note depuis le dossier models
import '../models/note.dart';

// Importe la page de création/modification de note
import 'create_page.dart';

// Déclare une page stateless (sans état interne) pour afficher les détails d'une note
class DetailPage extends StatelessWidget {
  // Propriété finale contenant la note à afficher (obligatoire)
  final Note note;

  // Constructeur avec paramètre obligatoire note
  const DetailPage({super.key, required this.note});

  // Méthode de construction de l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    // Scaffold fournit la structure visuelle de base (AppBar, body, etc.)
    return Scaffold(
      // Barre d'applications en haut de l'écran
      appBar: AppBar(
        // Titre de l'AppBar = titre de la note
        title: Text(note.titre),
        // Couleur de fond de l'AppBar = couleur de la note
        backgroundColor: Color(
          // Convertit la chaîne hexadécimale en couleur (ex: #FFE082 -> Color)
          int.parse('FF${note.couleur.substring(1)}', radix: 16),
        ),
        // Liste des actions dans l'AppBar (icônes à droite)
        actions: [
          // Bouton d'édition (crayon)
          IconButton(
            icon: const Icon(Icons.edit), // Icône crayon
            onPressed: () async {
              // Fonction asynchrone appelée au clic
              // Ouvre la page de création/modification avec la note existante
              final noteModifiee = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateNotePage(noteExistante: note),
                ),
              );
              // Si une note modifiée est retournée ET que c'est bien une Note
              if (noteModifiee != null && noteModifiee is Note) {
                // Retourne la note modifiée à la page précédente (liste)
                Navigator.pop(context, noteModifiee);
              }
            },
          ),
          // Bouton de suppression (poubelle)
          IconButton(
            icon: const Icon(Icons.delete), // Icône poubelle
            onPressed: () async {
              // Fonction asynchrone appelée au clic
              // Affiche une boîte de dialogue de confirmation
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer'), // Titre du dialogue
                  content: const Text(
                    // Message de confirmation
                    'Voulez-vous vraiment supprimer cette note ?',
                  ),
                  actions: [
                    // Boutons d'action
                    // Bouton Annuler
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false), // Retourne false
                      child: const Text('Annuler'),
                    ),
                    // Bouton Supprimer
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, true), // Retourne true
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ), // Texte rouge
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );
              // Si l'utilisateur a confirmé la suppression (true)
              if (confirm == true) {
                // Retourne 'deleted' à la page précédente pour indiquer la suppression
                Navigator.pop(context, 'deleted');
              }
            },
          ),
        ],
      ),
      // Corps principal de la page
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ), // Marge intérieure de 16 pixels sur tous les côtés
        child: Column(
          // Disposition verticale
          crossAxisAlignment: CrossAxisAlignment.start, // Alignement à gauche
          children: [
            // Affichage du titre de la note
            Text(
              note.titre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ), // Taille 24, gras
            ),
            const SizedBox(height: 8), // Espace vertical de 8 pixels
            // Affichage de la date formatée de la note
            Text(
              note.dateFormatee,
              style: const TextStyle(color: Colors.grey), // Texte en gris
            ),
            const SizedBox(height: 24), // Espace vertical de 24 pixels
            // Zone extensible pour le contenu (prend l'espace restant)
            Expanded(
              // SingleChildScrollView permet de faire défiler le texte trop long
              child: SingleChildScrollView(
                child: Text(note.contenu), // Affichage du contenu de la note
              ),
            ),
          ],
        ),
      ),
    );
  }
}
