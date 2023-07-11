import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:textsharer/Components/appbar.dart';
import 'package:textsharer/Components/popupmenu.dart';
import 'package:textsharer/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String deviceModel = 'Loading.....';
  bool showModel = false;
  IconData deviceIcon = Icons.developer_mode;
  TextEditingController value = TextEditingController();

  void getDeviceInfo() async {
    setState(() {
      deviceModel = deviceInfo['deviceName'] ?? '';
      if (deviceInfo['deviceIcon'] != null) {
        int icon = deviceInfo['deviceIcon'];
        IconData iconData = IconData(icon, fontFamily: 'MaterialIcons');
        deviceIcon = iconData;
      }
    });
  }

  void toggleDeviceModelVisibilty() {
    setState(() {
      showModel = !showModel;
    });
  }

  void handlePasteButtonClick() async {
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
    if (cdata != null && cdata.text != null && cdata.text!.isNotEmpty) {
      String copiedText = cdata.text!;
      setState(() {
        value.text = copiedText;
      });
    }
  }

  void handleClearButtonClick() {
    setState(() {
      value.text = '';
    });
  }

  void handleSendButton() async {}

  void sendText() async {
    print('yup');
  }

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: BlurredAppBar(
        title: const Text('text Sharer'),
        actions: [
          PopupMenu(
            deviceIcon: deviceIcon,
            deviceModel: deviceModel,
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          // Main content of the screen
          Container(
              // Add main content widgets here
              ),
          // Chat bar widget fixed at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  // Add your chat bar widgets here
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type something...',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.transparent),
                        shape: MaterialStatePropertyAll(
                            CircleBorder(side: BorderSide.none)),
                        padding: MaterialStatePropertyAll(
                            EdgeInsets.only(top: 3, left: 3)),
                        iconColor: MaterialStatePropertyAll(Colors.white24)),
                    onPressed: () {
                      print('yo mate!!');
                    },
                    child: const Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.send_rounded),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
