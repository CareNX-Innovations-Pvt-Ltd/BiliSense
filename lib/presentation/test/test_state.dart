part of 'test_cubit.dart';

@immutable
sealed class TestState {}

final class TestInitial extends TestState {}
final class TestLoading extends TestState {}
final class TestSuccess extends TestState {
  final String message;

  TestSuccess({required this.message});
}
final class TestError extends TestState {
  final String message;

  TestError({required this.message});
}
