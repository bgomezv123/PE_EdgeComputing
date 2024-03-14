import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iotflutter/models/image.dart';
import 'package:http/http.dart' as http;
import 'package:iotflutter/widgets/cardDataImage.dart';

class ScreenViewDataImage extends StatelessWidget {
  const ScreenViewDataImage({super.key});

  Future<List<DataImage>> fetchData() async {
    var url = 'https://brthu4f4ef.execute-api.us-east-2.amazonaws.com/images';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => DataImage.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<List<DataImage>>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return CardDataImage(data: snapshot.data![index]);
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
