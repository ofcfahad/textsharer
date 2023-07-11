import 'package:flutter/material.dart';
import 'package:textsharer/Components/appBar.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      appBar: BlurredAppBar(title: Text('History')),
      body: Center(
        child: Text(
          'History',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
