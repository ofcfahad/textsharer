import 'dart:io';
import 'package:airplane_mode_checker/airplane_mode_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';

String replaceSpacesWithUnderscores(String input) {
  return input.replaceAll(' ', '_');
}

void handleInternetSettingsClick(reference) async {
  if (Platform.isAndroid) {
    if (reference == 'wifi') {
      OpenSettings.openWIFISetting();
    } else if (reference == 'mobiledata') {
      OpenSettings.openDataUsageSetting();
    } else if (reference == 'airplane') {
      OpenSettings.openAirplaneModeSetting();
    }
  } else {
    print('soon');
  }
}

Future<bool> checkConnection(reference) async {
  final connectivityResult = await (Connectivity().checkConnectivity());
  if (reference == 'mobiledata') {
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    }
    return false;
  } else if (reference == 'wifi') {
    if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  } else if (reference == 'airplane') {
    AirplaneModeStatus isAirplane =
        await AirplaneModeChecker.checkAirplaneMode();
    if (isAirplane == AirplaneModeStatus.on) {
      return true;
    }
    return false;
  } else {
    return false;
  }
}

Future<Map<String, dynamic>> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //Windows
  if (Platform.isWindows) {
    WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
    IconData icon = Icons.computer_rounded;
    Map<String, dynamic> data = {
      'os': 'Windows',
      'deviceId': windowsInfo.deviceId,
      'deviceName': windowsInfo.computerName,
      'deviceIcon': icon.codePoint
    };
    return data;
    //Android
  } else if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    IconData icon = Icons.phone_android;
    Map<String, dynamic> data = {
      'os': 'Android',
      'deviceId': androidInfo.id,
      'deviceName': androidInfo.model,
      'deviceIcon': icon.codePoint
    };
    return data;
    //Linux
  } else if (Platform.isLinux) {
    LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
    IconData icon = Icons.computer;
    Map<String, dynamic> data = {
      'os': 'Linux',
      'deviceId': linuxInfo.id,
      'deviceName': linuxInfo.name,
      'deviceIcon': icon.codePoint
    };
    return data;
  } else {
    return {'os': 'unknown device'};
  }
}

Future<bool> checkInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
    return false;
  } on SocketException catch (_) {
    return false;
  }
}
