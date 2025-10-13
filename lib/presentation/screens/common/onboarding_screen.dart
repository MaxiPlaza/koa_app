import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/kova_mascot.dart';
import '../core/theme/colors.dart';
import '../core/constants/firebase_constants.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Aprender juntos para un mundo más inclusivo',
      'subtitle': 'KOVA - Donde cada niño encuentra su camino',
    },
    {
      'title': 'Estamos aquí para ayudarte a ganar...',
      'subtitle': 'Confianza y habilidades para la vida',
    },
    {
      'title': 'Aprendizaje Adaptado a Cada Niño',
      'subtitle': 'Personalizado según sus necesidades únicas',
    },
    {
      'title': 'Observa el Progreso de tu Hijo',
      'subtitle': 'Seguimiento detallado y reportes automáticos',
    },
    {
      'title': 'Únete a una Comunidad de Apoyo',
      'subtitle': 'Padres y profesionales trabajando juntos',
    },
  ];

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),
            _buildIndicator(),
            _buildNavigationButtons(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          KovaMascot(size: 120, expression: KovaExpression.happy),
          const Spacer(),
          Text(
            data['title']!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'OpenDyslexic',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data['subtitle']!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: 'OpenDyslexic',
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              child: const Text(
                'Atrás',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'OpenDyslexic',
                ),
              ),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_currentPage < _onboardingData.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              } else {
                _navigateToLogin(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              _currentPage < _onboardingData.length - 1
                  ? 'Siguiente'
                  : 'Comenzar',
              style: const TextStyle(
                fontFamily: 'OpenDyslexic',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
