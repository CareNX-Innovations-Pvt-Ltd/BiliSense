import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bili_sense/core/service/shared_prefs_service.dart';
import 'package:bili_sense/presentation/home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

void showMotherRegistrationDialog(BuildContext context) {
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final weightController = TextEditingController();
  final apgarController = TextEditingController();
  final dobController = TextEditingController();
  DateTime? selectedDOB;
  String gender = 'Male';
  final prefs = getIt<SharedPreferenceHelper>();

  Future<void> pickDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        selectedDOB = combinedDateTime;

        final formatted = DateFormat(
          'dd-MM-yyyy \'at\' hh:mm a',
        ).format(combinedDateTime);
        dobController.text = formatted;
      }
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(10),
            title: const Text('Register Mother & Newborn'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: 'Mother Name',
                      counterText: '',
                    ),
                    maxLength: 50,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-Z\s]+$'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: contactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      counterText: '',
                    ),
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: apgarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'APGAR Score',
                      counterText: '',
                    ),
                    maxLength: 5,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dobController,
                    readOnly: true,
                    onTap: () => pickDateTime(context),
                    decoration: const InputDecoration(
                      labelText: 'Child\'s DOB',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Gender:'),
                      Radio<String>(
                        value: 'Male',
                        groupValue: gender,
                        onChanged: (value) => setState(() => gender = value!),
                      ),
                      const Text('Male'),
                      Radio<String>(
                        value: 'Female',
                        groupValue: gender,
                        onChanged: (value) => setState(() => gender = value!),
                      ),
                      const Text('Female'),
                    ],
                  ),
                  TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      // Allows only digits and one decimal point
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      contactController.text.isNotEmpty &&
                      selectedDOB != null &&
                      apgarController.text.isNotEmpty &&
                      dobController.text.isNotEmpty &&
                      weightController.text.isNotEmpty) {
                    MotherModel motherModel = MotherModel(
                      motherName: nameController.text.trim(),
                      contact: contactController.text.trim(),
                      dob: selectedDOB!,
                      gender: gender,
                      weight: double.tryParse(weightController.text.trim()),
                      apgarScore: int.tryParse(apgarController.text.trim()),
                      doctorName: prefs.userModel.name,
                      doctorId: prefs.userModel.id,
                    );
                    context.read<HomeCubit>().registerNewborn(motherModel);
                    context.pop();
                    context.read<HomeCubit>().fetchRecent();
                  } else {}
                },
                child: const Text('Register'),
              ),
            ],
          );
        },
      );
    },
  );
}
