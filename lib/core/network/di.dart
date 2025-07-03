import 'package:bili_sense/core/service/auth_service.dart';
import 'package:bili_sense/core/service/bluetooth_service.dart';
import 'package:bili_sense/core/service/shared_prefs_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

void setupDependencyInjection() async {
  getIt.registerSingleton(BleBluetoothService());
  getIt.registerSingleton(FirebaseAuth.instance);
  getIt.registerSingleton(FirebaseFirestore.instance);
  getIt.registerSingleton(AuthService());
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferenceHelper>(SharedPreferenceHelper(prefs));
}
