import 'dart:ui';

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
  TextEditingController textController = TextEditingController();
  String textControllerValue = '';

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
        textController.text = copiedText;
      });
    }
  }

  void handleClearButtonClick() {
    setState(() {
      textController.text = '';
    });
  }

  void handleSendButton() async {
    print(textController.text);
  }

  void handleAddButton() async {
    print('*adds*');
  }

  void handleTextChange(value) {
    setState(() {
      textControllerValue = textController.text;
    });
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
        title: const Text('Text Sharer'),
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
          const Center(),
          Container(
              // Add main content widgets here
              ),
          // Chat bar widget fixed at the bottom
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black
                    .withOpacity(0.5), // Use a semi-transparent color
                padding: const EdgeInsets.all(2),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 5,
                      sigmaY: 5,
                    ),
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white10),
                              shape: MaterialStateProperty.all(
                                const CircleBorder(side: BorderSide.none),
                              ),
                              iconColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            onPressed: handleAddButton,
                            child: const Center(
                              child: SizedBox(
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            width: textControllerValue.isNotEmpty ? 250 : 200,
                            height: 35,
                            child: TextField(
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                              cursorColor: Colors.amberAccent,
                              decoration: const InputDecoration(
                                filled: true,
                                focusColor: Colors.amberAccent,
                                fillColor: Colors.white10,
                                hintText: 'Type something...',
                                hintStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                ),
                                contentPadding: EdgeInsets.only(left: 10),
                              ),
                              controller: textController,
                              onChanged: handleTextChange,
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  textControllerValue.isNotEmpty
                                      ? Colors.white10
                                      : Colors.transparent),
                              shape: MaterialStateProperty.all(
                                const CircleBorder(side: BorderSide.none),
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.only(top: 1, left: 2),
                              ),
                              iconColor: MaterialStateProperty.all(
                                textControllerValue.isNotEmpty
                                    ? Colors.white
                                    : Colors.white24,
                              ),
                            ),
                            onPressed: handleSendButton,
                            child: const Icon(
                              Icons.send_rounded,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
