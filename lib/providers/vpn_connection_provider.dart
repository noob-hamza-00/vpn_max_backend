import 'package:flutter/material.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VpnConnectionProvider with ChangeNotifier {
  double radius = 0;
   bool _isInitialized = false;
bool _isConnected = false;

  bool _isChangingServer = false;

  bool get isChangingServer => _isChangingServer;

  void startServerChange() {
    _isChangingServer = true;
    notifyListeners();
  }

  void completeServerChange() {
    _isChangingServer = false;
    notifyListeners();
  }

  bool get isConnected => _isConnected;
   Future<void> saveVpnState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isConnected', _isConnected);
  }
  Future<void> restoreVpnState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isConnected = prefs.getBool('isConnected') ?? false;
   
    if (_isConnected) {
      initialize(); 
    }
  }
  void setRadius() {
    radius = 0.25;
    notifyListeners();
  }

  void resetRadius() {
    radius = 0;
    notifyListeners();
  }

  late OpenVPN engine;
  VpnStatus? status;
  VPNStage? stage;
  bool _init = true;

  bool getInitCheck() => _init;
  String defaultVpnUsername = "freeopenvpn";
  String defaultVpnPassword = "605196725";
  String config = "YOUR OPENVPN CONFIG HERE";

  void initialize() {
    if (!_isInitialized) {
      engine = OpenVPN(
        onVpnStatusChanged: (data) {
          status = data;
          notifyListeners();
        },
        onVpnStageChanged: (data, raw) {
          stage = data;
          notifyListeners();
        },
      );

      engine.initialize(
        groupIdentifier: "group.com.laskarmedia.vpn",
        providerBundleIdentifier:
         "id.laskarmedia.openvpn_flutter.OpenVPNFlutterPlugin",
        localizedDescription: "VPN by Nizwar",
        lastStage: (stage) {
          this.stage = stage;
          notifyListeners();
        },
        lastStatus: (status) {
          this.status = status;
          notifyListeners();
        },
      );

      _isInitialized = true; 
      notifyListeners();
    }
  }

  Future<void> initPlatformState(String ovpn, String country,
      List<String> _disallowList, String username, String pass) async {
    print("username $username");
    print("username $pass");
    config = ovpn;
    engine.connect(config, country,
        username: username,
        password: pass,
        bypassPackages: _disallowList,
        certIsRequired: true);
         _isConnected = true;
    notifyListeners();
    await saveVpnState();
  }
}
