import 'package:flutter/material.dart';
import 'package:lovepeople_gemini/core/enum/enum.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage(
    this.title,
    this.descriptionFailed, {
    super.key,
    required this.status,
  });

  final FeedbackPageStatus status;
  final String? title;
  final String? descriptionFailed;

  @override
  State<StatefulWidget> createState() => FeedbackPageState();
}

class FeedbackPageState extends State<FeedbackPage> {
  @override
  Widget build(BuildContext context) => buildFeedbackByStatus();

  Widget buildFeedbackByStatus() {
    switch (widget.status) {
      case FeedbackPageStatus.success:
        return successPage();
      case FeedbackPageStatus.failed:
        return failedPage();
      default:
        return defaultPage();
    }
  }

  Widget successPage() {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Result"),
        ),
        body: const SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/icons8-success.png'),
                  fit: BoxFit.cover,
                ),
                Text(
                  "You got it",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text("Now you can go to the next level!",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget failedPage() {
    return Material(
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage('assets/images/icons8-error.png'),
                    fit: BoxFit.cover,
                  ),
                  Text(
                    widget.title ?? "",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.descriptionFailed ?? "",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget defaultPage() {
    return const Material(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image(image: ""),
              Text("You got it"),
              Text(""),
            ],
          ),
        ),
      ),
    );
  }
}
