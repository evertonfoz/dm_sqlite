import 'package:pet_care/features/pet/domain/models/pet.dart';

/// Contrato que define as operações de repositório para o modelo de negócio [Pet].
///
/// Serve como abstração para desacoplar a camada de apresentação das implementações
/// de persistência de dados (como SQLite ou APIs remotas).
abstract class PetRepository {
  /// Insere um novo [Pet] na base de dados. Retorna o ID gerado.
  Future<int> insertPet(Pet pet);

  /// Recupera todos os registros de [Pet] persistidos.
  Future<List<Pet>> getAllPets();

  /// Busca um [Pet] pelo seu identificador único [id]. Retorna null se não encontrar.
  Future<Pet?> getPetById(int id);

  /// Atualiza os dados de um [Pet] existente. Retorna a quantidade de linhas alteradas.
  Future<int> updatePet(Pet pet);

  /// Remove um [Pet] por meio de seu [id]. Retorna a quantidade de linhas afetadas.
  Future<int> deletePet(int id);

  /// Recupera todos os pets ativos associados a um tutor específico pelo seu [tutorId].
  Future<List<Pet>> getPetsByTutorId(int tutorId);
}

