import 'package:pet_care/features/tutor/data/datasources/tutor_local_datasource.dart';
import 'package:pet_care/features/tutor/domain/models/tutor.dart';
import 'package:pet_care/features/tutor/domain/repositories/tutor_repository.dart';

/// Implementação concreta do repositório [TutorRepository] voltada para o banco SQLite.
class SqliteTutorRepository implements TutorRepository {
  final TutorLocalDataSource _localDataSource;

  SqliteTutorRepository({TutorLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? SqfliteTutorLocalDataSource();

  @override
  Future<int> insertTutor(Tutor tutor) {
    return _localDataSource.insert(tutor);
  }

  @override
  Future<List<Tutor>> getAllTutors({int limit = 20, int offset = 0}) {
    return _localDataSource.getAll(limit: limit, offset: offset);
  }

  @override
  Future<Tutor?> getTutorById(int id) {
    return _localDataSource.getById(id);
  }

  @override
  Future<int> updateTutor(Tutor tutor) {
    return _localDataSource.update(tutor);
  }

  @override
  Future<int> deleteTutor(int id) {
    return _localDataSource.delete(id);
  }
}
