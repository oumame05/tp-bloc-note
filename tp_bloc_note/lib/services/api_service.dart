// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart'; // Import du modèle Note

class ApiService {
  // L'URL de base de l'API REST fictive (JSONPlaceholder)
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // 1. Récupérer toutes les notes (GET)
  Future<List<Note>> getAllNotes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));

      if (response.statusCode == 200) {
        // La requête a réussi, on décode le JSON en une liste dynamique
        final List<dynamic> data = jsonDecode(response.body);
        
        // On mappe chaque élément JSON vers un objet Note
        return data.map((json) {
          return Note(
            id: json['id'].toString(), // Conversion de l'ID en String
            titre: json['title'] ?? 'Sans titre', // Mapping de title vers titre
            contenu: json['body'] ?? '', // Mapping de body vers contenu
            couleur: '#FFE082', // Couleur par défaut
            dateCreation: DateTime.now(), // Date actuelle par défaut
          );
        }).toList();
      } else {
        print('Erreur GET: code ${response.statusCode}');
        return []; // Retourne une liste vide en cas de code d'erreur HTTP
      }
    } catch (e) {
      print('Exception GET: $e');
      return []; // Retourne une liste vide en cas d'erreur réseau
    }
  }

  // 2. Créer une nouvelle note (POST)
  Future<bool> createNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json', // On précise qu'on envoie du JSON
        },
        body: jsonEncode({
          'title': note.titre,
          'body': note.contenu,
          'userId': 1, // Requis par JSONPlaceholder
        }),
      );

      // JSONPlaceholder renvoie 201 (Created) lors d'une création réussie
      if (response.statusCode == 201) {
        return true;
      } else {
        print('Erreur POST: code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception POST: $e');
      return false; // Retourne false en cas d'erreur réseau
    }
  }

  // 3. Supprimer une note (DELETE)
  Future<bool> deleteNote(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));

      // JSONPlaceholder renvoie 200 (OK) lors d'une suppression réussie
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erreur DELETE: code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception DELETE: $e');
      return false; // Retourne false en cas d'erreur réseau
    }
  }
}
