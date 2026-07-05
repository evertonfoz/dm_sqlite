import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_gate.dart';

/// Modelo para armazenar as informações de cada slide do onboarding.
class OnboardingItem {
  final String lightImagePath;
  final String darkImagePath;
  final String title;
  final String description;

  const OnboardingItem({
    required this.lightImagePath,
    required this.darkImagePath,
    required this.title,
    required this.description,
  });
}

/// Tela de Onboarding/Apresentação do Pet Care com 3 páginas e suporte a Light/Dark Mode.
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Itens do onboarding com os nomes reais de arquivos encontrados nos assets
  static const List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      lightImagePath: 'assets/images/on_boarding/onboarding_1_light_mode.png.png',
      darkImagePath: 'assets/images/on_boarding/onboarding_1_dark_mode.png',
      title: 'Organize os dados dos pets',
      description: 'Cadastre e consulte informações importantes dos animais de estimação em um só lugar.',
    ),
    OnboardingItem(
      lightImagePath: 'assets/images/on_boarding/onboarding_2_light_mode.png.png',
      darkImagePath: 'assets/images/on_boarding/onboarding_2_dark_mode.png.png',
      title: 'Gerencie tutores',
      description: 'Mantenha os dados dos tutores vinculados aos seus respectivos pets de forma simples.',
    ),
    OnboardingItem(
      lightImagePath: 'assets/images/on_boarding/onboarding_3_light_mode.png.png',
      darkImagePath: 'assets/images/on_boarding/onboarding_3_dark_mode.png.png',
      title: 'Acesse com segurança',
      description: 'Utilize uma estrutura preparada para autenticação, organização e integração com a nuvem.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthGate(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Cores conforme requisito
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final primaryColor = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF008577);
    final mainTextColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF17223B);
    final secondaryTextColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Botão Pular no topo direito (visível apenas se não for o último slide)
              SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.topRight,
                  child: _currentPage < _onboardingItems.length - 1
                      ? TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'Pular',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              // Carrossel com imagem, título e descrição
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingItems.length,
                  itemBuilder: (context, index) {
                    final item = _onboardingItems[index];
                    final imagePath = isDark ? item.darkImagePath : item.lightImagePath;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Imagem centralizada
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Título
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: mainTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Descrição
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Indicadores de página
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingItems.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? primaryColor
                          : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Botão de Avançar ou Começar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_currentPage < _onboardingItems.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  child: Text(
                    _currentPage == _onboardingItems.length - 1 ? 'Começar' : 'Próximo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
