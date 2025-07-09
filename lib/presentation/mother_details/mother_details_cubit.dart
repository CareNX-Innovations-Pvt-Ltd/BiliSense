import 'package:bili_sense/core/constants/app_constants.dart';
import 'package:bili_sense/core/models/test_model.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'mother_details_state.dart';

class MotherDetailsCubit extends Cubit<MotherDetailsState> {
  MotherDetailsCubit() : super(MotherDetailsInitial());

  final firestore = getIt<FirebaseFirestore>();

  List<TestModel> tests = [];

  Future<void> fetchTests(String motherName) async {
    emit(MotherDetailsLoading());
    try {
      final result =
          await firestore
              .collection(AppConstants.testsCollection)
              .where('motherName', isEqualTo: motherName)
              .orderBy('createdAt', descending: true)
              .get();
      tests = result.docs.map((doc) => TestModel.fromJson(doc.data())).toList();
      emit(MotherDetailsSuccess(tests));
    } catch (e) {
      emit(MotherDetailsError('Failed to load tests'));
    }
  }
}
