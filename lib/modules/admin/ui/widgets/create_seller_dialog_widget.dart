import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/mixins/validation_mixin.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';

class CreateSellerDialogWidget extends StatefulWidget {
  const CreateSellerDialogWidget({super.key});

  @override
  State<CreateSellerDialogWidget> createState() => _CreateSellerDialogWidgetState();
}

class _CreateSellerDialogWidgetState extends State<CreateSellerDialogWidget> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! Authenticated) return;

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Vendedor cadastrado na equipe!'), backgroundColor: AppColors.admin),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.person_add_rounded, color: AppColors.admin),
                  SizedBox(width: 8),
                  Text('Cadastrar Novo Vendedor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const Divider(color: AppColors.border, height: 24),
              TextFormField(
                controller: _nameController,
                validator: (v) => validateNotEmpty(v, 'Nome do Vendedor'),
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Nome do Vendedor', 'Ex: Carlos Silva', Icons.person_outline),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                validator: validateEmail,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('E-mail do Vendedor', 'carlos@loja.com', Icons.email_outlined),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _passwordController,
                      validator: (v) => validateNotEmpty(v, 'Senha'),
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Senha Inicial', '••••••••', Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('WhatsApp/Celular', '11999998888', Icons.phone_android),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted))),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.admin, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Cadastrar Vendedor'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      prefixIcon: Icon(icon, color: AppColors.admin, size: 20),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    );
  }
}
