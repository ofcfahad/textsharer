import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firedart/auth/user_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:restart_app/restart_app.dart';
import 'package:textsharer/main.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String apiUrl = dotenv.env['SERVER_URL'] ?? '';
  final dio = Dio();
  double progress = 0;
  String guideText = 'Please Wait!';
  bool failedtoCreateUser = true;

  void goToHomePage() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  String replaceSpacesWithUnderscores(String input) {
    return input.replaceAll(' ', '_');
  }

  Future<bool> setDeviceInfo(device_) async {
    try {
      final response = await dio.post('$apiUrl/getDeviceCustomData', data: {
        'documentId': device_.id,
      });
      Map<String, dynamic> device = {
        'deviceId': response.data['deviceId'],
        'username': device_.email,
        'deviceName': device_.displayName,
        'deviceIcon': response.data['deviceIcon']
      };
      setState(() {
        deviceInfo = device;
      });
      return true;
    } catch (e) {
      print('from setDeviceInfo: $e');
      return false;
    }
  }

  void registerDevice(
      String deviceId, String deviceName, int deviceIcon) async {
    try {
      final response = await dio.post('$apiUrl/registerDevice', data: {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'deviceIcon': deviceIcon
      });
      if (response.statusCode == 200) {
        setProgress(0.5, 'Device Registered!');
        authenticateWithFirebase(deviceId, deviceName, deviceIcon);
      } else {
        setState(() {
          failedtoCreateUser = true;
        });
        showErrorPopup();
      }
    } catch (e) {
      print('from registerDevice: $e');
    }
  }

  void restartApp() async {
    Restart.restartApp();
  }

  void showErrorPopup() {
    if (failedtoCreateUser) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Sorry, something went wrong',
        backgroundColor: Colors.black,
        titleColor: Colors.white,
        textColor: Colors.white,
        onConfirmBtnTap: restartApp,
      );
    }
  }

  void authenticateWithFirebase(
      String deviceId, String deviceName, int deviceIcon) async {
    String email = replaceSpacesWithUnderscores('$deviceName@textsharer.app');
    String password = deviceId.toString();
    try {
      setProgress(0.3, 'Checking for Device Record');
      await fireauth.signIn(email, password);
    } catch (e) {
      print('Authentication error: $e');
      setProgress(0.4, 'Device Not Found! Registering Device');
      registerDevice(deviceId, deviceName, deviceIcon);
      return;
    }
    User device = await fireauth.getUser();
    bool response = await setDeviceInfo(device);
    if (response) {
      setProgress(1, 'Device Authenticated');
      print('Authenticated Device: ${deviceInfo['deviceName']}');
      goToHomePage();
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

  void authenticate() async {
    setProgress(0.02, 'Getting Device Info');
    final response = await getDeviceInfo();
    setProgress(0.1, 'Authenticating Device Info');
    authenticateWithFirebase(
        response['deviceId'], response['deviceName'], response['deviceIcon']);
  }

  void setProgress(double value, String message) {
    setState(() {
      progress = value;
      guideText = message;
    });
  }

  @override
  void initState() {
    super.initState();
    authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              guideText,
              style: const TextStyle(color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: LoadingAnimationWidget.bouncingBall(
                color: progress >= 0.5 ? Colors.greenAccent : Colors.white70,
                size: 20,
              ),
            ),
            SizedBox(
              width: 300,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                semanticsLabel: 'Progress Bar',
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Card buildButton({
  required onTap,
  required title,
  required text,
  required leadingImage,
}) {
  return Card(
    shape: const StadiumBorder(),
    margin: const EdgeInsets.symmetric(
      horizontal: 20,
    ),
    clipBehavior: Clip.antiAlias,
    elevation: 1,
    child: ListTile(
      onTap: onTap,
      leading: const CircleAvatar(
        child: Icon(Icons.error),
      ),
      title: Text(title ?? ""),
      subtitle: Text(text ?? ""),
      trailing: const Icon(
        Icons.keyboard_arrow_right_rounded,
      ),
    ),
  );
}
