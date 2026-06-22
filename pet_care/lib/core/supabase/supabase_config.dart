import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static final String url = dotenv.env['SUPABASE_URL']!;
  static final String publishableKey = dotenv.env['SUPABASE_PUBLISHED_KEY']!;
}
