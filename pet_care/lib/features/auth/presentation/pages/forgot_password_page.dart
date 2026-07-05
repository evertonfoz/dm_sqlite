import 'package:flutter/material.dart';
import 'package:pet_care/features/auth/presentation/controllers/auth_controller.dart';

class ForgotPasswordPage extends StatefulWidget {
  final AuthController? authController;

  const ForgotPasswordPage({
    super.key,
    this.authController,
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final AuthController _authController;
  final _emailController = TextEditingController();
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _authController = widget.authController ?? AuthController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    if (widget.authController == null) {
      _authController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar senha'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _authController,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildFeedbackMessage(),
                    const SizedBox(height: 24),
                    _buildSendButton(),
                    const SizedBox(height: 16),
                    _buildBackToLoginButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Esqueceu sua senha?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Informe o e-mail cadastrado para receber as '
          'instruções de recuperação de senha.',
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'E-mail',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      validator: _validateEmail,
      onFieldSubmitted: (_) => _submit(),
    );
  }

  Widget _buildFeedbackMessage() {
    if (_authController.hasError) {
      return _buildMessageBox(
        message: _authController.errorMessage!,
        color: Colors.red,
        icon: Icons.error_outline,
      );
    }
    if (_success) {
      return _buildMessageBox(
        message: 'Se o e-mail estiver cadastrado, você '
            'receberá as instruções de recuperação.',
        color: const Color(0xFF0F766E),
        icon: Icons.check_circle_outline,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMessageBox({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _authController.isLoading ? null : _submit,
        child: _authController.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Enviar recuperação'),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return TextButton(
      onPressed: _authController.isLoading
          ? null
          : () {
              Navigator.pop(context);
            },
      child: const Text('Voltar ao login'),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() {
      _success = false;
    });
    final success = await _authController.resetPassword(
      email: _emailController.text,
    );
    if (!mounted) return;
    if (success) {
      setState(() {
        _success = true;
      });
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu e-mail.';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }
}
