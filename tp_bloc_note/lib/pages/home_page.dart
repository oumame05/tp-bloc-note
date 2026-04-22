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
      appBar: AppBar(title: const Text('Mes Notes'), centerTitle: true),
      body: _notes.isEmpty
          ? const Center(child: Text('Aucune note'))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Color(
                            int.parse(note.couleur.substring(1, 7), radix: 16),
                          ),
                          width: 6,
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        note.titre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.contenu.length > 30
                                ? '${note.contenu.substring(0, 30)}...'
                                : note.contenu,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            note.dateFormatee,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(note: note),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            if (result is Note) {
                              final index = _notes.indexWhere(
                                (n) => n.id == result.id,
                              );
                              if (index != -1) {
                                _notes[index] = result;
                              }
                            } else if (result == 'deleted') {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nouvelleNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNotePage()),
          );
          if (nouvelleNote != null && nouvelleNote is Note) {
            setState(() {
              _notes.add(nouvelleNote);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
