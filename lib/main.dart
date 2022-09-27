import 'dart:async';

import 'package:arc/debug/log/Log.dart';
import 'package:arc/src/config/app_themes.dart';
import 'package:arc/ui/screen/main_screen.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';

void main() async {
  const items = ['Salad', 'Popcorn', 'Toast', 'Lasagne'];
  var foundItem4 = items.firstWhere(
        (item) => item.length > 10,
    orElse: () => 'None!',
  );
  print(foundItem4);
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(milliseconds: 200));
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runZonedGuarded(() {
    runApp(
      const MyApp(),
    );
  }, (dynamic exception, StackTrace stack, {dynamic context}) {
    Log.error(exception.toString(), stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "ARC",
      builder: BotToastInit(),
      theme: AppThemes.darkTheme,
      navigatorObservers: [
        BotToastNavigatorObserver(),
      ],
      home: const MainScreen(),
      logWriterCallback: (String text, {bool? isError}) {
        Log.d(text);
      },
    );
  }
}


