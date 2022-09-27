import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'setting_page.dart';

class SettingIcon {
  static Widget action() {
    return IconButton(
      onPressed: () {
        Get.to(() => const SettingPage());
      },
      icon: const Icon(Icons.settings_outlined),
    );
  }
}
