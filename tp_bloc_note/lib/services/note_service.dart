import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteService extends ChangeNotifier {
  List<Note> _notes = [];
  String _sortCritere =
      'date_desc'; // date_desc, date_asc, titre_asc, titre_desc

  // Getters
  List<Note> get notes => List.unmodifiable(_notes);
  int get count => _notes.length;
  String get sortCritere => _sortCritere;

  // Tri
  void setSortCritere(String critere) {
    _sortCritere = critere;
    _applySort();
    notifyListeners();
  }

  void _applySort() {
    switch (_sortCritere) {
      case 'date_desc':
        _notes.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        break;
      case 'date_asc':
        _notes.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
        break;
      case 'titre_asc':
        _notes.sort((a, b) => a.titre.compareTo(b.titre));
        break;
      case 'titre_desc':
        _notes.sort((a, b) => b.titre.compareTo(a.titre));
        break;
    }
  }

  // CRUD
  void addNote(Note note) {
    _notes.insert(0, note);
    _applySort();
    notifyListeners();
  }

  void updateNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      _applySort();
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  // Recherche
  List<Note> search(String query) {
    if (query.isEmpty) return notes;
    return notes.where((note) {
      return note.titre.toLowerCase().contains(query.toLowerCase()) ||
          note.contenu.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
