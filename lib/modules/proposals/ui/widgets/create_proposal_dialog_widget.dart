import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/mixins/validation_mixin.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../cubit/proposals_cubit.dart';
import '../mixins/proposal_form_mixin.dart';

class CreateProposalDialogWidget extends StatefulWidget {
  const CreateProposalDialogWidget({super.key});

  @override
  State<CreateProposalDialogWidget> createState() =>
      _CreateProposalDialogWidgetState();
}

class _CreateProposalDialogWidgetState extends State<CreateProposalDialogWidget>
    with ValidationMixin, ProposalFormMixin<CreateProposalDialogWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _totalValueController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! Authenticated) return;

      final proposalData = {
        'title': _titleController.text.trim(),
        'clientName': _clientNameController.text.trim(),
        'clientEmail': _clientEmailController.text.trim(),
        'clientPhone': _clientPhoneController.text.trim(),
        'totalValue': double.tryParse(_totalValueController.text.trim()) ?? 0.0,
        'blocks': blocks,
      };

      await context
          .read<ProposalsCubit>()
          .createProposal(authState.token, proposalData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Proposta criada com sucesso! Link disponível.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar proposta: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
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
        width: 650,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.add_task_rounded, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Criar Nova Proposta Comercial',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const Divider(color: AppColors.border, height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        validator: (v) => validateNotEmpty(v, 'Título'),
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('Título da Proposta',
                            'Ex: Redesign & Tráfego Pago', Icons.title),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _clientNameController,
                              validator: (v) =>
                                  validateNotEmpty(v, 'Nome do Cliente'),
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration(
                                  'Nome do Cliente',
                                  'Ex: Loja ABC',
                                  Icons.person_outline),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _totalValueController,
                              validator: (v) =>
                                  validateNumber(v, 'Valor Total'),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration(
                                  'Valor Total (R\$)',
                                  'Ex: 8500.00',
                                  Icons.attach_money),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _clientEmailController,
                              validator: validateEmail,
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration(
                                  'E-mail do Cliente',
                                  'cliente@empresa.com',
                                  Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _clientPhoneController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration(
                                  'WhatsApp do Cliente',
                                  '11999998888',
                                  Icons.phone_android),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Blocos da Proposta',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'TEXT') addTextBlock();
                              if (value == 'VIDEO') addVideoBlock();
                              if (value == 'PRICE') addPriceTableBlock();
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'TEXT',
                                  child: Row(children: [
                                    Icon(Icons.notes, size: 18),
                                    SizedBox(width: 8),
                                    Text('+ Bloco de Texto')
                                  ])),
                              const PopupMenuItem(
                                  value: 'VIDEO',
                                  child: Row(children: [
                                    Icon(Icons.video_library_outlined,
                                        size: 18),
                                    SizedBox(width: 8),
                                    Text('+ Bloco de Vídeo')
                                  ])),
                              const PopupMenuItem(
                                  value: 'PRICE',
                                  child: Row(children: [
                                    Icon(Icons.table_chart_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text('+ Tabela de Preços')
                                  ])),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                border: Border.all(color: AppColors.primary),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add,
                                      color: AppColors.primary, size: 18),
                                  SizedBox(width: 4),
                                  Text('Adicionar Bloco',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (blocks.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'Nenhum bloco adicionado. Clique acima para adicionar texto, vídeo ou tabela de preços.',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: blocks.length,
                          itemBuilder: (context, index) {
                            final block = blocks[index];
                            return _buildBlockItem(block, index);
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 2))
                        : const Text('Salvar e Gerar Link',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
      String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  Widget _buildBlockItem(Map<String, dynamic> block, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            block['type'] == 'TEXT'
                ? Icons.notes
                : block['type'] == 'VIDEO'
                    ? Icons.video_library
                    : Icons.table_chart,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(block['title'] ?? 'Bloco',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text('Tipo: ${block['type']}',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: AppColors.error, size: 20),
            onPressed: () => removeBlock(index),
          )
        ],
      ),
    );
  }
}
