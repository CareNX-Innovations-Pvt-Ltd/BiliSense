import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/presentation/home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void showMotherRegistrationDialog(BuildContext context) {
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final weightController = TextEditingController();
  DateTime? selectedDOB;
  String gender = 'Male';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(10),
            title: const Text('Register Mother and Newborn'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(labelText: 'Mother Name'),
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
                  Row(
                    children: [
                      const Text('Child\'s DOB: '),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
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

                              setState(() {
                                selectedDOB = combinedDateTime;
                              });
                            }
                          }
                        },
                        child: Text(
                          selectedDOB != null
                              ? '${selectedDOB!.day}/${selectedDOB!.month}/${selectedDOB!.year} ${selectedDOB!.hour.toString().padLeft(2, '0')}:${selectedDOB!.minute.toString().padLeft(2, '0')}'
                              : 'Select DOB & Time',
                        ),
                      ),
                    ],
                  ),
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
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
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
                      selectedDOB != null) {
                    context.read<HomeCubit>().registerNewborn(
                      MotherModel(
                        motherName: nameController.text.trim(),
                        contact: contactController.text.trim(),
                        dob: selectedDOB!,
                        gender: gender,
                        weight: double.tryParse(weightController.text.trim()),
                      ),
                    );
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
