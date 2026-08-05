import 'package:equatable/equatable.dart';
import '../domain/entities/proposal_entity.dart';

abstract class ProposalsState extends Equatable {
  const ProposalsState();

  @override
  List<Object?> get props => [];
}

class ProposalsInitial extends ProposalsState {}

class ProposalsLoading extends ProposalsState {}

class ProposalsLoaded extends ProposalsState {
  final List<ProposalEntity> proposals;

  const ProposalsLoaded(this.proposals);

  @override
  List<Object?> get props => [proposals];
}

class ProposalsError extends ProposalsState {
  final String message;

  const ProposalsError(this.message);

  @override
  List<Object?> get props => [message];
}
