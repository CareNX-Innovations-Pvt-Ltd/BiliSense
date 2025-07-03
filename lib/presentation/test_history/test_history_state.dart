part of 'test_history_cubit.dart';

@immutable
sealed class TestHistoryState {}

final class TestHistoryInitial extends TestHistoryState {}
final class TestHistoryLoading extends TestHistoryState {}
final class TestHistorySuccess extends TestHistoryState {
  final List<TestModel> testHistories;

  TestHistorySuccess(this.testHistories);
}
final class TestHistoryError extends TestHistoryState {
  final String message;

  TestHistoryError(this.message);
}
