import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:pet_care/features/pet/domain/repositories/pet_repository.dart';
import 'package:pet_care/features/tutor/domain/models/tutor.dart';
import 'package:pet_care/features/tutor/domain/repositories/sync_tutor_repository.dart';
import 'package:pet_care/features/tutor/domain/repositories/tutor_repository.dart';

/// Controlador responsável por gerenciar a comunicação entre a UI
/// e a camada de repositórios para a entidade de Tutores.
class TutorController extends ChangeNotifier {
  final ITutorRepository _repository;
  final PetRepository _petRepository;
  final ISyncTutorRepository _syncRepository;

  TutorController(this._repository, this._petRepository, this._syncRepository);

  final List<Tutor> _tutors = [];
  bool _isLoading = false;
  bool _isPaginating = false; // loading de paginação (próxima página)
  bool _isInserting = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  bool _isSyncing = false;
  String? _errorMessage;

  int _limit = 7;
  int _offset = 0;
  bool _hasMoreData = true;

  List<Tutor> get tutors => _tutors;
  bool get isLoading => _isLoading;
  bool get isPaginating => _isPaginating;
  bool get isInserting => _isInserting;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

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

  /// Sincroniza os tutores da base remota para a base local.
  Future<void> syncData() async {
    try {
      _isSyncing = true;
      _errorMessage = null;
      notifyListeners();

      await _syncRepository.syncTutors();
      await getAllTutors();
    } catch (e) {
      _errorMessage = 'Erro ao sincronizar tutores: ${e.toString()}';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Recupera todos os tutores cadastrados e ativos (reseta a paginação).
  Future<void> getAllTutors() async {
    try {
      _isLoading = true;
      _offset = 0;
      _hasMoreData = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _repository.getAllTutors(
        limit: _limit,
        offset: _offset,
      );
      _tutors
        ..clear()
        ..addAll(result);

      if (result.length < _limit) {
        _hasMoreData = false;
      }
    } catch (e) {
      _errorMessage = 'Erro ao buscar tutores: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFirstPage() async {
    await getAllTutors();
  }

  Future<void> loadNextPage() async {
    if (_isLoading || _isPaginating || !_hasMoreData) return;

    _isPaginating = true;
    notifyListeners(); // exibe o CircularProgressIndicator no rodapé

    // O SQLite local é rápido demais (< 1ms) para que o Flutter consiga
    // renderizar um frame com o spinner antes do estado já ser revertido.
    // Aguardamos o próximo frame para garantir que o spinner seja exibido.
    await Future.delayed(const Duration(milliseconds: 300));

    _offset += _limit;
    try {
      final newTutors = await _repository.getAllTutors(
        limit: _limit,
        offset: _offset,
      );
      if (newTutors.length < _limit) {
        _hasMoreData = false;
      }
      _tutors.addAll(newTutors);
    } catch (e) {
      _errorMessage = 'Erro ao carregar mais tutores: ${e.toString()}';
      _offset -= _limit; // desfaz o avanço do offset em caso de erro
    } finally {
      _isPaginating = false;
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

  /// Registra 100 tutores fictícios de forma aleatória e recarrega a lista.
  Future<void> addFakeTutors() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final random = math.Random();
      final nomes = [
        'Ana',
        'Bruno',
        'Carlos',
        'Diana',
        'Eduardo',
        'Fernanda',
        'Gabriel',
        'Helena',
        'Igor',
        'Julia',
        'Lucas',
        'Mariana',
        'Neto',
        'Olivia',
        'Pedro',
        'Renata',
        'Silvio',
        'Teresa',
        'Victor',
        'Yasmin',
      ];
      final sobrenomes = [
        'Silva',
        'Santos',
        'Oliveira',
        'Souza',
        'Rodrigues',
        'Ferreira',
        'Alves',
        'Pereira',
        'Lima',
        'Gomes',
        'Costa',
        'Ribeiro',
        'Martins',
        'Carvalho',
        'Almeida',
        'Lopes',
        'Soares',
        'Dias',
        'Moreira',
        'Vieira',
      ];
      final provedores = [
        'gmail.com',
        'yahoo.com',
        'outlook.com',
        'hotmail.com',
      ];

      for (var i = 1; i <= 100; i++) {
        final nome =
            '${nomes[random.nextInt(nomes.length)]} ${sobrenomes[random.nextInt(sobrenomes.length)]}';
        final email =
            '${nome.toLowerCase().replaceAll(' ', '')}$i@${provedores[random.nextInt(provedores.length)]}';
        final ddd = 11 + random.nextInt(89);
        final tel1 = 90000 + random.nextInt(10000);
        final tel2 = 1000 + random.nextInt(9000);
        final telefone = '($ddd) $tel1-$tel2';

        final tutor = Tutor(
          nome: '$nome ($i)',
          email: email,
          telefone: telefone,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _repository.insertTutor(tutor);
      }

      await getAllTutors();
    } catch (e) {
      _errorMessage = 'Erro ao cadastrar tutores fictícios: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
}
