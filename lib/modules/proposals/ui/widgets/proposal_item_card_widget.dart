import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/simproposta_colors.dart';
import '../../domain/entities/proposal_entity.dart';

class ProposalItemCardWidget extends StatelessWidget {
  final ProposalEntity item;

  const ProposalItemCardWidget({super.key, required this.item});

  String _getProposalLink() {
    const apiHost = String.fromEnvironment('API_HOST', defaultValue: 'https://api.simaprova.com.br');
    final rawCompanyName = item.companyName ?? 'empresa';
    final companySlug = rawCompanyName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    return '$apiHost/$companySlug/${item.slug}';
  }

  void _copyProposalLink(BuildContext context) {
    final link = _getProposalLink();
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📋 Link White-Label copiado: $link'),
        backgroundColor: SimPropostaColors.teal,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openWhatsApp(BuildContext context) {
    final link = _getProposalLink();
    final message = Uri.encodeComponent(
      'Olá ${item.clientName}, tudo bem? Segue a proposta comercial "${item.title}" elaborada exclusivamente para você: $link',
    );

    final whatsappUrl = 'https://wa.me/?text=$message';
    try {
      html.window.open(whatsappUrl, '_blank');
    } catch (_) {
      Clipboard.setData(ClipboardData(text: 'https://wa.me/?text=$message'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAccepted = item.status == 'ACCEPTED';
    final isViewed = item.status == 'VIEWED';

    final primaryColor = isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal;
    final textMain = isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.navy;
    final textSub = isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : SimPropostaColors.navy).withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description_outlined, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cliente: ${item.clientName}',
                  style: TextStyle(color: textSub, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            'R\$ ${item.totalValue.toStringAsFixed(2)}',
            style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(width: 16),
          
          // Badge de Status V2
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isAccepted
                  ? SimPropostaColors.teal.withOpacity(0.15)
                  : isViewed
                      ? SimPropostaColors.mint.withOpacity(0.2)
                      : SimPropostaColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAccepted
                    ? SimPropostaColors.teal
                    : isViewed
                        ? primaryColor
                        : SimPropostaColors.warning,
                width: 1,
              ),
            ),
            child: Text(
              isAccepted
                  ? '✓ Aprovada Digitalmente'
                  : isViewed
                      ? '⚡ Lida em Tempo Real'
                      : '⏳ Aguardando Leitura',
              style: TextStyle(
                color: isAccepted
                    ? SimPropostaColors.teal
                    : isViewed
                        ? primaryColor
                        : SimPropostaColors.warning,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Botão WhatsApp
          ElevatedButton.icon(
            onPressed: () => _openWhatsApp(context),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
            label: const Text('Enviar WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 8),

          // Botão Copiar Link
          OutlinedButton.icon(
            onPressed: () => _copyProposalLink(context),
            icon: const Icon(Icons.copy_rounded, size: 15),
            label: const Text('Copiar Link', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: textMain,
              side: BorderSide(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
