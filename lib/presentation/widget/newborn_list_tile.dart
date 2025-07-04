import 'package:bili_sense/core/models/mother_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewbornListTile extends StatelessWidget {
  final MotherModel model;
  final void Function()? onTap;

  const NewbornListTile({super.key, required this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    String formatDateTime(DateTime dateTime) {
      final formatted = DateFormat('dd-MM-yyyy \'at\' HH:mm').format(dateTime);
      return formatted;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and ID row
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text(
                    model.motherName.isNotEmpty
                        ? model.motherName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontSize: 20),
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
                IconButton(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("DOB: ${formatDateTime(model.dob)}"),
                Text("Gender: ${model.gender}"),
                Text("Contact: ${model.contact}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
