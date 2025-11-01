import 'package:flutter/material.dart';

class AppConstants {
  static const bool isDebug = true;
  static const bool isSsl = isDebug ? false : true;
  static const bool mentionPort = isDebug ? true : false;
  static const String host = isDebug ? "localhost" : "kilnpilot-fastapi.onrender.com/";
  static const int port = 8000;
  static const String apiPath = "/api/v1";
  static const String baseUrl =
      "${isSsl ? "https" : "http"}://$host"
      "${mentionPort ? ":$port" : ""}"
      "$apiPath";
  static const String appName = "Kiln Pilot";
  static const Color seedColor = Colors.deepPurple;
}
