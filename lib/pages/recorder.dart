/*
 * Copyright 2018, 2019, 2020, 2021 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0),
 * as published by the Mozilla organization.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:project/data.dart';

/*
 * This is an example showing how to record to a Dart Stream.
 * It writes all the recorded data from a Stream to a File, which is completely stupid:
 * if an App wants to record something to a File, it must not use Streams.
 *
 * The real interest of recording to a Stream is for example to feed a
 * Speech-to-Text engine, or for processing the Live data in Dart in real time.
 *
 */

///
typedef _Fn = void Function();

/* This does not work. on Android we must have the Manifest.permission.CAPTURE_AUDIO_OUTPUT permission.
 * But this permission is _is reserved for use by system components and is not available to third-party applications._
 * Pleaser look to [this](https://developer.android.com/reference/android/media/MediaRecorder.AudioSource#VOICE_UPLINK)
 *
 * I think that the problem is because it is illegal to record a communication in many countries.
 * Probably this stands also on iOS.
 * Actually I am unable to record DOWNLINK on my Xiaomi Chinese phone.
 *
 */
//const theSource = AudioSource.voiceUpLink;
//const theSource = AudioSource.voiceDownlink;

const theSource = AudioSource.microphone;

/// Example app.
class SimpleRecorder extends StatefulWidget {
  const SimpleRecorder({Key? key}) : super(key: key);
  @override
  _SimpleRecorderState createState() => _SimpleRecorderState();
}

class _SimpleRecorderState extends State<SimpleRecorder> {
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mRecorderIsInited = false;
  String complete_path = '';
  String _directoryPath =
      'storage/emulated/0/${directory_name}\'s Semnan Recorder/';
  bool fTime = false;
  bool invis = false;
  late List _folders;
  String text = '';
  Color colour_text = Colors.white;

  @override
  void initState() {
    check_access();
    getDataLastFile();
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  void check_access() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      invis = false;
      text =
          'دسترسی میکروفون داده نشده است\nلطفا از تنظیمات دسترسی فایل را بررسی کنید ';
      colour_text = Colors.red;
      throw RecordingPermissionException('Microphone permission not granted');
    }
    text =
        'لطفا در انتها تلفظ اعداد (وُ) بگید\nمثال بیستو، سیو ،...، صدو، دویصدو و ...';
    colour_text = Colors.lightGreenAccent;
  }

  Future<void> openTheRecorder() async {
    await _mRecorder!.openRecorder();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }

  void getDataLastFile() async {
    String pdfDirectory = _directoryPath;
    print(pdfDirectory);
    final myDir = Directory(pdfDirectory);
    var _exi = await File('storage/emulated/0/info.txt').exists();
    if (_exi) {
      try {
        _folders = myDir.listSync(recursive: true, followLinks: false);
        invis = true;
      } catch (e) {
        print(e);
      }
    } else {
      invis = false;
      return;
    }

    List temp = [];
    String t1 = '';

    for (var i in _folders) {
      t1 = (i.toString().split('/').last);
      temp.add(t1.replaceAll('\'', ''));
    }
    List list_exist_file = temp;
    list_exist_file = list_exist_file.reversed.toList();
    if (list_exist_file.isNotEmpty) {
      if (list_exist_file[0].split('_').length > 1) {
        data_number = list_exist_file[0].split('_')[0];
        for (int j = 0; j < knumber.length; j++) {
          if (data_number == knumber[j]) {
            counter_number = j;
            break;
          }
        }
        data_count = list_exist_file[0].split('_')[1].split('.')[0];
        for (int j = 0; j < kcount.length; j++) {
          if (data_count == kcount[j]) {
            counter_count = j;
          }
        }
        _mRecorderIsInited = false;
      } else {
        data_number = list_exist_file[0].toString();
        for (int j = 0; j < knumber.length; j++) {
          if (data_number == knumber[j]) {
            counter_number = j;
          }
        }
        data_count = '1';
        counter_count = 0;
      }
    }
  }

  List<DropdownMenuItem<String>> androidDropDown(List<String> list) {
    List<DropdownMenuItem<String>> dropDownItems = [];

    for (String num in list) {
      var newItem = DropdownMenuItem(
        child: Text(
          num,
          style: TextStyle(fontSize: 20.0),
        ),
        value: num,
      );
      dropDownItems.add(newItem);
    }
    return dropDownItems;
  }

// ----------------------  Here is the code for recording and playback -------
  void record() {
    setState(() {
      create_Directory(data_number);
      complete_path = _directoryPath +
          '${data_number}/' +
          '${data_number}_${data_count}.wav';
      _mRecorder!
          .startRecorder(
        toFile: complete_path,
        codec: Codec.pcm16WAV,
        audioSource: theSource,
      )
          .then((value) {
        setState(() {});
      });
    });
  }

  void stopRecorder() async {
    setState(() {
      counter_count++;
      if (counter_count <= 19) data_count = kcount[counter_count];
      print(counter_count);
      if (counter_count == 20) {
        counter_count = 0;
        data_count = kcount[0];
        if (counter_number <= knumber.length) {
          counter_number++;
          data_number = knumber[counter_number];
          if (data_number != null) create_Directory(data_number);
        } else {
          print("------------------------------");
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('ذخیره 900 با تکرار 20'),
              content: const Text('دیتاست شما 900 را با تکرار 20 ذخیره کرد'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'End'),
                  child: const Text('فهمیدم'),
                ),
              ],
            ),
          );
        }
      }
    });
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        //var url = value;
        if (value != null) {}
      });
    });
  }

// ----------------------------- UI --------------------------------------------
  void create_Directory(String dir_name) async {
    var directory = await Directory(
            'storage/emulated/0/${directory_name}\'s Semnan Recorder/${dir_name}')
        .create(recursive: true);
    final myDir = Directory(
        'storage/emulated/0/${directory_name}\'s Semnan Recorder/${dir_name}');
    var isThere = await myDir.exists();
  }

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited) {
      return null;
    }
    setState(() {});
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'عدد :',
                style: TextStyle(fontSize: 20.0),
              ),
              const SizedBox(
                width: 50.0,
              ),
              DropdownButton(
                  iconEnabledColor: Colors.teal,
                  alignment: Alignment.center,
                  dropdownColor: Colors.teal,
                  value: data_number,
                  items: androidDropDown(knumber),
                  onChanged: (value) {
                    setState(() {
                      data_number = value.toString();
                      for (int j = 0; j < knumber.length; j++) {
                        if (data_number == knumber[j]) {
                          counter_number = j;
                          // print(counter_number);
                        }
                      }
                    });
                  }),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'بار :',
                style: TextStyle(fontSize: 20.0),
              ),
              const SizedBox(
                width: 50.0,
              ),
              DropdownButton(
                iconEnabledColor: Colors.teal,
                alignment: Alignment.center,
                dropdownColor: Colors.teal,
                value: data_count,
                items: androidDropDown(kcount),
                onChanged: (value) {
                  setState(
                    () {
                      data_count = value.toString();
                      for (int i = 0; i < kcount.length; i++) {
                        if (data_count == kcount[i]) {
                          counter_count = i;
                          print(counter_count);
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Visibility(
            visible: invis,
            child: Container(
              margin: const EdgeInsets.all(3),
              height: 150,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black87,
                border: Border.all(
                  color: Colors.teal,
                  width: 3,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(50),
                      ),
                      onPressed: getRecorderFn(),
                      //color: Colors.white,
                      //disabledColor: Colors.grey,
                      child: Text(_mRecorder!.isRecording ? 'Stop' : 'Record'),
                    ),
                  ),
                  SizedBox(
                    height: 35.0,
                  ),
                  Text(_mRecorder!.isRecording
                      ? 'Recording in progress'
                      : 'Recorder is stopped'),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Text(
                text,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: colour_text),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
