import 'package:intl/intl.dart';

class DataImage2 {
  String description;
  String unit;
  String code;
  int value;

  DataImage2(
      {this.description = "",
      this.unit = "",
      required this.code,
      required this.value});

  // Constructor para manejar peticiones
  DataImage2.fromJson(Map<String, dynamic> json)
      : description = json['description'] ?? "",
        unit = json['unit'] ?? "",
        code = json['code'] ?? "",
        value = json['value_sensor'] ?? 0;

  // String getFormattedDateTime() {
  //   // Utiliza el método DateFormat para personalizar la presentación de la fecha
  //   DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
  //   return DateFormat('MM/dd HH:mm:ss').format(dateTime);
  // }
}
