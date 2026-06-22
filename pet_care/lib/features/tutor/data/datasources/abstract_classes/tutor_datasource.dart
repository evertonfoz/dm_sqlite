import '../../../domain/models/tutor.dart';

abstract class ITutorDataSource {
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
