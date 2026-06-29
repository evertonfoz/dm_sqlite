import 'package:pet_care/features/tutor/data/datasources/abstract_classes/tutor_datasource.dart';
import 'package:pet_care/features/tutor/domain/repositories/sync_tutor_repository.dart';

class SyncTutorRepositoryImpl implements ISyncTutorRepository {
  final ITutorDataSource remoteDataSource;
  final ITutorDataSource localDataSource;

  SyncTutorRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> syncTutors() async {
    try {
      final remoteTutors = await remoteDataSource.getAll(limit: 1000, offset: 0);
      
      for (final remoteTutor in remoteTutors) {
        if (remoteTutor.tutorId != null) {
          final localTutor = await localDataSource.getById(remoteTutor.tutorId!);
          
          if (localTutor == null) {
            await localDataSource.insert(remoteTutor);
          } else {
            await localDataSource.update(remoteTutor);
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to sync tutors: $e');
    }
  }
}
