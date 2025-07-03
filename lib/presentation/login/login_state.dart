part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String email;
  LoginSuccess(this.email);
}

class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
}