import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/datasources/proposal_remote_datasource.dart';
import 'proposals_state.dart';

class ProposalsCubit extends Cubit<ProposalsState> {
  final ProposalRemoteDatasource _datasource;

  ProposalsCubit(this._datasource) : super(ProposalsInitial());

  Future<void> fetchProposals(String token) async {
    emit(ProposalsLoading());
    try {
      final proposals = await _datasource.getProposals(token);
      emit(ProposalsLoaded(proposals));
    } catch (e) {
      emit(ProposalsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> createProposal(String token, Map<String, dynamic> proposalData) async {
    try {
      await _datasource.createProposal(token, proposalData);
      await fetchProposals(token);
    } catch (e) {
      rethrow;
    }
  }
}
