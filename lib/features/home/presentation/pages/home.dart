import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lovepeople_gemini/features/challenge/presentation/pages/challenge_page.dart';
import 'package:lovepeople_gemini/features/home/data/models/challenge.dart';
import 'package:flutter/material.dart';
import 'package:lovepeople_gemini/features/home/data/models/user_info.dart';
import 'package:lovepeople_gemini/features/home/presentation/controller/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userUUID});

  final String userUUID;

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  late HomeController _homeController;

  @override
  void initState() {
    getUserInfo();
    fetchChallenges();
    initController();
    super.initState();
  }

  Future<void> fetchChallenges() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection("challenges").get();
    final challenges = querySnapshot.docs
        .map((doc) => Challenge.fromJson(doc.data()))
        .toList();
    challenges.sort((a, b) => a.level.compareTo(b.level));
    setState(() {
      _homeController.challengeList = challenges;
    });
  }

  Future<void> getUserInfo() async {
    await FirebaseFirestore.instance
        .collection("user-info")
        .doc(widget.userUUID)
        .get()
        .then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _homeController.userInfo = UserInfo.fromJson(data);
        });
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Challenges"),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: ListView.builder(
                  itemCount: _homeController.challengeList?.length ?? 0,
                  itemBuilder: (context, index) {
                    return _buildLevel(
                        context, _homeController.challengeList?[index]);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevel(BuildContext context, Challenge? challenge) {
    Color color =
        _defineColor(challenge?.level, _homeController.userInfo?.level);
    return GestureDetector(
      onTap: () => _checkLevelAvailability(
          challenge, _homeController.userInfo?.level ?? 0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          height: 150,
          child: Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _progressBar(context, color),
              _spacing(null),
              _level(context, challenge, color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionCard(
      BuildContext context, String title, String description, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            softWrap: true,
          ),
          _spacing(2),
          Text(
            description,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  Widget _progressBar(BuildContext context, Color color) {
    return LayoutBuilder(builder: (context, constraints) {
      final boxHeight = constraints.constrainHeight();
      return Flex(
        direction: Axis.vertical,
        children: [
          Stack(alignment: Alignment.center, children: [
            Icon(
              Icons.circle,
              color: color.withOpacity(0.1),
              size: 30,
            ),
            Icon(Icons.circle, color: color.withOpacity(0.4), size: 15)
          ]),
          _separator(context, color, boxHeight)
        ],
      );
    });
  }

  Widget _level(BuildContext context, Challenge? challenge, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          challenge?.levelTitle ?? "",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        _spacing(null),
        _buildMissionCard(
          context,
          challenge?.title ?? "",
          challenge?.description ?? "",
          color,
        ),
      ],
    );
  }

  Widget _separator(BuildContext context, Color color, double boxHeight) {
    const dashWidth = 1.0;
    const dashHeight = 1.0;
    final dashCount = (boxHeight / 2).floor() - 15;
    return Flex(
        direction: Axis.vertical,
        children: List.generate(dashCount, (_) {
          return Column(
            children: [
              SizedBox(
                width: dashWidth,
                height: dashWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color.withOpacity(0.1)),
                ),
              ),
              SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color.withOpacity(0.3)),
                ),
              ),
            ],
          );
        }));
  }

  Widget _spacing(double? size) {
    return SizedBox(
      width: size ?? 12,
      height: size ?? 12,
    );
  }

  Color _defineColor(int? levelTapped, int? currentUserLevel) {
    if (levelTapped != null && currentUserLevel != null) {
      if (levelTapped < currentUserLevel) {
        return Colors.blue;
      } else if (levelTapped == currentUserLevel) {
        return Colors.green;
      } else if (levelTapped > currentUserLevel) {
        return Colors.grey;
      }
    }
    return Colors.grey;
  }

  _checkLevelAvailability(Challenge? challenge, int currentUserLevel) {
    if (challenge?.level != null) {
      if (challenge!.level <= currentUserLevel) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChallengePage(
                      challenge: challenge,
                    )));
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(challenge.levelTitle,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              content: const Text(
                "You are not able to do this challenge yet",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.normal),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  void initController() {
    _homeController = HomeController();
    _homeController.challengeList = List.empty();
    _homeController.userInfo = UserInfo();
  }
}
