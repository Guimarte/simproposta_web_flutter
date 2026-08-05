import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/mixins/validation_mixin.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';

class UpdateThemeDialogWidget extends StatefulWidget {
  const UpdateThemeDialogWidget({super.key});

  @override
  State<UpdateThemeDialogWidget> createState() => _UpdateThemeDialogWidgetState();
}

class _UpdateThemeDialogWidgetState extends State<UpdateThemeDialogWidget> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _primaryColorController = TextEditingController(text: '#10B981');
  final _logoUrlController = TextEditingController();
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
          const SnackBar(content: Text('🎨 Identidade visual e tema atualizados!'), backgroundColor: AppColors.primary),
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
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.palette_outlined, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Personalizar Tema da Proposta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const Divider(color: AppColors.border, height: 24),
              TextFormField(
                controller: _primaryColorController,
                validator: (v) => validateNotEmpty(v, 'Cor Primária'),
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Cor Primária (Hexadecimal)', 'Ex: #10B981 ou #3B82F6', Icons.color_lens_outlined),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _logoUrlController,
                validator: (v) => validateNotEmpty(v, 'URL da Logo'),
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('URL da Logo da Empresa', 'https://suaempresa.com/logo.png', Icons.image_outlined),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted))),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Text('Salvar Alterações'),
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
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    );
  }
}
