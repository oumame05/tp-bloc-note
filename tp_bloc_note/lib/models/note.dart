import 'package:intl/intl.dart';

class Note {
  final String id;
  final String titre;
  final String contenu;
  final String couleur; // code hexadécimal ex: "#FFE082"
  final DateTime dateCreation;
  final DateTime? dateModification;

  Note({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.couleur,
    required this.dateCreation,
    this.dateModification,
  });

  // Factory pour créer une nouvelle note
  factory Note.nouvelle({
    required String titre,
    required String contenu,
    required String couleur,
  }) {
    final now = DateTime.now();
    return Note(
      id: now.millisecondsSinceEpoch.toString(),
      titre: titre,
      contenu: contenu,
      couleur: couleur,
      dateCreation: now,
      dateModification: null,
    );
  }

  // copyWith pour modifier une note existante
  Note copyWith({
    String? id,
    String? titre,
    String? contenu,
    String? couleur,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Note(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      couleur: couleur ?? this.couleur,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? DateTime.now(),
    );
  }

  // Convertit une Note en Map (JSON) pour le stockage local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'couleur': couleur,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification?.toIso8601String(),
    };
  }

  // Reconstruit une Note depuis une Map (JSON)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      titre: json['titre'] as String,
      contenu: json['contenu'] as String,
      couleur: json['couleur'] as String,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      dateModification: json['dateModification'] != null
          ? DateTime.parse(json['dateModification'] as String)
          : null,
    );
  }

  // Getter pour la date formatée en français
  String get dateFormatee {
    final formatter = DateFormat('d MMMM yyyy à HH:mm', 'fr_FR');
    return formatter.format(dateCreation);
  }

  String get dateFormateee {
    // Utiliser une méthode manuelle au lieu de intl
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    final day = dateCreation.day;
    final month = months[dateCreation.month - 1];
    final year = dateCreation.year;
    final hour = dateCreation.hour;
    final minute = dateCreation.minute.toString().padLeft(2, '0');

    return '$day $month $year à $hour:$minute';
  }
}
