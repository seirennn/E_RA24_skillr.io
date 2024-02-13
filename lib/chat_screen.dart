import 'dart:math';
import 'question_data.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:markdown_widget/config/all.dart';
import 'dart:convert';
import 'package:markdown_widget/widget/markdown.dart';

class ChatScreen extends StatefulWidget {
  final String career;
  final QuestionData ans;

  const ChatScreen({super.key, required this.career, required this.ans});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  var _awaitingResponse = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final List<MessageBubble> _chatHistory = [];
  List<String> loadingPhrases = [
    'Loading...',
    'Working on it...',
    'Just a moment please.',
    'Hold on for a while...',
    'We\'ll get that for you',
    'Just in a moment...'
  ];

  @override
  void initState() {
    super.initState();
    initMessage();
  }

  void initMessage() async {
    setState(() => _awaitingResponse = true);
    String response = await fetchResultFromBard(
        'Why was I recommended the career [${widget.career}]');
    setState(() {
      _addMessage(response, false);
      _awaitingResponse = false;
    });
  }

  void _addMessage(String response, bool isUserMessage) {
    _chatHistory.add(MessageBubble(content: response, isUserMessage: isUserMessage));
    final chatHistoryJson = _chatHistory.map((bubble) {
      return {"content": bubble.content, "isUserMessage": bubble.isUserMessage};
    }).toList();
    debugPrint('Chat history: $chatHistoryJson');
    try {
      _listKey.currentState!.insertItem(_chatHistory.length - 1);
    } catch (e) {
      debugPrint(e.toString());
    }
    // Scroll to the bottom of the list
    // Schedule the scroll after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onSubmitted(String message) async {
    _messageController.clear();
    setState(() {
      _addMessage(message, true);
      _awaitingResponse = true;
    });
    final result = await fetchResultFromBard(message);
    setState(() {
      _addMessage(result, false);
      _awaitingResponse = false;
    });
  }

  Future<String> fetchResultFromGPT(String career) async {
    OpenAI.apiKey = await rootBundle.loadString('assets/openai.key');
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    final prompt =
        "Hello! I'm interested in learning more about $career. Can you tell me more about the career and provide some suggestions on what I should learn first?";

    final completion = await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo',
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)
          ],
        ),
      ],
      maxTokens: 150,
      temperature: 0.7,
    );

    if (completion.choices.isNotEmpty) {
      return completion.choices.first.message.content!.first.text.toString();
    } else {
      throw Exception('Failed to load result');
    }
  }

  Future<String> fetchResultFromBard(String message) async {
    final apiKey = await rootBundle.loadString('assets/gemini.key');
    final endpoint =
        "https://generativelanguage.googleapis.com/v1beta2/models/chat-bison-001:generateMessage?key=$apiKey";

    final chatHistory = _chatHistory.map((bubble) {
      return {"content": bubble.content};
    }).toList();
    if (chatHistory.isEmpty) chatHistory.add({"content": message});

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "prompt": {
          "context": '''
            You are Teyah, a very funny and friendly, discerning career recommendation bot who helps students pick the best career for them and answer in markdown.
            You are trained to reject to answer questions that are too offtopic and reply in under 40-70 words unless more are needed.
            You are chatting with a student who is interested in the career ["${widget.career}"] and so will speak only regarding it.
            but you crack a joke at times and have a good sense of humour.
            The student asks you to tell them more about the career and provide some suggestions on what they should learn first.
            You respond to them with the most helpful information you can think of as well as base your answers on their previous
            questions and the answers they have provided in the following survey json:\n${widget.ans.toJson()}''',
          "examples": [
            {
              "input": {"content": "Who are you."},
              "output": {
                "content":
                    "I'm Teyah, a helpful career recommending bot. I've been trained to help you with career guidance."
              }
            },
            {
              "input": {
                "content": "Let's talk about something other than the career."
              },
              "output": {
                "content":
                    "I apollogise if I am not making this conversation fun enough, but I cant talk about anything unrelated to the career. So, to make things interesting, how about we play a small game to help u get a better idea of your career?."
              }
            },
            {
              "input": {"content": "What is the career about?"},
              "output": {
                "content":
                    "That's a very good question!! The career is about ${widget.career}. It is a very interesting career that will help you learn a lot of things."
              }
            }
          ],
          "messages": chatHistory,
        },
        "candidate_count": 1,
        "top_p": 0.8,
        "temperature": 0.7,
      }),
    );
    debugPrint("$chatHistory");
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      debugPrint('Response: $json');
      if (json['filters'] != null) {
        return "Oops! Looks like your response was too offtopic, so it was filtered due to reason [${json['filters'][0]['reason']}].\nLet's try again, shall we?";
      } else {
        return json['candidates'][0]['content'];
      }
    } else {
      // throw Exception('Failed to load result: ${response.body}');
      return 'Status [${response.statusCode}]\nFailed to load result: ${response.body}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final clrSchm = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Talk to Teyah"),
        backgroundColor: clrSchm.primaryContainer.withOpacity(0.2),
        actions: [],
      ),
      body: _chatHistory.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: min(720, screenSize.width * 0.95),
                  child: AnimatedList(
                    key: _listKey,
                    controller: _scrollController,
                    initialItemCount: _chatHistory.length,
                    itemBuilder: (context, index, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: _chatHistory[index],
                      );
                    },
                  ),
                ),
              ),
            )
          : Column(
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
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  },
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: clrSchm.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: clrSchm.secondary, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: !_awaitingResponse
                  ? RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (RawKeyEvent event) {
                        if (event is RawKeyDownEvent) {
                          if (event.logicalKey == LogicalKeyboardKey.enter) {
                            if (event.isShiftPressed) {
                              _messageController.text =
                                  '${_messageController.text}\n';
                              _messageController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: _messageController.text.length));
                            } else {
                              _onSubmitted(_messageController.text);
                            }
                          }
                        }
                      },
                      child: TextField(
                        minLines: 1,
                        maxLines: 5,
                        controller: _messageController,
                        onSubmitted: _onSubmitted,
                        decoration: InputDecoration(
                          hintText: 'What would you like to know...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          prefixIcon: Icon(Icons.question_answer,
                              color: clrSchm.primary),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: 24,
                            width: 24,
                            child: SpinKitPouringHourGlassRefined(
                                color: clrSchm.primary)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: StreamBuilder<String>(
                            stream: Stream.periodic(
                                const Duration(seconds: 3),
                                (i) => loadingPhrases[
                                    Random().nextInt(loadingPhrases.length)]),
                            builder: (context, snapshot) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                        scale: animation,
                                        alignment: Alignment.centerLeft,
                                        child: child),
                                  );
                                },
                                child: Text(
                                  snapshot.data ??
                                      loadingPhrases[Random()
                                          .nextInt(loadingPhrases.length)],
                                  key: ValueKey<String>(snapshot.data ??
                                      loadingPhrases[Random()
                                          .nextInt(loadingPhrases.length)]),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
            ),
            IconButton(
              onPressed: !_awaitingResponse
                  ? () => _onSubmitted(_messageController.text.trim())
                  : null,
              icon: Icon(Icons.send, color: clrSchm.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isUserMessage;

  const MessageBubble({
    required this.content,
    required this.isUserMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUserMessage
            ? themeData.colorScheme.secondary.withOpacity(0.4)
            : themeData.colorScheme.primary.withOpacity(0.4),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isUserMessage ? 'You' : 'Teyah',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            MarkdownWidget(
                data: content,
                shrinkWrap: true,
                config: MarkdownConfig.darkConfig),
          ],
        ),
      ),
    );
  }
}
