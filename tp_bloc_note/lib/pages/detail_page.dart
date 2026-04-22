import 'package:flutter/material.dart';
import '../models/note.dart';
import 'create_page.dart';

class DetailPage extends StatelessWidget {
  final Note note;
  const DetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.titre),
        backgroundColor: Color(
          int.parse(note.couleur.substring(1, 7), radix: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final noteModifiee = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateNotePage(noteExistante: note),
                ),
              );
              if (noteModifiee != null && noteModifiee is Note) {
                Navigator.pop(context, noteModifiee);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer'),
                  content: const Text(
                    'Voulez-vous vraiment supprimer cette note ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                Navigator.pop(context, 'deleted');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.titre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(note.dateFormatee, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Expanded(child: SingleChildScrollView(child: Text(note.contenu))),
          ],
        ),
      ),
    );
  }
}
