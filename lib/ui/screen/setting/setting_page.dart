import 'dart:typed_data';

import 'package:arc/debug/log/Log.dart';
import 'package:arc/src/utils/bluetooth_utils.dart';
import 'package:arc/ui/other/my_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingPage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const SettingPage({this.checkAvailability = true, Key? key})
      : super(key: key);

  @override
  createState() => _SettingPage();
}

class TaskInfo {
  bool enable;
  int delayUs;
  String name;
  int index;

  double get hz {
    if (delayUs == 0) {
      return 0;
    }
    return (1000000 / (delayUs / 400));
  }

  set hz(double s) {
    delayUs = 1000000 ~/ s * 400;
  }

  TaskInfo({
    required this.enable,
    required this.delayUs,
    required this.name,
    required this.index,
  });
}

class _SettingPage extends State<SettingPage> {
  static const int ASK_CMD_RESPOND = 0;
  static const int ASK_CMD_GET_TASK_INFO = 1;
  static const int ASK_CMD_SAVE_TASK_INFO = 2;

  bool ask = false;
  Uint8List askSend = Uint8List(0);
  bool save = true;
  bool saving = false;
  bool configSuccess = false;

  List<TaskInfo> taskInfo = [];

  void sendCmd() {
    BluetoothUtils.connection?.output
        .add(Uint8List.fromList(askSend + [0xd, 0xa]));
  }

  @override
  void initState() {
    super.initState();
    BluetoothUtils.onListerAsk = (s) {
      var cmd = s[0];
      s = s.sublist(1);
      switch (cmd) {
        case ASK_CMD_RESPOND:
          switch (s[0]) {
            case ASK_CMD_SAVE_TASK_INFO: //config success
              configSuccess = true;
              break;
            case 65:
              ask = true;
              Log.d("wait arc done");
              sendCmd();
              break;
          }
          break;
        case ASK_CMD_GET_TASK_INFO:
          Log.d("receive task name");
          var i = 0;
          while (i < s.length) {
            var sEnd = s.indexOf(0);
            var name = String.fromCharCodes(s.sublist(0, sEnd));
            var index = s[sEnd + 1];
            var enable = s[sEnd + 2];
            var buffer = Uint8List.fromList(
                [s[sEnd + 3], s[sEnd + 4], s[sEnd + 5], s[sEnd + 6]]).buffer;
            ByteData data = ByteData.view(buffer);
            int delay = data.getUint32(0, Endian.big);
            if (!taskInfo.map((e) => e.name).toList().contains(name)) {
              taskInfo.add(TaskInfo(
                enable: enable == 1,
                delayUs: delay,
                name: name,
                index: index,
              ));
            }
            taskInfo.sort((a, b) => a.index.compareTo(b.index));
            s = s.sublist(sEnd + 7);
          }
          setState(() {});
          break;
        case ASK_CMD_SAVE_TASK_INFO:
          break;
      }
    };
    BluetoothUtils.connectAddress()
        .then((value) => waitAsk([ASK_CMD_GET_TASK_INFO]));
  }

  waitAsk(List<int> cmd) async {
    askSend = Uint8List.fromList(cmd);
    ask = false;
    var waitTime = 10;
    while (!ask && waitTime > 0) {
      Log.d("waiting ask!");
      BluetoothUtils.connection?.output
          .add(Uint8List.fromList([0, 0xff, 0xff])); // Sending data
      await Future.delayed(const Duration(milliseconds: 100));
      waitTime--;
    }
    if (waitTime == 0) {
      MyToast.show("通訊錯誤");
    }
  }

  @override
  void dispose() {
    BluetoothUtils.onListerAsk = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task設定'),
        actions: [
          if (saving)
            Center(
              child: Row(
                children: const [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(
                    width: 16,
                  )
                ],
              ),
            ),
          if (!save)
            IconButton(
              onPressed: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  save = true;
                  saving = true;
                });
                List<int> sendData = [ASK_CMD_SAVE_TASK_INFO];
                for (var i in taskInfo) {
                  sendData += [i.enable ? 1 : 0];
                  sendData += [(i.delayUs >> 24) & 0xff];
                  sendData += [(i.delayUs >> 16) & 0xff];
                  sendData += [(i.delayUs >> 8) & 0xff];
                  sendData += [(i.delayUs) & 0xff];
                }
                waitAsk(sendData);
                var time = 10;
                configSuccess = false;
                while (!configSuccess && time > 0) {
                  await Future.delayed(const Duration(milliseconds: 100));
                  time--;
                }
                setState(() {
                  saving = false;
                });
                if (time == 0) {
                  MyToast.show("儲存失敗");
                  setState(() {
                    save = false;
                  });
                }
              },
              icon: const Icon(Icons.save_outlined),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: taskInfo.length,
        itemBuilder: (BuildContext context, int index) {
          var t = taskInfo[index];
          TextEditingController controller = TextEditingController();
          if (t.hz.toInt() == t.hz) {
            controller.text = t.hz.toInt().toString();
          } else {
            controller.text = t.hz.toStringAsFixed(1);
          }
          return Container(
            padding: const EdgeInsets.all(10),
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Text(t.name),
                ),
                Expanded(
                  flex: 3,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: controller,
                    onChanged: (s) {
                      t.hz = double.parse(s);
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      t.hz = double.parse(controller.text);
                      setState(() {
                        save = false;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Switch(
                    value: t.enable,
                    onChanged: (value) {
                      setState(() {
                        t.enable = !t.enable;
                        setState(() {
                          save = false;
                        });
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
