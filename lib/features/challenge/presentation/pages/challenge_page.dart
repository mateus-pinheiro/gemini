import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:lovepeople_gemini/core/enum/enum.dart';
import 'package:lovepeople_gemini/core/ui/feedback_page.dart';
import 'package:lovepeople_gemini/features/home/data/models/challenge.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key, required this.challenge});
  final Challenge challenge;

  @override
  State<StatefulWidget> createState() => ChallengePageState();
}

class ChallengePageState extends State<ChallengePage> {
  final String promptTrainingAsTeacher =
      "You are a teacher specializing in Dart and Flutter for a diverse EdTech platform. You only discuss topics related to Flutter, Dart, and programming. You will grade a student's exercise and determine if the student has passed or not. The student will only pass if the code works exactly as specified in the question. When the student has not passed, always provide a suggestion on how they could improve, without giving away the answer. Always finish your response with the following pattern: 'Result: pass' or 'Result: not pass'. Suggestion:";
  String userResponse = "";
  String promptQuestion = "";

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.challenge.title),
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    onChanged: (value) => userResponse = value,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Write your code here:',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => initAIAndFixChallenge(context),
                child: const Text("Send it"))),
      ),
    );
  }

  void initAIAndFixChallenge(BuildContext context) async {
    final model =
        FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');

    final prompt = [
      Content.text(
          "$promptTrainingAsTeacher, question: ${widget.challenge.description}, student answer: $userResponse"),
    ];
    try {
      final response = await model.generateContent(prompt);

      String resultPattern = r'Result:\s*(.*?)(\s*Suggestion:|$)';
      String suggestionPattern = r'Suggestion:\s*(.*)';

      RegExp resultRegExp = RegExp(resultPattern, dotAll: true);
      RegExp suggestionRegExp = RegExp(suggestionPattern, dotAll: true);

      String result =
          resultRegExp.firstMatch(response.text!)?.group(1)?.trim() ??
              "Sorry, we couldn't analyze it";
      String suggestion =
          suggestionRegExp.firstMatch(response.text!)?.group(1)?.trim() ??
              "Sorry, we couldn't analyze it";

      checkChallengeResult(context, result, suggestion);
    } catch (e) {
      print(e);
    }
  }
}

void checkChallengeResult(
    BuildContext context, String result, String? suggestion) {
  if (result == "not pass.") {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FeedbackPage(
                status: FeedbackPageStatus.failed, result, suggestion)));
  } else {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const FeedbackPage(
                status: FeedbackPageStatus.success, null, null)));
  }
}
