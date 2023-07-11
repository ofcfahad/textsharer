import 'package:flutter/material.dart';

class PopupMenu extends StatelessWidget {
  final IconData deviceIcon;
  final String deviceModel;
  const PopupMenu(
      {super.key, required this.deviceIcon, required this.deviceModel});

  @override
  Widget build(BuildContext context) {
    void handleDevicesClick() {
      Navigator.pushNamed(context, '/devices');
    }

    void handleHistoryClick() {
      Navigator.pushNamed(context, '/history');
    }

    return PopupMenuButton<int>(
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.white10),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      itemBuilder: (context) => [
        PopupMenuItem(
          textStyle: const TextStyle(color: Colors.amber),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                deviceIcon,
                color: Colors.amber,
              ),
              Expanded(
                child: Text(
                  deviceModel,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 1,
          // row with 2 children
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: Colors.black,
                size: 25,
              ),
              SizedBox(
                width: 10,
              ),
              Text("History")
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 2,
          // row with 2 children
          child: Row(
            children: [
              Icon(
                Icons.laptop_chromebook_outlined,
                color: Colors.black,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Paired Devices")
            ],
          ),
        ),
      ],
      offset: const Offset(0, 50),
      splashRadius: 90,
      color: Colors.white,
      // on selected we show the dialog box
      onSelected: (value) {
        // if value 1 show dialog
        if (value == 1) {
          handleHistoryClick();
          // if value 2 show dialog
        } else if (value == 2) {
          handleDevicesClick();
        }
      },
    );
  }
}
