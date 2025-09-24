import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = "Kiln Pilot";
  static const bool isSsl = false;
  static const bool mentionPort = true;
  static const String host = "localhost";
  static const int port = 8000;
  static const String apiPath = "/api/v1";
  static const String baseUrl =
      "${isSsl ? "https" : "http"}://$host:"
      "${mentionPort ? port : ""}"
      "$apiPath";
  static const Color seedColor = Colors.deepPurple;
}
