import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/simproposta_colors.dart';
import '../../../../core/mixins/validation_mixin.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@simaprova.com.br');
  final _passwordController = TextEditingController(text: 'admin123');

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? SimPropostaColors.darkBackground : SimPropostaColors.offWhite,
      body: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: isDark ? SimPropostaColors.darkSurface : SimPropostaColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : SimPropostaColors.navy).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('⚠️ ${state.message}'),
                    backgroundColor: SimPropostaColors.error,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo V2 Oficial
                    Image.asset(
                      isDark ? 'assets/images/simproposta-logo-fundo-escuro-v2.png' : 'assets/images/simproposta-logo-fundo-claro-v2.png',
                      height: 54,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/images/simproposta-logo-horizontal.png', height: 50);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Acordo Sólido — Confiança Imediatamente Visível',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Alerta Inline de Erro de Autenticação
                    if (state is AuthError)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: SimPropostaColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SimPropostaColors.error.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: SimPropostaColors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                state.message,
                                style: const TextStyle(
                                  color: SimPropostaColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    TextFormField(
                      controller: _emailController,
                      validator: validateEmail,
                      style: TextStyle(color: isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'E-mail profissional',
                        labelStyle: TextStyle(color: isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary),
                        prefixIcon: Icon(Icons.email_outlined, color: isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal),
                        filled: true,
                        fillColor: isDark ? SimPropostaColors.darkSurfaceSubtle : SimPropostaColors.surfaceSubtle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _passwordController,
                      validator: (v) => validateNotEmpty(v, 'Senha'),
                      obscureText: true,
                      style: TextStyle(color: isDark ? SimPropostaColors.darkTextPrimary : SimPropostaColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Senha de acesso',
                        labelStyle: TextStyle(color: isDark ? SimPropostaColors.darkTextSecondary : SimPropostaColors.textSecondary),
                        prefixIcon: Icon(Icons.lock_outline, color: isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal),
                        filled: true,
                        fillColor: isDark ? SimPropostaColors.darkSurfaceSubtle : SimPropostaColors.surfaceSubtle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? SimPropostaColors.darkBorder : SimPropostaColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: state is AuthLoading ? null : _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? SimPropostaColors.darkPrimary : SimPropostaColors.teal,
                        foregroundColor: isDark ? SimPropostaColors.darkBackground : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: state is AuthLoading
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: isDark ? Colors.black : Colors.white, strokeWidth: 2))
                          : const Text(
                              'Entrar na Plataforma',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
