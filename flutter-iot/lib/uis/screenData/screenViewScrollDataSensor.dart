import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iotflutter/models/sensor.dart';
import 'package:iotflutter/widgets/cardDataSensor.dart';

class ScreenViewDataSensor extends StatefulWidget {
  @override
  _ScreenViewDataSensorState createState() => _ScreenViewDataSensorState();
}

class _ScreenViewDataSensorState extends State<ScreenViewDataSensor> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> items = []; // Lista de elementos
  bool isLoading = false;
  DataSensor? lastEvaluatedKey;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchData(); // Realizar la primera consulta
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Se ha alcanzado el final de la lista
      if (!isLoading) {
        fetchData(); // Cargar más elementos
      }
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    const int pageSize = 15;

    var url =
        'https://brthu4f4ef.execute-api.us-east-2.amazonaws.com/items?pageSize=$pageSize';
    if (lastEvaluatedKey != null) {
      int? time = lastEvaluatedKey!.time;
      int? deviceId = lastEvaluatedKey!.deviceId;
      url += '&lastEvaluatedKey={"time":$time, "device_id":$deviceId}';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> newItems =
          jsonResponse.map((data) => DataSensor.fromJson(data)).toList();

      setState(() {
        if (lastEvaluatedKey == null) {
          items = newItems; // Para la primera consulta, reemplaza los elementos
        } else {
          items.addAll(
              newItems); // Para consultas posteriores, añade más elementos
        }
        lastEvaluatedKey = newItems.isNotEmpty ? newItems.last : null;
        isLoading = false;
      });
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paginación Personalizada'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: items.length + 1, // +1 para el indicador de carga
        itemBuilder: (context, index) {
          if (index < items.length) {
            return CardDataSensor(data: items[index]);
          } else {
            return _buildProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ScreenViewDataSensor(),
  ));
}
