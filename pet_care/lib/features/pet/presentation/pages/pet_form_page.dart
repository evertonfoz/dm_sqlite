import 'package:flutter/material.dart';
import 'package:pet_care/features/pet/domain/models/pet.dart';
import 'package:pet_care/features/pet/presentation/controllers/pet_controller.dart';
import 'package:pet_care/features/tutor/domain/models/tutor.dart';
import 'package:pet_care/features/tutor/presentation/controllers/tutor_controller.dart';
import 'package:pet_care/features/tutor/presentation/pages/tutor_form_page.dart';

class PetFormPage extends StatefulWidget {
  final Pet? pet;

  const PetFormPage({super.key, this.pet});

  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  final PetController _controller = PetController();
  final TutorController _tutorController = TutorController();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _especieController;

  bool _isEditing = false;
  String _selectedSpeciesPreset = '';
  bool _showCustomSpeciesInput = false;

  final List<String> _speciesPresets = ['Cachorro', 'Gato', 'Pássaro'];

  List<Tutor> _tutors = [];
  int? _selectedTutorId;
  bool _isLoadingTutors = true;

  @override
  void initState() {
    super.initState();
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
    
    _loadTutors();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _especieController.dispose();
    super.dispose();
  }

  Future<void> _loadTutors() async {
    setState(() {
      _isLoadingTutors = true;
    });
    try {
      final list = await _tutorController.getAllTutors();
      setState(() {
        _tutors = list;
        _isLoadingTutors = false;
        
        if (_isEditing) {
          _selectedTutorId = widget.pet!.tutorId;
        } else if (_tutors.isNotEmpty) {
          _selectedTutorId = _tutors.first.tutorId;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingTutors = false;
      });
      _showSnackBar('Erro ao obter tutores: $e', isError: true);
    }
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveForm() async {
    if (_tutors.isEmpty) {
      _showSnackBar('Cadastre um tutor antes de salvar o pet.', isError: true);
      return;
    }
    
    if (!_formKey.currentState!.validate()) return;

    final String nome = _nomeController.text.trim();
    String especie = _especieController.text.trim();

    if (!_showCustomSpeciesInput && _selectedSpeciesPreset.isNotEmpty && _selectedSpeciesPreset != 'Outro') {
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
          tutorId: _selectedTutorId!,
          createdAt: widget.pet!.createdAt,
          updatedAt: DateTime.now(),
          deletedAt: widget.pet!.deletedAt,
        );
        await _controller.updatePet(updatedPet);
        _showSnackBar('$nome atualizado com sucesso!');
      } else {
        final now = DateTime.now();
        final newPet = Pet(
          nome: nome,
          especie: especie,
          tutorId: _selectedTutorId!,
          createdAt: now,
          updatedAt: now,
        );
        await _controller.insertPet(newPet);
        _showSnackBar('$nome cadastrado com sucesso!');
      }
      if (mounted) {
        Navigator.of(context).pop(true);
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F766E)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoadingTutors
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderIcon(),
                      const SizedBox(height: 32),
                      if (_tutors.isEmpty)
                        _buildNoTutorWarning()
                      else ...[
                        _buildCardSection(
                          title: 'Tutor Responsável',
                          children: [
                            _buildLabel('Selecione o Tutor'),
                            const SizedBox(height: 8),
                            _buildTutorDropdown(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildCardSection(
                          title: 'Informações Básicas',
                          children: [
                            _buildLabel('Nome do Pet'),
                            const SizedBox(height: 8),
                            _buildNomeField(),
                            const SizedBox(height: 20),
                            _buildLabel('Espécie'),
                            const SizedBox(height: 12),
                            _buildSpeciesSelection(),
                            if (_showCustomSpeciesInput) ...[
                              const SizedBox(height: 16),
                              _buildCustomSpeciesField(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 40),
                        _buildSubmitButton(),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF0F766E).withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.pets_rounded,
          size: 48,
          color: Color(0xFF0F766E),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF475569),
      ),
    );
  }

  Widget _buildCardSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1.5),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNoTutorWarning() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.amber.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade900.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber.shade800,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum Tutor Cadastrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Cada pet precisa ter um tutor registrado a ele.\nPor favor, cadastre um tutor primeiro para poder gerenciar pets.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const TutorFormPage(),
                ),
              );
              if (result == true) {
                _loadTutors();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Cadastrar Tutor Agora',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedTutorId,
      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      items: _tutors.map((tutor) {
        return DropdownMenuItem<int>(
          value: tutor.tutorId,
          child: Text(tutor.nome),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedTutorId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Selecione o tutor responsável.';
        }
        return null;
      },
    );
  }

  Widget _buildNomeField() {
    return TextFormField(
      controller: _nomeController,
      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16),
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        hintText: 'Ex: Rex, Pipoca, Bella',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: const Icon(Icons.help_center_rounded, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
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
        ..._speciesPresets.map((preset) => Expanded(
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
                    color: _selectedSpeciesPreset == preset ? Colors.white : const Color(0xFF475569),
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
            )),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: const Text('Outro'),
              selected: _selectedSpeciesPreset == 'Outro' || (_isEditing && !_speciesPresets.contains(_especieController.text)),
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
                color: _selectedSpeciesPreset == 'Outro' ? Colors.white : const Color(0xFF475569),
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
    return TextFormField(
      controller: _especieController,
      style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16),
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'Ex: Coelho, Furão, Jabuti',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: const Icon(Icons.help_outline_rounded, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: (value) {
        if (_showCustomSpeciesInput && (value == null || value.trim().isEmpty)) {
          return 'Informe a espécie do pet.';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _saveForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 2,
        shadowColor: const Color(0xFF0F766E).withOpacity(0.4),
      ),
      child: Text(
        _isEditing ? 'Salvar Alterações' : 'Cadastrar Pet',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
