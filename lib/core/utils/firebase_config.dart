import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:lovepeople_gemini/core/utils/firebase_options.dart';

abstract class FirebaseConfig {
  static late FirebaseFirestore db;

  static void initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static firestoreDatabase() {
    db = FirebaseFirestore.instance;
  }

  static Future<String> initAIAndFixChallenge(String userAnswer) async {
    final model =
        FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');

    final prompt = [
      Content.text(
          "Please, tell me yes or no, if this could would work in dart: $userAnswer")
    ];
    final response = await model.generateContent(prompt);
    return response.text ?? "Sorry, we couldn't analyze it";
  }
}
