part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<MotherModel> recentTests;
  final String totalTests;
  final String totalNewborns;

  HomeLoaded({required this.recentTests, required this.totalTests, required this.totalNewborns});
}

final class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});
}
