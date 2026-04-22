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
