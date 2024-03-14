import 'package:intl/intl.dart';

class DataSensor {
  int time;
  int deviceId;
  String description;
  String unit;
  String code;
  double valueSensor;

  // Contructor
  DataSensor(
      {required this.time,
      required this.deviceId,
      this.description = "",
      this.unit = "",
      required this.code,
      required this.valueSensor});

  // Constructor para manejar peticiones
  DataSensor.fromJson(Map<String, dynamic> json)
      : time = json['time'] ?? 0,
        deviceId = json['device_id'] ?? 0,
        description = json['device_data']['description'] ?? "",
        unit = json['device_data']['unit'] ?? "",
        code = json['device_data']['code'] ?? "",
        valueSensor = json['device_data']['value_sensor'] ?? 0;

  String getFormattedDateTime() {
    // Utiliza el método DateFormat para personalizar la presentación de la fecha
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    return DateFormat('MM/dd HH:mm:ss').format(dateTime);
  }
}
