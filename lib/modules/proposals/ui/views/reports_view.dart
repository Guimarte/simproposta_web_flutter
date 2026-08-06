import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/simproposta_colors.dart';
import '../../cubit/proposals_cubit.dart';
import '../../cubit/proposals_state.dart';
import '../../domain/entities/proposal_entity.dart';
import '../widgets/donut_chart_widget.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/proposal_item_card_widget.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  String _selectedPeriod = 'ALL'; // 7D, 30D, 90D, ALL

  List<ProposalEntity> _filterProposals(List<ProposalEntity> list) {
    if (_selectedPeriod == 'ALL') return list;

    final now = DateTime.now();
    int days = 7;
    if (_selectedPeriod == '30D') days = 30;
    if (_selectedPeriod == '90D') days = 90;

    final cutoff = now.subtract(Duration(days: days));
    return list.where((p) => p.createdAt.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.navy;
    final textSub = isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary;
    final primaryColor = isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal;
    final bgCard = isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da Tela de Relatórios
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Relatórios & Analytics Detalhados',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textMain),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Análise de Desempenho Comercial, Funil de Conversão e Curvas de Faturamento.',
                    style: TextStyle(color: textSub, fontSize: 14),
                  ),
                ],
              ),
              // Filtro por Período
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    dropdownColor: bgCard,
                    style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: '7D', child: Text('Últimos 7 Dias')),
                      DropdownMenuItem(value: '30D', child: Text('Últimos 30 Dias')),
                      DropdownMenuItem(value: '90D', child: Text('Últimos 90 Dias')),
                      DropdownMenuItem(value: 'ALL', child: Text('Todo o Período')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPeriod = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          BlocBuilder<ProposalsCubit, ProposalsState>(
            builder: (context, state) {
              if (state is ProposalsLoading) {
                return Center(child: Padding(padding: const EdgeInsets.all(40), child: CircularProgressIndicator(color: primaryColor)));
              }
              if (state is ProposalsError) {
                return Center(child: Text(state.message, style: const TextStyle(color: SimPropostaColors.error)));
              }
              if (state is ProposalsLoaded) {
                final filtered = _filterProposals(state.proposals);

                final int totalCount = filtered.length;
                final double totalVal = filtered.fold(0.0, (sum, p) => sum + p.totalValue);

                final int acceptedCount = filtered.where((p) => p.status == 'ACCEPTED').length;
                final int viewedCount = filtered.where((p) => p.status == 'VIEWED').length;
                final int sentCount = filtered.where((p) => p.status == 'SENT').length;
                final int draftCount = filtered.where((p) => p.status == 'DRAFT').length;

                final double ticketMedio = totalCount > 0 ? totalVal / totalCount : 0.0;

                final donutSegments = [
                  ChartSegment(label: 'Aprovadas Digitalmente', value: acceptedCount.toDouble(), color: SimPropostaColors.mint),
                  ChartSegment(label: 'Lidas em Tempo Real', value: viewedCount.toDouble(), color: primaryColor),
                  ChartSegment(label: 'Aguardando Leitura', value: sentCount.toDouble(), color: SimPropostaColors.warning),
                  ChartSegment(label: 'Rascunhos / Em Edição', value: draftCount.toDouble(), color: textSub.withOpacity(0.5)),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cards de Métricas Secundárias de Analytics
                    Row(
                      children: [
                        _buildReportMetricCard('Ticket Médio por Proposta', 'R\$ ${ticketMedio.toStringAsFixed(2)}', Icons.payments_outlined, primaryColor, isDark, textMain, textSub),
                        const SizedBox(width: 14),
                        _buildReportMetricCard('Propostas em Negociação', 'R\$ ${totalVal.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined, SimPropostaColors.mint, isDark, textMain, textSub),
                        const SizedBox(width: 14),
                        _buildReportMetricCard('Total no Período Selecionado', '$totalCount propostas', Icons.description_outlined, SimPropostaColors.warning, isDark, textMain, textSub),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Gráficos Lado a Lado: Donut (Pizza) + Linha (Evolução)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: DonutChartWidget(
                            title: 'Distribuição do Funil (Pizza)',
                            segments: donutSegments,
                            centerValue: '$totalCount',
                            centerLabel: 'PROPOSTAS',
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          flex: 6,
                          child: LineChartWidget(
                            title: 'Evolução Financeira Temporal',
                            proposals: filtered,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Detalhamento das Propostas Filtradas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain),
                    ),
                    const SizedBox(height: 16),

                    if (filtered.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
                        ),
                        child: Center(
                          child: Text('Nenhuma proposta encontrada para o período selecionado.', style: TextStyle(color: textSub)),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return ProposalItemCardWidget(item: filtered[index]);
                        },
                      ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
    Color textMain,
    Color textSub,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
