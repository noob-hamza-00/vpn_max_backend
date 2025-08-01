class DeviceInfoModel {
  String androidId;
  String board;
  String bootloader;
  String brand;
  String device;
  String display;
  String hardware;
  String id;
  String isPhysicalDevice;
  String manufacturer;
  String model;
  String product;
  List<String> supported32BitAbis;
  List<String> supported64BitAbis;
  List<String> supportedAbis;
  String release;
  String sdkInt;

  DeviceInfoModel({
    required this.androidId,
    required this.board,
    required this.bootloader,
    required this.brand,
    required this.device,
    required this.display,
    required this.hardware,
    required this.id,
    required this.isPhysicalDevice,
    required this.manufacturer,
    required this.model,
    required this.product,
    required this.release,
    required this.sdkInt,
    required this.supported32BitAbis,
    required this.supported64BitAbis,
    required this.supportedAbis,
  });

  Map<String, dynamic> toMap() => {
        "androidId": androidId,
        "board": board,
        "bootloader": bootloader,
        "brand": brand,
        "device": device,
        "display": display,
        "hardware": hardware,
        "id": id,
        "model": model,
        "product": product,
        "isPhysicalDevice": isPhysicalDevice,
        "release": release,
        "sdkInt": sdkInt,
        "supported32BitAbis": supported32BitAbis,
        "supported64BitAbis": supported64BitAbis,
        "supportedAbis": supportedAbis,
      };
}
