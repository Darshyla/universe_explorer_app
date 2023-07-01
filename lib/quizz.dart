import 'package:astronomy_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

String category='';

class Question {
  final String question;
  final String? image;
  final List<String> options;
  final int answer;
  int? selectedOption;

  Question({
    required this.question,
    this.image,
    required this.options,
    required this.answer,
    this.selectedOption,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      image: json['image'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }
}

class CategoryList extends StatelessWidget {
  final List<String> categories = [
    'Astronomical Riddles',
    'Scale Calculations',
    'Popular Astronomy',
    'Wordplay',
    'Astrology vs Astronomy',
    'Astronomical Dates',
    'Famous Astronomers and Astronauts',
    'Astronomical Image Recognition',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtenez l'instance du ThemeProvider

    Color iconColor = themeProvider.isDarkMode ? Colors.indigo.shade300 : Colors.indigo;
    return Scaffold(
      appBar: AppbarWidget(icon: Icons.quiz,text: 'Quizz',),
      body: ListView.builder(
        itemCount: categories.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                navigateToCategoryPage(context, categories[index]);
                category = categories[index];
              },
              splashColor: Colors.indigo.shade100,
              highlightColor: Colors.indigo, // Propriété 2: Couleur de l'effet de highlight au toucher
              focusColor: Colors.indigo, // Propriété 3: Couleur de l'effet de focus
              hoverColor: Colors.indigo, // Propriété 4: Couleur de l'effet de hover
              borderRadius: BorderRadius.circular(20), // Propriété 5: Rayon de la bordure
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.black,
                  width: 2.0,
                  style: BorderStyle.solid,
                ),
              ), // Propriété 6: Bordure personnalisée
              enableFeedback: true, // Propriété 7: Activation du feedback tactile
              excludeFromSemantics: false, // Propriété 8: Exclusion des éléments de la sémantique
              canRequestFocus: true, // Propriété 9: Possibilité de demander le focus
              focusNode: FocusNode(), // Propriété 10: Noeud de focus
              autofocus: false, // Propriété 11: Autofocus
              onLongPress: () {}, // Propriété 12: Callback de long appui
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                  color: Colors.indigo.shade100
                ),
                transform: Matrix4.rotationZ(0.1), // Propriété 13: Transformation 3D
                constraints: BoxConstraints(minHeight: 100, maxWidth: 200), // Propriété 14: Contraintes de taille
                alignment: Alignment.center, // Propriété 18: Décoration avant
                height: 150, // Propriété 19: Hauteur fixe
                width: double.infinity, // Propriété 20: Largeur étendue
                transformAlignment: Alignment.bottomCenter, // Propriété 21: Alignement de la transformation 3D
                clipBehavior: Clip.antiAlias, // Propriété 22: Comportement de clipping
                child: Text(
                        categories[index],
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            );
          },
        ),

    );
  }

  void navigateToCategoryPage(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(category: category),
      ),
    );
  }
}

class CategoryPage extends StatefulWidget {
  final String category;

  CategoryPage({required this.category});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Question> questions=[];
  bool isSubmitButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    String jsonData = await rootBundle.loadString('assets/quizz.json');
    List<dynamic> jsonList = json.decode(jsonData)['categories'];

    for (var category in jsonList) {
      if (category['category'] == widget.category) {
        List<dynamic> jsonQuestions = category['questions'];
        List<Question> loadedQuestions = jsonQuestions.map((json) => Question.fromJson(json)).toList();
        setState(() {
          questions = loadedQuestions;
        });
        break;
      }
    }
  }

  bool allQuestionsAnswered() {
    for (var question in questions) {
      if (question.selectedOption == null) {
        return false;
      }
    }
    return true;
  }

  void submitAnswers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(questions: questions),
      ),
    );
  }

  void viewScore() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreScreen(questions: questions),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        widget.category,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.indigo,
    ),
    body: ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return QuestionCard(
          question: questions[index],
          onOptionSelected: (optionIndex) {
            setState(() {
              questions[index].selectedOption = optionIndex;
              isSubmitButtonEnabled = allQuestionsAnswered();
            });
          },
        );
      },
    ),
   bottomNavigationBar: ElevatedButton(
    onPressed: isSubmitButtonEnabled ? viewScore : null,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Text(
        'Submit',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
    ),
  ),

  );
}

}

class QuestionCard extends StatelessWidget {
  final Question question;
  final ValueChanged<int?> onOptionSelected;

  QuestionCard({required this.question, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.question,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (question.image != null) // Display the image if available
              Image.asset(
                question.image!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                return RadioListTile<int?>(
                  title: Text(question.options[index]),
                  value: index,
                  groupValue: question.selectedOption,
                  onChanged: onOptionSelected,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreScreen extends StatelessWidget {
  final List<Question> questions;

  ScoreScreen({required this.questions});

   Future<void> _saveScore(int score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? previousScores = prefs.getStringList(category);
    String scoreEntry = '${DateTime.now().toString()}: $score';

    if (previousScores != null) {
      previousScores.add(scoreEntry);
    } else {
      previousScores = [scoreEntry];
    }
    await prefs.setStringList(category, previousScores);
  }


@override
Widget build(BuildContext context) {
  int correctAnswers = 0;
  for (var question in questions) {
    if (question.selectedOption == question.answer) {
      correctAnswers++;
    }
  }
  _saveScore(correctAnswers);

  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Score',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.indigo,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/quizz/realistic-multicolored-confetti-vector-for-the-festival-confetti-and-tinsel-falling-background-colorful-confetti-isolated-on-transparent-background-carnival-elements-birthday-party-celebration-free-png.webp'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your Final Score is',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Text(
                        '$correctAnswers/10',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsPage(questions: questions),
                  ),
                );
              },
              child: Text(
                'View Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.indigo.shade300),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



}

class ResultsPage extends StatelessWidget {
  final List<Question> questions;

  ResultsPage({required this.questions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results',
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),
        leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final bool isCorrect = question.selectedOption == question.answer;

          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (question.image != null) // Display the image if available
                    Image.asset(question.image!),
                  Text(
                    'Selected Answer: ${question.options[question.selectedOption ?? -1]}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    'Correct Answer: ${question.options[question.answer]}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

