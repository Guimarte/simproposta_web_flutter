import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/simproposta_colors.dart';
import '../../../admin/ui/widgets/create_seller_dialog_widget.dart';
import '../../../admin/ui/widgets/update_theme_dialog_widget.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../supervisor/ui/widgets/create_company_dialog_widget.dart';
import '../../../supervisor/ui/widgets/super_admin_report_widget.dart';
import '../../cubit/proposals_cubit.dart';
import '../../cubit/proposals_state.dart';
import '../widgets/create_proposal_dialog_widget.dart';
import '../widgets/donut_chart_widget.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/proposal_item_card_widget.dart';
import '../widgets/store_analytics_widget.dart';
import 'reports_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentTab = 0; // 0 = Home/Dashboard, 1 = Relatórios & Analytics

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<ProposalsCubit>().fetchProposals(authState.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthCubit>().state;
    final user = authState is Authenticated ? authState.user : null;
    final role = user?.role ?? 'SELLER';

    final textMain = isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.navy;
    final textSub = isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary;
    final primaryColor = isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal;
    final bgCard = isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface;

    return Scaffold(
      backgroundColor: isDark ? SimPropostaColors.darkBackground : SimPropostaColors.offWhite,
      appBar: AppBar(
        backgroundColor: bgCard,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              isDark ? 'assets/images/simproposta-logo-fundo-escuro-v2.png' : 'assets/images/simproposta-logo-fundo-claro-v2.png',
              height: 38,
              errorBuilder: (context, error, stackTrace) {
                return Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: SimPropostaColors.teal, size: 24),
                    const SizedBox(width: 8),
                    Text('SimAprova', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textMain)),
                  ],
                );
              },
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: role == 'SUPER_ADMIN' ? SimPropostaColors.supervisor.withOpacity(0.15) : primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: role == 'SUPER_ADMIN' ? SimPropostaColors.supervisor : primaryColor,
                  width: 0.8,
                ),
              ),
              child: Text(
                role == 'SUPER_ADMIN' ? 'PAINEL SUPERVISOR SAAS' : (user?.companyName ?? 'LOJA'),
                style: TextStyle(
                  color: role == 'SUPER_ADMIN' ? SimPropostaColors.supervisor : primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: textSub),
            onPressed: () {
              if (authState is Authenticated) {
                context.read<ProposalsCubit>().fetchProposals(authState.token);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: SimPropostaColors.error),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          // ABA 0: HOME / DASHBOARD COMERCIAL
          _buildHomeDashboard(context, role, user, isDark, textMain, textSub, primaryColor),

          // ABA 1: RELATÓRIOS & ANALYTICS DEDICADOS
          const ReportsView(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgCard,
          border: Border(top: BorderSide(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (index) => setState(() => _currentTab = index),
          backgroundColor: bgCard,
          selectedItemColor: primaryColor,
          unselectedItemColor: textSub,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Home / Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics_rounded),
              label: 'Relatórios & Gráficos',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeDashboard(
    BuildContext context,
    String role,
    dynamic user,
    bool isDark,
    Color textMain,
    Color textSub,
    Color primaryColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da Página
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role == 'SUPER_ADMIN' ? 'Painel Administrativo do Supervisor' : 'Painel Comercial — ${user?.name ?? "Usuário"}',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textMain),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role == 'SUPER_ADMIN'
                        ? 'Gestão de Lojas Clientes, Limite de Vendedores e Volume de Emissão de Propostas.'
                        : 'Acompanhamento em Tempo Real de Vendas, Rastreamento e Conversão.',
                    style: TextStyle(color: textSub, fontSize: 14),
                  ),
                ],
              ),
              // Botões de Ação Principais
              Row(
                children: [
                  if (role == 'SUPER_ADMIN')
                    ElevatedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => const CreateCompanyDialogWidget()),
                      icon: const Icon(Icons.add_business_rounded, size: 18),
                      label: const Text('Cadastrar Nova Loja / Cliente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SimPropostaColors.supervisor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  if (role == 'COMPANY_ADMIN') ...[
                    ElevatedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => const CreateSellerDialogWidget()),
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('Cadastrar Vendedor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? SimPropostaColors.darkBackground : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => const UpdateThemeDialogWidget()),
                      icon: const Icon(Icons.palette_outlined, size: 18),
                      label: const Text('Alterar Tema'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textMain,
                        side: BorderSide(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                  if (role == 'SELLER' || role == 'COMPANY_ADMIN') ...[
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => const CreateProposalDialogWidget()),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nova Proposta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? SimPropostaColors.darkBackground : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ]
                ],
              )
            ],
          ),
          const SizedBox(height: 28),

          // MODO 1: Se for SUPER_ADMIN -> Exibe Relatório Administrativo do SaaS
          if (role == 'SUPER_ADMIN')
            const SuperAdminReportWidget()

          // MODO 2: Se for COMPANY_ADMIN ou SELLER -> Exibe Relatórios Visuais & Funil Analytics da Loja
          else ...[
            BlocBuilder<ProposalsCubit, ProposalsState>(
              builder: (context, state) {
                if (state is ProposalsLoading) {
                  return Center(child: Padding(padding: const EdgeInsets.all(40), child: CircularProgressIndicator(color: primaryColor)));
                }
                if (state is ProposalsError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: SimPropostaColors.error)));
                }
                if (state is ProposalsLoaded) {
                  final int acceptedCount = state.proposals.where((p) => p.status == 'ACCEPTED').length;
                  final int viewedCount = state.proposals.where((p) => p.status == 'VIEWED').length;
                  final int sentCount = state.proposals.where((p) => p.status == 'SENT').length;
                  final int draftCount = state.proposals.where((p) => p.status == 'DRAFT').length;

                  final donutSegments = [
                    ChartSegment(label: 'Aprovadas Digitalmente', value: acceptedCount.toDouble(), color: SimPropostaColors.mint),
                    ChartSegment(label: 'Lidas em Tempo Real', value: viewedCount.toDouble(), color: primaryColor),
                    ChartSegment(label: 'Aguardando Leitura', value: sentCount.toDouble(), color: SimPropostaColors.warning),
                    ChartSegment(label: 'Rascunhos / Em Edição', value: draftCount.toDouble(), color: textSub.withOpacity(0.5)),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPIs e Funil
                      StoreAnalyticsWidget(proposals: state.proposals),
                      const SizedBox(height: 28),

                      // Gráficos Principais na Home (Pizza + Linha)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: DonutChartWidget(
                              title: 'Distribuição das Vendas (Pizza)',
                              segments: donutSegments,
                              centerValue: '${state.proposals.length}',
                              centerLabel: 'PROPOSTAS',
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            flex: 6,
                            child: LineChartWidget(
                              title: 'Curva de Faturamento Negociado',
                              proposals: state.proposals,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Text(
                        'Propostas Comerciais Ativas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain),
                      ),
                      const SizedBox(height: 16),

                      if (state.proposals.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
                          ),
                          child: Center(
                            child: Text(
                              'Nenhuma proposta criada ainda. Clique em "Nova Proposta" acima para começar.',
                              style: TextStyle(color: textSub, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.proposals.length,
                          itemBuilder: (context, index) {
                            final item = state.proposals[index];
                            return ProposalItemCardWidget(item: item);
                          },
                        ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ]
        ],
      ),
    );
  }
}
