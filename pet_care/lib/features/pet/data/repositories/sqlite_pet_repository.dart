import 'package:pet_care/features/pet/data/datasources/pet_local_datasource.dart';
import 'package:pet_care/features/pet/domain/models/pet.dart';
import 'package:pet_care/features/pet/domain/repositories/pet_repository.dart';

/// Implementação concreta do repositório [PetRepository] voltada para o banco SQLite.
///
/// Atua como intermediário entre as regras de negócio da aplicação e a fonte de dados local [PetLocalDataSource].
class SqlitePetRepository implements PetRepository {
  final PetLocalDataSource _localDataSource;

  /// Permite injeção de dependência da fonte de dados para facilidade de mock em testes unitários.
  /// Caso omitido, utiliza a implementação padrão baseada no SQLite [SqflitePetLocalDataSource].
  SqlitePetRepository(
    SqflitePetLocalDataSource sqflitePetLocalDataSource, {
    PetLocalDataSource? localDataSource,
  }) : _localDataSource = localDataSource ?? SqflitePetLocalDataSource();

  @override
  Future<int> insertPet(Pet pet) {
    return _localDataSource.insert(pet);
  }

  @override
  Future<List<Pet>> getAllPets() {
    return _localDataSource.getAll();
  }

  @override
  Future<Pet?> getPetById(int id) {
    return _localDataSource.getById(id);
  }

  @override
  Future<int> updatePet(Pet pet) {
    return _localDataSource.update(pet);
  }

  @override
  Future<int> deletePet(int id) {
    return _localDataSource.delete(id);
  }

  @override
  Future<List<Pet>> getPetsByTutorId(int tutorId) {
    return _localDataSource.getByTutorId(tutorId);
  }
}
