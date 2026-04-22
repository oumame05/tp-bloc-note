import 'package:flutter/material.dart';
import '../models/note.dart';

class CreateNotePage extends StatefulWidget {
  final Note? noteExistante;

  const CreateNotePage({super.key, this.noteExistante});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _contenuController = TextEditingController();
  String _couleurChoisie = '#FFE082';

  // Palette de couleurs disponibles
  final List<String> _couleursDisponibles = [
    '#FFE082', // Jaune clair
    '#FFAB91', // Orange clair
    '#CE93D8', // Violet clair
    '#90CAF9', // Bleu clair
    '#A5D6A7', // Vert clair
    '#EF9A9A', // Rouge clair
  ];

  @override
  void initState() {
    super.initState();
    // Si on est en mode modification, pré-remplir les champs
    if (widget.noteExistante != null) {
      _titreController.text = widget.noteExistante!.titre;
      _contenuController.text = widget.noteExistante!.contenu;
      _couleurChoisie = widget.noteExistante!.couleur;
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  void _sauvegarder() {
    // Validation : le titre ne doit pas être vide
    if (_titreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le titre ne peut pas être vide'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Note note;

    if (widget.noteExistante != null) {
      // Mode modification
      note = widget.noteExistante!.copyWith(
        titre: _titreController.text.trim(),
        contenu: _contenuController.text.trim(),
        couleur: _couleurChoisie,
      );
    } else {
      // Mode création
      note = Note.nouvelle(
        titre: _titreController.text.trim(),
        contenu: _contenuController.text.trim(),
        couleur: _couleurChoisie,
      );
    }

    Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.noteExistante != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la note' : 'Nouvelle note'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champ Titre
            TextField(
              controller: _titreController,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                hintText: 'Entrez le titre de la note',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              maxLength: 60,
              maxLines: 1,
              autofocus: !isEditing,
            ),
            const SizedBox(height: 16),

            // Champ Contenu
            TextField(
              controller: _contenuController,
              decoration: const InputDecoration(
                labelText: 'Contenu',
                hintText: 'Entrez le contenu de la note',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 4,
              maxLines: 10,
            ),
            const SizedBox(height: 20),

            // Sélecteur de couleur
            const Text(
              'Couleur :',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _couleursDisponibles.map((couleur) {
                final isSelected = _couleurChoisie == couleur;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _couleurChoisie = couleur;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(couleur.substring(1, 7), radix: 16),
                      ),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : Border.all(color: Colors.grey, width: 1),
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
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Bouton Sauvegarder
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _sauvegarder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? 'Mettre à jour' : 'Créer la note',
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
