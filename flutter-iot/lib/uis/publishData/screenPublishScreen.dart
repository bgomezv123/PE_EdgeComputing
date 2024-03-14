import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iotflutter/mqtt/MqttConnection.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

class MqttPublishScreen extends StatefulWidget {
  const MqttPublishScreen({Key? key}) : super(key: key);
  @override
  _MqttPublishScreenState createState() => _MqttPublishScreenState();
}

class _MqttPublishScreenState extends State<MqttPublishScreen> {
  MqttServerClient? mqttController;
  TextEditingController messageController = TextEditingController();
  bool isConnected = false;
  final _colorNotifier = ValueNotifier(Colors.green);
  Color auxColorValue = Color(12);

  @override
  void initState() {
    super.initState();
    connect().then((value) {
      setState(() {
        mqttController = value;
        isConnected = true;
      });
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      mqttController!.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // decoration: BoxDecoration(color: Colors.white, boxShadow: [
                //   BoxShadow(
                //       color: Colors.grey.withOpacity(0.5),
                //       spreadRadius: 5,
                //       blurRadius: 7,
                //       offset: const Offset(0, 3)),
                // ]),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ValueListenableBuilder<Color>(
                    valueListenable: _colorNotifier,
                    builder: (_, color, __) {
                      return ColorPicker(
                        color: color,
                        onChanged: (value) {
                          color = value;
                          auxColorValue = value;
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final Map<String, dynamic> jsonMap = {
                    "on_off": 1,
                    "mode_led": 2,
                    "r": auxColorValue.red,
                    "g": auxColorValue.green,
                    "b": auxColorValue.blue
                  };

                  // Convertir el JSON a una cadena de texto
                  final String formatJSON = json.encode(jsonMap);
                  publishTopic(mqttController!, formatJSON, 'AWS/comand');
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
