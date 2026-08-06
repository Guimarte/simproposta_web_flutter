import 'package:flutter/material.dart';
import '../../../../core/constants/simproposta_colors.dart';
import '../../domain/entities/proposal_entity.dart';

class StoreAnalyticsWidget extends StatelessWidget {
  final List<ProposalEntity> proposals;

  const StoreAnalyticsWidget({super.key, required this.proposals});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.navy;
    final textSub = isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary;
    final primaryColor = isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal;
    final bgCard = isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface;
    final borderCard = isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border;

    int totalProposals = proposals.length;
    double totalValue = proposals.fold(0.0, (sum, p) => sum + p.totalValue);

    int acceptedCount = proposals.where((p) => p.status == 'ACCEPTED').length;
    double acceptedValue = proposals
        .where((p) => p.status == 'ACCEPTED')
        .fold(0.0, (sum, p) => sum + p.totalValue);

    int viewedCount = proposals.where((p) => p.status == 'VIEWED').length;
    int draftCount = proposals.where((p) => p.status == 'DRAFT').length;
    int sentCount = proposals.where((p) => p.status == 'SENT').length;

    double conversionRate = totalProposals > 0 ? (acceptedCount / totalProposals) * 100 : 0.0;
    double viewedRate = totalProposals > 0 ? ((viewedCount + acceptedCount) / totalProposals) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cards de KPIs em Grade
        Row(
          children: [
            _buildKpiCard(
              label: 'Faturamento Total Gerado',
              value: 'R\$ ${totalValue.toStringAsFixed(2)}',
              subtitle: '$totalProposals propostas no total',
              icon: Icons.account_balance_wallet_outlined,
              color: primaryColor,
              isDark: isDark,
              textMain: textMain,
              textSub: textSub,
            ),
            const SizedBox(width: 14),
            _buildKpiCard(
              label: 'Vendas Aprovadas Digitalmente',
              value: 'R\$ ${acceptedValue.toStringAsFixed(2)}',
              subtitle: '$acceptedCount propostas fechadas',
              icon: Icons.check_circle_outline_rounded,
              color: SimPropostaColors.mint,
              isDark: isDark,
              textMain: textMain,
              textSub: textSub,
            ),
            const SizedBox(width: 14),
            _buildKpiCard(
              label: 'Taxa de Conversão Comercial',
              value: '${conversionRate.toStringAsFixed(1)}%',
              subtitle: 'Do total de propostas enviadas',
              icon: Icons.trending_up_rounded,
              color: SimPropostaColors.teal,
              isDark: isDark,
              textMain: textMain,
              textSub: textSub,
            ),
            const SizedBox(width: 14),
            _buildKpiCard(
              label: 'Rastreamento & Leitura',
              value: '${viewedRate.toStringAsFixed(1)}%',
              subtitle: 'Propostas abertas pelo cliente',
              icon: Icons.remove_red_eye_outlined,
              color: SimPropostaColors.warning,
              isDark: isDark,
              textMain: textMain,
              textSub: textSub,
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Gráfico de Funil & Distribuição Visual
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights_rounded, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Funil de Conversão Comercial da Loja',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textMain),
                      ),
                    ],
                  ),
                  Text(
                    'Desempenho Atual',
                    style: TextStyle(fontSize: 12, color: textSub, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Barra de Funil Progresso Relativo
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 14,
                  child: Row(
                    children: [
                      if (acceptedCount > 0)
                        Expanded(
                          flex: acceptedCount,
                          child: Container(color: SimPropostaColors.mint),
                        ),
                      if (viewedCount > 0)
                        Expanded(
                          flex: viewedCount,
                          child: Container(color: primaryColor),
                        ),
                      if (sentCount > 0)
                        Expanded(
                          flex: sentCount,
                          child: Container(color: SimPropostaColors.warning),
                        ),
                      if (draftCount > 0)
                        Expanded(
                          flex: draftCount,
                          child: Container(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
                        ),
                      if (totalProposals == 0)
                        Expanded(
                          child: Container(color: isDark ? SimPropostaColors.darkSurfaceSubtle : SimPropostaColors.surfaceSubtle),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Legendas com Estatísticas em Cartões
              Row(
                children: [
                  _buildFunnelLegendItem(
                    label: '✓ Aprovadas Digitalmente',
                    count: acceptedCount,
                    total: totalProposals,
                    color: SimPropostaColors.mint,
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  _buildFunnelLegendItem(
                    label: '⚡ Lidas em Tempo Real',
                    count: viewedCount,
                    total: totalProposals,
                    color: primaryColor,
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  _buildFunnelLegendItem(
                    label: '⏳ Aguardando Leitura',
                    count: sentCount,
                    total: totalProposals,
                    color: SimPropostaColors.warning,
                    textMain: textMain,
                    textSub: textSub,
                  ),
                  _buildFunnelLegendItem(
                    label: '📝 Rascunhos / Em Edição',
                    count: draftCount,
                    total: totalProposals,
                    color: isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary,
                    textMain: textMain,
                    textSub: textSub,
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color textMain,
    required Color textSub,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : SimPropostaColors.navy).withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(color: textSub, fontSize: 12, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(color: textMain, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: textSub, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnelLegendItem({
    required String label,
    required int count,
    required int total,
    required Color color,
    required Color textMain,
    required Color textSub,
  }) {
    double pct = total > 0 ? (count / total) * 100 : 0.0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$count propostas', style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${pct.toStringAsFixed(0)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
