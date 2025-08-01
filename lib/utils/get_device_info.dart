// ignore_for_file: non_constant_identifier_names
import 'package:device_info_plus/device_info_plus.dart';
import '../Model/device_info_model.dart';


class GetDeviceInfo {
  static Future<DeviceInfoModel> GetInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    DeviceInfoModel deviceInfoModel = DeviceInfoModel(
        androidId: androidInfo.id,
        board: androidInfo.board,
        bootloader: androidInfo.bootloader,
        brand: androidInfo.brand,
        device: androidInfo.device,
        display: androidInfo.display,
        hardware: androidInfo.hardware,
        id: androidInfo.id,
        isPhysicalDevice: androidInfo.isPhysicalDevice.toString(),
        manufacturer: androidInfo.manufacturer,
        model: androidInfo.model,
        product: androidInfo.product,
        release: androidInfo.version.release,
        sdkInt: androidInfo.version.sdkInt.toString(),
        supported32BitAbis: androidInfo.supported32BitAbis,
        supported64BitAbis: androidInfo.supported64BitAbis,
        supportedAbis: androidInfo.supportedAbis);

    return deviceInfoModel;
  }
}
