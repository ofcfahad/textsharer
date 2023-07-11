import 'package:flutter/material.dart';
import 'package:textsharer/Components/appbar.dart';
import '../main.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  bool floatingButtonIsHovering = false;
  List devices = ['remember'];

  void addNewDevice() {
    Navigator.pushNamed(context, '/pair-device');
  }

  Future<void> getDevicesData() async {
    final response = firestore
        .collection('/paired-devices')
        .where('paired_with', isEqualTo: deviceInfo['deviceId']);
    print(response.runtimeType);
  }

  void doSomething(Map<String, String> device) {
    print(device['device_name']);
  }

  @override
  void initState() {
    super.initState();

    getDevicesData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BlurredAppBar(title: Text('Paired Devices')),
      backgroundColor: Colors.transparent,
      body: devices.isNotEmpty
          ? ListView(
              children: devices
                  .map((device) =>
                      Text(device, style: const TextStyle(color: Colors.white)))
                  .toList(),
            )
          : const Center(
              child: Text('No Devices Paired Yet',
                  style: TextStyle(color: Colors.white)),
            ),
      floatingActionButton: InkWell(
        onTap: () {
          // Add your desired action when the FAB is tapped
        },
        onHover: (value) {
          setState(() {
            floatingButtonIsHovering = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: floatingButtonIsHovering ? 200.0 : 56.0,
          height: 56.0,
          child: FloatingActionButton.extended(
              onPressed: addNewDevice,
              label: floatingButtonIsHovering
                  ? const Text('Add Device')
                  : const Icon(Icons.add)),
        ),
      ),
    );
  }
}
