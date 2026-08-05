import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/mixins/validation_mixin.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';

class CreateCompanyDialogWidget extends StatefulWidget {
  const CreateCompanyDialogWidget({super.key});

  @override
  State<CreateCompanyDialogWidget> createState() => _CreateCompanyDialogWidgetState();
}

class _CreateCompanyDialogWidgetState extends State<CreateCompanyDialogWidget> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _maxSellersController = TextEditingController(text: '5');
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
          const SnackBar(
            content: Text('🎉 Loja/Empresa cadastrada com sucesso!'),
            backgroundColor: AppColors.supervisor,
          ),
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
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.add_business_rounded, color: AppColors.supervisor),
                  SizedBox(width: 8),
                  Text('Cadastrar Nova Loja / Empresa (SaaS)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const Divider(color: AppColors.border, height: 24),
              TextFormField(
                controller: _nameController,
                validator: (v) => validateNotEmpty(v, 'Nome da Loja'),
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Nome da Loja/Empresa', 'Ex: Agência Mídia', Icons.business),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cnpjController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('CNPJ (Opcional)', '00.000.000/0001-00', Icons.badge_outlined),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _adminNameController,
                      validator: (v) => validateNotEmpty(v, 'Nome do Gestor'),
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Nome do Gestor', 'Ex: Roberto', Icons.person),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxSellersController,
                      validator: (v) => validateNumber(v, 'Limite Vendedores'),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Limite Vendedores', '5', Icons.people_outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _adminEmailController,
                validator: validateEmail,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('E-mail do Gestor', 'gestor@loja.com', Icons.email_outlined),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _adminPasswordController,
                validator: (v) => validateNotEmpty(v, 'Senha do Gestor'),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Senha do Gestor', '••••••••', Icons.lock_outline),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted))),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.supervisor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Cadastrar Loja'),
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
      prefixIcon: Icon(icon, color: AppColors.supervisor, size: 20),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    );
  }
}
