import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/simproposta_colors.dart';
import '../../../../core/mixins/validation_mixin.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';

class CreateCompanyDialogWidget extends StatefulWidget {
  const CreateCompanyDialogWidget({super.key});

  @override
  State<CreateCompanyDialogWidget> createState() =>
      _CreateCompanyDialogWidgetState();
}

class _CreateCompanyDialogWidgetState extends State<CreateCompanyDialogWidget>
    with ValidationMixin {
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

      final url = '${AuthRemoteDatasource.baseUrl}/admin/companies';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authState.token}',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'cnpj': _cnpjController.text.trim(),
          'adminName': _adminNameController.text.trim(),
          'adminEmail': _adminEmailController.text.trim(),
          'adminPassword': _adminPasswordController.text.trim(),
          'maxSellers': int.tryParse(_maxSellersController.text) ?? 5,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '🎉 Loja "${_nameController.text}" e conta Admin cadastradas com sucesso!'),
              backgroundColor: SimPropostaColors.supervisor,
            ),
          );
        }
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error'] ?? 'Falha ao cadastrar loja');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: ${e.toString()}'),
              backgroundColor: SimPropostaColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCard =
        isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface;
    final bgInput =
        isDark ? SimPropostaColors.darkBackground : SimPropostaColors.offWhite;
    final textMain =
        isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.navy;
    final textSub = isDark
        ? SimPropostaColors.darkTextSecondary
        : SimPropostaColors.textSecondary;

    return Dialog(
      backgroundColor: bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_business_rounded,
                      color: SimPropostaColors.supervisor),
                  const SizedBox(width: 8),
                  Text('Cadastrar Nova Loja / Empresa (SaaS)',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textMain)),
                ],
              ),
              Divider(
                  color: isDark
                      ? SimPropostaColors.darkBorder
                      : SimPropostaColors.border,
                  height: 24),
              TextFormField(
                controller: _nameController,
                validator: (v) => validateNotEmpty(v, 'Nome da Loja'),
                style: TextStyle(color: textMain),
                decoration: _buildInputDecoration('Nome da Loja/Empresa',
                    'Ex: Agência Mídia', Icons.business, bgInput, textSub),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cnpjController,
                style: TextStyle(color: textMain),
                decoration: _buildInputDecoration(
                    'CNPJ (Opcional)',
                    '00.000.000/0001-00',
                    Icons.badge_outlined,
                    bgInput,
                    textSub),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _adminNameController,
                      validator: (v) => validateNotEmpty(v, 'Nome do Gestor'),
                      style: TextStyle(color: textMain),
                      decoration: _buildInputDecoration('Nome do Gestor',
                          'Ex: Roberto', Icons.person, bgInput, textSub),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxSellersController,
                      validator: (v) => validateNumber(v, 'Limite Vendedores'),
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textMain),
                      decoration: _buildInputDecoration('Limite Vendedores',
                          '5', Icons.people_outline, bgInput, textSub),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _adminEmailController,
                validator: validateEmail,
                style: TextStyle(color: textMain),
                decoration: _buildInputDecoration(
                    'E-mail do Gestor (Login Admin)',
                    'gestor@loja.com',
                    Icons.email_outlined,
                    bgInput,
                    textSub),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _adminPasswordController,
                validator: (v) => validateNotEmpty(v, 'Senha do Gestor'),
                obscureText: true,
                style: TextStyle(color: textMain),
                decoration: _buildInputDecoration('Senha do Gestor', '••••••••',
                    Icons.lock_outline, bgInput, textSub),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child:
                          Text('Cancelar', style: TextStyle(color: textSub))),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: SimPropostaColors.supervisor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14)),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Cadastrar Loja & Gerar Acesso'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      String label, String hint, IconData icon, Color bg, Color subColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: subColor.withOpacity(0.5)),
      labelStyle: TextStyle(color: subColor),
      prefixIcon: Icon(icon, color: SimPropostaColors.supervisor, size: 20),
      filled: true,
      fillColor: bg,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: isDark
                  ? SimPropostaColors.darkBorder
                  : SimPropostaColors.border)),
    );
  }
}
