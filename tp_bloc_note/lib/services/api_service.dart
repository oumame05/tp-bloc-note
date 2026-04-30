import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Note>> getAllNotes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts?_limit=10'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map(
              (json) => Note(
                id: json['id'].toString(),
                titre: json['title'] ?? 'Sans titre',
                contenu: json['body'] ?? '',
                couleur: '#FFE082',
                dateCreation: DateTime.now(),
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createNote(Note note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': note.titre,
          'body': note.contenu,
          'userId': 1,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNote(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
