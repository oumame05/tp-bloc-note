import 'dart:convert';
// Importe le package Flutter pour les composants d'interface Material Design
import 'package:flutter/material.dart';

// Importe SharedPreferences pour la persistance locale
import 'package:shared_preferences/shared_preferences.dart';

// Importe le modèle Note depuis le dossier models
import '../models/note.dart';

// Définit un service de gestion des notes qui étend ChangeNotifier
// ChangeNotifier permet de notifier les widgets écoutants des changements
class NoteService extends ChangeNotifier {
  // Instance de SharedPreferences pour le stockage
  final SharedPreferences _prefs;

  // Liste privée des notes (encapsulation)
  List<Note> _notes = [];

  // Critère de tri actuel (par défaut : date décroissante)
  // Options possibles : 'date_desc', 'date_asc', 'titre_asc', 'titre_desc'
  String _sortCritere = 'date_desc';

  // Constructeur qui reçoit l'instance de SharedPreferences
  NoteService(this._prefs) {
    _loadNotes(); // Charge les notes au démarrage
  }

  // Méthode privée pour charger les notes depuis SharedPreferences
  void _loadNotes() {
    final List<String>? notesStringList = _prefs.getStringList('notes');
    if (notesStringList != null) {
      try {
        _notes = notesStringList
            .map((noteStr) => Note.fromJson(jsonDecode(noteStr)))
            .toList();
        _applySort(); // Trie les notes chargées
      } catch (e) {
        debugPrint('Erreur lors du chargement des notes: $e');
      }
    }
  }

  // Méthode privée pour sauvegarder les notes dans SharedPreferences
  Future<void> _saveNotes() async {
    final List<String> notesStringList =
        _notes.map((note) => jsonEncode(note.toJson())).toList();
    await _prefs.setStringList('notes', notesStringList);
  }

  // Getters (accesseurs publics en lecture seule)

  // Retourne une copie non modifiable de la liste des notes
  // Empêche la modification directe de la liste depuis l'extérieur
  List<Note> get notes => List.unmodifiable(_notes);

  // Retourne le nombre total de notes
  int get count => _notes.length;

  // Retourne le critère de tri actuel
  String get sortCritere => _sortCritere;

  // Méthode pour changer le critère de tri
  void setSortCritere(String critere) {
    _sortCritere = critere; // Met à jour le critère
    _applySort(); // Applique le tri sur la liste
    notifyListeners(); // Notifie les widgets pour qu'ils se rafraîchissent
  }

  // Méthode privée pour appliquer le tri selon le critère actuel
  void _applySort() {
    // Switch selon le critère de tri
    switch (_sortCritere) {
      case 'date_desc': // Tri par date décroissante (plus récent en premier)
        _notes.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
        break;

      case 'date_asc': // Tri par date croissante (plus ancien en premier)
        _notes.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
        break;

      case 'titre_asc': // Tri par titre alphabétique A→Z
        _notes.sort((a, b) => a.titre.compareTo(b.titre));
        break;

      case 'titre_desc': // Tri par titre alphabétique Z→A
        _notes.sort((a, b) => b.titre.compareTo(a.titre));
        break;
    }
  }

  // CRUD - Create (Ajouter une note)
  void addNote(Note note) {
    _notes.insert(0, note); // Insère la nouvelle note au début de la liste
    _applySort(); // Applique le tri actuel
    _saveNotes(); // Sauvegarde les changements
    notifyListeners(); // Notifie les widgets du changement
  }

  // CRUD - Update (Modifier une note existante)
  void updateNote(Note note) {
    // Trouve l'index de la note dans la liste (basé sur l'ID)
    final index = _notes.indexWhere((n) => n.id == note.id);

    // Si la note existe (index != -1)
    if (index != -1) {
      _notes[index] = note; // Remplace l'ancienne note par la nouvelle
      _applySort(); // Applique le tri actuel
      _saveNotes(); // Sauvegarde les changements
      notifyListeners(); // Notifie les widgets du changement
    }
  }

  // CRUD - Delete (Supprimer une note)
  void deleteNote(String id) {
    _notes.removeWhere(
      (n) => n.id == id,
    ); // Supprime toutes les notes avec cet ID
    _saveNotes(); // Sauvegarde les changements
    notifyListeners(); // Notifie les widgets du changement
  }

  // CRUD - Read (Récupérer une note par son ID)
  Note? getNoteById(String id) {
    try {
      // Essaye de trouver la première note correspondant à l'ID
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      // Si aucune note n'est trouvée, retourne null
      return null;
    }
  }

  // Fonction de recherche
  List<Note> search(String query) {
    // Si la requête est vide, retourne toutes les notes
    if (query.isEmpty) return notes;

    // Filtre les notes dont le titre OU le contenu contient la requête (insensible à la casse)
    return notes.where((note) {
      return note.titre.toLowerCase().contains(query.toLowerCase()) ||
          note.contenu.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
