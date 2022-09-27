import 'dart:async';
import 'dart:io';

import 'package:arc/src/config/app_colors.dart';
import 'package:arc/src/model/sensor_data.dart';
import 'package:arc/src/predict/tags.dart';
import 'package:arc/src/utils/bluetooth_utils.dart';
import 'package:arc/ui/other/my_toast.dart';
import 'package:arc/ui/screen/setting/setting_icon.dart';
import 'package:direct_select/direct_select.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class RecordPage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.

  const RecordPage({Key? key}) : super(key: key);

  @override
  createState() => _RecordPage();
}

var predictResult = Tags.tags;
var durationList = [5, 10, 20, 30, 60, 120, 180];
bool startRecord = false;
bool goingToRecord = false;
String fileName = "";

class _RecordPage extends State<RecordPage> {
  BluetoothConnection? connection;
  SensorData sensors = SensorData(aRange: 1, gRange: 1);
  int predictTag = 6;
  bool stopShow = false;
  bool raw = true;

  @override
  void dispose() {
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
  void initState() {
    super.initState();
    Future.delayed(const Duration(microseconds: 10)).then((value) {
      BluetoothUtils.onListenSensor = (s) {
        setState(() {
          if (!stopShow) {
            sensors.add(OneSensorData.clone(s, aRange: 1, gRange: 1));
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
    BluetoothUtils.connectAddress();
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
              interval: sensors.showARange / 2,
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
              interval: sensors.showGRange / 2,
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
        title: const Text('錄製'),
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
              const Text("加速度"),
              Container(
                padding: const EdgeInsets.only(right: 10),
                height: MediaQuery.of(context).size.height / 6,
                child: LineChart(
                  accelerationData,
                  swapAnimationDuration: const Duration(milliseconds: 250),
                ),
              ),
              const Text("陀螺儀"),
              Container(
                padding: const EdgeInsets.only(right: 10),
                height: MediaQuery.of(context).size.height / 6,
                child: LineChart(
                  gyroscopeData,
                  swapAnimationDuration: const Duration(milliseconds: 250),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const RecordTools(),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordTools extends StatefulWidget {
  const RecordTools({Key? key}) : super(key: key);

  @override
  State<RecordTools> createState() => _RecordToolsState();
}

class _RecordToolsState extends State<RecordTools> {
  final dataLabelOption = predictResult;
  final durationOption = durationList;
  int selectedLabel = 0;
  int selectedDuration = 0;
  String lastFullFileName = '';
  String lastFileName = '';

  List<Widget> _buildItems1() {
    return dataLabelOption
        .map((val) => MySelectionItem(
              title: val,
            ))
        .toList();
  }

  List<Widget> _buildItems2() {
    return durationOption
        .map((val) => MySelectionItem(
              title: val.toString(),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              "動作標籤",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          DirectSelect(
              itemExtent: 45.0,
              mode: DirectSelectMode.tap,
              selectedIndex: selectedLabel,
              backgroundColor: AppColors.darkAccent,
              selectionColor: const Color(0x882B2B2B),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedLabel = index!;
                });
              },
              items: _buildItems1(),
              child: MySelectionItem(
                isForList: false,
                title: dataLabelOption[selectedLabel],
              )),
          const Padding(
            padding: EdgeInsets.only(left: 10.0, top: 20.0),
            child: Text(
              "錄製時間(秒)",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          DirectSelect(
              itemExtent: 45.0,
              mode: DirectSelectMode.tap,
              selectedIndex: selectedDuration,
              backgroundColor: AppColors.darkAccent,
              selectionColor: const Color(0x882B2B2B),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedDuration = index!;
                });
              },
              items: _buildItems2(),
              child: MySelectionItem(
                isForList: false,
                title: durationOption[selectedDuration].toString(),
              )),
          Container(
            margin: EdgeInsets.only(
              top: 20,
              left: MediaQuery.of(context).size.width / 2 - 60,
              right: MediaQuery.of(context).size.width / 2 - 60,
            ),
            height: 100,
            width: 100,
            child: startRecord
                ? IconButton(
                    onPressed: () async {
                      setState(() {
                        startRecord = false;
                      });
                    },
                    icon: const Icon(
                      EvaIcons.stopCircleOutline,
                      size: 100,
                      color: Colors.red,
                    ))
                : IconButton(
                    onPressed: () async {
                      setState(() {
                        goingToRecord = true;
                      });
                      String tag = dataLabelOption[selectedLabel];
                      int time = durationOption[selectedDuration];
                      final DateTime now = DateTime.now();
                      final DateFormat formatter = DateFormat('yyyyMMddhhmmss');
                      fileName = formatter.format(now);
                      var dir = await getExternalStorageDirectory();
                      lastFileName = "${tag}_${time}_$fileName.txt";
                      fileName = "${dir!.path}/$lastFileName";
                      MyToast.show("1秒鐘後開始錄製");
                      await Future.delayed(const Duration(seconds: 1));
                      //MyToast.show("錄製開始");
                      setState(() {
                        startRecord = true;
                        goingToRecord = false;
                      });
                      await Future.delayed(Duration(seconds: time));
                      MyToast.show("錄製結束\n$fileName");
                      lastFullFileName = fileName;
                      //print(lastFullFileName);
                      setState(() {
                        startRecord = false;
                      });
                    },
                    icon: Icon(
                      EvaIcons.playCircle,
                      size: 100,
                      color: goingToRecord ? Colors.yellow : Colors.green,
                    )),
          ),
          Text(
            'Last Record:\n $lastFileName',
            style: const TextStyle(color: Colors.grey),
          ),
          TextButton(
              onPressed: startRecord
                  ? null
                  : () async {
                      MyToast.show("長按刪除");
                    },
              onLongPress: startRecord
                  ? null
                  : () async {
                      try {
                        //print(lastFullFileName);
                        await File(lastFullFileName).delete();
                        MyToast.show("$lastFileName已刪除");
                      } catch (e) {
                        MyToast.show("無法刪除");
                      }
                    },
              child: Text(
                '刪除',
                style: startRecord
                    ? const TextStyle(color: Colors.grey)
                    : const TextStyle(color: Colors.blue),
              )),
        ]);
  }
}

class MySelectionItem extends StatelessWidget {
  final String title;
  final bool isForList;

  const MySelectionItem({Key? key, required this.title, this.isForList = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.0,
      child: isForList
          ? Padding(
              child: _buildItem(context),
              padding: const EdgeInsets.all(10.0),
            )
          : Card(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                children: <Widget>[
                  _buildItem(context),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_drop_down),
                  )
                ],
              ),
            ),
    );
  }

  _buildItem(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
