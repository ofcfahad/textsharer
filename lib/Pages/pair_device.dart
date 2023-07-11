import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../Components/appbar.dart';

class PairDevice extends StatefulWidget {
  const PairDevice({super.key});

  @override
  State<PairDevice> createState() => _PairDeviceState();
}

class _PairDeviceState extends State<PairDevice> {
  Function p = (string) => {print(string)};
  String selectedNetwork = '';
  String deviceName = '';
  String deviceId = '';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      appBar: BlurredAppBar(
        title: Text('Device Pairing'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Available Networks:',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> getAvailableNetworks() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    final info = NetworkInfo();
    if (connectivityResult == ConnectivityResult.mobile) {
      p('I am connected to a mobile network.');
    } else if (connectivityResult == ConnectivityResult.wifi) {
      p('I am connected to a wifi network.');
      final wifiName = await info.getWifiName();
      p(wifiName);
    } else if (connectivityResult == ConnectivityResult.ethernet) {
      p('I am connected to a ethernet network.');
      final wifiName = await info.getWifiName();
      p(wifiName);
    } else if (connectivityResult == ConnectivityResult.vpn) {
      p('I am connected to a vpn network.');
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
    } else if (connectivityResult == ConnectivityResult.bluetooth) {
      p('I am connected to a bluetooth.');
    } else if (connectivityResult == ConnectivityResult.other) {
      p('I am connected to a network which is not in the above mentioned networks.');
    } else if (connectivityResult == ConnectivityResult.none) {
      p('I am not connected to any network.');
    }
    return [];
  }

  void pairDevices(String network, String name, String id) {
    // Implement the logic to pair the devices over Wi-Fi
    // You can use the selected network, device name, and device ID for the pairing process

    // Once pairing is successful, you can store the device information in Supabase
    storeDeviceInformation(name, id);
  }

  void storeDeviceInformation(String name, String id) {
    // Implement the Supabase client initialization and store the device information
    // Refer to the previous example code for initializing Supabase and storing data
  }
}
