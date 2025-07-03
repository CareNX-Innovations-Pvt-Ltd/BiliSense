import 'package:bili_sense/core/constants/app_constants.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
part 'test_state.dart';

class TestCubit extends Cubit<TestState> {
  TestCubit() : super(TestInitial());

  final firestore = getIt<FirebaseFirestore>();

  saveTest(TestModel test) async {
    emit(TestLoading());
    try {
      await firestore.collection(AppConstants.testsCollection).add({
        'createdAt': FieldValue.serverTimestamp(),
        'motherName': test.motherName,
        'dob': test.dob,
        'weight': test.weight,
        'bilirubinReading': test.bilirubinReading,
        'doctorName': test.doctorName,
        'readings': test.readings,
      });
      emit(TestSuccess(message: "Test saved successfully!"));
    } catch (e) {
      emit(TestError(message: e.toString()));
    }
  }



}
