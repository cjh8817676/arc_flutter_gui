import "dart:math" show pi;
import 'dart:typed_data';

import 'package:arc/debug/log/Log.dart';

class OneSensorData {
  int gXRaw;
  int gYRaw;
  int gZRaw;
  int aXRaw;
  int aYRaw;
  int aZRaw;
  double aRange;
  double gRange;

  static int toInt16(Uint8List byteArray) {
    ByteBuffer buffer = byteArray.buffer;
    ByteData data = ByteData.view(buffer);
    int short = data.getInt16(0, Endian.big);
    return short;
  }

  OneSensorData.clone(OneSensorData object,
      {double aRange = 4, double gRange = 500})
      : this(
          gXRaw: object.gXRaw,
          gYRaw: object.gYRaw,
          gZRaw: object.gZRaw,
          aXRaw: object.aXRaw,
          aYRaw: object.aYRaw,
          aZRaw: object.aZRaw,
          aRange: aRange,
          gRange: gRange,
        );

  OneSensorData({
    required this.gXRaw,
    required this.gYRaw,
    required this.gZRaw,
    required this.aXRaw,
    required this.aYRaw,
    required this.aZRaw,
    required this.aRange,
    required this.gRange,
  });

  double get gX {
    return gXRaw * gRange / 32768.0 * pi / 180;
  }

  double get gY {
    return gYRaw * gRange / 32768.0 * pi / 180;
  }

  double get gZ {
    return gZRaw * gRange / 32768.0 * pi / 180;
  }

  double get aX {
    return aXRaw * aRange / 32768.0;
  }

  double get aY {
    return aYRaw * aRange / 32768.0;
  }

  double get aZ {
    return aZRaw * aRange / 32768.0;
  }

  OneSensorData operator +(covariant OneSensorData other) {
    return OneSensorData(
      aXRaw: aXRaw + other.aXRaw,
      aYRaw: aYRaw + other.aYRaw,
      aZRaw: aZRaw + other.aZRaw,
      gXRaw: gXRaw + other.gXRaw,
      gYRaw: gYRaw + other.gYRaw,
      gZRaw: gZRaw + other.gZRaw,
      aRange: aRange,
      gRange: gRange,
    );
  }

  OneSensorData operator -() {
    return OneSensorData(
      aXRaw: -aXRaw,
      aYRaw: -aYRaw,
      aZRaw: -aZRaw,
      gXRaw: -gXRaw,
      gYRaw: -gYRaw,
      gZRaw: -gZRaw,
      aRange: aRange,
      gRange: gRange,
    );
  }

  OneSensorData operator /(int other) {
    return OneSensorData(
      aXRaw: aXRaw ~/ other,
      aYRaw: aYRaw ~/ other,
      aZRaw: aZRaw ~/ other,
      gXRaw: gXRaw ~/ other,
      gYRaw: gYRaw ~/ other,
      gZRaw: gZRaw ~/ other,
      aRange: aRange,
      gRange: gRange,
    );
  }

  @override
  String toString() {
    return "g --> X:$gX Y:$gY Z:$gZ\n"
        "a --> X:$aX Y:$aY Z:$aZ";
  }
}

class SensorData {
  double gRange;
  double aRange;

  double get showGRange {
    return gRange * pi / 180;
  }

  double get showARange {
    return aRange;
  }

  SensorData({this.aRange = 4, this.gRange = 500});

  final OneSensorData zero = OneSensorData(
    aXRaw: 0,
    aYRaw: 0,
    aZRaw: 0,
    gXRaw: 0,
    gYRaw: 0,
    gZRaw: 0,
    aRange: 1,
    gRange: 1,
  );
  List<OneSensorData> data = [];
  int max = 100;

  void add(OneSensorData s) {
    data.add(OneSensorData.clone(s, aRange: aRange, gRange: gRange));
    if (data.length >= max) {
      data = data.sublist(data.length - max + 1);
    }
  }

  void printMax() {
    if (data.isEmpty) {
      return;
    }
    var max = OneSensorData.clone(data.first);
    var min = OneSensorData.clone(data.first);
    for (var i in data) {
      if (i.aXRaw > max.aXRaw) {
        max.aXRaw = i.aXRaw;
      }
      if (i.aYRaw > max.aYRaw) {
        max.aYRaw = i.aYRaw;
      }
      if (i.aZRaw > max.aZRaw) {
        max.aZRaw = i.aZRaw;
      }
      if (i.gXRaw > max.gXRaw) {
        max.gXRaw = i.gXRaw;
      }
      if (i.gYRaw > max.gYRaw) {
        max.gYRaw = i.gYRaw;
      }
      if (i.gZRaw > max.gZRaw) {
        max.gZRaw = i.gZRaw;
      }

      if (i.aXRaw > min.aXRaw) {
        min.aXRaw = i.aXRaw;
      }
      if (i.aYRaw > min.aYRaw) {
        min.aYRaw = i.aYRaw;
      }
      if (i.aZRaw > min.aZRaw) {
        min.aZRaw = i.aZRaw;
      }
      if (i.gXRaw > min.gXRaw) {
        min.gXRaw = i.gXRaw;
      }
      if (i.gYRaw > min.gYRaw) {
        min.gYRaw = i.gYRaw;
      }
      if (i.gZRaw > min.gZRaw) {
        min.gZRaw = i.gZRaw;
      }
    }
    Log.d("aX: ${max.aX.toStringAsFixed(6)}  "
        "aY: ${max.aY.toStringAsFixed(6)}  "
        "aZ: ${max.aZ.toStringAsFixed(6)}  "
        "gX: ${max.gX.toStringAsFixed(6)}  "
        "gY: ${max.gY.toStringAsFixed(6)}  "
        "gZ: ${max.gZ.toStringAsFixed(6)}\n"
        "aX: ${min.aX.toStringAsFixed(6)}  "
        "aY: ${min.aY.toStringAsFixed(6)}  "
        "aZ: ${min.aZ.toStringAsFixed(6)}  "
        "gX: ${min.gX.toStringAsFixed(6)}  "
        "gY: ${min.gY.toStringAsFixed(6)}  "
        "gZ: ${min.gZ.toStringAsFixed(6)}");
  }
}
