import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';


class CategoryList extends StatelessWidget {
  final List<String> categories = [
    'Énigmes astronomiques',
    'Calculs d\'échelle',
    'Astronomie populaire',
    'Jeux de mots',
    'Astrologie vs Astronomie',
    'Dates astronomiques',
    'Astronome et astronaute célèbre',
    'Reconnaissance d\'image astronomique',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizz'),
      ),
      body: ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            navigateToCategoryPage(context, categories[index]);
          },
          child: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              categories[index],
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
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
        title: Text(widget.category),
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
      floatingActionButton: ElevatedButton(
        onPressed: isSubmitButtonEnabled ? viewScore : null,
        child: Text('Submit'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

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
                height: 150,
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

class ResultsPage extends StatelessWidget {
  final List<Question> questions;

  ResultsPage({required this.questions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
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

class ScoreScreen extends StatelessWidget {
  final List<Question> questions;

  ScoreScreen({required this.questions});

  @override
  Widget build(BuildContext context) {
    int correctAnswers = 0;
    for (var question in questions) {
      if (question.selectedOption == question.answer) {
        correctAnswers++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Score'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '$correctAnswers / ${questions.length}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsPage(questions: questions),
                  ),
                );
              },
              child: Text('View Answers'),
            ),
          ],
        ),
      ),
    );
  }
}
