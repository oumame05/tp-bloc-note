import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class ApiNotesPage extends StatefulWidget {
  const ApiNotesPage({super.key});

  @override
  State<ApiNotesPage> createState() => _ApiNotesPageState();
}

class _ApiNotesPageState extends State<ApiNotesPage> {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _error;
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

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
        _error = 'Erreur lors du chargement des notes: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestNote() async {
    // Création d'une note fictive pour tester l'API
    final note = Note.nouvelle(
      titre: 'Nouvelle note API',
      contenu: 'Ceci est une note de test envoyée vers JSONPlaceholder.',
      couleur: '#FFE082',
    );

    final success = await _apiService.createNote(note);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note créée avec succès !')),
      );
      // Au lieu de recharger la liste (JSONPlaceholder ne sauvegarde pas vraiment),
      // on ajoute la note directement dans notre liste locale pour la voir.
      setState(() {
        _notes.insert(0, note);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la création de la note'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes API'),
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTestNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchNotes,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_notes.isEmpty) {
      return const Center(
        child: Text('Aucune note trouvée.'),
      );
    }

    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Dismissible(
          // Utilisation de l'ID comme clé unique pour le Dismissible
          key: Key(note.id),
          // Direction vers la gauche (EndToStart)
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            // Retirer de la liste localement
            final removedNote = _notes[index];
            setState(() {
              _notes.removeAt(index);
            });

            // Appeler l'API pour supprimer
            _apiService.deleteNote(note.id).then((success) {
              if (!mounted) return;
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note supprimée avec succès')),
                );
              } else {
                // En cas d'erreur, remettre la note dans la liste
                setState(() {
                  _notes.insert(index, removedNote);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la suppression'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                note.titre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
