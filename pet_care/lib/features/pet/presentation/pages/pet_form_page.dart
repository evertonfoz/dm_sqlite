import 'package:flutter/material.dart';
import 'package:pet_care/features/pet/data/datasources/pet_local_datasource.dart';
import 'package:pet_care/features/pet/domain/models/pet.dart';
import 'package:pet_care/features/pet/domain/repositories/pet_repository.dart';
import 'package:pet_care/features/pet/presentation/controllers/pet_controller.dart';

import '../../../../core/presentation/widgets/form/custom_text_form_field.dart';
import '../../../../core/presentation/widgets/form/form_card_section.dart';
import '../../../../core/presentation/widgets/form/form_header_icon.dart';
import '../../../../core/presentation/widgets/form/form_section_label.dart';
import '../../../../core/presentation/widgets/form/form_submit_button.dart';
import '../../data/repositories/sqlite_pet_repository.dart';

class PetFormPage extends StatefulWidget {
  final Pet? pet;

  const PetFormPage({super.key, this.pet});

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  late PetController _controller;
  late PetRepository _repository;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _especieController;

  bool _isEditing = false;
  String _selectedSpeciesPreset = '';
  bool _showCustomSpeciesInput = false;

  final List<String> _speciesPresets = ['Cachorro', 'Gato', 'Pássaro'];

  @override
  void initState() {
    super.initState();
    _repository = SqlitePetRepository(SqflitePetLocalDataSource());
    _controller = PetController(repository: _repository);

    _isEditing = widget.pet != null;
    _nomeController = TextEditingController(text: widget.pet?.nome ?? '');
    _especieController = TextEditingController(text: widget.pet?.especie ?? '');

    if (_isEditing) {
      final petSpecies = widget.pet!.especie;
      if (_speciesPresets.contains(petSpecies)) {
        _selectedSpeciesPreset = petSpecies;
      } else {
        _selectedSpeciesPreset = 'Outro';
        _showCustomSpeciesInput = true;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nomeController.dispose();
    _especieController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final String nome = _nomeController.text.trim();
    String especie = _especieController.text.trim();

    if (!_showCustomSpeciesInput &&
        _selectedSpeciesPreset.isNotEmpty &&
        _selectedSpeciesPreset != 'Outro') {
      especie = _selectedSpeciesPreset;
    }

    if (especie.isEmpty) {
      _showSnackBar('Por favor, informe a espécie do pet.', isError: true);
      return;
    }

    try {
      if (_isEditing) {
        final updatedPet = Pet(
          petId: widget.pet!.petId,
          nome: nome,
          especie: especie,
          createdAt: widget.pet!.createdAt,
          updatedAt: DateTime.now(),
          deletedAt: widget.pet!.deletedAt,
        );
        await _controller.updatePet(updatedPet);

        if (_controller.errorMessage == null) {
          _showSnackBar('$nome atualizado com sucesso!');
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } else {
          _showSnackBar(
            'Erro ao atualizar: ${_controller.errorMessage}',
            isError: true,
          );
        }
      } else {
        final now = DateTime.now();
        final newPet = Pet(
          nome: nome,
          especie: especie,
          createdAt: now,
          updatedAt: now,
        );
        await _controller.insertPet(newPet);

        if (_controller.errorMessage == null) {
          _showSnackBar('$nome cadastrado com sucesso!');
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } else {
          _showSnackBar(
            'Erro ao cadastrar: ${_controller.errorMessage}',
            isError: true,
          );
        }
      }
    } catch (e) {
      _showSnackBar('Erro ao salvar informações: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Detalhes do Pet' : 'Novo Pet',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF0F766E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F766E),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FormHeaderIcon(icon: Icons.pets_rounded),
                    const SizedBox(height: 32),
                    FormCardSection(
                      title: 'Informações Básicas',
                      children: [
                        const FormSectionLabel(text: 'Nome do Pet'),
                        const SizedBox(height: 8),
                        _buildNomeField(),
                        const SizedBox(height: 20),
                        const FormSectionLabel(text: 'Espécie'),
                        const SizedBox(height: 12),
                        _buildSpeciesSelection(),
                        if (_showCustomSpeciesInput) ...[
                          const SizedBox(height: 16),
                          _buildCustomSpeciesField(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 40),
                    FormSubmitButton(
                      label: _isEditing ? 'Salvar Alterações' : 'Cadastrar Pet',
                      onPressed: _saveForm,
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildNomeField() {
    return CustomTextFormField(
      controller: _nomeController,
      hintText: 'Ex: Rex, Pipoca, Bella',
      prefixIcon: Icons.help_center_rounded,
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'O nome do pet é obrigatório.';
        }
        if (value.trim().length < 2) {
          return 'O nome deve ter pelo menos 2 caracteres.';
        }
        return null;
      },
    );
  }

  Widget _buildSpeciesSelection() {
    return Row(
      children: [
        ..._speciesPresets.map(
          (preset) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(preset),
                selected: _selectedSpeciesPreset == preset,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpeciesPreset = preset;
                      _showCustomSpeciesInput = false;
                      _especieController.text = preset;
                    }
                  });
                },
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _selectedSpeciesPreset == preset
                      ? Colors.white
                      : const Color(0xFF475569),
                ),
                selectedColor: const Color(0xFF0F766E),
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide.none,
                showCheckmark: false,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: const Text('Outro'),
              selected:
                  _selectedSpeciesPreset == 'Outro' ||
                  (_isEditing &&
                      !_speciesPresets.contains(_especieController.text)),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSpeciesPreset = 'Outro';
                    _showCustomSpeciesInput = true;
                    if (!_speciesPresets.contains(widget.pet?.especie)) {
                      _especieController.text = widget.pet?.especie ?? '';
                    } else {
                      _especieController.clear();
                    }
                  }
                });
              },
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: _selectedSpeciesPreset == 'Outro'
                    ? Colors.white
                    : const Color(0xFF475569),
              ),
              selectedColor: const Color(0xFF0F766E),
              backgroundColor: const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomSpeciesField() {
    return CustomTextFormField(
      controller: _especieController,
      hintText: 'Ex: Coelho, Furão, Jabuti',
      prefixIcon: Icons.help_outline_rounded,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (_showCustomSpeciesInput &&
            (value == null || value.trim().isEmpty)) {
          return 'Informe a espécie do pet.';
        }
        return null;
      },
    );
  }
}
