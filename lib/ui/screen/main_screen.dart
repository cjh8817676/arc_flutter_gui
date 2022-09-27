import 'package:arc/ui/log_console/log_console.dart';
import 'package:arc/ui/other/my_toast.dart';
import 'package:arc/ui/screen/record/record_page.dart';
import 'package:arc/ui/screen/sensor/senser_chart_page.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../debug/log/Log.dart';
import 'bluetooth/discovery_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  final _pageController = PageController();
  int _currentIndex = 0;
  int _closeAppCount = 0;
  final List<Widget> _pageList = [
    const SensorChartPage(),  // 顯示感測器數據的頁面
    const RecordPage(),       // 紀錄資料用的頁面
    const LogConsole(),       // 執行資訊的頁面
    const DiscoveryPage(),    // 尋找藍芽設備的頁面
  ];

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build _MainScreenState');
    return WillPopScope(                // 一秒點擊2次返回，才會離開的app
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _buildPageView(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }
  //異步操作可以在等待另一個操作完成的同時 完成工作。
  Future<bool> _onWillPop() async {                      // Future: 非同步
    var canPop = Navigator.of(context).canPop();
    print(canPop);    // 一案返回，canPop 會變成 'False'
    // Log.d(canPop.toString());
    if (canPop) {
      print('正常');
      Navigator.of(context).pop();
      _closeAppCount = 0;
    } else {
      _closeAppCount++;
      MyToast.show("再按一次關閉");
      Future.delayed(const Duration(seconds: 2)).then((_) {
        _closeAppCount = 0;
      });
    }
    return (_closeAppCount >= 2);
  }

  Widget _buildPageView() {          // 建立被顯示的Page (page也是widget) (1個widget 4 個page)
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      physics: const NeverScrollableScrollPhysics(),
      children: _pageList, // 禁止滑動
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: _onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            EvaIcons.gridOutline,
          ),
          label: "數據",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            EvaIcons.edit2Outline,
          ),
          label: "錄製",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            EvaIcons.infoOutline,
          ),
          label: "紀錄",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            EvaIcons.bluetoothOutline,
          ),
          label: "連接",
        ),
      ],
    );
  }

  void _onTap(int index) {
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {  // page變化就會設定現在顯示的page的index
    setState(() {
      _currentIndex = index;
    });
  }
}
