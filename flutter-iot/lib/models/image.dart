import 'package:intl/intl.dart';

class DataImage {
  int time;
  int deviceId;
  String description;
  String unit;
  String code;
  int value;

  DataImage(
      {required this.time,
      required this.deviceId,
      this.description = "",
      this.unit = "",
      required this.code,
      required this.value});

  // Constructor para manejar peticiones
  DataImage.fromJson(Map<String, dynamic> json)
      : time = json['time'] ?? 0,
        deviceId = json['device_id'] ?? 0,
        description = json['device_data']['description'] ?? "",
        unit = json['device_data']['unit'] ?? "",
        code = json['device_data']['code'] ?? "",
        value = json['device_data']['value_sensor'] ?? 0;

  String getFormattedDateTime() {
    // Utiliza el método DateFormat para personalizar la presentación de la fecha
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    return DateFormat('MM/dd HH:mm:ss').format(dateTime);
  }
}
