import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/simproposta_colors.dart';
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

  void _showEditBlockDialog(int index) {
    final block = blocks[index];
    final titleController = TextEditingController(text: (block['title'] ?? '').toString());
    final isPriceTable = block['type'] == 'PRICE_TABLE';
    final isVideo = block['type'] == 'VIDEO';

    String rawContent = '';
    List<Map<String, dynamic>> itemsList = [];

    final contentObj = block['content'];
    if (contentObj is Map) {
      if (contentObj['items'] is List) {
        itemsList = List<Map<String, dynamic>>.from(
          (contentObj['items'] as List).map((x) => Map<String, dynamic>.from(x)),
        );
      }
      rawContent = (contentObj['text'] ?? contentObj['url'] ?? contentObj['videoUrl'] ?? '').toString();
    } else if (contentObj is String) {
      rawContent = contentObj;
    }

    if (isPriceTable && itemsList.isEmpty) {
      itemsList.add({'name': 'Item / Serviço', 'description': 'Descrição do serviço inclusos no valor', 'price': 0.0});
    }

    final contentController = TextEditingController(text: rawContent);

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bgCard = isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface;
        final bgInput = isDark ? SimPropostaColors.darkInputBackground : SimPropostaColors.offWhite;
        final textMain = isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.navy;
        final textSub = isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary;
        final primaryColor = isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Row(
                children: [
                  Icon(
                    isPriceTable
                        ? Icons.table_chart_rounded
                        : isVideo
                            ? Icons.video_library_rounded
                            : Icons.edit_note_rounded,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text('Editar Bloco (${block['type']})', style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: titleController,
                        style: TextStyle(color: textMain),
                        decoration: InputDecoration(
                          labelText: 'Título do Bloco',
                          filled: true,
                          fillColor: bgInput,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (isPriceTable) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Itens & Preços da Tabela:', style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  itemsList.add({'name': 'Novo Item', 'description': 'Descrição do item', 'price': 0.0});
                                });
                              },
                              icon: Icon(Icons.add, size: 16, color: primaryColor),
                              label: Text('+ Adicionar Item', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...itemsList.asMap().entries.map((entry) {
                          final itemIdx = entry.key;
                          final itemData = entry.value;

                          final nameCtrl = TextEditingController(text: (itemData['name'] ?? '').toString());
                          final descCtrl = TextEditingController(text: (itemData['description'] ?? '').toString());
                          final priceCtrl = TextEditingController(text: (itemData['price'] ?? 0).toString());

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: bgInput,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: nameCtrl,
                                        onChanged: (v) => itemsList[itemIdx]['name'] = v,
                                        style: TextStyle(color: textMain, fontSize: 13),
                                        decoration: const InputDecoration(labelText: 'Nome do Item', isDense: true),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 1,
                                      child: TextFormField(
                                        controller: priceCtrl,
                                        onChanged: (v) => itemsList[itemIdx]['price'] = double.tryParse(v) ?? 0.0,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(color: textMain, fontSize: 13),
                                        decoration: const InputDecoration(labelText: 'Valor R\$', isDense: true),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: SimPropostaColors.error, size: 18),
                                      onPressed: () {
                                        setDialogState(() {
                                          itemsList.removeAt(itemIdx);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: descCtrl,
                                  onChanged: (v) => itemsList[itemIdx]['description'] = v,
                                  style: TextStyle(color: textSub, fontSize: 12),
                                  decoration: const InputDecoration(labelText: 'Descrição detalhada do item', isDense: true),
                                ),
                              ],
                            ),
                          );
                        }),
                      ] else ...[
                        Text(
                          isVideo ? 'Link do Vídeo (YouTube / Vimeo):' : 'Descrição dos Serviços / Texto:',
                          style: TextStyle(color: textMain, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: contentController,
                          maxLines: isVideo ? 2 : 5,
                          style: TextStyle(color: textMain),
                          decoration: InputDecoration(
                            hintText: isVideo ? 'https://www.youtube.com/watch?v=...' : 'Escreva os detalhes do projeto...',
                            filled: true,
                            fillColor: bgInput,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? SimPropostaColors.darkBackground : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      blocks[index]['title'] = titleController.text.trim();

                      if (isPriceTable) {
                        blocks[index]['content'] = {'items': itemsList};
                      } else if (isVideo) {
                        String input = contentController.text.trim();
                        RegExp urlRegex = RegExp(r'https?://[^\s"]+');
                        Match? match = urlRegex.firstMatch(input);
                        String cleanUrl = match != null ? match.group(0)! : input;
                        blocks[index]['content'] = {'videoUrl': cleanUrl};
                      } else {
                        blocks[index]['content'] = {'text': contentController.text.trim()};
                      }
                    });

                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Bloco atualizado com sucesso!'),
                        backgroundColor: SimPropostaColors.teal,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text('Salvar Bloco'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
            backgroundColor: SimPropostaColors.teal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar proposta: ${e.toString()}'),
            backgroundColor: SimPropostaColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCard = isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface;
    final bgInput = isDark ? SimPropostaColors.darkInputBackground : SimPropostaColors.offWhite;
    final textMain = isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.navy;
    final textSub = isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary;
    final primaryColor = isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal;

    return Dialog(
      backgroundColor: bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 680,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.add_task_rounded, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Criar Nova Proposta Comercial',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textMain),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textSub),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              Divider(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border, height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        validator: (v) => validateNotEmpty(v, 'Título'),
                        style: TextStyle(color: textMain),
                        decoration: _buildInputDecoration('Título da Proposta',
                            'Ex: Redesign & Tráfego Pago', Icons.title, bgInput, textSub, primaryColor),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _clientNameController,
                              validator: (v) =>
                                  validateNotEmpty(v, 'Nome do Cliente'),
                              style: TextStyle(color: textMain),
                              decoration: _buildInputDecoration(
                                  'Nome do Cliente',
                                  'Ex: Loja ABC',
                                  Icons.person_outline, bgInput, textSub, primaryColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _totalValueController,
                              validator: (v) =>
                                  validateNumber(v, 'Valor Total'),
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textMain),
                              decoration: _buildInputDecoration(
                                  'Valor Total (R\$)',
                                  'Ex: 8500.00',
                                  Icons.attach_money, bgInput, textSub, primaryColor),
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
                              style: TextStyle(color: textMain),
                              decoration: _buildInputDecoration(
                                  'E-mail do Cliente',
                                  'cliente@empresa.com',
                                  Icons.email_outlined, bgInput, textSub, primaryColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _clientPhoneController,
                              style: TextStyle(color: textMain),
                              decoration: _buildInputDecoration(
                                  'WhatsApp do Cliente',
                                  '11999998888',
                                  Icons.phone_android, bgInput, textSub, primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Blocos da Proposta (Clique para Editar)',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textMain),
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
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.15),
                                border: Border.all(color: primaryColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: primaryColor, size: 18),
                                  const SizedBox(width: 4),
                                  Text('Adicionar Bloco',
                                      style: TextStyle(
                                          color: primaryColor,
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
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: bgInput,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
                          ),
                          child: Center(
                            child: Text(
                              'Nenhum bloco adicionado. Clique em "+ Adicionar Bloco" acima para montar sua proposta.',
                              style: TextStyle(color: textSub, fontSize: 13),
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
                            return _buildBlockItem(block, index, isDark, textMain, textSub, primaryColor);
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
                    child: Text('Cancelar', style: TextStyle(color: textSub)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: isDark ? SimPropostaColors.darkBackground : Colors.white,
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
                                color: Colors.white, strokeWidth: 2))
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
      String label, String hint, IconData icon, Color bg, Color subColor, Color accent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: subColor.withOpacity(0.5)),
      labelStyle: TextStyle(color: subColor),
      prefixIcon: Icon(icon, color: accent, size: 20),
      filled: true,
      fillColor: bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
      ),
    );
  }

  Widget _buildBlockItem(Map<String, dynamic> block, int index, bool isDark, Color textMain, Color textSub, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? SimPropostaColors.darkInputBackground : SimPropostaColors.offWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
      ),
      child: Row(
        children: [
          Icon(
            block['type'] == 'TEXT'
                ? Icons.notes
                : block['type'] == 'VIDEO'
                    ? Icons.video_library
                    : Icons.table_chart,
            color: accent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _showEditBlockDialog(index),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(block['title'] ?? 'Bloco',
                          style: TextStyle(
                              color: textMain,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit, size: 13, color: SimPropostaColors.teal),
                    ],
                  ),
                  Text('Tipo: ${block['type']} (Clique para editar o texto/itens da tabela)',
                      style: TextStyle(color: textSub, fontSize: 11)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: SimPropostaColors.teal, size: 20),
            tooltip: 'Editar Conteúdo do Bloco',
            onPressed: () => _showEditBlockDialog(index),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: SimPropostaColors.error, size: 20),
            tooltip: 'Remover Bloco',
            onPressed: () => removeBlock(index),
          )
        ],
      ),
    );
  }
}
