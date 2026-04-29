// Importe le package Flutter pour les composants d'interface Material Design
import 'package:flutter/material.dart';

// Importe le modèle Note depuis le dossier models
import '../models/note.dart';

// Déclare une page avec état (StatefulWidget) pour créer/modifier une note
class CreateNotePage extends StatefulWidget {
  // Propriété optionnelle contenant une note existante (pour la modification)
  final Note? noteExistante;

  // Constructeur avec paramètre optionnel noteExistante et clé super
  const CreateNotePage({super.key, this.noteExistante});

  // Crée l'état associé à ce widget
  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

// Classe d'état privée pour CreateNotePage
class _CreateNotePageState extends State<CreateNotePage> {
  // Contrôleur pour le champ de texte du titre
  final TextEditingController _titreController = TextEditingController();

  // Contrôleur pour le champ de texte du contenu
  final TextEditingController _contenuController = TextEditingController();

  // Stocke la couleur choisie (format hexadécimal par défaut : jaune clair)
  String _couleurChoisie = '#FFE082';

  // Liste des couleurs disponibles pour la note
  final List<String> _couleursDisponibles = [
    '#FFE082', // Jaune clair
    '#FFAB91', // Orange clair
    '#CE93D8', // Violet clair
    '#90CAF9', // Bleu clair
    '#A5D6A7', // Vert clair
    '#EF9A9A', // Rouge clair
  ];

  // Méthode appelée une fois lorsque l'état est initialisé
  @override
  void initState() {
    super.initState(); // Appelle la méthode initState parente
    // Si on est en mode modification, pré-remplir les champs
    if (widget.noteExistante != null) {
      _titreController.text = widget.noteExistante!.titre; // Remplit le titre
      _contenuController.text =
          widget.noteExistante!.contenu; // Remplit le contenu
      _couleurChoisie = widget.noteExistante!.couleur; // Restaure la couleur
    }
  }

  // Méthode appelée lors de la destruction du widget pour libérer les ressources
  @override
  void dispose() {
    _titreController.dispose(); // Libère le contrôleur du titre
    _contenuController.dispose(); // Libère le contrôleur du contenu
    super.dispose(); // Appelle la méthode dispose parente
  }

  // Méthode pour sauvegarder la note (création ou modification)
  void _sauvegarder() {
    // Validation : le titre ne doit pas être vide (après suppression des espaces)
    if (_titreController.text.trim().isEmpty) {
      // Affiche un message d'erreur en bas de l'écran
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le titre ne peut pas être vide'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return; // Sort de la méthode
    }

    Note note; // Déclare une variable pour stocker la note

    if (widget.noteExistante != null) {
      // Mode modification : crée une copie modifiée de la note existante
      note = widget.noteExistante!.copyWith(
        titre: _titreController.text.trim(), // Nouveau titre
        contenu: _contenuController.text.trim(), // Nouveau contenu
        couleur: _couleurChoisie, // Nouvelle couleur
      );
    } else {
      // Mode création : crée une nouvelle note
      note = Note.nouvelle(
        titre: _titreController.text.trim(),
        contenu: _contenuController.text.trim(),
        couleur: _couleurChoisie,
      );
    }

    // Ferme la page actuelle et retourne la note à la page précédente
    Navigator.pop(context, note);
  }

  // Méthode de construction de l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    // Détermine si on est en mode édition (modification)
    final bool isEditing = widget.noteExistante != null;

    // Scaffold fournit la structure visuelle de base (AppBar, body, etc.)
    return Scaffold(
      // Barre d'applications en haut de l'écran
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifier la note' : 'Nouvelle note',
        ), // Titre dynamique
        backgroundColor: Colors.blue, // Fond bleu
        foregroundColor: Colors.white, // Texte blanc
      ),
      // Corps principal de la page
      body: SingleChildScrollView(
        // Permet de faire défiler si le contenu dépasse
        padding: const EdgeInsets.all(16), // Marge intérieure de 16 pixels
        child: Column(
          // Disposition verticale
          crossAxisAlignment: CrossAxisAlignment.start, // Alignement à gauche
          children: [
            // Champ Titre
            TextField(
              controller: _titreController, // Lie le contrôleur au champ
              decoration: const InputDecoration(
                labelText: 'Titre *', // Texte du label
                hintText: 'Entrez le titre de la note', // Texte indicatif
                border: OutlineInputBorder(), // Bordure avec contour
                counterText: '', // Supprime le compteur de caractères
              ),
              maxLength: 60, // Limite à 60 caractères
              maxLines: 1, // Une seule ligne
              autofocus: !isEditing, // Auto-focus seulement en création
            ),
            const SizedBox(height: 16), // Espace vertical de 16 pixels
            // Champ Contenu
            TextField(
              controller: _contenuController,
              decoration: const InputDecoration(
                labelText: 'Contenu',
                hintText: 'Entrez le contenu de la note',
                border: OutlineInputBorder(),
                alignLabelWithHint: true, // Aligne le label avec le hint
              ),
              minLines: 4, // Hauteur minimale de 4 lignes
              maxLines: 10, // Hauteur maximale de 10 lignes
            ),
            const SizedBox(height: 20),

            // Sélecteur de couleur
            const Text(
              'Couleur :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),

            // Ligne horizontale pour les cercles de couleur
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Espacement égal
              children: _couleursDisponibles.map((couleur) {
                final isSelected =
                    _couleurChoisie ==
                    couleur; // Vérifie si cette couleur est sélectionnée

                // Détecteur de geste pour le tap
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Met à jour l'interface
                      _couleurChoisie = couleur;
                    });
                  },
                  child: Container(
                    width: 50, // Largeur 50 pixels
                    height: 50, // Hauteur 50 pixels
                    decoration: BoxDecoration(
                      // Convertit la chaîne hexadécimale en couleur
                      color: Color(
                        int.parse('FF${couleur.substring(1)}', radix: 16),
                      ),
                      shape: BoxShape.circle, // Forme circulaire
                      // Bordure plus épaisse si sélectionnée
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : Border.all(color: Colors.grey, width: 1),
                      // Ombre portée si sélectionnée
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(), // Convertit le map en liste
            ),
            const SizedBox(height: 32),

            // Bouton Sauvegarder (pleine largeur)
            SizedBox(
              width: double.infinity, // Prend toute la largeur disponible
              height: 50, // Hauteur fixe de 50 pixels
              child: ElevatedButton(
                onPressed: _sauvegarder, // Appelle la méthode de sauvegarde
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Fond bleu
                  foregroundColor: Colors.white, // Texte blanc
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Coins arrondis
                  ),
                ),
                child: Text(
                  isEditing
                      ? 'Mettre à jour'
                      : 'Créer la note', // Texte dynamique
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
