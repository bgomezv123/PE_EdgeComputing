import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iotflutter/models/image2.dart';

class CardDataImage2 extends StatelessWidget {
  final DataImage2 data;

  const CardDataImage2({super.key, required this.data});

  String _addLeadingZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8.0),
            Image.memory(
              Uint8List.fromList(base64Decode(data.description)),
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8.0),
            Text(
                "Tiempo: ${now.year}/${_addLeadingZero(now.month)}/${_addLeadingZero(now.day)} ${_addLeadingZero(now.hour)}:${_addLeadingZero(now.minute)}:${_addLeadingZero(now.second)}")
          ],
        ),
      ),
    );
  }
}
