import 'package:bili_sense/core/constants/app_constants.dart';
import 'package:bili_sense/core/models/user_model.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bili_sense/core/service/auth_service.dart';
import 'package:bili_sense/core/service/shared_prefs_service.dart';
import 'package:bloc/bloc.dart' show Cubit;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;

  LoginCubit(this._authService) : super(LoginInitial());

  final prefs = getIt<SharedPreferenceHelper>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore firestore = getIt<FirebaseFirestore>();

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final user = await _authService.signInWithEmail(email, password);
      await firestore
          .collection(AppConstants.userCollection)
          .where('email', isEqualTo: email)
          .where('app', isEqualTo: 'bili_sense')
          .get()
          .then((value) {
            if (value.docs.isNotEmpty) {
              final userData = value.docs.first.data();
              prefs.setUserModel(UserModel.fromJson(userData));
            }
          });
      if (user != null) {
        prefs.setIsLoggedIn(true);
        emit(LoginSuccess(user.email!));
      } else {
        emit(LoginFailure("User not found"));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> register(String email, String password, String name) async {
    emit(LoginLoading());
    try {
      final user = await _authService.register(email, password);
      await firestore.collection(AppConstants.userCollection).add({
        'email': email,
        'name': name,
        'type': 'doctor',
        'app': 'bili_sense',
      });
      if (user != null) {
        prefs.setIsLoggedIn(true);
        prefs.setUserModel(UserModel(name: name, email: email));
        emit(LoginSuccess(user.email!));
      } else {
        emit(LoginFailure("Registration failed"));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
