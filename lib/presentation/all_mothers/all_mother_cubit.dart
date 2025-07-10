import 'package:bili_sense/core/constants/app_constants.dart';
import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bili_sense/core/service/shared_prefs_service.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'all_mother_state.dart';

class AllMotherCubit extends Cubit<AllMotherState> {
  AllMotherCubit() : super(AllMotherInitial());

  final FirebaseFirestore _firestore = getIt<FirebaseFirestore>();
  List<MotherModel> recentTests = [];
  final prefs = getIt<SharedPreferenceHelper>();

  init() {
    _fetchAllNewborns();
  }

  /// Fetches all newborns from Firestore and emits the results.
  _fetchAllNewborns() async {
    String doctorId = prefs.userModel.id;
    emit(AllMotherInitial());
    try {
      final result =
          await _firestore
              .collection(AppConstants.userCollection)
              .where('type', isEqualTo: 'newborn')
              .where('doctorId', isEqualTo: doctorId)
              .orderBy('createdAt', descending: true)
              .get();

      recentTests =
          result.docs
              .map((doc) => MotherModel.fromJson(doc.data(), id: doc.id))
              .toList();

      emit(AllMotherSuccess(mothers: recentTests));
    } catch (e) {
      emit(AllMotherError(message: e.toString()));
    }
  }

  /// Searches mothers by name and emits the results.
  void searchMothers(String query) {
    if (query.isEmpty) {
      emit(AllMotherSuccess(mothers: recentTests));
      return;
    }

    final filteredMothers = recentTests
        .where((mother) => mother.motherName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    emit(AllMotherSuccess(mothers: filteredMothers));
  }


}
