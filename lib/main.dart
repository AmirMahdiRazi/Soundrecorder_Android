import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/pages/info_page.dart';
import 'package:project/pages/recorder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
          appBarTheme: AppBarTheme(
        elevation: 0.0,
        backgroundColor: Colors.teal,
      )),
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Voice Recorder')),
        ),
        body: Recordepage(),
      ),
    );
  }
}

class Recordepage extends StatefulWidget {
  const Recordepage({Key? key}) : super(key: key);

  @override
  State<Recordepage> createState() => _RecordepageState();
}

class _RecordepageState extends State<Recordepage> {
  int _currentIndex = 1;
  List<Widget> pages = const [
    SimpleRecorder(),
    InfoPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.white.withOpacity(0.5),
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.teal,
          animationDuration: const Duration(seconds: 2),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          height: 60.0,
          selectedIndex: _currentIndex,
          onDestinationSelected: (int newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
          },
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.record_voice_over),
              icon: Icon(Icons.record_voice_over_outlined),
              label: 'eco',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.info),
              icon: Icon(Icons.info_outlined),
              label: 'home',
            ),
          ],
        ),
      ),
    );
  }
}
