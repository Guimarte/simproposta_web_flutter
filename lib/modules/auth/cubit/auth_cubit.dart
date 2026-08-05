import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/datasources/auth_remote_datasource.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRemoteDatasource _datasource;

  AuthCubit(this._datasource) : super(AuthInitial());

  /// Verifica se existe uma sessão ativa ao abrir a aplicação
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final token = await _datasource.getSavedToken();
      if (token == null || token.isEmpty) {
        emit(AuthUnauthenticated());
        return;
      }

      final user = await _datasource.fetchProfileWithToken(token);
      if (user != null) {
        emit(Authenticated(user: user, token: token));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  /// Realiza a autenticação de login
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final result = await _datasource.login(email, password);
      emit(Authenticated(
        user: result['user'],
        token: result['token'],
      ));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Realiza o logout e limpa os dados locais
  Future<void> logout() async {
    await _datasource.clearToken();
    emit(AuthUnauthenticated());
  }
}
