import 'package:flutter/material.dart';
import 'package:pet_care/features/pet/data/datasources/pet_local_datasource.dart';
import 'package:pet_care/features/pet/data/repositories/sqlite_pet_repository.dart';
import 'package:pet_care/features/tutor/data/datasources/tutor_remote_datasource.dart';
import 'package:pet_care/features/tutor/data/repositories/tutor_repository.dart';
import 'package:pet_care/features/tutor/domain/models/tutor.dart';
import 'package:pet_care/features/tutor/presentation/controllers/tutor_controller.dart';
import 'package:pet_care/features/tutor/data/repositories/sync_tutor_repository_impl.dart';
import 'package:pet_care/features/tutor/data/datasources/tutor_local_datasource.dart';

import '../../../../core/presentation/widgets/form/custom_text_form_field.dart';
import '../../../../core/presentation/widgets/form/form_card_section.dart';
import '../../../../core/presentation/widgets/form/form_header_icon.dart';
import '../../../../core/presentation/widgets/form/form_section_label.dart';
import '../../../../core/presentation/widgets/form/form_submit_button.dart';

class TutorFormPage extends StatefulWidget {
  final Tutor? tutor;

  const TutorFormPage({super.key, this.tutor});

  @override
  State<TutorFormPage> createState() => _TutorFormPageState();
}

class _TutorFormPageState extends State<TutorFormPage> {
  final TutorController _controller = TutorController(
    TutorRepositoryImpl(SupabaseTutorRemoteDataSource()),
    SqlitePetRepository(SqflitePetLocalDataSource()),
    SyncTutorRepositoryImpl(
      remoteDataSource: SupabaseTutorRemoteDataSource(),
      localDataSource: SqfliteTutorLocalDataSourceImpl(),
    ),
  );
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefoneController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.tutor != null;
    _nomeController = TextEditingController(text: widget.tutor?.nome ?? '');
    _emailController = TextEditingController(text: widget.tutor?.email ?? '');
    _telefoneController = TextEditingController(
      text: widget.tutor?.telefone ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
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
    final String email = _emailController.text.trim();
    final String telefone = _telefoneController.text.trim();

    try {
      if (_isEditing) {
        final updatedTutor = Tutor(
          tutorId: widget.tutor!.tutorId,
          nome: nome,
          email: email,
          telefone: telefone,
          createdAt: widget.tutor!.createdAt,
          updatedAt: DateTime.now(),
          deletedAt: widget.tutor!.deletedAt,
        );
        await _controller.updateTutor(updatedTutor);
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
        final newTutor = Tutor(
          nome: nome,
          email: email,
          telefone: telefone,
          createdAt: now,
          updatedAt: now,
        );
        await _controller.insertTutor(newTutor);

        if (_controller.errorMessage == null) {
          _showSnackBar('$nome cadastrado com sucesso!');
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        } else {
          _showSnackBar(
            'Erro ao salvar informações: ${_controller.errorMessage}',
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
          _isEditing ? 'Editar Tutor' : 'Novo Tutor',
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
                const FormHeaderIcon(icon: Icons.person_rounded),
                const SizedBox(height: 32),
                FormCardSection(
                  title: 'Informações de Contato',
                  children: [
                    const FormSectionLabel(text: 'Nome Completo'),
                    const SizedBox(height: 8),
                    _buildNomeField(),
                    const SizedBox(height: 20),
                    const FormSectionLabel(text: 'E-mail'),
                    const SizedBox(height: 8),
                    _buildEmailField(),
                    const SizedBox(height: 20),
                    const FormSectionLabel(text: 'Telefone'),
                    const SizedBox(height: 8),
                    _buildTelefoneField(),
                  ],
                ),
                const SizedBox(height: 40),
                FormSubmitButton(
                  label: _isEditing ? 'Salvar Alterações' : 'Cadastrar Tutor',
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
      hintText: 'Ex: Everton Coimbra',
      prefixIcon: Icons.person_rounded,
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'O nome do tutor é obrigatório.';
        }
        if (value.trim().length < 3) {
          return 'O nome deve ter pelo menos 3 caracteres.';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return CustomTextFormField(
      controller: _emailController,
      hintText: 'Ex: everton@example.com',
      prefixIcon: Icons.email_rounded,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'O e-mail é obrigatório.';
        }
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Informe um e-mail válido.';
        }
        return null;
      },
    );
  }

  Widget _buildTelefoneField() {
    return CustomTextFormField(
      controller: _telefoneController,
      hintText: 'Ex: (45) 99999-9999',
      prefixIcon: Icons.phone_rounded,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'O telefone é obrigatório.';
        }
        if (value.trim().length < 8) {
          return 'Informe um telefone válido.';
        }
        return null;
      },
    );
  }
}
