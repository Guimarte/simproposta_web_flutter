import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/simproposta_colors.dart';
import 'modules/auth/cubit/auth_cubit.dart';
import 'modules/auth/cubit/auth_state.dart';
import 'modules/auth/data/datasources/auth_remote_datasource.dart';
import 'modules/auth/ui/views/login_view.dart';
import 'modules/proposals/cubit/proposals_cubit.dart';
import 'modules/proposals/data/datasources/proposal_remote_datasource.dart';
import 'modules/proposals/ui/views/dashboard_view.dart';

void main() {
  runApp(const SimAprovaApp());
}

class SimAprovaApp extends StatelessWidget {
  const SimAprovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authDatasource = AuthRemoteDatasource();
    final proposalDatasource = ProposalRemoteDatasource();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authDatasource)..checkAuthStatus(),
        ),
        BlocProvider<ProposalsCubit>(
          create: (context) => ProposalsCubit(proposalDatasource),
        ),
      ],
      child: MaterialApp(
        title: 'SimAprova SaaS — Acordo Sólido v2',
        debugShowCheckedModeBanner: false,
        theme: SimPropostaTheme.light,
        darkTheme: SimPropostaTheme.dark,
        themeMode: ThemeMode.system,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: SimPropostaColors.teal),
                ),
              );
            }
            if (state is Authenticated) {
              return const DashboardView();
            }
            return const LoginView();
          },
        ),
      ),
    );
  }
}
