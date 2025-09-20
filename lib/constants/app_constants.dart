import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = "Kiln Pilot";
  static const bool isSsl = true;
  static const String host = "api.myflutterapp.com";
  static const String baseUrl = "${isSsl ? "https" : "http"}://$host";
  static const Color seedColor = Colors.deepPurple;
}