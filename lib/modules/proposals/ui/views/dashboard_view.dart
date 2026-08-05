import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/simproposta_colors.dart';
import '../../../admin/ui/widgets/create_seller_dialog_widget.dart';
import '../../../admin/ui/widgets/update_theme_dialog_widget.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../../../supervisor/ui/widgets/create_company_dialog_widget.dart';
import '../../cubit/proposals_cubit.dart';
import '../../cubit/proposals_state.dart';
import '../widgets/create_proposal_dialog_widget.dart';
import '../widgets/metric_card_widget.dart';
import '../widgets/proposal_item_card_widget.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
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

    return Scaffold(
      backgroundColor: isDark ? SimPropostaColors.darkBackground : SimPropostaColors.offWhite,
      appBar: AppBar(
        backgroundColor: isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              isDark ? 'assets/images/simproposta-logo-fundo-escuro-v2.png' : 'assets/images/simproposta-logo-fundo-claro-v2.png',
              height: 38,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/simproposta-logo-horizontal.png', height: 36);
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
                role == 'SUPER_ADMIN' ? 'SUPERVISOR' : (user?.companyName ?? 'EMPRESA'),
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
      body: Padding(
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
                      'Visão Geral — ${user?.name ?? "Usuário"}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textMain),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acordo Sólido — Confiança imediatamente visível.',
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
                        label: const Text('Cadastrar Nova Loja'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SimPropostaColors.supervisor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

            // Métricas em Cards
            BlocBuilder<ProposalsCubit, ProposalsState>(
              builder: (context, state) {
                int totalCount = 0;
                double totalValue = 0.0;

                if (state is ProposalsLoaded) {
                  totalCount = state.proposals.length;
                  totalValue = state.proposals.fold(0.0, (sum, item) => sum + item.totalValue);
                }

                return Row(
                  children: [
                    MetricCardWidget(
                      label: 'Total de Propostas Enviadas',
                      value: '$totalCount',
                      icon: Icons.description_outlined,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 16),
                    MetricCardWidget(
                      label: 'Faturamento em Negociação',
                      value: 'R\$ ${totalValue.toStringAsFixed(2)}',
                      icon: Icons.attach_money_rounded,
                      color: SimPropostaColors.mint,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            Text(
              'Propostas Comerciais Ativas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain),
            ),
            const SizedBox(height: 16),

            // Lista de Propostas
            Expanded(
              child: BlocBuilder<ProposalsCubit, ProposalsState>(
                builder: (context, state) {
                  if (state is ProposalsLoading) {
                    return Center(child: CircularProgressIndicator(color: primaryColor));
                  }
                  if (state is ProposalsError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: SimPropostaColors.error)));
                  }
                  if (state is ProposalsLoaded) {
                    if (state.proposals.isEmpty) {
                      return Container(
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
                      );
                    }

                    return ListView.builder(
                      itemCount: state.proposals.length,
                      itemBuilder: (context, index) {
                        final item = state.proposals[index];
                        return ProposalItemCardWidget(item: item);
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
