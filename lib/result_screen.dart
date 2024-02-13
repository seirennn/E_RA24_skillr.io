
import 'dart:convert';
import 'dart:math';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'question_data.dart';
import 'chat_screen.dart';

class ResultScreen extends StatefulWidget {
  final QuestionData answers;

  const ResultScreen({super.key, required this.answers});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late Future<ResultData> futureResult;
  late String systemString, userString;
  List<String> loadingPhrases = [
    'Loading...',
    'Working on it...',
    'Just a moment, please.',
    'Hold on for a while...',
    'We\'ll get that for you',
    'Just in a moment...'
  ];

  @override
  void initState() {
    super.initState();

    systemString = """
      You serve as a highly considerate course advisor catering to grade 10-12 students and also different users with diverse level of experiences,
      You analyze data presented in json format and exclusively respond in json format you are also funny and amusing at times and jokes sometimes.
      Presenting 5 courses aligned with the input json, accompanied by vibrant and concise justifications in 5-10 words each.
      Following each rationale, outline 3-5 essential skills (expressed briefly) crucial for success in each recommended course.
      The output should be in this exact same format:
      {\"course1name\": [\"reasoning1\", \"Skills Required: skill1, skill2, skill3\"], \"course2name\": [\"reasoning2\", \"Skills Required: skill1, skill2, skill3, skill4, skill5\"],....}
      Here's an example output format for u to use to base ur reply on-
      {\"Flutter Programmer\": [\"I bet there\'s no better place to improve your programming skills!!\", \"Dart programming, State Management, Testing, Problem-solving\"], \"Design Architect\": [\"Let your imagination flow into the world around you!!\", \"Skills Required: Attention to detail, Leadership, Creativity, Organizational skills\"],....}
    """;
    userString = """
      HERE IS THE USER'S ANSWERS:
      ${widget.answers.toJson()}
    """;

    // futureResult = fetchResultFromGPT();
    futureResult = fetchResultFromBard();
  }

  Future<ResultData> fetchResultFromGPT() async {
    OpenAI.apiKey = await rootBundle.loadString('assets/openai.key');
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(systemString)
      ],
    );
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.user,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(userString)
      ],
    );

    final completion = await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo',
      messages: [systemMessage, userMessage],
      maxTokens: 500,
      temperature: 0.2,
    );

    if (completion.choices.isNotEmpty) {
      debugPrint(
          'Result: ${completion.choices.first.message.content!.first.text}');
      return ResultData.fromJson(
          completion.choices.first.message.content!.first.text.toString());
    } else {
      throw Exception('Failed to load result');
    }
  }

  Future<ResultData> fetchResultFromBard() async {
    final apiKey = await rootBundle.loadString('assets/gemini.key');
    final endpoint =
        "https://generativelanguage.googleapis.com/v1beta3/models/text-bison-001:generateText?key=$apiKey"; //reference: https://ai.google.dev/api/python/google/generativeai/GenerativeModel
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': {
          'text': '$systemString\n\n$userString',
        },
      }),
    );

    if (response.statusCode == 200) {
      String result = jsonDecode(response.body)['candidates'][0]['output'];
      debugPrint('Result: $result');
      return ResultData.fromJson(result);
    } else {
      throw Exception('Failed to load result: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final clrSchm = Theme.of(context).colorScheme; // color scheme

    return Scaffold(
      appBar: AppBar(
        title: const Text('Best options'),
      ),
      body: Center(
        child: FutureBuilder<ResultData>(
          future: futureResult,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  [
                    SpinKitPouringHourGlassRefined(
                        color: clrSchm.primary, size: 120),
                    SpinKitDancingSquare(color: clrSchm.primary, size: 120),
                    SpinKitSpinningLines(color: clrSchm.primary, size: 120),
                    SpinKitPulsingGrid(color: clrSchm.primary, size: 120)
                  ][Random().nextInt(4)],
                  const SizedBox(height: 10),
                  StreamBuilder<String>(
                    stream: Stream.periodic(
                        const Duration(seconds: 3),
                        (i) => loadingPhrases[
                            Random().nextInt(loadingPhrases.length)]),
                    builder: (context, snapshot) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.horizontal,
                                axisAlignment: -1,
                                child: child),
                          );
                        },
                        child: Text(
                          snapshot.data ??
                              loadingPhrases[
                                  Random().nextInt(loadingPhrases.length)],
                          key: ValueKey<String>(snapshot.data ??
                              loadingPhrases[
                                  Random().nextInt(loadingPhrases.length)]),
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    },
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data?.result.length,
                itemBuilder: (context, index) {
                  final entry = snapshot.data?.result.entries.elementAt(index);
                  return FutureBuilder(
                    future: Future.delayed(Duration(milliseconds: 200 * index)),
                    builder: (context, AsyncSnapshot<void> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(); // Empty container
                      } else {
                        return SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(1, 0), end: Offset.zero)
                              .animate(
                            CurvedAnimation(
                              parent: AnimationController(
                                  duration: const Duration(milliseconds: 300),
                                  vsync: this)
                                ..forward(),
                              curve: Curves.easeInOutSine,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            career: entry!.key,
                                            ans: widget.answers)));
                              },
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient:const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 55, 71, 120),
                                        Color.fromARGB(255, 55, 71, 120),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 12),
                                    title: Text(entry!.key,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(entry.value[0],
                                            style: TextStyle(fontSize: 16)),
                                        Padding(
                                            padding: EdgeInsets.only(top: 8)),
                                        Divider(
                                            color: clrSchm.primaryContainer,
                                            thickness: 2.5),
                                        Wrap(
                                          spacing: 4,
                                          runSpacing: 2,
                                          children: [
                                            Chip(
                                                label: Text('Skills Required:',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                                backgroundColor:
                                                    clrSchm.inversePrimary),
                                            for (var skill
                                                in entry.value[1].split(','))
                                              Chip(
                                                label: Text(skill.trim(),
                                                    style: TextStyle(
                                                        fontSize: 10)),
                                                backgroundColor: 
                                                    clrSchm.primaryContainer,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class ResultData {
  final Map<String, List<String>> result;

  ResultData({required this.result});

  factory ResultData.fromJson(String jsonString) {
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    Map<String, List<String>> resultMap = {};

    debugPrint('JsonMap: $jsonMap');

    jsonMap.forEach((key, value) {
      var splitValues = value.toString().split(',');
      var firstPart = splitValues[0].replaceAll('[', '');
      var secondPart =
          splitValues.sublist(1).join(',').trim().replaceAll(']', '');
      resultMap[key] = [firstPart, secondPart];
    });

    debugPrint('ResultMap: $resultMap');

    return ResultData(result: resultMap);
  }
}