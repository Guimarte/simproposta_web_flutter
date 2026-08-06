import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/proposal_entity.dart';

class ProposalRemoteDatasource {
  // URL Oficial em Produção (Locaweb / Render API) — SimAprova
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.simaprova.com.br/api',
  );

  Future<List<ProposalEntity>> getProposals(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/proposals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List proposalsJson = data['proposals'];
      return proposalsJson.map((json) => ProposalEntity.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar propostas');
    }
  }

  Future<void> createProposal(String token, Map<String, dynamic> proposalData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/proposals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(proposalData),
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao cadastrar proposta');
    }
  }
}
