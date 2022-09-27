import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PickerDialog {
  static Future<T?> show<T>(String title, List<T> info) async {
    T value = info.first;
    T? select = await Get.dialog<T>(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<T>(
                        value: value,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        onChanged: (T? newValue) {
                          setState(() {
                            value = newValue as T;
                          });
                        },
                        items: info.map<DropdownMenuItem<T>>((T value) {
                          return DropdownMenuItem<T>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                )
              ],
            ),
            actions: [
              TextButton(
                  child: const Text("確定"),
                  onPressed: () {
                    Get.back<T>(result: value);
                  })
            ],
          );
        },
      ),
    );
    return select;
  }
}
