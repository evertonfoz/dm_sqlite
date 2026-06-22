import 'package:pet_care/features/tutor/data/datasources/abstract_classes/tutor_datasource.dart';
import 'package:pet_care/features/tutor/domain/models/tutor.dart';
import 'package:pet_care/features/tutor/domain/repositories/tutor_repository.dart';

class TutorRepositoryImpl implements ITutorRepository {
  final ITutorDataSource _dataSource;

  TutorRepositoryImpl(this._dataSource);

  @override
  Future<int> insertTutor(Tutor tutor) {
    return _dataSource.insert(tutor);
  }

  @override
  Future<List<Tutor>> getAllTutors({int limit = 20, int offset = 0}) {
    return _dataSource.getAll(limit: limit, offset: offset);
  }

  @override
  Future<Tutor?> getTutorById(int id) {
    return _dataSource.getById(id);
  }

  @override
  Future<int> updateTutor(Tutor tutor) {
    return _dataSource.update(tutor);
  }

  @override
  Future<int> deleteTutor(int id) {
    return _dataSource.delete(id);
  }
}
