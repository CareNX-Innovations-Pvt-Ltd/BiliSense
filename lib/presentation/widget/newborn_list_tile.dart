import 'package:bili_sense/core/models/mother_model.dart';
import 'package:bili_sense/core/util.dart';
import 'package:flutter/material.dart';

class NewbornListTile extends StatelessWidget {
  final MotherModel model;
  final void Function()? onTap;

  const NewbornListTile({super.key, required this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.teal,
                    radius: 24,
                    child: Text(
                      model.motherName.isNotEmpty
                          ? model.motherName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.motherName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("DOB: ${Utilities.formatDateTime(model.dob)}"),
                  Text("Gender: ${model.gender}"),
                  Text("Contact: ${model.contact}"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
