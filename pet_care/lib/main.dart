import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pet_care/features/pet/presentation/pages/pet_list_page.dart';
import 'package:pet_care/features/tutor/presentation/pages/tutor_list_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/supabase/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  debugPrint('Supabase inicializado com sucesso.');

  final response = await Supabase.instance.client
      .from('tutors')
      .select()
      .limit(1);
  debugPrint('Teste:  $response');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          primary: const Color(0xFF0F766E),
          secondary: const Color(0xFFF97316),
          surface: const Color(0xFFF8FAFC),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
        ),
        fontFamily:
            'Inter', // Utiliza a fonte padrão com fallback do sistema operacional
      ),
      home: const TutorListPage(),
    );
  }
}
