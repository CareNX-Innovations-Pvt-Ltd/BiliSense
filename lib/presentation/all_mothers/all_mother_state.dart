part of 'all_mother_cubit.dart';

@immutable
sealed class AllMotherState {}

final class AllMotherInitial extends AllMotherState {}
final class AllMotherLoading extends AllMotherState {}
final class AllMotherSuccess extends AllMotherState {
  final List<MotherModel> mothers;

  AllMotherSuccess({required this.mothers});
}
final class AllMotherError extends AllMotherState {
  final String message;

  AllMotherError({required this.message});
}
