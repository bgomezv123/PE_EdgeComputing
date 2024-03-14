import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:iotflutter/models/sensor.dart';

// ignore: avoid_classes_with_only_static_members
class RemoteApi {
  static Future<List<DataSensor>> getSensorList(int limit, String time) async =>
      http
          .get(
            _ApiUrlBuilder.dataSensorList(limit, time),
          )
          .mapFromResponse<List<DataSensor>, List<dynamic>>(
            (jsonArray) => _parseItemListFromJsonArray(
              jsonArray,
              (jsonObject) => DataSensor.fromJson(jsonObject),
            ),
          );

  static List<T> _parseItemListFromJsonArray<T>(
    List<dynamic> jsonArray,
    T Function(dynamic object) mapper,
  ) =>
      jsonArray.map(mapper).toList();
}

class GenericHttpException implements Exception {}

class NoConnectionException implements Exception {}

// ignore: avoid_classes_with_only_static_members
class _ApiUrlBuilder {
  static const _baseUrl =
      'https://brthu4f4ef.execute-api.us-east-2.amazonaws.com/';
  static const _dataSensorResource = 'items';

  static Uri dataSensorList(int limit, String? time) =>
      Uri.parse('$_baseUrl$_dataSensorResource?'
          'pageSize=$limit'
          '&lastEvaluatedKey={"time":$time, "device_id":1}');
}

extension on Future<http.Response> {
  Future<R> mapFromResponse<R, T>(R Function(T) jsonParser) async {
    try {
      final response = await this;
      if (response.statusCode == 200) {
        return jsonParser(jsonDecode(response.body));
      } else {
        throw GenericHttpException();
      }
    } on SocketException {
      throw NoConnectionException();
    }
  }
}
