import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bili_sense/core/service/shared_prefs_service.dart';
import 'package:bili_sense/presentation/home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

void showMotherRegistrationDialog(BuildContext context) {
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final weightController = TextEditingController();
  final apgarController = TextEditingController();
  final dobController = TextEditingController();
  DateTime? selectedDOB;
  String gender = '';
  final prefs = getIt<SharedPreferenceHelper>();

  Future<void> pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final fiveDaysAgo = now.subtract(const Duration(days: 5));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: fiveDaysAgo,
      lastDate: now,
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
      final _formKey = GlobalKey<FormState>(); // Add this
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(10),
            title: const Text('Register Mother & Newborn'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'Mother Name*',
                        counterText: '',
                      ),
                      maxLength: 50,
                      validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^[a-zA-Z\s]+$'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: contactController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number*',
                        counterText: '',
                      ),
                      maxLength: 10,
                      validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: apgarController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'APGAR Score*',
                        counterText: '',
                      ),
                      maxLength: 2,
                      validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dobController,
                      readOnly: true,
                      onTap: () async {
                        await pickDateTime(context);
                        setState(() {}); // trigger rebuild to reflect selectedDOB
                      },
                      decoration: const InputDecoration(
                        labelText: 'Child\'s DOB*',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) =>
                      selectedDOB == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Gender*:'),
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
                    if (gender.isEmpty)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 4.0, top: 4),
                          child: Text(
                            'Required',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)*',
                        counterText: '',
                      ),
                      maxLength: 4,
                      validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && gender.isNotEmpty && selectedDOB != null) {
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
                    Navigator.pop(context);
                    context.read<HomeCubit>().fetchRecent();
                  }
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
