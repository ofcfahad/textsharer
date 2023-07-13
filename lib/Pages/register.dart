// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firedart/auth/user_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:textsharer/main.dart';
import '../Components/functions.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String apiUrl = dotenv.env['SERVER_URL'] ?? '';
  final dio = Dio();
  double progress = 0.5;
  String guideText = 'Please Wait!';
  bool isMobile = Platform.isAndroid;
  bool airplaneMode = false;
  bool wifi = false;
  bool mobileData = false;

  Future<void> setConnection() async {
    bool isAirplane = await checkConnection('airplane');
    bool isMobileData = await checkConnection('mobiledata');
    bool isWifi = await checkConnection('wifi');

    setState(() {
      airplaneMode = isAirplane;
      wifi = isWifi;
      mobileData = isMobileData;
    });
  }

  void setProgress(double value, String message) {
    setState(() {
      progress = value;
      guideText = message;
    });
  }

  void gotoHomePage() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void exitApp() async {
    exit(0);
  }

  void showErrorPopup(String message, [Widget customWidget = const Text('')]) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      text: message,
      widget: customWidget,
      backgroundColor: Colors.black,
      titleColor: Colors.white,
      textColor: Colors.white,
      onConfirmBtnTap: exitApp,
      barrierDismissible: false,
    );
  }

  Future<bool> setDeviceInfo(device_) async {
    try {
      Response response = await dio.post(
        '$apiUrl/getDeviceCustomData',
        data: {
          'documentId': device_.id,
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
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
      } else {
        return false;
      }
    } catch (e) {
      print('from setDeviceInfo: $e');
      showErrorPopup(
        'Something went wrong!',
        const Text(
          'Please try again later',
          style: TextStyle(color: Colors.white, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      );
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
        showErrorPopup('Something went wrong');
      }
    } catch (e) {
      print('from registerDevice: $e');
    }
  }

  void handleRefresh() async {
    await setConnection();
    Navigator.pop(context);
    authenticate();
  }

  void authenticateWithFirebase(
      String deviceId, String deviceName, int deviceIcon) async {
    try {
      bool connection = await checkInternetConnection();
      if (!connection) {
        showErrorPopup(
            'You`re not connected to Internet',
            isMobile
                ? Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Color(0xFFde0038)),
                                shape: MaterialStatePropertyAll(
                                    CircleBorder(side: BorderSide.none))),
                            onPressed: () {
                              handleInternetSettingsClick('wifi');
                            },
                            child: Icon(
                                wifi
                                    ? Icons.wifi_rounded
                                    : Icons.wifi_off_rounded,
                                color: wifi ? Colors.white : Colors.white54)),
                        ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Color(0xFFde0038)),
                                shape: MaterialStatePropertyAll(
                                    CircleBorder(side: BorderSide.none))),
                            onPressed: () {
                              handleInternetSettingsClick('mobiledata');
                            },
                            child: Icon(
                              mobileData
                                  ? Icons.e_mobiledata_rounded
                                  : Icons.mobiledata_off_rounded,
                              color: mobileData ? Colors.white : Colors.white54,
                            )),
                        ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Color(0xFFde0038)),
                                shape: MaterialStatePropertyAll(
                                    CircleBorder(side: BorderSide.none))),
                            onPressed: () {
                              handleInternetSettingsClick('airplane');
                            },
                            child: Icon(
                              airplaneMode
                                  ? Icons.airplanemode_active_rounded
                                  : Icons.airplanemode_inactive_rounded,
                              color:
                                  airplaneMode ? Colors.white : Colors.white54,
                            )),
                        ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Color(0xFFde0038)),
                                shape: MaterialStatePropertyAll(
                                    CircleBorder(side: BorderSide.none))),
                            onPressed: handleRefresh,
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  )
                : const Text(''));
        return;
      }
    } catch (e) {
      print(e);
    }

    String email = replaceSpacesWithUnderscores('$deviceName@textsharer.app');
    String password = deviceId.toString();
    try {
      setProgress(0.3, 'Checking for Device Record');
      await fireauth.signIn(email, password);
    } catch (e) {
      print('Authentication error: $e');
      setProgress(0.4, 'Device Record not found! Registering Device');
      registerDevice(deviceId, deviceName, deviceIcon);
      return;
    }
    User device = await fireauth.getUser();
    setProgress(0.8, 'Almost Done!');
    bool response = await setDeviceInfo(device);
    if (response) {
      setProgress(1, 'Device Authenticated');
      print('Authenticated Device: ${deviceInfo['deviceName']}');
      gotoHomePage();
    }
  }

  void authenticate() async {
    setProgress(0.02, 'Getting Device Info');
    final response = await getDeviceInfo();
    setProgress(0.1, 'Authenticating Device Info');
    authenticateWithFirebase(
        response['deviceId'], response['deviceName'], response['deviceIcon']);
  }

  @override
  void initState() {
    super.initState();
    authenticate();
    setConnection();
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
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(9999)),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  semanticsLabel: 'Progress Bar',
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}