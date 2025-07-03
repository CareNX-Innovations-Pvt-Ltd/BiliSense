part of 'mother_details_cubit.dart';

@immutable
sealed class MotherDetailsState {}

final class MotherDetailsInitial extends MotherDetailsState {}
final class MotherDetailsLoading extends MotherDetailsState {}
final class MotherDetailsSuccess extends MotherDetailsState {
 final List<TestModel> tests;

  MotherDetailsSuccess(this.tests);
}
final class MotherDetailsError extends MotherDetailsState {
  final String message;

  MotherDetailsError(this.message);
}
