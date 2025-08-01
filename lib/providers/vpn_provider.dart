import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Model/vpn_config.dart';

class VpnProvider extends ChangeNotifier {
  VpnConfig? _vpnConfig;

  set vpnConfig(VpnConfig? vpnConfig) {
    _vpnConfig = vpnConfig;
    print("get best");
    notifyListeners();
  }

  VpnConfig? get vpnConfig => _vpnConfig;

  static VpnProvider instance(BuildContext context) =>
      Provider.of(context, listen: false);
}
