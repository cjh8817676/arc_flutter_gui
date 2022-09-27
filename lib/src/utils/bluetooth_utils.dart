import 'dart:typed_data';

import 'package:arc/src/model/sensor_data.dart';
import 'package:arc/ui/other/my_toast.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

typedef SensorCallback = void Function(OneSensorData);
typedef PredictCallback = void Function(int);
typedef LogCallback = void Function(String);
typedef AskCallback = void Function(List<int>);

class BluetoothUtils {
  static List<int> buffer = [];
  static BluetoothConnection? connection;
  static SensorCallback? onListenSensor;
  static PredictCallback? onListerPredict;
  static AskCallback? onListerAsk;
  static LogCallback? onListerLog;

  static Future<void> close() async {
    connection?.close();
  }

  static Future<void> disconnect() async {
    try {
      close();
      var i = await FlutterBluetoothSerial.instance.getBondedDevices();
      if (i.isNotEmpty) {
        var address = i.first.address;
        await FlutterBluetoothSerial.instance
            .removeDeviceBondWithAddress(address);
        await FlutterBluetoothSerial.instance
            .bondDeviceAtAddress(address, pin: "1234", passkeyConfirm: false);
      }
    } catch (e) {
      return;
    }
  }

  static Future<void> connectAddress() async {
    if (connection == null) {
      var i = await FlutterBluetoothSerial.instance.getBondedDevices();
      if (i.isEmpty) {
        MyToast.show("尚未連接裝置");
        return;
      }
      var address = i.first.address;
      try {
        connection = await BluetoothConnection.toAddress(address);
      } catch (e) {
        MyToast.show("連接裝置發生錯誤");
        return;
      }
      connection?.input!.listen((data) {
        handleData(data);
      }).onDone(() {
        MyToast.show("已斷開通訊");
        connection = null;
      });
    }
  }

  static handleData(
    Uint8List data,
  ) {
    buffer += data;
    int i = 0;
    while (i < buffer.length) {
      int lenBit = 6;                     // MAX_STR_LEN_BIT    6
      int mask = (1 << lenBit) - 1;
      int len = buffer[i] & mask;
      int cmd = buffer[i] >> lenBit;

      if (len > mask || len == 0) {
        i++;
        continue;
      }
      if (i + len + 1 >= buffer.length) {
        break;
      }
      if (len == buffer[i + len + 1]) {
        switch (cmd) {
          case 0:
            var s = buffer.sublist(i + 1, len + i + 1);
            if (onListerAsk != null) {
              onListerAsk!(s);
            }
            break;
          case 1:
            var s = OneSensorData(
              gXRaw: OneSensorData.toInt16(
                  Uint8List.fromList([buffer[i + 1], buffer[i + 2]])),
              gYRaw: OneSensorData.toInt16(
                  Uint8List.fromList([buffer[i + 3], buffer[i + 4]])),
              gZRaw: OneSensorData.toInt16(
                  Uint8List.fromList([buffer[i + 5], buffer[i + 6]])),
              aXRaw: OneSensorData.toInt16(
                  Uint8List.fromList([buffer[i + 7], buffer[i + 8]])),
              aYRaw: OneSensorData.toInt16(
                  Uint8List.fromList([buffer[i + 9], buffer[i + 10]])),
              aZRaw: OneSensorData.toInt16(
                  Uint8List.fromList([buffer[i + 11], buffer[i + 12]])),
              aRange: 1,
              gRange: 1,
            );
            if (onListenSensor != null) {
              onListenSensor!(s);
            }
            break;
          case 2:
            var s = buffer[i + 1];
            if (onListerPredict != null) {
              onListerPredict!(s);
            }
            break;
          case 3:
            var s = buffer.sublist(i + 1, len + i + 1);
            var k = String.fromCharCodes(s);
            if (k[k.length - 1] == "\n") {
              k = k.substring(0, k.length - 1);
            }
            if (onListerLog != null) {
              onListerLog!(k);
            }
            break;
        }
        i += (len + 2);
        continue;
      }
      i++;
    }
    buffer = buffer.sublist(i);
  }
}
