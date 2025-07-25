import 'package:bili_sense/core/constants/app_constants.dart';
import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/models/user_model.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bili_sense/core/service/shared_prefs_service.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  final FirebaseFirestore _firestore = getIt<FirebaseFirestore>();
  final _prefs = getIt<SharedPreferenceHelper>();
  List<MotherModel> recentTests = [];

  int totalTests = 0;
  int totalNewborns = 0;

  init() {
    fetchRecent();
  }


  fetchRecent() async {
    emit(HomeLoading());
    UserModel userModel = _prefs.userModel;
    try {
      final result =
          await _firestore
              .collection(AppConstants.userCollection)
              .where('type', isEqualTo: 'newborn')
              .where('doctorId', isEqualTo: userModel.id)
              .orderBy('createdAt', descending: true)
              .limit(3)
              .get();

      recentTests =
          result.docs
              .map((doc) => MotherModel.fromJson(doc.data(), id: doc.id))
              .toList();

      totalTests = await _firestore
          .collection(AppConstants.testsCollection)
          .where('doctorId', isEqualTo: userModel.id)
          .get()
          .then((value) => value.docs.length);

      totalNewborns = await _firestore
          .collection(AppConstants.userCollection)
          .where('type', isEqualTo: 'newborn')
          .where('doctorId', isEqualTo: userModel.id)
          .get()
          .then((value) => value.docs.length);

      emit(
        HomeLoaded(
          recentTests: recentTests,
          totalTests: totalTests.toString(),
          totalNewborns: recentTests.length.toString(),
        ),
      );
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  registerNewborn(MotherModel motherModel) async {
    try {
      await _firestore.collection('users').add({
        'motherName': motherModel.motherName,
        'contact': motherModel.contact,
        'dob': motherModel.dob,
        'gender': motherModel.gender,
        'doctor': motherModel.doctorName,
        'doctorId': motherModel.doctorId,
        'weight': motherModel.weight,
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'newborn',
        'apgarScore': motherModel.apgarScore,
      });
      emit(
        HomeLoaded(
          recentTests: recentTests,
          totalTests: totalTests.toString(),
          totalNewborns: recentTests.length.toString(),
        ),
      );
      emit(HomeNavigationState(motherModel: motherModel));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
