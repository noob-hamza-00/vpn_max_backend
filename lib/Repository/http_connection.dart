// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../Model/model.dart';
import '../providers/vpn_provider.dart';class HttpConnection {
  final BuildContext context;

  VpnProvider? vpnProvider;

  HttpConnection(this.context) {
    vpnProvider = VpnProvider.instance(context);
  }

  String paramsToString(Map<String, String>? params) {
    if (params == null) return "";
    String output = "?";
    params.forEach((key, value) {
      output += "$key=$value&";
    });
    return output.substring(0, output.length - 1);
  }
}

class ApiResponse<T> extends Model {
  ApiResponse({
    this.success,
    this.message,
    this.data,
  });

  bool? success;
  String? message;
  T? data;

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        success: json["success"] ?? false,
        message: json["message"],
        data: json["data"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data,
      };
}
