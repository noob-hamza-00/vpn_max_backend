// ignore_for_file: non_constant_identifier_names

import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class GetApps {
  static Future<List<AppInfo>> GetAllAppInfo() async {
    List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true, "");
    print(apps[0].name);
    return apps;
  }
}
