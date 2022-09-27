import 'dart:async';
import 'dart:io';

import 'package:arc/src/model/sensor_data.dart';
import 'package:arc/src/predict/tags.dart';
import 'package:arc/src/utils/bluetooth_utils.dart';
import 'package:arc/ui/other/my_toast.dart';
import 'package:arc/ui/screen/picker/picker_dialog.dart';
import 'package:arc/ui/screen/setting/setting_icon.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class SensorChartPage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.

  const SensorChartPage({Key? key}) : super(key: key);

  @override
  createState() => _SensorChartPage();
}

class _SensorChartPage extends State<SensorChartPage> {
  SensorData sensors = SensorData();
  int predictTag = 6;
  bool stopShow = false;
  bool raw = false;
  var predictResult = Tags.tags;
  bool startRecord = false;
  String fileName = "";

  @override
  void dispose() {                                 //離開此頁面，將讀到的資料清空
    BluetoothUtils.onListenSensor = null;
    BluetoothUtils.onListerPredict = null;
    super.dispose();
  }

  void saveRaw(OneSensorData s) async {
    if (startRecord) {
      var f = File(fileName);
      f.writeAsStringSync(
          "${s.aXRaw},${s.aYRaw},${s.aZRaw},${s.gXRaw},${s.gYRaw},${s.gZRaw}\n",
          mode: FileMode.append);
    }
  }

  @override
  void initState() {              // 移到此page時進行的初始化動作
    super.initState();
    Future.delayed(const Duration(microseconds: 10)).then((value) {
      BluetoothUtils.onListenSensor = (s) {
        setState(() {
          if (!stopShow) {
            sensors.add(s);
            saveRaw(s);
          }
        });
      };
      BluetoothUtils.onListerPredict = (s) {
        setState(() {
          predictTag = s;
          //sensors.printMax();
        });
      };
    });
    BluetoothUtils.connectAddress();             //連芽連接
  }

  LineChartData get accelerationData => LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          ),
        ),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 20,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              getTitlesWidget: leftTitleWidgets,
              showTitles: true,
              interval: sensors.showARange / 4,
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Color(0xff4e4965), width: 4),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
            top: BorderSide(color: Colors.transparent),
          ),
        ),
        lineBarsData: [accelerationDataX, accelerationDataY, accelerationDataZ],
        minX: 0,
        maxX: sensors.max.toDouble(),
        maxY: sensors.showARange,
        minY: -sensors.showARange,
      );

  LineChartData get gyroscopeData => LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          ),
        ),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 20,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              getTitlesWidget: leftTitleWidgets,
              showTitles: true,
              interval: sensors.showGRange / 4,
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Color(0xff4e4965), width: 4),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
            top: BorderSide(color: Colors.transparent),
          ),
        ),
        lineBarsData: [gyroscopeDataX, gyroscopeDataY, gyroscopeDataZ],
        minX: 0,
        maxX: sensors.max.toDouble(),
        maxY: sensors.showGRange,
        minY: -sensors.showGRange,
      );

  LineChartBarData get accelerationDataX => LineChartBarData(
        isCurved: false,
        color: Colors.red,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: sensors.data.asMap().entries.map<FlSpot>((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.aX);
        }).toList(),
      );

  LineChartBarData get accelerationDataY => LineChartBarData(
        isCurved: false,
        color: Colors.green,
        curveSmoothness: 0,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: sensors.data.asMap().entries.map<FlSpot>((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.aY);
        }).toList(),
      );

  LineChartBarData get accelerationDataZ => LineChartBarData(
        isCurved: false,
        color: Colors.blue,
        curveSmoothness: 0,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: sensors.data.asMap().entries.map<FlSpot>((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.aZ);
        }).toList(),
      );

  LineChartBarData get gyroscopeDataX => LineChartBarData(
        isCurved: false,
        color: Colors.red,
        curveSmoothness: 0,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: sensors.data.asMap().entries.map<FlSpot>((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.gX);
        }).toList(),
      );

  LineChartBarData get gyroscopeDataY => LineChartBarData(
        isCurved: false,
        color: Colors.green,
        curveSmoothness: 0,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: sensors.data.asMap().entries.map<FlSpot>((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.gY);
        }).toList(),
      );

  LineChartBarData get gyroscopeDataZ => LineChartBarData(
        isCurved: false,
        color: Colors.blue,
        curveSmoothness: 0,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: sensors.data.asMap().entries.map<FlSpot>((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.gZ);
        }).toList(),
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff75729e),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text = numberFormat(value);
    return Text(text, style: style, textAlign: TextAlign.center);
  }

  String numberFormat(double nn) {
    double n = nn.abs();
    String num = n.toStringAsFixed(2);
    int len = num.length;
    String s;
    if (n >= 1000 && n < 1000000) {
      s = '${num.substring(0, len - 3)}.${num.substring(len - 3, 1 + (len - 3))}k';
    } else if (n >= 1000000 && n < 1000000000) {
      s = '${num.substring(0, len - 6)}.${num.substring(len - 6, 1 + (len - 6))}m';
    } else if (n > 1000000000) {
      s = '${num.substring(0, len - 9)}.${num.substring(len - 9, 1 + (len - 9))}b';
    } else {
      s = num.toString();
    }
    if (nn < 0) {
      return "-$s";
    }
    return s;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff72719b),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        value.toInt().toString(),
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('圖表'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                raw = !raw;
              });
              if (raw) {
                sensors = SensorData(aRange: 1, gRange: 1);
              } else {
                sensors = SensorData();
              }
            },
            icon: Icon(raw ? Icons.raw_on_outlined : Icons.raw_off_outlined),
          ),
          startRecord
              ? IconButton(
                  onPressed: () async {
                    setState(() {
                      startRecord = false;
                    });
                  },
                  icon: const Icon(EvaIcons.stopCircleOutline))
              : IconButton(
                  onPressed: () async {
                    String? tag =
                        await PickerDialog.show<String>("請選擇動作", predictResult);
                    int? time = await PickerDialog.show<int>(
                        "請選擇紀錄時間(秒)，確定後將在3秒後開始", [5, 10, 20, 30, 60, 120, 180]);
                    if (time == null || tag == null) {
                      return;
                    }
                    final DateTime now = DateTime.now();
                    final DateFormat formatter =
                        DateFormat('yyyy_MM_dd_hh_mm_ss');
                    fileName = formatter.format(now);
                    var dir = await getExternalStorageDirectory();
                    fileName = "${dir!.path}/${tag}_$fileName.txt";
                    await Future.delayed(const Duration(seconds: 3));
                    MyToast.show("紀錄開始");
                    setState(() {
                      startRecord = true;
                    });
                    await Future.delayed(Duration(seconds: time));
                    MyToast.show("紀錄結束\n$fileName");
                    setState(() {
                      startRecord = false;
                    });
                  },
                  icon: const Icon(EvaIcons.playCircle)),
          IconButton(
            onPressed: () {
              setState(() {
                stopShow = !stopShow;
              });
            },
            icon: Icon(stopShow ? Icons.play_arrow : Icons.stop),
          ),
          SettingIcon.action(),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Center(
                child: Text(
                  predictResult[predictTag],
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("加速度"),
              Container(
                padding: const EdgeInsets.only(right: 10),
                height: MediaQuery.of(context).size.height / 3,
                child: LineChart(
                  accelerationData,
                  swapAnimationDuration: const Duration(milliseconds: 250),
                ),
              ),
              const Text("陀螺儀"),
              Container(
                padding: const EdgeInsets.only(right: 10),
                height: MediaQuery.of(context).size.height / 3,
                child: LineChart(
                  gyroscopeData,
                  swapAnimationDuration: const Duration(milliseconds: 250),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
