import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iotflutter/models/image2.dart';
import 'package:iotflutter/mqtt/MqttConnection.dart';
import 'package:iotflutter/widgets/cardDataImage2.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

class MqttSubscribeScreen extends StatefulWidget {
  const MqttSubscribeScreen({Key? key}) : super(key: key);
  @override
  _MqttSubscribeScreenState createState() => _MqttSubscribeScreenState();
}

class _MqttSubscribeScreenState extends State<MqttSubscribeScreen> {
  MqttServerClient? mqttController;
  bool isConnected = false;
  // List<dynamic> dataImages = [];
  DataImage2? latestData;

  @override
  void initState() {
    super.initState();
    connect().then((value) {
      setState(() {
        mqttController = value;
        isConnected = true;
        subscribeToTopic(value, "video/data");
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
      appBar: AppBar(
        title: const Text('Real time images'),
      ),
      body: Center(
        child: latestData != null
            ? CardDataImage2(data: latestData!)
            : const CircularProgressIndicator(),
      ),
    );
  }

  void subscribeToTopic(MqttServerClient client, String topic) {
    try {
      client.subscribe(topic, MqttQos.atLeastOnce);
      client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt =
            MqttUtilities.bytesToStringAsString(recMess.payload.message!);
        var data = jsonDecode(pt);
        DataImage2 decodedData = DataImage2.fromJson(data);
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            latestData = decodedData;
          });
        });
      });
    } catch (e) {
      print('Exception during subscription: $e');
    }
  }
}
