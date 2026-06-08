import 'package:flutter/material.dart';

import '../../../domain/models/pet.dart';
import '../../controllers/pet_controller.dart';

class DismissibleItem extends StatelessWidget {
  final Pet pet;
  final PetController petController;

  const DismissibleItem(this.pet, this.petController, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(pet.petId ?? pet.hashCode),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmation(context, pet);
        },
        onDismissed: (direction) async {
          await petController.deletePet(pet.petId!);
          if (context.mounted) {
            if (petController.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Erro ao remover pet: ${petController.errorMessage}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 3),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${pet.nome} foi removido com sucesso.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: const Color(0xFF0F766E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
          petController.getAllPets();
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.delete_rounded, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Remover',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              // final result = await Navigator.of(context).push<bool>(
              //   MaterialPageRoute(builder: (context) => PetFormPage(pet: pet)),
              // );
              // if (result == true) {
              //   _controller.getAllPets();
              // }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _getSpeciesColor(pet.especie),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSpeciesIcon(pet.especie),
                      color: _getSpeciesTextColor(pet.especie),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.nome,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _getSpeciesColor(
                                  pet.especie,
                                ).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                pet.especie,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getSpeciesTextColor(pet.especie),
                                ),
                              ),
                            ),
                            if (pet.tutor != null) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  pet.tutor!.nome,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, Pet pet) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red.shade600,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Confirmar Exclusão',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Deseja mesmo excluir o pet '),
                      TextSpan(
                        text: pet.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const TextSpan(
                        text: '?\nEsta ação não poderá ser desfeita.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Excluir',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getSpeciesColor(String especie) {
    final clean = especie.toLowerCase().trim();
    if (clean.contains('cão') ||
        clean.contains('cachorro') ||
        clean.contains('dog')) {
      return const Color(0xFFE0F2FE); // Soft Blue
    } else if (clean.contains('gato') || clean.contains('cat')) {
      return const Color(0xFFFEE2E2); // Soft Pink/Red
    } else if (clean.contains('pássaro') ||
        clean.contains('passaro') ||
        clean.contains('ave') ||
        clean.contains('bird')) {
      return const Color(0xFFFEF3C7); // Soft Amber
    }
    return const Color(0xFFECFDF5); // Soft Green
  }

  Color _getSpeciesTextColor(String especie) {
    final clean = especie.toLowerCase().trim();
    if (clean.contains('cão') ||
        clean.contains('cachorro') ||
        clean.contains('dog')) {
      return const Color(0xFF0369A1); // Deep Blue
    } else if (clean.contains('gato') || clean.contains('cat')) {
      return const Color(0xFFB91C1C); // Deep Red
    } else if (clean.contains('pássaro') ||
        clean.contains('passaro') ||
        clean.contains('ave') ||
        clean.contains('bird')) {
      return const Color(0xFFB45309); // Deep Amber
    }
    return const Color(0xFF047857); // Deep Green
  }

  IconData _getSpeciesIcon(String especie) {
    final clean = especie.toLowerCase().trim();
    if (clean.contains('cão') ||
        clean.contains('cachorro') ||
        clean.contains('dog')) {
      return Icons.pets_rounded;
    } else if (clean.contains('gato') || clean.contains('cat')) {
      return Icons.pets_rounded;
    } else if (clean.contains('pássaro') ||
        clean.contains('passaro') ||
        clean.contains('ave') ||
        clean.contains('bird')) {
      return Icons.flutter_dash_rounded;
    }
    return Icons.star_rounded;
  }
}
