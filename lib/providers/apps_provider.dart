import 'package:flutter/foundation.dart';
import '../Model/application_model.dart';

import '../utils/prefs.dart';

class AppsProvider extends ChangeNotifier {
  List<ApplicationModel> _apps = [];
  bool _loading = true;
  List<String> _disallowList = [];
  bool _isVpnConnected = false;

  bool get isVpnConnected => _isVpnConnected;

  void updateVpnConnectionState(bool isConnected) {
    _isVpnConnected = isConnected;
    notifyListeners();
  }
  
  List<ApplicationModel> get getAllApps => _apps;
  bool get isLoading => _loading;
  List<String> get getDisallowedList => _disallowList;
  Future<void> setDisallowList() async {
    final disallowList =
    await MySharedPreference.GetStringList("disallowedList");

    _disallowList = disallowList;
    notifyListeners();
  }

  void setAllApps(List<ApplicationModel> apps) {
    for (final item in _disallowList) {
      for (final app in apps) {
        if (item == app.app.packageName) {
          apps[apps.indexOf(app)].isSelected = false;
        }
      }
    }
    _apps = apps;
    notifyListeners();
  }

  void updateAppsList(String packageName, bool allow) async {
   
    if (!allow && !_disallowList.contains(packageName)) {
      _disallowList.add(packageName);
      MySharedPreference.SaveStringList("disallowedList", _disallowList);
    } else {
      if (_disallowList.contains(packageName)) {
        _disallowList.remove(packageName);
        MySharedPreference.SaveStringList("disallowedList", _disallowList);
      }
    }
    notifyListeners();
  }

  void updateLoader(bool value) {
    _loading = value;
    notifyListeners();

  }
}
