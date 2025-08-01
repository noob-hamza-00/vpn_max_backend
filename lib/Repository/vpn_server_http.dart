import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import '../Model/vpn_config.dart';
import '../Model/vpn_server.dart';
import '../providers/vpn_provider.dart';
import '../utils/environment.dart';
import 'http_connection.dart';
import 'package:http/http.dart' as http;

class VpnServerHttp extends HttpConnection {
  VpnServerHttp(BuildContext context) : super(context);

  Future<List<VpnServer>> getServers(String type) async {
    List<VpnServer> servers = [];
    Map<String, String> header = {'auth_token': 'wQLAYr4pe4Bl'};
    final res =
    await http.get(Uri.parse("${api}servers/$type"), headers: header);

    try {
      if (res.statusCode == 200) {
        var json = jsonDecode(res.body.toString());
        json = json['data'];

        for (final js in json) {
          final server = VpnServer.fromJson(js);
          servers.add(server);
        }

        // Shuffle the servers list before returning
        servers.shuffle(Random());
      } else {
        servers = [];
      }
      dev.log("_____________________________DATA_____________________________");
      dev.log(type);
    } catch (e) {
      servers = [];
      dev.log(e.toString());
    }
    return servers;
  }

  Future<VpnConfig?> getBestServer(BuildContext context) async {
    Map<String, String> header = {'auth_token': 'wQLAYr4pe4Bl'}; // ye lgaye hy
    final res =
        await http.get(Uri.parse("${api}servers/best"), headers: header);
    final vpn = VpnProvider.instance(context);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body.toString());
      // print("____________data_______________");
      // print(json);

      VpnConfig server = VpnConfig.fromJson(json["data"]);
      vpn.vpnConfig = server;
    }
    dev.log("__________________________________________");
    dev.log("Status for best api  : ${res.body.toString()}");
    return vpn.vpnConfig;
  }
}
