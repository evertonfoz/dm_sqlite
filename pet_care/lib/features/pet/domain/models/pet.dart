import 'package:pet_care/features/tutor/domain/models/tutor.dart';

class Pet {
  final int? petId;
  final String nome;
  final String especie;
  // final int tutorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Tutor? tutor;

  Pet({
    this.petId,
    required this.nome,
    required this.especie,
    // required this.tutorId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.tutor,
  });

  /// Converte a instância de [Pet] em um mapa de chave/valor [Map<String, dynamic>].
  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'nome': nome,
      'especie': especie,
      // 'tutorId': tutorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  /// Cria uma instância de [Pet] a partir de um mapa de chave/valor [Map<String, dynamic>].
  factory Pet.fromMap(Map<String, dynamic> map, {Tutor? tutor}) {
    return Pet(
      petId: map['petId'] as int?,
      nome: map['nome'] as String,
      especie: map['especie'] as String,
      // tutorId: map['tutorId'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'] as String)
          : null,
      tutor: tutor,
    );
  }

  /// Retorna uma cópia desta instância com campos atualizados.
  Pet copyWith({
    int? petId,
    String? nome,
    String? especie,
    // int? tutorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    Tutor? tutor,
  }) {
    return Pet(
      petId: petId ?? this.petId,
      nome: nome ?? this.nome,
      especie: especie ?? this.especie,
      // tutorId: tutorId ?? this.tutorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      tutor: tutor ?? this.tutor,
    );
  }
}
