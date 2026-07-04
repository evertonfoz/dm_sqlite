import 'package:flutter/material.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pet_care/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:pet_care/features/pet/presentation/pages/pet_list_page.dart';
import 'package:pet_care/features/tutor/presentation/pages/tutor_list_page.dart';

class AppDrawer extends StatelessWidget {
  final String activeRoute;
  final AuthController? authController;

  const AppDrawer({
    super.key,
    required this.activeRoute,
    this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.pets_rounded,
            title: 'Pets',
            isActive: activeRoute == 'pets',
            onTap: () {
              if (activeRoute == 'pets') {
                Navigator.of(context).pop();
                return;
              }
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const PetListPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.person_rounded,
            title: 'Tutores',
            isActive: activeRoute == 'tutors',
            onTap: () {
              if (activeRoute == 'tutors') {
                Navigator.of(context).pop();
                return;
              }
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const TutorListPage()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout_rounded,
            title: 'Sair',
            isActive: false,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sair'),
                  content: const Text('Deseja realmente sair do aplicativo?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Sair',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                Navigator.of(context).pop(); // Close drawer
                final controller = authController ?? AuthController();
                await controller.signOut();
              }
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Pet Care v1.1.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Pet Care',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Cuidado inteligente para animais',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0F766E).withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            icon,
            color: isActive ? const Color(0xFF0F766E) : const Color(0xFF64748B),
            size: 24,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF0F766E)
                  : const Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
        ),
      ),
    );
  }
}
