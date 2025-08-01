// ignore: file_names
// import 'package:package_info_plus/package_info_plus.dart';

// class GetPackageInfo {
//   static Future<PackageInfoModel> packageInfo() async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     String appName = packageInfo.appName;
//     String packageName = packageInfo.packageName;
//     String versionCode = packageInfo.version;
//     String buildNumber = packageInfo.buildNumber;

//     PackageInfoModel packageInfoModel = PackageInfoModel(
//         appName: appName,
//         packageName: packageName,
//         versionCode: versionCode,
//         buildNumber: buildNumber);

//     return packageInfoModel;
//   }
// }

class PackageInfoModel {
  String appName;
  String packageName;
  String versionCode;
  String buildNumber;

  PackageInfoModel(
      {required this.appName,
      required this.packageName,
      required this.versionCode,
      required this.buildNumber});
}
