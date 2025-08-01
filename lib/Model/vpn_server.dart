import 'model.dart';

class VpnServer extends Model {
  VpnServer({
    required this.id,
    required this.ipAddress,
    required this.country,
    required this.countryCode,
    required this.ovpn,
    required this.ispro,
    required this.state,
  });

  late final int id;
  late final String ipAddress;
  late final String country;
  late final String countryCode;
  late final String ovpn;
  late final String ispro;
  late final String state;
  String? username;
  String? password;

  VpnServer.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    ipAddress = json['ip_address'];
    country = json['country'];
    countryCode = json['country_code'];
    ovpn = json['ovpn'];
    ispro = json['ispro'] ?? "0";
    state = json['state'];
    username = json['username'] ?? "";
    password = json['password'] ?? "";
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['ip_address'] = ipAddress;
    data['country'] = country;
    data['country_code'] = countryCode;
    data['ovpn'] = ovpn;
    data['ispro'] = ispro;
    data['state'] = state;
    data['username'] = username;
    data['password'] = password;
    return data;
  }

  bool isEmpty() {
    return id==0 || country.isEmpty;
  }
}
