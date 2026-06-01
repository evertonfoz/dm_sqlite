import 'package:pet_care/features/pet/data/repositories/sqlite_pet_repository.dart';
import 'package:pet_care/features/pet/domain/models/pet.dart';
import 'package:pet_care/features/pet/domain/repositories/pet_repository.dart';

/// Controlador responsável por intermediar a comunicação entre a interface do usuário (Views)
/// e a camada de domínio / persistência de dados (`PetRepository`).
///
/// Como as Views gerenciam seu estado local via `setState`, este controlador expõe
/// métodos diretos e limpos para execução das operações de CRUD.
class PetController {
  final PetRepository _repository;

  /// Inicializa o controlador com uma implementação de [PetRepository].
  ///
  /// Caso [repository] não seja fornecido, o controlador inicializa por padrão
  /// a implementação concreta baseada em SQLite [SqlitePetRepository].
  PetController({PetRepository? repository})
      : _repository = repository ?? SqlitePetRepository();

  /// Solicita a inserção de um novo [Pet].
  /// Retorna o ID gerado pelo banco de dados para o novo registro.
  Future<int> insertPet(Pet pet) {
    return _repository.insertPet(pet);
  }

  /// Recupera todos os registros de [Pet] persistidos localmente.
  Future<List<Pet>> getAllPets() {
    return _repository.getAllPets();
  }

  /// Busca as informações de um [Pet] específico através do seu [id].
  /// Retorna `null` caso nenhum registro seja encontrado com o identificador fornecido.
  Future<Pet?> getPetById(int id) {
    return _repository.getPetById(id);
  }

  /// Atualiza os dados de um [Pet] existente.
  /// Retorna a quantidade de registros que foram afetados pela atualização.
  Future<int> updatePet(Pet pet) {
    return _repository.updatePet(pet);
  }

  /// Remove o registro de um [Pet] do armazenamento por meio do seu [id].
  /// Retorna a quantidade de linhas deletadas no processo.
  Future<int> deletePet(int id) {
    return _repository.deletePet(id);
  }
}
