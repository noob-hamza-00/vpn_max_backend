import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceDetailProvider extends ChangeNotifier {
  AndroidDeviceInfo? androidInfo;
  String _uuid = "";

  String get uuid => _uuid;
  AndroidDeviceInfo? get deviceInfo => androidInfo;

  Future<void> getDeviceInfo(String id) async {
    try {
      androidInfo = await DeviceInfoPlugin().androidInfo;

      // Safely print known fields instead of raw `data`
      print("Device ID : ${androidInfo?.id ?? 'Unknown'}");
      print("Model: ${androidInfo?.model}");
      print("Brand: ${androidInfo?.brand}");
      print("Device: ${androidInfo?.device}");

      _uuid = id;
      notifyListeners();
    } catch (e, stack) {
      print("Error while fetching device info: $e");
      print(stack);
    }
  }
}

