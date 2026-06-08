import 'package:flutter/foundation.dart';
import 'package:pet_care/features/pet/data/datasources/pet_local_datasource.dart';
import 'package:pet_care/features/pet/data/repositories/sqlite_pet_repository.dart';
import 'package:pet_care/features/pet/domain/repositories/pet_repository.dart';
import 'package:pet_care/features/tutor/data/repositories/sqlite_tutor_repository.dart';
import 'package:pet_care/features/tutor/domain/models/tutor.dart';
import 'package:pet_care/features/tutor/domain/repositories/tutor_repository.dart';

/// Controlador responsável por gerenciar a comunicação entre a UI
/// e a camada de repositórios para a entidade de Tutores.
class TutorController extends ChangeNotifier {
  final TutorRepository _repository;
  final PetRepository _petRepository;

  TutorController({TutorRepository? repository, PetRepository? petRepository})
    : _repository = repository ?? SqliteTutorRepository(),
      _petRepository = petRepository ?? SqlitePetRepository(SqflitePetLocalDataSource());

  final List<Tutor> _tutors = [];
  bool _isLoading = false;
  bool _isInserting = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _errorMessage;

  List<Tutor> get tutors => _tutors;
  bool get isLoading => _isLoading;
  bool get isInserting => _isInserting;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  /// Insere um novo tutor na base de dados.
  Future<void> insertTutor(Tutor tutor) async {
    try {
      _isInserting = true;
      _errorMessage = null;
      notifyListeners();
      await _repository.insertTutor(tutor);
    } catch (e) {
      _errorMessage = 'Erro ao inserir tutor: ${e.toString()}';
    } finally {
      _isInserting = false;
      notifyListeners();
    }
  }

  /// Recupera todos os tutores cadastrados e ativos.
  Future<void> getAllTutors() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _tutors.clear();
      _tutors.addAll(await _repository.getAllTutors());
    } catch (e) {
      _errorMessage = 'Erro ao buscar tutores: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Busca um tutor pelo ID.
  Future<Tutor?> getTutorById(int id) {
    return _repository.getTutorById(id);
  }

  /// Atualiza os dados de um tutor existente.
  Future<void> updateTutor(Tutor tutor) async {
    try {
      _isUpdating = true;
      _errorMessage = null;
      notifyListeners();
      await _repository.updateTutor(tutor);
    } catch (e) {
      _errorMessage = 'Erro ao atualizar tutor: ${e.toString()}';
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Realiza a exclusão lógica de um tutor.
  Future<void> deleteTutor(int id) async {
    try {
      _isDeleting = true;
      _errorMessage = null;
      notifyListeners();
      await _repository.deleteTutor(id);
    } catch (e) {
      _errorMessage = 'Erro ao deletar tutor: ${e.toString()}';
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  /// Verifica se o tutor possui pets ativos associados, para impedir deleção cascata.
  Future<bool> hasActivePets(int tutorId) async {
    final petsList = await _petRepository.getPetsByTutorId(tutorId);
    return petsList.isNotEmpty;
  }
}
