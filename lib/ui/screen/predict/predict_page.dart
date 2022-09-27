import 'package:arc/src/utils/bluetooth_utils.dart';
import 'package:flutter/material.dart';

class PredictPage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const PredictPage({this.checkAvailability = true, Key? key})
      : super(key: key);

  @override
  createState() => _PredictPage();
}

class _PredictPage extends State<PredictPage> {
  int predictTag = 6;
  var result = [
    "WALKING",
    "WALKING_UPSTAIRS",
    "WALKING_DOWNSTAIRS",
    "SITTING",
    "STANDING",
    "LAYING",
    "Nothing"
  ];

  @override
  void dispose() {
    BluetoothUtils.onListerPredict = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    BluetoothUtils.onListerPredict = (s) {
      setState(() {
        predictTag = s;
      });
    };
    BluetoothUtils.connectAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('辨識結果'),
      ),
      body: Center(
        child: Text(result[predictTag]),
      ),
    );
  }
}
