// ignore_for_file: prefer_const_constructors, prefer_final_fields, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rive/rive.dart';
import 'dart:ui';
import 'underconstruction.dart';
import 'result_screen.dart';
import 'question_data.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter/cupertino.dart';


class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _index = 0, _step = 1;
  late int _totSteps = 10;
  late QuestionData qns, ans;

  Future<QuestionData> loadJsonData(String path) async {
    String jsonString = await rootBundle.loadString(path);
    Map<String, dynamic> jsonData = jsonDecode(jsonString);
    return QuestionData.fromJson(jsonData);
  }

  void gotoStep(int i) {
    i = i <= 0 ? 1 : i;
    i = i > _totSteps ? _totSteps : i;
    setState(() {
      _step = i;
      _index = i - 1;
      ans.titles[_index] = qns.titles[_index];
      ans.options[_index].map((e) => null);
    });
  }

  @override
  void initState() {
    super.initState();
    loadJsonData('assets/data/questions.json').then((data) {
      setState(() {
        qns = data;
        _totSteps = qns.titles.length;
        ans = QuestionData(
          titles: List.from(qns.titles),
          options: qns.options.map((o) => o.map((e) => '').toList()).toList(),
        );
        ans.options[_index].map((e) => '');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final clrschm = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        constraints: BoxConstraints.expand(), // Added constraints
        child: Stack(
          children: [
            Positioned(
              width: screenSize.width * 1.7,
              left: 100,
              bottom: 100,
              child: Image.asset(
                "assets/Backgrounds/Spline.png",
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: const SizedBox(),
              ),
            ),
            const RiveAnimation.asset(
              "assets/RiveAssets/shapes.riv",
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: const SizedBox(),
              ),
            ),
            Scaffold(
              appBar: AppBar(
                title: Text('SKLR'),
                titleTextStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
                centerTitle: true,
                backgroundColor: Color.fromARGB(255, 18, 19, 24),
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UnderConstructionPage(),
                        ),
                      );
                    },
                  )
                ],
              ),
              body: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    LinearPercentIndicator(
                      lineHeight: 18.0,
                      percent: _step / _totSteps,
                      center: Text(
                        'Step $_step out of $_totSteps',
                        style: TextStyle(fontSize: 12.0, fontFamily: 'Poppins'),
                      ),
                      leading: CupertinoButton(
                          child: Icon(CupertinoIcons.back),
                          onPressed: () => gotoStep(--_step)),
                      trailing: CupertinoButton(
                          child: Icon(CupertinoIcons.forward),
                          onPressed: () => gotoStep(++_step)),
                      barRadius: Radius.circular(50),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3),
                      progressColor: clrschm.primaryContainer,
                      curve: Curves.easeInCirc,
                      animateFromLastPercent: true,
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: min(560, screenSize.width * 0.9),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SizeTransition(
                                            sizeFactor: animation,
                                            axis: Axis.horizontal,
                                            axisAlignment: -1,
                                            child: child),
                                      );
                                    },
                                    child: Text(qns.titles[_index],
                                        style: TextStyle(fontSize: 26),
                                        key: ValueKey(_index)),
                                  ),
                                  Text('Pick what describes you best',
                                      style: TextStyle(
                                          fontSize: 14, fontFamily: 'Inter')),
                                ],
                              )),
                            ],
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 40)),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                          begin: Offset(0.0, -0.5),
                                          end: Offset(0.0, 0.0))
                                      .animate(animation),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            key: ValueKey<int>(_step),
                            child: Container(
                              alignment: Alignment.center,
                              width: min(560, screenSize.width * 0.9),
                              height: kIsWeb
                                  ? screenSize.height * 0.45
                                  : Platform.isAndroid || Platform.isIOS
                                      ? screenSize.height * 0.45
                                      : max(
                                          60,
                                          0.9582 * screenSize.height - 410),
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing:
                                      screenSize.width < 560 ? 8.0 : 26.0,
                                  runSpacing:
                                      screenSize.width < 560 ? 8.0 : 26.0,
                                  children: List<Widget>.generate(
                                    qns.options[_index].length,
                                    (i) {
                                      return Container(
                                        decoration: ans.options[_index][i] == ''
                                            ? null
                                            : BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: clrschm.inverseSurface,
                                                      spreadRadius: 2,
                                                      blurRadius: 2)
                                                ],
                                              ),
                                        child: qns.options[_index][i] != "Other"
                                            ? FilterChip(
                                                label: Text(
                                                    qns.options[_index][i]),
                                                selected: ans.options[_index][i] ==
                                                        ''
                                                    ? false
                                                    : true,
                                                onSelected: (s) => setState(() =>
                                                    ans.options[_index][i] = ans
                                                                .options[_index][i] ==
                                                            ''
                                                        ? qns.options[_index][i]
                                                        : ''))
                                            : InputChip(
                                                label: Text('Other'),
                                                onPressed: () async {
                                                  String? newOption =
                                                      await showDialog<String>(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Add a new option'),
                                                        content: TextFormField(
                                                            autofocus: true,
                                                            onFieldSubmitted:
                                                                (value) =>
                                                                    Navigator.pop(
                                                                        context,
                                                                        value)),
                                                      );
                                                    },
                                                  );
                                                  if (newOption!.isNotEmpty) {
                                                    setState(() {
                                                      qns.options[_index]
                                                          .insert(i, newOption);
                                                      ans.options[_index]
                                                          .insert(i, newOption);
                                                    });
                                                  }
                                                },
                                              ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Container(
                margin: EdgeInsets.symmetric(vertical: 36, horizontal: 96),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (ans.options[_index]
                        .where((o) => o.isNotEmpty)
                        .toList()
                        .isEmpty) return;
                    if (_step == _totSteps) {
                      debugPrint("Answers: ${ans.toJson()}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(answers: ans),
                        ),
                      );
                    }
                    gotoStep(++_step);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: Size(double.infinity, 51),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w400,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
