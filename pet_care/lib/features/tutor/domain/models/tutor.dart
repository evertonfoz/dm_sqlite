class Tutor {
  final int? tutorId;
  final String nome;
  final String email;
  final String telefone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Tutor({
    this.tutorId,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Converte a instância de [Tutor] em um [Map<String, dynamic>] para persistência no SQLite.
  Map<String, dynamic> toMap() {
    return {
      'tutorId': tutorId,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  /// Converte um registro do SQLite [Map<String, dynamic>] em uma instância de [Tutor].
  factory Tutor.fromMap(Map<String, dynamic> map) {
    return Tutor(
      tutorId: map['tutorId'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      telefone: map['telefone'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'] as String)
          : null,
    );
  }

  /// Retorna uma cópia desta instância com campos atualizados.
  Tutor copyWith({
    int? tutorId,
    String? nome,
    String? email,
    String? telefone,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Tutor(
      tutorId: tutorId ?? this.tutorId,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
