import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';

class AuthRemoteDatasource {
  // URL Oficial em Produção (Locaweb / Render API)
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.simproposta.com.br/api',
  );
  
  static const String _tokenKey = 'simproposta_jwt_token';

  /// Dispara a autenticação por e-mail e senha integrada ao Supabase Auth + API Node.js
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;
        final user = UserEntity.fromJson(data['user']);

        await saveToken(token);

        return {
          'token': token,
          'user': user,
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Credenciais inválidas');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        throw Exception('Servidor offline. Verifique a conexão com a API SimProposta.');
      }
      rethrow;
    }
  }

  /// Valida o token de sessão do Supabase / API e recupera o perfil atualizado do usuário
  Future<UserEntity?> fetchProfileWithToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserEntity.fromJson(data['user']);
      } else {
        await clearToken();
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// Salva o token de acesso na memória local do navegador (SharedPreferences)
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Recupera o token de acesso salvo
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Apaga o token de acesso e encerra a sessão (Logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
