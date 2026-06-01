import 'package:pet_care/features/tutor/domain/models/tutor.dart';

/// Contrato que define as operações de repositório para o modelo de negócio [Tutor].
abstract class TutorRepository {
  /// Insere um novo [Tutor] na base de dados. Retorna o ID gerado.
  Future<int> insertTutor(Tutor tutor);

  /// Recupera todos os registros de [Tutor] ativos persistidos.
  Future<List<Tutor>> getAllTutors();

  /// Busca um [Tutor] ativo pelo seu identificador único [id]. Retorna null se não encontrar.
  Future<Tutor?> getTutorById(int id);

  /// Atualiza os dados de um [Tutor] existente. Retorna a quantidade de linhas alteradas.
  Future<int> updateTutor(Tutor tutor);

  /// Realiza o soft delete de um [Tutor] por meio de seu [id]. Retorna a quantidade de linhas afetadas.
  Future<int> deleteTutor(int id);
}
