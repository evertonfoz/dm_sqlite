import 'package:pet_care/features/tutor/data/datasources/abstract_classes/tutor_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/tutor.dart';

class SupabaseTutorRemoteDataSource implements ITutorDataSource {
  final SupabaseClient _client;
  static const String _tableName = 'tutors';

  SupabaseTutorRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<int> insert(Tutor tutor) async {
    final result = await _client
        .from(_tableName)
        .insert(tutor.toSupabaseMap())
        .select('tutor_id')
        .single();

    return result['tutor_id'] as int;
  }

  @override
  Future<List<Tutor>> getAll({int limit = 20, int offset = 0}) async {
    final response = await _client
        .from(_tableName)
        .select()
        .range(offset, offset + limit - 1)
        .order('tutor_id');

    return response.map((json) => Tutor.fromSupabaseMap(json)).toList();
  }

  @override
  Future<Tutor?> getById(int id) async {
    final response = await _client.from(_tableName).select().eq('tutor_id', id);

    if (response.isEmpty) return null;

    return Tutor.fromSupabaseMap(response.first);
  }

  @override
  Future<int> update(Tutor tutor) async {
    await _client
        .from(_tableName)
        .update(tutor.toSupabaseMap())
        .eq('tutor_id', tutor.tutorId!);
    return 1;
  }

  @override
  Future<int> delete(int id) async {
    await _client.from(_tableName).delete().eq('tutor_id', id);
    return 1;
  }
}
