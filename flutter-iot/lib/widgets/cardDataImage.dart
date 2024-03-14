import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iotflutter/models/image.dart';

class CardDataImage extends StatelessWidget {
  final DataImage data;

  const CardDataImage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
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
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Device ID: ${data.deviceId.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    data.getFormattedDateTime(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Image.memory(
              Uint8List.fromList(base64Decode(data.description)),
              fit: BoxFit.cover,
            )
          ],
        ),
      ),
    );
  }
}
