import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'intro_page.dart';
import 'auth_gate.dart';

/// Tela de SplashScreen que exibe a marca Pet Care por alguns instantes
/// e direciona o usuário para o Onboarding ou para o AuthGate.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  // Chave constante conforme requisito
  static const String _onboardingKey = 'hasSeenOnboarding';

  @override
  void initState() {
    super.initState();

    // Configurando animação de fade-in e scale para dar sensação premium
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    // Iniciar verificação do fluxo inicial
    _checkInitialFlow();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialFlow() async {
    // Aguarda um tempo mínimo de 2 segundos para exibir a SplashScreen e a animação
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(_onboardingKey) ?? false;

      if (!mounted) return;

      if (hasSeenOnboarding) {
        // Se já viu o onboarding, redireciona para o fluxo principal de autenticação
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthGate(),
          ),
        );
      } else {
        // Se não viu o onboarding, redireciona para a página de onboarding/tutorial
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const IntroPage(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao verificar fluxo de onboarding: $e');
      // Fallback em caso de erro para não travar o usuário
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthGate(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Identidade visual do Pet Care
              // DICA: Pode ser substituído pelo asset oficial do projeto futuramente
              // por exemplo: Image.asset('assets/images/app_icon/light_mode.png', width: 120, height: 120)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 64,
                  color: Color(0xFF0F766E),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pet Care',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cuidado e carinho ao seu alcance',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 48),
              // Indicador sutil de carregamento
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
