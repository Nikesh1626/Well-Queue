import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/clinic.dart';
import '../../../core/constants/supabase_schema.dart';

class ClinicRepository {
  final _client = Supabase.instance.client;

  Stream<List<Clinic>> streamNearbyClinics() {
    return _client
        .from(SupabaseSchema.clinicsTable)
        .stream(primaryKey: [SupabaseSchema.clinicId])
        .order(SupabaseSchema.clinicCreatedAt)
        .map((rows) => rows
            .map((row) => Clinic.fromJson(row).copyWith(distance: 1.2))
            .toList());
  }
}
