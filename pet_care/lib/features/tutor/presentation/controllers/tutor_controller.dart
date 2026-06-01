import 'package:pet_care/features/pet/data/repositories/sqlite_pet_repository.dart';
import 'package:pet_care/features/pet/domain/repositories/pet_repository.dart';
import 'package:pet_care/features/tutor/data/repositories/sqlite_tutor_repository.dart';
import 'package:pet_care/features/tutor/domain/models/tutor.dart';
import 'package:pet_care/features/tutor/domain/repositories/tutor_repository.dart';

/// Controlador responsável por gerenciar a comunicação entre a UI
/// e a camada de repositórios para a entidade de Tutores.
class TutorController {
  final TutorRepository _repository;
  final PetRepository _petRepository;

  TutorController({TutorRepository? repository, PetRepository? petRepository})
      : _repository = repository ?? SqliteTutorRepository(),
        _petRepository = petRepository ?? SqlitePetRepository();

  /// Insere um novo tutor na base de dados.
  Future<int> insertTutor(Tutor tutor) {
    return _repository.insertTutor(tutor);
  }

  /// Recupera todos os tutores cadastrados e ativos.
  Future<List<Tutor>> getAllTutors() {
    return _repository.getAllTutors();
  }

  /// Busca um tutor pelo ID.
  Future<Tutor?> getTutorById(int id) {
    return _repository.getTutorById(id);
  }

  /// Atualiza os dados de um tutor existente.
  Future<int> updateTutor(Tutor tutor) {
    return _repository.updateTutor(tutor);
  }

  /// Realiza a exclusão lógica de um tutor.
  Future<int> deleteTutor(int id) {
    return _repository.deleteTutor(id);
  }

  /// Verifica se o tutor possui pets ativos associados, para impedir deleção cascata.
  Future<bool> hasActivePets(int tutorId) async {
    final petsList = await _petRepository.getPetsByTutorId(tutorId);
    return petsList.isNotEmpty;
  }
}
