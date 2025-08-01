import 'package:installed_apps/app_info.dart';

class ApplicationModel {
  bool isSelected;
  AppInfo app;

  ApplicationModel({required this.isSelected, required this.app});

  ApplicationModel.fromJson(Map<String, dynamic> json)
      : isSelected = json['isSelected'],
        app = json['app'];

  static Map<String, dynamic> toJson(ApplicationModel model) => {
    "isSelected": model.isSelected,
    "app": model.app,
  };
}
