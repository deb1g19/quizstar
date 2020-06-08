import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: QuizPage(),
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Icon> scoreKeeper = [];
  HtmlUnescape unescape = HtmlUnescape();
  Future<Quiz> futureQuiz;
  int currentQuestion = 0;
  bool isTrue = false;
  Color diffColor;
  int score = 0;

  Future<Quiz> fetchQuiz() async {
    var url = 'https://opentdb.com/api.php?amount=10&type=boolean';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return Quiz.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load quiz data");
    }
  }

  @override
  void initState() {
    super.initState();
    futureQuiz = fetchQuiz();
  }

  void restartQuiz() {
    scoreKeeper.clear();
    futureQuiz = fetchQuiz();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EndScreen(score: score)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
            height: 100,
            child: Center(
                child: Text(
              "${currentQuestion + 1}/10",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w200),
            ))),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: FutureBuilder<Quiz>(
                future: futureQuiz,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    isTrue = snapshot.data.questions
                        .toList()[currentQuestion]
                        .isTrue;
                    var difficulty = snapshot.data.questions
                        .toList()[currentQuestion]
                        .difficulty;
                    if (difficulty == "easy") {
                      diffColor = Colors.green;
                    } else if (difficulty == "medium") {
                      diffColor = Colors.orange;
                    } else {
                      diffColor = Colors.red;
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            unescape.convert(snapshot.data.questions
                                .toList()[currentQuestion]
                                .category),
                            style: TextStyle(fontSize: 15, color: Colors.white),
                            textAlign: TextAlign.center),
                        Container(width: 100, child: Divider(color: Colors.white)),
                        Text(
                          unescape.convert(snapshot.data.questions
                              .toList()[currentQuestion]
                              .question),
                          style: TextStyle(fontSize: 25, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          padding: EdgeInsets.all(3),
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: diffColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: Text(
                            snapshot.data.questions
                                .toList()[currentQuestion]
                                .difficulty,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    print("There's an error");
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: FlatButton(
            onPressed: () {
              setState(() {
                setState(() {
                  if (isTrue) {
                    print("Correct!");
                    scoreKeeper.add(Tick());
                    score += 1;
                  } else {
                    print("Wrong!");
                    scoreKeeper.add(Cross());
                  }
                  if (currentQuestion < 9) {
                    currentQuestion += 1;
                  } else {
                    restartQuiz();
                  }
                });
              });
            },
            child: Text(
              "true".toUpperCase(),
              style: TextStyle(
                  letterSpacing: 2,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            ),
            color: Colors.green,
            padding: EdgeInsets.all(25),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: FlatButton(
            onPressed: () {
              setState(() {
                if (isTrue) {
                  print("Wrong!");
                  scoreKeeper.add(Cross());
                } else {
                  print("Correct!");
                  scoreKeeper.add(Tick());
                  score += 1;
                }
                if (currentQuestion < 9) {
                  currentQuestion += 1;
                } else {
                  restartQuiz();
                }
              });
            },
            child: Text(
              "false".toUpperCase(),
              style: TextStyle(
                  letterSpacing: 2,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            ),
            color: Colors.red,
            padding: EdgeInsets.all(25),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(15),
          child: Container(
              height: 30,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: scoreKeeper)),
        )
      ],
    );
  }
}

class EndScreen extends StatelessWidget {
  final int score;
  EndScreen({Key key, @required this.score}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "You scored $score/10.",
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Center(
            child: FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
              child: Container(
                  margin: EdgeInsets.all(25),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.grey),
                  child: Text("Play again?")),
            ),
          ),
        ],
      ),
    );
  }
}

class Tick extends Icon {
  Tick() : super(Icons.check, color: Colors.green);
}

class Cross extends Icon {
  Cross() : super(Icons.clear, color: Colors.red);
}

class Quiz {
  var questions = <Question>[];

  Quiz({this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var questionsFromJson =
        (json['results'] as List).map((i) => Question.fromJson(i)).toList();
    return Quiz(
      questions: questionsFromJson,
    );
  }
}

class Question {
  final String category;
  final String difficulty;
  final String question;
  final bool isTrue;

  Question({this.category, this.difficulty, this.question, this.isTrue});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
        category: json['category'],
        difficulty: json['difficulty'],
        question: json['question'],
        isTrue: (json['correct_answer'] == "True"));
  }
}
