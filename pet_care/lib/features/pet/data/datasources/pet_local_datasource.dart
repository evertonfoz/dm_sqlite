import 'package:pet_care/core/database/database_helper.dart';
import 'package:pet_care/features/pet/domain/models/pet.dart';
import 'package:pet_care/features/tutor/domain/models/tutor.dart';

/// Contrato para a fonte de dados local da feature Pet.
abstract class PetLocalDataSource {
  /// Insere um novo pet no banco de dados local.
  Future<int> insert(Pet pet);

  /// Recupera todos os pets ativos cadastrados no banco de dados local.
  Future<List<Pet>> getAll();

  /// Busca um pet específico ativo por ID no banco de dados local.
  Future<Pet?> getById(int id);

  /// Atualiza as informações de um pet no banco de dados local.
  Future<int> update(Pet pet);

  /// Realiza a exclusão lógica (soft delete) de um pet por ID.
  Future<int> delete(int id);

  /// Recupera todos os pets ativos associados a um determinado tutor.
  Future<List<Pet>> getByTutorId(int tutorId);
}

/// Implementação da fonte de dados local utilizando o pacote `sqflite`.
class SqflitePetLocalDataSource implements PetLocalDataSource {
  final DatabaseHelper _dbHelper;
  static const String _tableName = 'pets';

  SqflitePetLocalDataSource({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<int> insert(Pet pet) async {
    final db = await _dbHelper.database;
    try {
      return await db.insert(_tableName, pet.toMap());
    } catch (e) {
      throw Exception('Erro ao inserir pet: ${e.toString()}');
    }
  }

  @override
  Future<List<Pet>> getAll() async {
    final db = await _dbHelper.database;

    // Realiza um INNER JOIN para recuperar os dados do Tutor de forma eficiente em uma só consulta
    final result = await db.rawQuery('''
      SELECT p.*
      FROM $_tableName p
      WHERE p.deletedAt IS NULL
      ORDER BY p.createdAt DESC
    ''');
    // final result = await db.rawQuery('''
    //   SELECT p.*, t.nome as tutorNome, t.email as tutorEmail, t.telefone as tutorTelefone,
    //          t.createdAt as tutorCreatedAt, t.updatedAt as tutorUpdatedAt, t.deletedAt as tutorDeletedAt
    //   FROM $_tableName p
    //   INNER JOIN tutors t ON p.tutorId = t.tutorId
    //   WHERE p.deletedAt IS NULL AND t.deletedAt IS NULL
    //   ORDER BY p.createdAt DESC
    // ''');

    return result.map((row) {
      // final tutor = Tutor(
      //   tutorId: row['tutorId'] as int,
      //   nome: row['tutorNome'] as String,
      //   email: row['tutorEmail'] as String,
      //   telefone: row['tutorTelefone'] as String,
      //   createdAt: DateTime.parse(row['tutorCreatedAt'] as String),
      //   updatedAt: DateTime.parse(row['tutorUpdatedAt'] as String),
      //   deletedAt: row['tutorDeletedAt'] != null
      //       ? DateTime.parse(row['tutorDeletedAt'] as String)
      //       : null,
      // );
      return Pet.fromMap(row); //, tutor: tutor);
    }).toList();
  }

  @override
  Future<Pet?> getById(int id) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT p.*, t.nome as tutorNome, t.email as tutorEmail, t.telefone as tutorTelefone,
             t.createdAt as tutorCreatedAt, t.updatedAt as tutorUpdatedAt, t.deletedAt as tutorDeletedAt
      FROM $_tableName p
      INNER JOIN tutors t ON p.tutorId = t.tutorId
      WHERE p.petId = ? AND p.deletedAt IS NULL
    ''',
      [id],
    );

    if (result.isNotEmpty) {
      final row = result.first;
      final tutor = Tutor(
        tutorId: row['tutorId'] as int,
        nome: row['tutorNome'] as String,
        email: row['tutorEmail'] as String,
        telefone: row['tutorTelefone'] as String,
        createdAt: DateTime.parse(row['tutorCreatedAt'] as String),
        updatedAt: DateTime.parse(row['tutorUpdatedAt'] as String),
        deletedAt: row['tutorDeletedAt'] != null
            ? DateTime.parse(row['tutorDeletedAt'] as String)
            : null,
      );
      return Pet.fromMap(row, tutor: tutor);
    }
    return null;
  }

  @override
  Future<int> update(Pet pet) async {
    final db = await _dbHelper.database;
    return await db.update(
      _tableName,
      pet.toMap(),
      where: 'petId = ?',
      whereArgs: [pet.petId],
    );
  }

  @override
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    // Soft Delete: Atualiza apenas o campo deletedAt em vez de deletar o registro fisicamente
    return await db.update(
      _tableName,
      {'deletedAt': now},
      where: 'petId = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Pet>> getByTutorId(int tutorId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      _tableName,
      where: 'tutorId = ? AND deletedAt IS NULL',
      whereArgs: [tutorId],
      orderBy: 'createdAt DESC',
    );

    return result.map((map) => Pet.fromMap(map)).toList();
  }
}
