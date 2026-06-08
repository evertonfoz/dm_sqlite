import 'package:flutter/material.dart';
import 'package:pet_care/features/pet/data/repositories/sqlite_pet_repository.dart';
import 'package:pet_care/features/pet/domain/models/pet.dart';
import 'package:pet_care/features/pet/domain/repositories/pet_repository.dart';

/// Controlador responsável por intermediar a comunicação entre a interface do usuário (Views)
/// e a camada de domínio / persistência de dados (`PetRepository`).
///
/// Como as Views gerenciam seu estado local via `setState`, este controlador expõe
/// métodos diretos e limpos para execução das operações de CRUD.
class PetController extends ChangeNotifier {
  final PetRepository _repository;

  /// Inicializa o controlador com uma implementação de [PetRepository].
  ///
  /// Caso [repository] não seja fornecido, o controlador inicializa por padrão
  /// a implementação concreta baseada em SQLite [SqlitePetRepository].
  PetController({required PetRepository repository}) : _repository = repository;

  final List<Pet> _pets = [];
  bool _isLoading = false;
  bool _isInserting = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _errorMessage;

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  bool get isInserting => _isInserting;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  /// Solicita a inserção de um novo [Pet].
  /// Retorna o ID gerado pelo banco de dados para o novo registro.
  Future<void> insertPet(Pet pet) async {
    try {
      _isInserting = true;
      _errorMessage = null;
      notifyListeners();
      await _repository.insertPet(pet);
    } catch (e) {
      _errorMessage = 'Erro ao inserir pet: ${e.toString()}';
    } finally {
      _isInserting = false;
      notifyListeners();
    }
  }

  /// Recupera todos os registros de [Pet] persistidos localmente.
  Future<void> getAllPets() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _pets.clear();
      _pets.addAll(await _repository.getAllPets());
    } catch (e) {
      _errorMessage = 'Erro ao buscar pets: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Busca as informações de um [Pet] específico através do seu [id].
  /// Retorna `null` caso nenhum registro seja encontrado com o identificador fornecido.
  Future<Pet?> getPetById(int id) {
    return _repository.getPetById(id);
  }

  /// Atualiza os dados de um [Pet] existente.
  Future<void> updatePet(Pet pet) async {
    try {
      _isUpdating = true;
      _errorMessage = null;
      notifyListeners();
      await _repository.updatePet(pet);
    } catch (e) {
      _errorMessage = 'Erro ao atualizar pet: ${e.toString()}';
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Remove o registro de um [Pet] do armazenamento por meio do seu [id].
  /// Retorna a quantidade de linhas deletadas no processo.
  Future<void> deletePet(int id) async {
    try {
      _isDeleting = true;
      _errorMessage = null;
      notifyListeners();
      await _repository.deletePet(id);
    } catch (e) {
      _errorMessage = 'Erro ao deletar pet: ${e.toString()}';
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}
