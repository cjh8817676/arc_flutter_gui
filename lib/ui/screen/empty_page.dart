import 'package:flutter/material.dart';

class EmptyPage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const EmptyPage({this.checkAvailability = true, Key? key}) : super(key: key);

  @override
  createState() => _EmptyPage();
}

class _EmptyPage extends State<EmptyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NULL'),
      ),
      body: const Center(child: Text("NULL")),
    );
  }
}
