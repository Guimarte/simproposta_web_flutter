import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/simproposta_colors.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuperAdminReportWidget extends StatefulWidget {
  const SuperAdminReportWidget({super.key});

  @override
  State<SuperAdminReportWidget> createState() => _SuperAdminReportWidgetState();
}

class _SuperAdminReportWidgetState extends State<SuperAdminReportWidget> {
  bool _isLoading = true;
  List<dynamic> _companies = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAdminReport();
  }

  Future<void> _fetchAdminReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      const apiHost = String.fromEnvironment('API_HOST', defaultValue: 'https://api.simaprova.com.br');
      final response = await http.get(Uri.parse('$apiHost/api/admin/companies'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _companies = data['companies'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar relatório de clientes.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão ao carregar relatório.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain = isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.navy;
    final textSub = isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary;
    final supervisorColor = SimPropostaColors.supervisor;

    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: supervisorColor),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(_errorMessage, style: const TextStyle(color: SimPropostaColors.error)),
      );
    }

    int totalCompanies = _companies.length;
    int totalSellers = _companies.fold<int>(
      0,
      (sum, item) => sum + ((item['users'] as List?)?.length ?? 0),
    );
    int totalProposals = _companies.fold<int>(
      0,
      (sum, item) => sum + ((item['_count']?['proposals'] as num?)?.toInt() ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cards Administrativos
        Row(
          children: [
            _buildAdminCard(
              label: 'Clientes / Lojas Cadastradas',
              value: '$totalCompanies',
              icon: Icons.store_rounded,
              color: supervisorColor,
              isDark: isDark,
              textMain: textMain,
              textSub: textSub,
            ),
            const SizedBox(width: 16),
            _buildAdminCard(
              label: 'Total de Vendedores Ativos',
              value: '$totalSellers',
              icon: Icons.people_outline_rounded,
              color: SimPropostaColors.teal,
              isDark: isDark,
              textMain: textMain,
              textSub: textSub,
            ),
            const SizedBox(width: 16),
            _buildAdminCard(
              label: 'Volume Global de Propostas Emitidas',
              value: '$totalProposals',
              icon: Icons.description_outlined,
              color: SimPropostaColors.mint,
              isDark: isDark,
              textMain: textMain,
              textSub: textSub,
            ),
          ],
        ),
        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Relatório de Clientes SaaS & Utilização',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: _fetchAdminReport,
              tooltip: 'Atualizar Relatório',
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Tabela Executiva Administrativa
        Container(
          decoration: BoxDecoration(
            color: isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark ? SimPropostaColors.darkSurfaceSubtle : SimPropostaColors.surfaceSubtle,
              ),
              columns: [
                DataColumn(label: Text('NOME DA EMPRESA / CNPJ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textSub))),
                DataColumn(label: Text('STATUS DO PLANO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textSub))),
                DataColumn(label: Text('VENDEDORES (USO/LIMITE)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textSub))),
                DataColumn(label: Text('PROPOSTAS EMITIDAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textSub))),
              ],
              rows: _companies.map((company) {
                final users = company['users'] as List? ?? [];
                final proposalCount = company['_count']?['proposals'] ?? 0;
                final maxSellers = company['maxSellers'] ?? 5;
                final planStatus = company['planStatus'] ?? 'ACTIVE';

                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(company['name'] ?? 'Empresa', style: TextStyle(fontWeight: FontWeight.bold, color: textMain, fontSize: 14)),
                          Text(company['cnpj'] ?? 'CNPJ não informado', style: TextStyle(color: textSub, fontSize: 12)),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: planStatus == 'ACTIVE' ? SimPropostaColors.teal.withOpacity(0.15) : SimPropostaColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: planStatus == 'ACTIVE' ? SimPropostaColors.teal : SimPropostaColors.warning),
                        ),
                        child: Text(
                          planStatus == 'ACTIVE' ? '✓ Ativo' : '⏳ Pendente',
                          style: TextStyle(
                            color: planStatus == 'ACTIVE' ? SimPropostaColors.teal : SimPropostaColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text('${users.length} / $maxSellers vendedores', style: TextStyle(color: textMain, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: supervisorColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$proposalCount propostas',
                          style: TextStyle(color: supervisorColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color textMain,
    required Color textSub,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : SimPropostaColors.navy).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: textSub, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(color: textMain, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
