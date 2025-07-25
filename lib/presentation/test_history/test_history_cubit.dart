import 'package:bili_sense/core/constants/app_constants.dart';
import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'package:bili_sense/core/models/user_model.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bili_sense/core/service/shared_prefs_service.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'test_history_state.dart';

class TestHistoryCubit extends Cubit<TestHistoryState> {
  TestHistoryCubit() : super(TestHistoryInitial());

  List<TestModel> testHistory = [];

  final FirebaseFirestore _firestore = getIt<FirebaseFirestore>();
  final _prefs = getIt<SharedPreferenceHelper>();

  Future<void> fetchAllTests() async {
    if (testHistory.isNotEmpty) {
      emit(TestHistorySuccess(testHistory));
      return;
    }
    emit(TestHistoryLoading());
    UserModel userModel = _prefs.userModel;
    try {
      final results =
          await _firestore
              .collection(AppConstants.testsCollection)
              .orderBy('createdAt', descending: true)
              .where('doctorId', isEqualTo: userModel.id)
              .get();
      testHistory =
          results.docs.map((doc) => TestModel.fromJson(doc.data())).toList();

      emit(TestHistorySuccess(testHistory));
    } catch (e) {
      emit(TestHistoryError(e.toString()));
    }
  }

  Future<MotherModel> getMotherDetails(String motherName) async {
    UserModel userModel = _prefs.userModel;
    try {
      final results =
          await _firestore
              .collection(AppConstants.userCollection)
              .where('type', isEqualTo: 'newborn')
              .where('motherName', isNotEqualTo: motherName)
              .where('doctorId', isEqualTo: userModel.id)
              .get();
      return MotherModel.fromJson(
        results.docs.first.data(),
        id: results.docs.first.id,
      );
    } catch (e) {
      throw Exception('Failed to fetch mother details: $e');
    }
  }
}
