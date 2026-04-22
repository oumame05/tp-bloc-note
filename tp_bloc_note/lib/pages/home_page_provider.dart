import 'package:flutter/material.dart';
import '../models/note.dart';
import 'create_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> _notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune note',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Appuyez sur le bouton + pour créer une note',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return _buildNoteCard(note, index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _creerNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    // Convertir la couleur hexadécimale en Color
    Color borderColor = Color(
      int.parse(note.couleur.substring(1, 7), radix: 16),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: borderColor, width: 6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            note.titre,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                note.contenu.length > 30
                    ? '${note.contenu.substring(0, 30)}...'
                    : note.contenu,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    note.dateFormatee,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () => _ouvrirDetailNote(note, index),
        ),
      ),
    );
  }

  // Créer une nouvelle note
  Future<void> _creerNote() async {
    final nouvelleNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNotePage()),
    );

    if (nouvelleNote != null && nouvelleNote is Note) {
      setState(() {
        _notes.add(nouvelleNote);
      });
    }
  }

  // Ouvrir le détail d'une note
  Future<void> _ouvrirDetailNote(Note note, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(note: note)),
    );

    if (result != null) {
      setState(() {
        if (result is Note) {
          // Modification : remplacer la note existante
          _notes[index] = result;
        } else if (result == 'deleted') {
          // Suppression : retirer la note de la liste
          _notes.removeAt(index);
        }
      });
    }
  }
}
