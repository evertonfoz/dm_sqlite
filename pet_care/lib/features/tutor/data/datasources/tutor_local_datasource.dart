import 'package:pet_care/core/database/database_helper.dart';
import 'package:pet_care/features/tutor/domain/models/tutor.dart';

/// Contrato para a fonte de dados local da feature Tutor.
abstract class TutorLocalDataSource {
  /// Insere um novo tutor no banco de dados local.
  Future<int> insert(Tutor tutor);

  /// Recupera todos os tutores ativos (não excluídos) no banco de dados local.
  Future<List<Tutor>> getAll({int limit = 20, int offset = 0});

  /// Busca um tutor específico ativo por ID no banco de dados local.
  Future<Tutor?> getById(int id);

  /// Atualiza as informações de um tutor no banco de dados local.
  Future<int> update(Tutor tutor);

  /// Realiza a exclusão lógica (soft delete) de um tutor por ID.
  Future<int> delete(int id);
}

/// Implementação da fonte de dados local utilizando o pacote `sqflite`.
class SqfliteTutorLocalDataSource implements TutorLocalDataSource {
  final DatabaseHelper _dbHelper;
  static const String _tableName = 'tutors';

  SqfliteTutorLocalDataSource({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<int> insert(Tutor tutor) async {
    final db = await _dbHelper.database;
    return await db.insert(_tableName, tutor.toMap());
  }

  @override
  Future<List<Tutor>> getAll({int limit = 20, int offset = 0}) async {
    final db = await _dbHelper.database;

    // Retorna apenas tutores onde deletedAt é nulo
    final result = await db.query(
      _tableName,
      where: 'deletedAt IS NULL',
      orderBy: 'nome ASC',
      limit: limit,
      offset: offset,
    );

    return result.map((map) => Tutor.fromMap(map)).toList();
  }

  @override
  Future<Tutor?> getById(int id) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      _tableName,
      where: 'tutorId = ? AND deletedAt IS NULL',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Tutor.fromMap(result.first);
    }
    return null;
  }

  @override
  Future<int> update(Tutor tutor) async {
    final db = await _dbHelper.database;
    return await db.update(
      _tableName,
      tutor.toMap(),
      where: 'tutorId = ?',
      whereArgs: [tutor.tutorId],
    );
  }

  @override
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    // Soft Delete: Define deletedAt como a data/hora atual
    return await db.update(
      _tableName,
      {'deletedAt': now},
      where: 'tutorId = ?',
      whereArgs: [id],
    );
  }
}
