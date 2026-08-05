import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/simproposta_colors.dart';
import '../../domain/entities/proposal_entity.dart';

class ProposalItemCardWidget extends StatelessWidget {
  final ProposalEntity item;

  const ProposalItemCardWidget({super.key, required this.item});

  void _copyProposalLink(BuildContext context) {
    final link = 'http://localhost:3333/p/${item.slug}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Link da proposta copiado para a área de transferência!'),
        backgroundColor: SimPropostaColors.teal,
        duration: Duration(seconds: 2),
      ),
    );
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
          const SizedBox(width: 20),
          
          // Badge de Status V2
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),

          OutlinedButton.icon(
            onPressed: () => _copyProposalLink(context),
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copiar Link', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: textMain,
              side: BorderSide(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
