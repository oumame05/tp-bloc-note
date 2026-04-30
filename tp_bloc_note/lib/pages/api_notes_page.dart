import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class ApiNotesPage extends StatefulWidget {
  const ApiNotesPage({super.key});

  @override
  State<ApiNotesPage> createState() => _ApiNotesPageState();
}

class _ApiNotesPageState extends State<ApiNotesPage> {
  // Instance du service API pour communiquer avec JSONPlaceholder
  final ApiService _apiService = ApiService();

  // État de chargement — true pendant qu'on attend la réponse du serveur
  bool _isLoading = false;

  // Message d'erreur — null si pas d'erreur
  String? _error;

  // Liste des notes récupérées depuis le serveur
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    // Charge les notes dès l'ouverture de la page
    _fetchNotes();
  }

  // GET — Récupère toutes les notes depuis JSONPlaceholder
  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notes = await _apiService.getAllNotes();
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  // POST — Affiche un formulaire et crée une note via JSONPlaceholder
  Future<void> _showCreateDialog() async {
    final titreController = TextEditingController();
    final contenuController = TextEditingController();

    // Sauvegarde le ScaffoldMessenger AVANT le dialog
    // pour éviter l'erreur de contexte après fermeture du dialog
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nouvelle note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Champ titre obligatoire
            TextField(
              controller: titreController,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            // Champ contenu optionnel
            TextField(
              controller: contenuController,
              decoration: const InputDecoration(
                labelText: 'Contenu',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          // Annuler — ferme le dialog sans rien faire
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          // Créer — envoie la note via POST
          ElevatedButton(
            onPressed: () async {
              // Validation : titre ne doit pas être vide
              if (titreController.text.trim().isEmpty) return;

              // Crée l'objet Note avec un ID unique (timestamp)
              final note = Note.nouvelle(
                titre: titreController.text.trim(),
                contenu: contenuController.text.trim(),
                couleur: '#FFE082',
              );

              // Ferme le dialog AVANT l'appel API
              Navigator.pop(dialogContext);

              // Envoie la note au serveur via POST
              final success = await _apiService.createNote(note);

              // Si le widget est encore actif, met à jour l'interface
              if (mounted) {
                if (success) {
                  // Ajoute la note en tête de liste localement
                  setState(() {
                    _notes.insert(0, note);
                  });
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Note créée avec succès ✅'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de la création ❌'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    // Libère les contrôleurs pour éviter les fuites mémoire
    titreController.dispose();
    contenuController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes API'),
        centerTitle: true,
        actions: [
          // Bouton refresh — recharge les notes depuis le serveur
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchNotes),
        ],
      ),
      body: _buildBody(),
      // Bouton + pour créer une nouvelle note
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Construit le corps selon les 3 états : chargement / erreur / liste
  Widget _buildBody() {
    // État 1 — Chargement en cours
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // État 2 — Erreur réseau ou serveur
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchNotes,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    // État 3 — Liste vide
    if (_notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune note trouvée', style: TextStyle(color: Colors.grey)),
            Text(
              'Appuyez sur + pour créer une note',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // État 4 — Affiche la liste des notes
    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];

        // Dismissible — suppression par glissement vers la gauche
        return Dismissible(
          key: Key(note.id),
          direction: DismissDirection.endToStart,
          // Fond rouge avec icône poubelle pendant le glissement
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          // DELETE — appelé quand la note est complètement glissée
          onDismissed: (direction) {
            final removedNote = note;

            // Supprime visuellement immédiatement
            setState(() {
              _notes.removeAt(index);
            });

            // Envoie la requête DELETE au serveur
            _apiService.deleteNote(note.id).then((success) {
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note supprimée ✅'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                // Remet la note si le DELETE a échoué
                setState(() {
                  _notes.insert(index, removedNote);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la suppression ❌'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
          },
          // Carte affichant la note
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              // Barre colorée à gauche selon la couleur de la note
              leading: Container(
                width: 6,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse('FF${note.couleur.substring(1)}', radix: 16),
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Titre en gras
              title: Text(
                note.titre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // Contenu tronqué à 50 caractères
              subtitle: Text(
                note.contenu.length > 50
                    ? '${note.contenu.substring(0, 50)}...'
                    : note.contenu,
              ),
            ),
          ),
        );
      },
    );
  }
}
