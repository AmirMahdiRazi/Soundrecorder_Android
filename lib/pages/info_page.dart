import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/data.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);
  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Color colour_button = Colors.lightBlueAccent;
  String result = 'اطلاعات ذخیره شد!';
  String detail_access = '';
  bool _btnActiveSTDN = false;
  bool visablewidget = false;
  bool access_storage = false;
  Color colour_text = Colors.white;
  final controllerFLName = TextEditingController();
  final controllerStdNum = TextEditingController();
  bool _data = false;

  @override
  void initState() {
    getaccess();
    checkInfo();

    if (directory_name != '') controllerStdNum.text = directory_name;

    super.initState();
  }

  void getaccess() async {
    var access = await Permission.manageExternalStorage.request();
    if (access == PermissionStatus.denied) {
      detail_access =
          'دسترسی به فایل ها داده نشده است\nلطفا از تنظیمات دسترسی فایل را بررسی کنید';
      _btnActiveSTDN = false;
      colour_text = Colors.red;
      return;
    }
    colour_text = Colors.green;
    detail_access = 'دسترسی داده شده است';
    access_storage = true;
  }

  void checkInfo() async {
    var location = File('storage/emulated/0/info.txt');
    var exi = await location.exists();
    if (exi) {
      var contents = await location.readAsString();
      if (contents != '') {
        var out = contents.split('\n');
        directory_name = out[0];

        controllerStdNum.text = directory_name;
        _data = true;
        colour_button = Colors.green;
        visablewidget = true;
        _btnActiveSTDN = true;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextFormField(
            textAlign: TextAlign.center,
            controller: controllerStdNum,
            textDirection: TextDirection.rtl,
            autofocus: true,
            maxLines: 1,
            maxLength: 10,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            textInputAction: TextInputAction.next,
            decoration:
                kTextFieldDecoration.copyWith(labelText: 'شماره دانشجویی'),
            keyboardType: TextInputType.datetime,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onChanged: (value) {
              setState(() {
                _btnActiveSTDN = value.length >= 10 ? true : false;
              });
            },
          ),
          RaisedButton(
            color: colour_button,
            onPressed: _btnActiveSTDN && access_storage ? saveOnFile : null,
            child: const Text(
              'Save!',
            ),
          ),
          Column(
            children: [
              Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: true,
                child: Text(
                  detail_access,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: colour_text,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
              Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: visablewidget,
                child: Text(
                  result,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void saveOnFile() async {
    directory_name = controllerStdNum.text;
    var directory = await Directory(
            'storage/emulated/0/${directory_name}\'s Semnan Recorder/')
        .create(recursive: true);
    final myDir =
        Directory('storage/emulated/0/${directory_name}\'s Semnan Recorder/');
    var isThere = await myDir.exists();
    setState(() {
      if (isThere == true) {
        colour_button = Colors.green;
        visablewidget = true;
      }
    });
    var file = File('storage/emulated/0/info.txt');
    file.writeAsString('${directory_name}');
    file.writeAsString('${directory_name}');
  }
}
