import 'model.dart';

class VpnConfig extends Model {
  VpnConfig(
      {required this.id,
      required this.ipAddress,
      required this.country,
      required this.countryCode,
      required this.ovpn,
      required this.ispro,
      required this.state,
      this.username,
      this.password});
  late final int id;
  late final String ipAddress;
  late final String country;
  late final String countryCode;
  late final String ovpn;
  late final String ispro;
  late final String state;
  String? username;
  String? password;

  VpnConfig.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ipAddress = json['ip_address'];
    country = json['country'];
    countryCode = json['country_code'];
    ovpn = json['ovpn'];
    ispro = json['ispro'] ?? "0";
    state = json['state'] ?? "";
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
}
